Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 89B586B02BF
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:34:56 -0400 (EDT)
Date: Fri, 20 Aug 2010 13:34:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100820053447.GA13406@localhost>
References: <325E0A25FE724BA18190186F058FF37E@rainbow>
 <20100817111018.GQ19797@csn.ul.ie>
 <4385155269B445AEAF27DC8639A953D7@rainbow>
 <20100818154130.GC9431@localhost>
 <565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
 <20100819160006.GG6805@barrios-desktop>
 <AA3F2D89535A431DB91FE3032EDCB9EA@rainbow>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AA3F2D89535A431DB91FE3032EDCB9EA@rainbow>
Sender: owner-linux-mm@kvack.org
To: Iram Shahzad <iram.shahzad@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

You do run lots of tasks: kernel_stack=1880kB.

And you have lots of free memory, page reclaim has never run, so
inactive_anon=0. This is where compaction is different from vmscan.
In vmscan, inactive_anon is reasonably large, and will only be
compared directly with isolated_anon.

Thanks,
Fengguang

On Fri, Aug 20, 2010 at 01:31:03PM +0800, Iram Shahzad wrote:
> > Could you apply below patch for debugging and report it?
> 
> The Mem-info gets printed forever. So I have picked the first 2 of them
> and then another 2 after some time. These 4 Mem-infos are shown in
> the attached log.
> 
> Thanks
> Iram

> Mem-info:
> Normal per-cpu:
> CPU    0: hi:  186, btch:  31 usd: 184
> active_anon:40345 inactive_anon:0 isolated_anon:8549
>  active_file:2713 inactive_file:10418 isolated_file:1871
>  unevictable:0 dirty:0 writeback:0 unstable:0
>  free:53713 slab_reclaimable:533 slab_unreclaimable:1076
>  mapped:9461 shmem:2349 pagetables:1574 bounce:0
> Normal free:214852kB min:2884kB low:3604kB high:4324kB active_anon:161380kB inactive_anon:0kB active_file:10852kB inactive_file:41672kB unevictable:0kB isolated(anon):34196kB isolated(file):7484kB present:520192kB mlocked:0kB dirty:0kB writeback:0kB mapped:37844kB shmem:9396kB slab_reclaimable:2132kB slab_unreclaimable:4304kB kernel_stack:1880kB pagetables:6296kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0
> Normal: 31*4kB 29*8kB 20*16kB 23*32kB 21*64kB 19*128kB 19*256kB 20*512kB 20*1024kB 3*2048kB 41*4096kB = 214852kB
> 15491 total pagecache pages
> 131072 pages of RAM
> 54242 free pages
> 18897 reserved pages
> 1609 slab pages
> 84316 pages shared
> 0 pages swap cached
> Mem-info:
> Normal per-cpu:
> CPU    0: hi:  186, btch:  31 usd: 184
> active_anon:40345 inactive_anon:0 isolated_anon:8549
>  active_file:2713 inactive_file:10418 isolated_file:1871
>  unevictable:0 dirty:0 writeback:0 unstable:0
>  free:53713 slab_reclaimable:533 slab_unreclaimable:1076
>  mapped:9461 shmem:2349 pagetables:1574 bounce:0
> Normal free:214852kB min:2884kB low:3604kB high:4324kB active_anon:161380kB inactive_anon:0kB active_file:10852kB inactive_file:41672kB unevictable:0kB isolated(anon):34196kB isolated(file):7484kB present:520192kB mlocked:0kB dirty:0kB writeback:0kB mapped:37844kB shmem:9396kB slab_reclaimable:2132kB slab_unreclaimable:4304kB kernel_stack:1880kB pagetables:6296kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0
> Normal: 26*4kB 27*8kB 19*16kB 22*32kB 20*64kB 19*128kB 19*256kB 20*512kB 20*1024kB 3*2048kB 41*4096kB = 214704kB
> 15491 total pagecache pages
> 131072 pages of RAM
> 54258 free pages
> 18897 reserved pages
> 1609 slab pages
> 84296 pages shared
> 0 pages swap cached
> 
> 
> [snip]
> 
> 
> Mem-info:
> Normal per-cpu:
> CPU    0: hi:  186, btch:  31 usd: 100
> active_anon:40429 inactive_anon:0 isolated_anon:8581
>  active_file:2719 inactive_file:10423 isolated_file:1871
>  unevictable:0 dirty:0 writeback:0 unstable:0
>  free:53777 slab_reclaimable:534 slab_unreclaimable:1070
>  mapped:9461 shmem:2349 pagetables:1574 bounce:0
> Normal free:215108kB min:2884kB low:3604kB high:4324kB active_anon:161716kB inactive_anon:0kB active_file:10876kB inactive_file:41692kB unevictable:0kB isolated(anon):34324kB isolated(file):7484kB present:520192kB mlocked:0kB dirty:0kB writeback:0kB mapped:37844kB shmem:9396kB slab_reclaimable:2136kB slab_unreclaimable:4280kB kernel_stack:1872kB pagetables:6296kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0
> Normal: 31*4kB 29*8kB 20*16kB 21*32kB 22*64kB 19*128kB 20*256kB 20*512kB 20*1024kB 3*2048kB 41*4096kB = 215108kB
> 15491 total pagecache pages
> 131072 pages of RAM
> 54221 free pages
> 18897 reserved pages
> 1604 slab pages
> 84289 pages shared
> 0 pages swap cached
> Mem-info:
> Normal per-cpu:
> CPU    0: hi:  186, btch:  31 usd: 100
> active_anon:40429 inactive_anon:0 isolated_anon:8581
>  active_file:2719 inactive_file:10423 isolated_file:1871
>  unevictable:0 dirty:0 writeback:0 unstable:0
>  free:53777 slab_reclaimable:534 slab_unreclaimable:1070
>  mapped:9461 shmem:2349 pagetables:1574 bounce:0
> Normal free:215108kB min:2884kB low:3604kB high:4324kB active_anon:161716kB inactive_anon:0kB active_file:10876kB inactive_file:41692kB unevictable:0kB isolated(anon):34324kB isolated(file):7484kB present:520192kB mlocked:0kB dirty:0kB writeback:0kB mapped:37844kB shmem:9396kB slab_reclaimable:2136kB slab_unreclaimable:4280kB kernel_stack:1872kB pagetables:6296kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0
> Normal: 31*4kB 29*8kB 20*16kB 21*32kB 22*64kB 19*128kB 20*256kB 20*512kB 20*1024kB 3*2048kB 41*4096kB = 215108kB
> 15491 total pagecache pages
> 131072 pages of RAM
> 54222 free pages
> 18897 reserved pages
> 1603 slab pages
> 84289 pages shared
> 0 pages swap cached

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
