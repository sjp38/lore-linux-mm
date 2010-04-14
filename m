Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CD600600374
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 02:52:49 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3E6ql0Q017577
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 14 Apr 2010 15:52:47 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 07B7745DE53
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 15:52:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C5A7445DE4F
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 15:52:45 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 631401DB803C
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 15:52:45 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id F07AE1DB8040
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 15:52:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
In-Reply-To: <20100414014041.GD2493@dastard>
References: <20100413202021.GZ13327@think> <20100414014041.GD2493@dastard>
Message-Id: <20100414155233.D153.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 14 Apr 2010 15:52:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Tue, Apr 13, 2010 at 04:20:21PM -0400, Chris Mason wrote:
> > On Tue, Apr 13, 2010 at 08:34:29PM +0100, Mel Gorman wrote:
> > > > This problem is not a filesystem recursion problem which is, as I
> > > > understand it, what GFP_NOFS is used to prevent. It's _any_ kernel
> > > > code that uses signficant stack before trying to allocate memory
> > > > that is the problem. e.g a select() system call:
> > > > 
> > > >        Depth    Size   Location    (47 entries)
> > > >        -----    ----   --------
> > > >  0)     7568      16   mempool_alloc_slab+0x16/0x20
> > > >  1)     7552     144   mempool_alloc+0x65/0x140
> > > >  2)     7408      96   get_request+0x124/0x370
> > > >  3)     7312     144   get_request_wait+0x29/0x1b0
> > > >  4)     7168      96   __make_request+0x9b/0x490
> > > >  5)     7072     208   generic_make_request+0x3df/0x4d0
> > > >  6)     6864      80   submit_bio+0x7c/0x100
> > > >  7)     6784      96   _xfs_buf_ioapply+0x128/0x2c0 [xfs]
> > > > ....
> > > > 32)     3184      64   xfs_vm_writepage+0xab/0x160 [xfs]
> > > > 33)     3120     384   shrink_page_list+0x65e/0x840
> > > > 34)     2736     528   shrink_zone+0x63f/0xe10
> > > > 35)     2208     112   do_try_to_free_pages+0xc2/0x3c0
> > > > 36)     2096     128   try_to_free_pages+0x77/0x80
> > > > 37)     1968     240   __alloc_pages_nodemask+0x3e4/0x710
> > > > 38)     1728      48   alloc_pages_current+0x8c/0xe0
> > > > 39)     1680      16   __get_free_pages+0xe/0x50
> > > > 40)     1664      48   __pollwait+0xca/0x110
> > > > 41)     1616      32   unix_poll+0x28/0xc0
> > > > 42)     1584      16   sock_poll+0x1d/0x20
> > > > 43)     1568     912   do_select+0x3d6/0x700
> > > > 44)      656     416   core_sys_select+0x18c/0x2c0
> > > > 45)      240     112   sys_select+0x4f/0x110
> > > > 46)      128     128   system_call_fastpath+0x16/0x1b
> > > > 
> > > > There's 1.6k of stack used before memory allocation is called, 3.1k
> > > > used there before ->writepage is entered, XFS used 3.5k, and
> > > > if the mempool needed to allocate a page it would have blown the
> > > > stack. If there was any significant storage subsystem (add dm, md
> > > > and/or scsi of some kind), it would have blown the stack.
> > > > 
> > > > Basically, there is not enough stack space available to allow direct
> > > > reclaim to enter ->writepage _anywhere_ according to the stack usage
> > > > profiles we are seeing here....
> > > > 
> > > 
> > > I'm not denying the evidence but how has it been gotten away with for years
> > > then? Prevention of writeback isn't the answer without figuring out how
> > > direct reclaimers can queue pages for IO and in the case of lumpy reclaim
> > > doing sync IO, then waiting on those pages.
> > 
> > So, I've been reading along, nodding my head to Dave's side of things
> > because seeks are evil and direct reclaim makes seeks.  I'd really loev
> > for direct reclaim to somehow trigger writepages on large chunks instead
> > of doing page by page spatters of IO to the drive.

I agree that "seeks are evil and direct reclaim makes seeks". Actually,
making 4k io is not must for pageout. So, probably we can improve it.


> Perhaps drop the lock on the page if it is held and call one of the
> helpers that filesystems use to do this, like:
> 
> 	filemap_write_and_wait(page->mapping);

Sorry, I'm lost what you talk about. Why do we need per-file waiting?
If file is 1GB file, do we need to wait 1GB writeout?


> 
> > But, somewhere along the line I overlooked the part of Dave's stack trace
> > that said:
> > 
> > 43)     1568     912   do_select+0x3d6/0x700
> > 
> > Huh, 912 bytes...for select, really?  From poll.h:
> 
> Sure, it's bad, but we focussing on the specific case misses the
> point that even code that is using minimal stack can enter direct
> reclaim after consuming 1.5k of stack. e.g.:

checkstack.pl says do_select() and __generic_file_splice_read() are one
of worstest stack consumer. both sould be fixed.

also, checkstack.pl says such stack eater aren't so much.


> 
>  50)     3168      64   xfs_vm_writepage+0xab/0x160 [xfs]
>  51)     3104     384   shrink_page_list+0x65e/0x840
>  52)     2720     528   shrink_zone+0x63f/0xe10
>  53)     2192     112   do_try_to_free_pages+0xc2/0x3c0
>  54)     2080     128   try_to_free_pages+0x77/0x80
>  55)     1952     240   __alloc_pages_nodemask+0x3e4/0x710
>  56)     1712      48   alloc_pages_current+0x8c/0xe0
>  57)     1664      32   __page_cache_alloc+0x67/0x70
>  58)     1632     144   __do_page_cache_readahead+0xd3/0x220
>  59)     1488      16   ra_submit+0x21/0x30
>  60)     1472      80   ondemand_readahead+0x11d/0x250
>  61)     1392      64   page_cache_async_readahead+0xa9/0xe0
>  62)     1328     592   __generic_file_splice_read+0x48a/0x530
>  63)      736      48   generic_file_splice_read+0x4f/0x90
>  64)      688      96   xfs_splice_read+0xf2/0x130 [xfs]
>  65)      592      32   xfs_file_splice_read+0x4b/0x50 [xfs]
>  66)      560      64   do_splice_to+0x77/0xb0
>  67)      496     112   splice_direct_to_actor+0xcc/0x1c0
>  68)      384      80   do_splice_direct+0x57/0x80
>  69)      304      96   do_sendfile+0x16c/0x1e0
>  70)      208      80   sys_sendfile64+0x8d/0xb0
>  71)      128     128   system_call_fastpath+0x16/0x1b
> 
> Yes, __generic_file_splice_read() is a hog, but they seem to be
> _everywhere_ today...
> 
> > So, select is intentionally trying to use that much stack.  It should be using
> > GFP_NOFS if it really wants to suck down that much stack...
> 
> The code that did the allocation is called from multiple different
> contexts - how is it supposed to know that in some of those contexts
> it is supposed to treat memory allocation differently?
> 
> This is my point - if you introduce a new semantic to memory allocation
> that is "use GFP_NOFS when you are using too much stack" and too much
> stack is more than 15% of the stack, then pretty much every code path
> will need to set that flag...

Nodding my head to Dave's side. changing caller argument seems not good
solution. I mean
 - do_select() should use GFP_KERNEL instead stack (as revert 70674f95c0)
 - reclaim and xfs (and other something else) need to diet.

Also, I believe stack eater function should be created waring. patch attached.


> > if only the
> > kernel had some sort of way to dynamically allocate ram, it could try
> > that too.
> 
> Sure, but to play the devil's advocate: if memory allocation blows
> the stack, then surely avoiding allocation by using stack variables
> is safer? ;)
> 
> FWIW, even if we use GFP_NOFS, allocation+reclaim can still use 2k
> of stack; stuff like the radix tree code appears to be a significant
> user of stack now:
> 
>         Depth    Size   Location    (56 entries)
>         -----    ----   --------
>   0)     7904      48   __call_rcu+0x67/0x190
>   1)     7856      16   call_rcu_sched+0x15/0x20
>   2)     7840      16   call_rcu+0xe/0x10
>   3)     7824     272   radix_tree_delete+0x159/0x2e0
>   4)     7552      32   __remove_from_page_cache+0x21/0x110
>   5)     7520      64   __remove_mapping+0xe8/0x130
>   6)     7456     384   shrink_page_list+0x400/0x860
>   7)     7072     528   shrink_zone+0x636/0xdc0
>   8)     6544     112   do_try_to_free_pages+0xc2/0x3c0
>   9)     6432     112   try_to_free_pages+0x64/0x70
>  10)     6320     256   __alloc_pages_nodemask+0x3d2/0x710
>  11)     6064      48   alloc_pages_current+0x8c/0xe0
>  12)     6016      32   __page_cache_alloc+0x67/0x70
>  13)     5984      80   find_or_create_page+0x50/0xb0
>  14)     5904     160   _xfs_buf_lookup_pages+0x145/0x350 [xfs]
> 
> or even just calling ->releasepage and freeing bufferheads:
> 
>        Depth    Size   Location    (55 entries)
>        -----    ----   --------
>  0)     7440      48   add_partial+0x26/0x90
>  1)     7392      64   __slab_free+0x1a9/0x380
>  2)     7328      64   kmem_cache_free+0xb9/0x160
>  3)     7264      16   free_buffer_head+0x25/0x50
>  4)     7248      64   try_to_free_buffers+0x79/0xc0
>  5)     7184     160   xfs_vm_releasepage+0xda/0x130 [xfs]
>  6)     7024      16   try_to_release_page+0x33/0x60
>  7)     7008     384   shrink_page_list+0x585/0x860
>  8)     6624     528   shrink_zone+0x636/0xdc0
>  9)     6096     112   do_try_to_free_pages+0xc2/0x3c0
> 10)     5984     112   try_to_free_pages+0x64/0x70
> 11)     5872     256   __alloc_pages_nodemask+0x3d2/0x710
> 12)     5616      48   alloc_pages_current+0x8c/0xe0
> 13)     5568      32   __page_cache_alloc+0x67/0x70
> 14)     5536      80   find_or_create_page+0x50/0xb0
> 15)     5456     160   _xfs_buf_lookup_pages+0x145/0x350 [xfs]
> 
> And another eye-opening example, this time deep in the sata driver
> layer:
> 
>         Depth    Size   Location    (72 entries)
>         -----    ----   --------
>   0)     8336     304   select_task_rq_fair+0x235/0xad0
>   1)     8032      96   try_to_wake_up+0x189/0x3f0
>   2)     7936      16   default_wake_function+0x12/0x20
>   3)     7920      32   autoremove_wake_function+0x16/0x40
>   4)     7888      64   __wake_up_common+0x5a/0x90
>   5)     7824      64   __wake_up+0x48/0x70
>   6)     7760      64   insert_work+0x9f/0xb0
>   7)     7696      48   __queue_work+0x36/0x50
>   8)     7648      16   queue_work_on+0x4d/0x60
>   9)     7632      16   queue_work+0x1f/0x30
>  10)     7616      16   queue_delayed_work+0x2d/0x40
>  11)     7600      32   ata_pio_queue_task+0x35/0x40
>  12)     7568      48   ata_sff_qc_issue+0x146/0x2f0
>  13)     7520      96   mv_qc_issue+0x12d/0x540 [sata_mv]
>  14)     7424      96   ata_qc_issue+0x1fe/0x320
>  15)     7328      64   ata_scsi_translate+0xae/0x1a0
>  16)     7264      64   ata_scsi_queuecmd+0xbf/0x2f0
>  17)     7200      48   scsi_dispatch_cmd+0x114/0x2b0
>  18)     7152      96   scsi_request_fn+0x419/0x590
>  19)     7056      32   __blk_run_queue+0x82/0x150
>  20)     7024      48   elv_insert+0x1aa/0x2d0
>  21)     6976      48   __elv_add_request+0x83/0xd0
>  22)     6928      96   __make_request+0x139/0x490
>  23)     6832     208   generic_make_request+0x3df/0x4d0
>  24)     6624      80   submit_bio+0x7c/0x100
>  25)     6544      96   _xfs_buf_ioapply+0x128/0x2c0 [xfs]
> 
> We need at least _700_ bytes of stack free just to call queue_work(),
> and that now happens deep in the guts of the driver subsystem below XFS.
> This trace shows 1.8k of stack usage on a simple, single sata disk
> storage subsystem, so my estimate of 2k of stack for the storage system
> below XFS is too small - a worst case of 2.5-3k of stack space is probably
> closer to the mark.

your explanation is very interesting. I have a (probably dumb) question.
Why nobody faced stack overflow issue in past? now I think every users
easily get stack overflow if your explanation is correct.


> 
> This is the sort of thing I'm pointing at when I say that stack
> usage outside XFS has grown significantly significantly over the
> past couple of years. Given XFS has remained pretty much the same or
> even reduced slightly over the same time period, blaming XFS or
> saying "callers should use GFP_NOFS" seems like a cop-out to me.
> Regardless of the IO pattern performance issues, writeback via
> direct reclaim just uses too much stack to be safe these days...

Yeah, My answer is simple, All stack eater should be fixed.
but XFS seems not innocence too. 3.5K is enough big although
xfs have use such amount since very ago.


===========================================================
Subject: [PATCH] kconfig: reduce FRAME_WARN default value to 512

Surprisedly, now several odd functions use very much stack.

% objdump -d vmlinux | ./scripts/checkstack.pl

0xffffffff81e3db07 get_next_block [vmlinux]:            1976
0xffffffff8130b9bd node_read_meminfo [vmlinux]:         1240
0xffffffff811553fd do_sys_poll [vmlinux]:               1000
0xffffffff8122b49d test_aead [vmlinux]:                 904
0xffffffff81154c9d do_select [vmlinux]:                 888
0xffffffff81168d9d default_file_splice_read [vmlinux]:  760

Oh well, Every developers have to pay attention a stack usage!
Thus, this patch reduce FRAME_WARN default value to 512.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 lib/Kconfig.debug |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index ff01710..44ebba6 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -28,8 +28,7 @@ config ENABLE_MUST_CHECK
 config FRAME_WARN
 	int "Warn for stack frames larger than (needs gcc 4.4)"
 	range 0 8192
-	default 1024 if !64BIT
-	default 2048 if 64BIT
+	default 512
 	help
 	  Tell gcc to warn at build time for stack frames larger than this.
 	  Setting this too low will cause a lot of warnings.
-- 
1.6.5.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
