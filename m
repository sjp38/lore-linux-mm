Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id C35C16B006C
	for <linux-mm@kvack.org>; Sat, 18 Oct 2014 16:36:32 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id w10so2663309pde.28
        for <linux-mm@kvack.org>; Sat, 18 Oct 2014 13:36:32 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id kp1si4168197pbd.33.2014.10.18.13.36.31
        for <linux-mm@kvack.org>;
        Sat, 18 Oct 2014 13:36:31 -0700 (PDT)
Date: Sat, 18 Oct 2014 13:41:00 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v11 19/21] dax: Add dax_zero_page_range
Message-ID: <20141018174100.GO11522@wil.cx>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-20-git-send-email-matthew.r.wilcox@intel.com>
 <20141016123824.GQ19075@thinkos.etherlink>
 <20141016220126.GK11522@wil.cx>
 <1868658383.10922.1413560979310.JavaMail.zimbra@efficios.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1868658383.10922.1413560979310.JavaMail.zimbra@efficios.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Fri, Oct 17, 2014 at 03:49:39PM +0000, Mathieu Desnoyers wrote:
> > I kind of wonder if we shouldn't just declare the function.  It's called
> > like this:
> > 
> >         if (IS_DAX(inode))
> >                 return dax_zero_page_range(inode, from, length,
> >                 ext4_get_block);
> >         return __ext4_block_zero_page_range(handle, mapping, from, length);
> > 
> > and if CONFIG_DAX is not set, IS_DAX evaluates to 0 at compile time, so
> > the compiler will optimise out the call to dax_zero_page_range() anyway.
> 
> I strongly prefer to implement "unimplemented stub" as static inlines
> rather than defining to 0, because the compiler can check that the types
> passed to the function are valid, even in the #else configuration which
> uses the stubs.

I think my explanation was unclear.  This is what I meant:

+++ b/include/linux/fs.h
@@ -2473,7 +2473,6 @@ extern loff_t fixed_size_llseek(struct file *file, loff_t 
offset,
 extern int generic_file_open(struct inode * inode, struct file * filp);
 extern int nonseekable_open(struct inode * inode, struct file * filp);
 
-#ifdef CONFIG_FS_DAX
 int dax_clear_blocks(struct inode *, sector_t block, long size);
 int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t)
;
 int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 #define dax_mkwrite(vma, vmf, gb)      dax_fault(vma, vmf, gb)
-#else
-static inline int dax_clear_blocks(struct inode *i, sector_t blk, long sz)
-{
-       return 0;
-}
-
-static inline int dax_truncate_page(struct inode *i, loff_t frm, get_block_t gb)
-{
-       return 0;
-}
-
-static inline int dax_zero_page_range(struct inode *i, loff_t frm,
-                                               unsigned len, get_block_t gb)
-{
-       return 0;
-}
-
-static inline ssize_t dax_do_io(int rw, struct kiocb *iocb,
-               struct inode *inode, struct iov_iter *iter, loff_t pos,
-               get_block_t get_block, dio_iodone_t end_io, int flags)
-{
-       return -ENOTTY;
-}
-#endif
 
 #ifdef CONFIG_BLOCK
 typedef void (dio_submit_t)(int rw, struct bio *bio, struct inode *inode,


So after the preprocessor has run, the compiler will see:

	if (0)
		return dax_zero_page_range(inode, from, length, ext4_get_block);

and it will still do type checking on the call, even though it will eliminate
the call.

I think what you're really complaining about is that the argument to
IS_DAX() is not checked for being an inode.

We could solve that this way:

#ifdef CONFIG_FS_DAX
#define S_DAX		8192
#else
#define S_DAX		0
#endif
...
#define IS_DAX(inode)           ((inode)->i_flags & S_DAX)

After preprocessing, the compiler than sees:

	if (((inode)->i_flags & 0))
		return dax_zero_page_range(inode, from, length, ext4_get_block);

and successfully deduces that the condition evaluates to 0, and still
elide the reference to dax_zero_page_range (checked with 'nm').

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
