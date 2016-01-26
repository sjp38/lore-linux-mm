Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id E25366B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 03:28:55 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id r129so94076719wmr.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 00:28:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dm6si348470wjb.119.2016.01.26.00.28.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 00:28:54 -0800 (PST)
Date: Tue, 26 Jan 2016 09:29:04 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: mm: WARNING in __delete_from_page_cache
Message-ID: <20160126082904.GS24938@quack.suse.cz>
References: <CACT4Y+aBnm8VLe5f=AwO2nUoQZaH-UVqUynGB+naAC-zauOQsQ@mail.gmail.com>
 <20160124230422.GA8439@node.shutemov.name>
 <20160125122206.GA24938@quack.suse.cz>
 <1453779754.32645.3.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1453779754.32645.3.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Cc: "kirill@shutemov.name" <kirill@shutemov.name>, "jack@suse.cz" <jack@suse.cz>, "syzkaller@googlegroups.com" <syzkaller@googlegroups.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "kcc@google.com" <kcc@google.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "dvyukov@google.com" <dvyukov@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "gthelen@google.com" <gthelen@google.com>, "willy@linux.intel.com" <willy@linux.intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "jack@suse.com" <jack@suse.com>, "glider@google.com" <glider@google.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "j-nomura@ce.jp.nec.com" <j-nomura@ce.jp.nec.com>

On Tue 26-01-16 03:42:34, Williams, Dan J wrote:
> On Mon, 2016-01-25 at 13:22 +0100, Jan Kara wrote:
> [..]
> > Thanks. Despite the huge list of recipients the author of the changes
> > hasn't been CCed :) I've added Dan to CC since he wrote DAX support
> > for
> > block devices. It seems somehow the write didn't go through the DAX
> > path
> > but through the standard page cache write path. Ah, I see, only
> > file->f_mapping->host has S_DAX set but io_is_direct() which decides
> > whether DAX or pagecache path should be used for writes uses file-
> > >f_inode
> > which is something different for block devices... 
> 
> Thanks, yes, the following silences the warning for me:
> 
> 8<----- (git am --scissors)
> Subject: fs, block: force direct-I/O for dax-enabled block devices
> 
> From: Dan Williams <dan.j.williams@intel.com>
> 
> Similar to the file I/O path, re-direct all I/O to the DAX path for I/O
> to a block-device special file.
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
> Cc: Matthew Wilcox <willy@linux.intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Fixes: 5a023cdba50c ("block: enable dax for raw block devices")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Reported-by: Kirill A. Shutemov <kirill@shutemov.name>
> Suggested-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

The patch looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
> ---
>  fs/block_dev.c     |    5 -----
>  include/linux/fs.h |   12 +++++++++++-
>  2 files changed, 11 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index 7b9cd49622b1..277008617b2d 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -156,11 +156,6 @@ blkdev_get_block(struct inode *inode, sector_t iblock,
>  	return 0;
>  }
>  
> -static struct inode *bdev_file_inode(struct file *file)
> -{
> -	return file->f_mapping->host;
> -}
> -
>  static ssize_t
>  blkdev_direct_IO(struct kiocb *iocb, struct iov_iter *iter, loff_t offset)
>  {
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 1a2046275cdf..a4c4314eed48 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1237,6 +1237,11 @@ static inline struct inode *file_inode(const struct file *f)
>  	return f->f_inode;
>  }
>  
> +static inline struct inode *bdev_file_inode(struct file *file)
> +{
> +	return file->f_mapping->host;
> +}
> +
>  static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
>  {
>  	return locks_lock_inode_wait(file_inode(filp), fl);
> @@ -2907,7 +2912,12 @@ extern void replace_mount_options(struct super_block *sb, char *options);
>  
>  static inline bool io_is_direct(struct file *filp)
>  {
> -	return (filp->f_flags & O_DIRECT) || IS_DAX(file_inode(filp));
> +	struct inode *inode = file_inode(filp);
> +
> +	if (S_ISBLK(inode->i_mode))
> +		inode = bdev_file_inode(filp);
> +
> +	return (filp->f_flags & O_DIRECT) || IS_DAX(inode);
>  }
>  
>  static inline int iocb_flags(struct file *file)
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
