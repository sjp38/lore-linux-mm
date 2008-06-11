Date: Tue, 10 Jun 2008 23:27:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.26-rc5-mm2: OOM with 1G free swap
Message-Id: <20080610232705.3aaf5c06.akpm@linux-foundation.org>
In-Reply-To: <20080611060029.GA5011@martell.zuzino.mipt.ru>
References: <20080609223145.5c9a2878.akpm@linux-foundation.org>
	<20080611060029.GA5011@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jun 2008 10:00:29 +0400 Alexey Dobriyan <adobriyan@gmail.com> wrote:

> On Mon, Jun 09, 2008 at 10:31:45PM -0700, Andrew Morton wrote:
> > - This is a bugfixed version of 2.6.26-rc5-mm1 - mainly to repair a
> >   vmscan.c bug which would have prevented testing of the other vmscan.c
> >   bugs^Wchanges.
> 
> OOM condition happened with 1G free swap.

Thanks for testing.  Again.

> 4G RAM, 1G swap partition, normally LTP survives during much, much higher
> load.
> 
> vm.overcommit_memory = 0
> vm.overcommit_ratio = 50

Well I assume that Rik ran LTP.  Perhaps a merge problem.

>
> ...
>
> [ 6773.608125] init invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=0

GFP_USER

> [ 6773.608215] Pid: 1, comm: init Not tainted 2.6.26-rc5-mm2 #2

wot?  The oom-killer isn't supposed to kill init!

> [ 6773.608888] 
> [ 6773.608888] Call Trace:
> [ 6773.610887]  [<ffffffff80269e4b>] oom_kill_process+0x11b/0x220
> [ 6773.610887]  [<ffffffff8026a0e6>] ? badness+0x156/0x210
> [ 6773.610887]  [<ffffffff8026a352>] out_of_memory+0x1b2/0x200
> [ 6773.610887]  [<ffffffff8026d0f2>] __alloc_pages_internal+0x322/0x470
> [ 6773.610887]  [<ffffffff8026f71c>] __do_page_cache_readahead+0xfc/0x210
> [ 6773.610887]  [<ffffffff8026fc8f>] do_page_cache_readahead+0x5f/0x80
> [ 6773.610887]  [<ffffffff80269310>] filemap_fault+0x250/0x4c0
> [ 6773.610887]  [<ffffffff80276bf0>] __do_fault+0x50/0x490
> [ 6773.610887]  [<ffffffff80256005>] ? __lock_acquire+0x9e5/0x10b0
> [ 6773.610887]  [<ffffffff80278972>] handle_mm_fault+0x242/0x780
> [ 6773.610887]  [<ffffffff8022146f>] ? do_page_fault+0x2df/0x8d0
> [ 6773.610887]  [<ffffffff8022141d>] do_page_fault+0x28d/0x8d0
> [ 6773.610887]  [<ffffffff8046842d>] error_exit+0x0/0xa9
> [ 6773.610887] 
> [ 6773.610887] Mem-info:
> [ 6773.610887] DMA per-cpu:
> [ 6773.610887] CPU    0: hi:    0, btch:   1 usd:   0
> [ 6773.610887] CPU    1: hi:    0, btch:   1 usd:   0
> [ 6773.610887] DMA32 per-cpu:
> [ 6773.610887] CPU    0: hi:  186, btch:  31 usd:  45
> [ 6773.610952] CPU    1: hi:  186, btch:  31 usd:   0
> [ 6773.611462] Normal per-cpu:
> [ 6773.611513] CPU    0: hi:  186, btch:  31 usd: 161
> [ 6773.611573] CPU    1: hi:  186, btch:  31 usd: 107
> [ 6773.611634] Active_anon:0 active_file:473789 inactive_anon0
> [ 6773.611635]  inactive_file:473447 dirty:41471 writeback:0 unstable:0
> [ 6773.611636]  free:5688 slab:45896 mapped:1 pagetables:415 bounce:0
> [ 6773.611829] DMA free:6724kB min:12kB low:12kB high:16kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB present:6124kB pages_scanned:0 all_unreclaimable? no
> [ 6773.612003] lowmem_reserve[]: 0 1975 3995 3995
> [ 6773.612086] DMA32 free:11964kB min:3996kB low:4992kB high:5992kB active_anon:0kB inactive_anon:0kB active_file:911668kB inactive_file:911232kB present:2023200kB pages_scanned:5792629 all_unreclaimable? no
> [ 6773.612459] lowmem_reserve[]: 0 0 2020 2020
> [ 6773.613544] Normal free:3980kB min:4084kB low:5104kB high:6124kB active_anon:0kB inactive_anon:0kB active_file:983488kB inactive_file:982556kB present:2068480kB pages_scanned:5756927 all_unreclaimable? no

OK, weird.

Zero pages on active_anon and inactive_anon.  I suspect we lost those pages.

And what's up with the all_unreclaimable logic?  If that isn't working
then we'll spend lots of CPU scanning zones which aren't releasing any
pages.  Hopefully that won't be needed at all if all these patches work
as hoped, but I don't think Rik intentionally disabled it at this
stage.  But I've only read half his patches to date.

> [ 6773.613544] lowmem_reserve[]: 0 0 0 0
> [ 6773.613544] DMA: 3*4kB 7*8kB 4*16kB 4*32kB 5*64kB 4*128kB 4*256kB 1*512kB 0*1024kB 0*2048kB 1*4096kB = 6724kB
> [ 6773.613544] DMA32: 1513*4kB 5*8kB 5*16kB 1*32kB 26*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 1*4096kB = 11964kB
> [ 6773.613544] Normal: 1*4kB 4*8kB 2*16kB 3*32kB 1*64kB 1*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3940kB
> [ 6773.613544] 675611 total pagecache pages
> [ 6773.613544] Swap cache: add 3407179, delete 3407179, find 2573/2828
> [ 6773.613544] Free swap  = 9765272kB
> [ 6773.613603] Total swap = 9775512kB
> [ 6773.631577] 1572864 pages of RAM
> [ 6773.631639] 566471 reserved pages
> [ 6773.631693] 652567 pages shared
> [ 6773.631745] 0 pages swap cached
> [ 6773.631799] Out of memory: kill process 4788 (sshd) score 11194 or a child
> [ 6773.631876] Killed process 4789 (bash)
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
