Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3F9868D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 13:43:19 -0400 (EDT)
Date: Thu, 24 Mar 2011 13:43:11 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: XFS memory allocation deadlock in 2.6.38
Message-ID: <20110324174311.GA31576@infradead.org>
References: <081DDE43F61F3D43929A181B477DCA95639B52FD@MSXAOA6.twosigma.com>
 <081DDE43F61F3D43929A181B477DCA95639B5327@MSXAOA6.twosigma.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <081DDE43F61F3D43929A181B477DCA95639B5327@MSXAOA6.twosigma.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sean Noonan <Sean.Noonan@twosigma.com>
Cc: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, Martin Bligh <Martin.Bligh@twosigma.com>, Trammell Hudson <Trammell.Hudson@twosigma.com>, Christos Zoulas <Christos.Zoulas@twosigma.com>, "'linux-xfs@oss.sgi.com'" <linux-xfs@oss.sgi.com>, Stephen Degler <Stephen.Degler@twosigma.com>, walken@google.com, linux-mm@kvack.org

Michel,

can you take a look at this bug report?  It looks like a regression
in your mlock handling changes.


On Wed, Mar 23, 2011 at 03:39:05PM -0400, Sean Noonan wrote:
> I believe this patch fixes the behavior:
> diff --git a/mm/memory.c b/mm/memory.c
> index e48945a..740d5ab 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3461,7 +3461,9 @@ int make_pages_present(unsigned long addr, unsigned long end)
>          * to break COW, except for shared mappings because these don't COW
>          * and we would not want to dirty them for nothing.
>          */
> -       write = (vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE;
> +       write = (vma->vm_flags & VM_WRITE) != 0;
> +       if (write && ((vma->vm_flags & VM_SHARED) !=0) && (vma->vm_file == NULL))
> +               write = 0;
>         BUG_ON(addr >= end);
>         BUG_ON(end > vma->vm_end);
>         len = DIV_ROUND_UP(end, PAGE_SIZE) - addr/PAGE_SIZE;
> 
> 
> This was traced to the following commit:
> 5ecfda041e4b4bd858d25bbf5a16c2a6c06d7272 is the first bad commit
> commit 5ecfda041e4b4bd858d25bbf5a16c2a6c06d7272
> Author: Michel Lespinasse <walken@google.com>
> Date:   Thu Jan 13 15:46:09 2011 -0800
> 
>     mlock: avoid dirtying pages and triggering writeback
>     
>     When faulting in pages for mlock(), we want to break COW for anonymous or
>     file pages within VM_WRITABLE, non-VM_SHARED vmas.  However, there is no
>     need to write-fault into VM_SHARED vmas since shared file pages can be
>     mlocked first and dirtied later, when/if they actually get written to.
>     Skipping the write fault is desirable, as we don't want to unnecessarily
>     cause these pages to be dirtied and queued for writeback.
>     
>     Signed-off-by: Michel Lespinasse <walken@google.com>
>     Cc: Hugh Dickins <hughd@google.com>
>     Cc: Rik van Riel <riel@redhat.com>
>     Cc: Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>
>     Cc: Peter Zijlstra <peterz@infradead.org>
>     Cc: Nick Piggin <npiggin@kernel.dk>
>     Cc: Theodore Tso <tytso@google.com>
>     Cc: Michael Rubin <mrubin@google.com>
>     Cc: Suleiman Souhlal <suleiman@google.com>
>     Cc: Dave Chinner <david@fromorbit.com>
>     Cc: Christoph Hellwig <hch@infradead.org>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> :040000 040000 604eede2f45b7e5276ce9725b715ed15a868861d 3c175eadf4cf33d4f78d4d455c9a04f3df2c199e M	mm
> 
> 
> -----Original Message-----
> From: Sean Noonan 
> Sent: Monday, March 21, 2011 12:20
> To: 'linux-kernel@vger.kernel.org'
> Cc: Trammell Hudson; Martin Bligh; Stephen Degler; Christos Zoulas
> Subject: XFS memory allocation deadlock in 2.6.38
> 
> This message was originally posted to the XFS mailing list, but received no responses.  Thus, I am sending it to LKML on the advice of Martin.
> 
> Using the attached program, we are able to reproduce this bug reliably.
> $ make vmtest
> $ ./vmtest /xfs/hugefile.dat $(( 16 * 1024 * 1024 * 1024 )) # vmtest <path_to_file> <size_in_bytes>
> /xfs/hugefile.dat: mapped 17179869184 bytes in 33822066943 ticks
> 749660: avg 13339 max 234667 ticks
> 371945: avg 26885 max 281616 ticks
> ---
> At this point, we see the following on the console:
> [593492.694806] XFS: possible memory allocation deadlock in kmem_alloc (mode:0x250)
> [593506.724367] XFS: possible memory allocation deadlock in kmem_alloc (mode:0x250)
> [593524.837717] XFS: possible memory allocation deadlock in kmem_alloc (mode:0x250)
> [593556.742386] XFS: possible memory allocation deadlock in kmem_alloc (mode:0x250)
> 
> This is the same message presented in
> http://oss.sgi.com/bugzilla/show_bug.cgi?id=410
> 
> We started testing with 2.6.38-rc7 and have seen this bug through to the .0 release.  This does not appear to be present in 2.6.33, but we have not done testing in between.  We have tested with ext4 and do not encounter this bug.
> CONFIG_XFS_FS=y
> CONFIG_XFS_QUOTA=y
> CONFIG_XFS_POSIX_ACL=y
> CONFIG_XFS_RT=y
> # CONFIG_XFS_DEBUG is not set
> # CONFIG_VXFS_FS is not set
> 
> Here is the stack from the process:
> [<ffffffff81357553>] call_rwsem_down_write_failed+0x13/0x20
> [<ffffffff812ddf1e>] xfs_ilock+0x7e/0x110
> [<ffffffff8130132f>] __xfs_get_blocks+0x8f/0x4e0
> [<ffffffff813017b1>] xfs_get_blocks+0x11/0x20
> [<ffffffff8114ba3e>] __block_write_begin+0x1ee/0x5b0
> [<ffffffff8114be9d>] block_page_mkwrite+0x9d/0xf0
> [<ffffffff81307e05>] xfs_vm_page_mkwrite+0x15/0x20
> [<ffffffff810f2ddb>] do_wp_page+0x54b/0x820
> [<ffffffff810f347c>] handle_pte_fault+0x3cc/0x820
> [<ffffffff810f5145>] handle_mm_fault+0x175/0x2f0
> [<ffffffff8102e399>] do_page_fault+0x159/0x470
> [<ffffffff816cf6cf>] page_fault+0x1f/0x30
> [<ffffffffffffffff>] 0xffffffffffffffff
> 
> # uname -a
> Linux testhost 2.6.38 #2 SMP PREEMPT Fri Mar 18 15:00:59 GMT 2011 x86_64 GNU/Linux
> 
> Please let me know if additional information is required.
> 
> Thanks!
> 
> Sean
> 
> _______________________________________________
> xfs mailing list
> xfs@oss.sgi.com
> http://oss.sgi.com/mailman/listinfo/xfs
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
