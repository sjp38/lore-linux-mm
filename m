Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 35BE66B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 17:04:29 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id 65so11486935pfd.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 14:04:29 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id iu1si11997803pac.43.2016.01.27.14.04.28
        for <linux-mm@kvack.org>;
        Wed, 27 Jan 2016 14:04:28 -0800 (PST)
Date: Wed, 27 Jan 2016 15:04:21 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: mm: WARNING in __delete_from_page_cache
Message-ID: <20160127220421.GA6634@linux.intel.com>
References: <CACT4Y+aBnm8VLe5f=AwO2nUoQZaH-UVqUynGB+naAC-zauOQsQ@mail.gmail.com>
 <20160124230422.GA8439@node.shutemov.name>
 <20160125122206.GA24938@quack.suse.cz>
 <1453779754.32645.3.camel@intel.com>
 <20160126125456.GK2948@linux.intel.com>
 <20160126133636.GE23820@quack.suse.cz>
 <1453827566.32645.5.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1453827566.32645.5.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Cc: "jack@suse.cz" <jack@suse.cz>, "willy@linux.intel.com" <willy@linux.intel.com>, "syzkaller@googlegroups.com" <syzkaller@googlegroups.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kcc@google.com" <kcc@google.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "dvyukov@google.com" <dvyukov@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "gthelen@google.com" <gthelen@google.com>, "kirill@shutemov.name" <kirill@shutemov.name>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "jack@suse.com" <jack@suse.com>, "glider@google.com" <glider@google.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "j-nomura@ce.jp.nec.com" <j-nomura@ce.jp.nec.com>

On Tue, Jan 26, 2016 at 04:59:27PM +0000, Williams, Dan J wrote:
> On Tue, 2016-01-26 at 14:36 +0100, Jan Kara wrote:
> > On Tue 26-01-16 07:54:56, Matthew Wilcox wrote:
> > > On Tue, Jan 26, 2016 at 03:42:34AM +0000, Williams, Dan J wrote:
> > > > @@ -2907,7 +2912,12 @@ extern void replace_mount_options(struct
> > > > super_block *sb, char *options);
> > > >  
> > > >  static inline bool io_is_direct(struct file *filp)
> > > >  {
> > > > -	return (filp->f_flags & O_DIRECT) ||
> > > > IS_DAX(file_inode(filp));
> > > 
> > > I think this should just be a one-liner:
> > > 
> > > -	return (filp->f_flags & O_DIRECT) ||
> > > IS_DAX(file_inode(filp));
> > > +	return (filp->f_flags & O_DIRECT) || IS_DAX(filp-
> > > >f_mapping->host);
> > > 
> > > This does the right thing for block device inodes and filesystem
> > > inodes.
> > > (see the opening stanzas of __dax_fault for an example).
> > 
> > Ah, right. This looks indeed better.
> > 
> 
> 
> Oh, yeah, looks good.
> 
> 8<---- (git am --scissors)
> Subject: fs, block: force direct-I/O for dax-enabled block devices
> 
> From: Dan Williams <dan.j.williams@intel.com>
> 
> Similar to the file I/O path, re-direct all I/O to the DAX path for I/O
> to a block-device special file.  Both regular files and device special
> files can use the common filp->f_mapping->host lookup to determing is
> DAX is enabled.
> 
> Otherwise, we confuse the DAX code that does not expect to find live
> data in the page cache:
> 
>     ------------[ cut here ]------------
>     WARNING: CPU: 0 PID: 7676 at mm/filemap.c:217
>     __delete_from_page_cache+0x9f6/0xb60()
>     Modules linked in:
>     CPU: 0 PID: 7676 Comm: a.out Not tainted 4.4.0+ #276
>     Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>      00000000ffffffff ffff88006d3f7738 ffffffff82999e2d 0000000000000000
>      ffff8800620a0000 ffffffff86473d20 ffff88006d3f7778 ffffffff81352089
>      ffffffff81658d36 ffffffff86473d20 00000000000000d9 ffffea0000009d60
>     Call Trace:
>      [<     inline     >] __dump_stack lib/dump_stack.c:15
>      [<ffffffff82999e2d>] dump_stack+0x6f/0xa2 lib/dump_stack.c:50
>      [<ffffffff81352089>] warn_slowpath_common+0xd9/0x140 kernel/panic.c:482
>      [<ffffffff813522b9>] warn_slowpath_null+0x29/0x30 kernel/panic.c:515
>      [<ffffffff81658d36>] __delete_from_page_cache+0x9f6/0xb60 mm/filemap.c:217
>      [<ffffffff81658fb2>] delete_from_page_cache+0x112/0x200 mm/filemap.c:244
>      [<ffffffff818af369>] __dax_fault+0x859/0x1800 fs/dax.c:487
>      [<ffffffff8186f4f6>] blkdev_dax_fault+0x26/0x30 fs/block_dev.c:1730
>      [<     inline     >] wp_pfn_shared mm/memory.c:2208
>      [<ffffffff816e9145>] do_wp_page+0xc85/0x14f0 mm/memory.c:2307
>      [<     inline     >] handle_pte_fault mm/memory.c:3323
>      [<     inline     >] __handle_mm_fault mm/memory.c:3417
>      [<ffffffff816ecec3>] handle_mm_fault+0x2483/0x4640 mm/memory.c:3446
>      [<ffffffff8127eff6>] __do_page_fault+0x376/0x960 arch/x86/mm/fault.c:1238
>      [<ffffffff8127f738>] trace_do_page_fault+0xe8/0x420 arch/x86/mm/fault.c:1331
>      [<ffffffff812705c4>] do_async_page_fault+0x14/0xd0 arch/x86/kernel/kvm.c:264
>      [<ffffffff86338f78>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:986
>      [<ffffffff86336c36>] entry_SYSCALL_64_fastpath+0x16/0x7a
>     arch/x86/entry/entry_64.S:185
>     ---[ end trace dae21e0f85f1f98c ]---
> 
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Fixes: 5a023cdba50c ("block: enable dax for raw block devices")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Reported-by: Kirill A. Shutemov <kirill@shutemov.name>
> Suggested-by: Jan Kara <jack@suse.cz>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Suggested-by: Matthew Wilcox <willy@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

I had a test case where I was hitting a warning while inserting into the page
cache when the inode was supposed to be DAX, and this clears up my issue as
well.

Tested-by: Ross Zwisler <ross.zwisler@linux.intel.com>

> ---
>  include/linux/fs.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 1a2046275cdf..b10002d4a5f5 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2907,7 +2907,7 @@ extern void replace_mount_options(struct super_block *sb, char *options);
>  
>  static inline bool io_is_direct(struct file *filp)
>  {
> -	return (filp->f_flags & O_DIRECT) || IS_DAX(file_inode(filp));
> +	return (filp->f_flags & O_DIRECT) || IS_DAX(filp->f_mapping->host);
>  }
>  
>  static inline int iocb_flags(struct file *file)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
