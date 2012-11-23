Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id E631E6B005D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 00:44:32 -0500 (EST)
Date: Fri, 23 Nov 2012 14:44:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: another allocation livelock with zram
Message-ID: <20121123054446.GB13626@bbox>
References: <CAA25o9T8cBhuFnesnxHDsv3PmV8tiHKoLz0dGQeUSCvtpBBv3A@mail.gmail.com>
 <20121121012726.GA5121@bbox>
 <CAA25o9Q=qnmrZ5iyVcmKxDr+nO7J-o-z1X6QtiEdLdxZHCViBw@mail.gmail.com>
 <20121121135957.GB2084@barrios>
 <CAA25o9SeEM0RH1Ztt9aqjpAd50tzbf=0FUXuCOapZjBQuNRZEw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9SeEM0RH1Ztt9aqjpAd50tzbf=0FUXuCOapZjBQuNRZEw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org

On Wed, Nov 21, 2012 at 10:21:38AM -0800, Luigi Semenzato wrote:
> On Wed, Nov 21, 2012 at 5:59 AM, Minchan Kim <minchan@kernel.org> wrote:
> > On Tue, Nov 20, 2012 at 05:47:33PM -0800, Luigi Semenzato wrote:
> >> It's 3.4.0 plus:
> >>
> >> - yes, hacky min_filelist_kbytes patch is applies, sorry
> >> - other Chrome OS patches, but AFAIK none of them in the MM
> >> - TIF_MEMDIE fix for my previous problem applied
> >> - Zsmalloc changes to remove x86 dependency backported.
> >>
> >> Thanks!
> >
> > Below hacky patch makes difference?
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 370244c..44289e9 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2101,7 +2101,7 @@ static bool all_unreclaimable(struct zonelist *zonelist,
> >                         continue;
> >                 if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
> >                         continue;
> > -               if (!zone->all_unreclaimable)
> > +               if (zone->pages_scanned < zone_reclaimable_pages(zone) * 6)
> >                         return false;
> >         }
> 
> With this hacky patch, the system remains responsive but still not
> working well.  I can start new processes, but existing processes seem
> to make very little progress if any.  Swapping out stops very early,
> for instance here:

When I saw your previous mail, I found pages_scanned is abnormally very high.
Before reaching such high number, you should meet OOM kill.'
The reason why you see the hang instead of OOM kill is kswapd is stopped.
For triggering OOM kill, kswapd need to set zone->all_unreclaimable but it doesn't.
So all of processes continue to reclaim pages in direct reclaim path.

First problem you should investigate is why kswapd stop although there are
not enough free memory.
Of course, direct reclaimer can wake up kswapd by moving wake_all_kswapd into
rebalance label below. But it's not a fundamental fix. Before that, we should
know why kswapd stop.

> 
> SwapTotal:       3028768 kB
> SwapFree:        2225072 kB
> 
> OOM killer was triggered several times.  Note no swapout activity from

That's what I expected and it's normal behavior. If kswapd works well,
you can see same result.

> vmstat, and lots of idle time.

Although zram say he has a free space, it's not true.
The zram gets free pages dynamically when the swapout request come.
When zram try to get free pages, it uses GFP_NOIO of zs_malloc so it can
fail easily to get free page when memory pressure is severe.

Have you seen any info message from zram?
Othrewise, It seems that there are no input to swap out anon pages.
So you should investigate shrink_page_list and get_scan_count whether they
are tring to reclaim anon pages.

> 
> procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
>  2  0 806984 167464   1704 228392    0    0     0     0  831 1574 48  5 47  0
>  1  0 806980 167952   1704 228392    0    0     0     0  843 1618 46  5 50  0
>  1  0 806976 167712   1704 228396    0    0     0    68 1409 2178 47  5 49  0
>  1  0 806972 167340   1704 228392    0    0     0     0  855 1632 46  4 50  0
>  1  0 806964 167340   1704 228396    0    0     0     0  829 1573 47  6 48  0
>  1  0 806960 167340   1704 228392    0    0     0     0  793 1627 46  5 50  0
>  1  0 806960 167340   1704 228392    0    0     0     0  784 1618 49  5 46  0
>  1  0 806948 167224   1704 228392   12    0    12     0  785 1606 47  4 49  0
>  1  0 806940 168084   1704 228392   32    0    32     0  807 1663 47  4 49  0
>  1  0 806936 168456   1704 228392    0    0     0     0  839 1697 43  6 52  0
>  1  0 806936 167836   1704 228388    0    0     0     0  859 1662 46  4 49  0
>  1  0 806672 164860   1712 229124 1756    0  2504     4 1027 1829 49  8 44  1
>  1  0 806640 165356   1712 229156   48    0    48     0  978 1792 49  7 44  0
>  0  0 806636 164612   1712 229144    0    0     0     4  913 1766 45  7 48  0
>  2  0 806624 164736   1712 229144    8    0     8     0  832 1571 48  8 45  0
>  1  0 806616 164488   1712 229120   32    0    32     0  883 1610 45  6 49  0
>  2  0 806608 164728   1712 229144    0    0     0     0  719 1518 46  6 47  0
>  1  0 806608 164736   1712 229144    0    0     0     0  778 1605 44  7 50  0
>  1  0 806608 164612   1712 229144    0    0     0     0  912 1685 49  4 47  0
>  1  0 806484 164744   1712 229168  188    0   188     0  888 1714 46  8 47  0
>  2  0 806484 165456   1712 229144    0    0     0     0  737 1535 44  6 50  0
>  3  0 806484 165480   1712 229144    0    0     0     0  844 1637 48  5 48  0
>  1  0 806484 164860   1736 229204    0    0     0   208 1301 2549 44  7 49  1
>  3  0 806288 165604   1736 229216  148    0   148     0  904 1757 47  6 47  0
>  4  0 806288 164860   1736 229204    0    0     0    20  927 1814 47  6 48  0
>  1  0 806284 165116   1736 229204    0    0     0     0  875 1637 45  8 48  0
>  3  0 806280 164984   1736 229208    0    0     0     0  820 1614 46  6 48  0
>  1  0 806264 164240   1736 229216    0    0     0     0  853 1630 47  8 45  0
>  1  0 806248 165604   1736 229220    0    0     0     0  792 1577 41  7 53  0
>  1  0 806248 164240   1736 229204    0    0     0     0  873 1687 47  7 47  0
>  2  0 806248 164488   1736 229204    0    0     0     0  811 1628 44  4 52  0
>  0  0 806232 164372   1736 229212   28    0    28     0  841 1639 47  6 48  0
>  1  0 806232 164240   1736 229204    0    0     0     0  805 1583 44  9 47  0
>  1  0 806232 164116   1760 229252    0    0     0   172 1301 2569 46  7 46  1
>  1  0 806224 163744   1760 229228   32    0    32     0  889 1627 45  6 49  0
>  1  0 806224 164736   1760 229252    0    0     0     4  879 1689 46  8 47  0
>  1  0 806216 164092   1760 229212   48    0    60     0  916 1678 48  6 46  0
>  0  0 806212 164240   1768 229244   24    0    24    40 1361 2217 47  6 46  1
>  1  0 806200 164356   1768 229272    0    0     0     0  993 1739 45  8 48  0
>  1  0 806160 164116   1768 229188  100    0   100    28 1205 1925 41 23 36  0
>  1  0 806160 164240   1776 229264   24    0    24    40 1070 1979 44  8 48  0
>  1  0 804936 135448   1780 237992 3124    0  3280     0 1400 3395 67 19 13  0
>  1  0 804936 135200   1780 237964    0    0     0     0  828 1618 46  5 50  0
>  1  0 804932 135456   1788 237940   20    0    20   120 2860 5483 47  8 45  0
>  3  0 804640 114248   1796 251516 1136    0  4952    88 2207 5031 59 18 24  0
>  2  0 804540 101160   1808 254268  212    0  4576     0 1660 3445 79 14  4  2
>  1  0 804536  99424   1808 254308   76    0    76     0  624 1395 39  7 54  0
>  1  0 804536 101036   1816 254308    0    0     0    48 1329 2772 45  5 50  0
>  1  0 804536 100788   1816 254308    0    0     0     0  754 1520 41  7 52  0
> 
> I am now beginning to wonder if zram is working correctly.  Why is the
> OOM killer triggering so soon?  On x86, the OOM killer starts when the
> entire swap space is taken.
> 
> Also, this is with Chrome processes, and they all seem blocked on
> futex or select or read, none of them on memory allocation.
> 
> Here are a few zram parameters.  In this run, SwapTotal is 3.0 GB and
> SwapFree is 2.5 GB and vmstat shows that nothing is swapped out.
> 
>     compr_data_size:    147103227 (140 MB)
>             disksize:   3101462528 (2957 MB)
>       mem_used_total:    156119040 (148 MB)
>          notify_free:      1961405 (1 MB)
>            num_reads:       945213 (0 MB)
>           num_writes:      1234062 (1 MB)
>       orig_data_size:    391450624 (373 MB)
>                 size:      6057544 (5 MB)
>           zero_pages:         5218 (0 MB)
>    eff. compr. ratio:  2.66
> 
> 
> >
> >
> >>
> >>
> >> On Tue, Nov 20, 2012 at 5:27 PM, Minchan Kim <minchan@kernel.org> wrote:
> >> > Hi Luigi,
> >> >
> >> > Question.
> >> > Is it a 3.4.0 vanilla kernel?
> >> > Otherwise, some hacky patches(ex, min_filelist_kbytes) are applied?
> >> >
> >> > On Tue, Nov 20, 2012 at 03:46:34PM -0800, Luigi Semenzato wrote:
> >> >> Greetings MM folks,
> >> >>
> >> >> and thanks again for fixing my previous hang-with-zram problem.  I am
> >> >> now running into a similar problem and I hope I will not take
> >> >> advantage of your kindness by asking for further advice.
> >> >>
> >> >> By running a few dozen memory-hungry processes on an ARM cpu with 2 Gb
> >> >> RAM, with zram enabled, I can easily get into a situation where all
> >> >> processes are either:
> >> >>
> >> >> 1. blocked in a futex
> >> >> 2. trying unsuccessfully to allocate memory
> >> >>
> >> >> This happens when there should still be plenty of memory: the zram
> >> >> swap device is about 1/3 full. (The output of SysRq-M is at the end.)
> >> >> Yet the SI and SO fields of vmstat stay at 0, and CPU utilization is
> >> >> 100% system.
> >> >>
> >> >> procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
> >> >>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
> >> >> 46  0 1076432  13636   2844 216648    0    0     0     0  621  229  0 100  0  0
> >> >> 44  0 1076432  13636   2844 216648    0    0     0     0  618  204  0 100  0  0
> >> >>
> >> >> I added counters in various places in the page allocator to see which
> >> >> paths were being taken and noticed the following facts:
> >> >>
> >> >> - alloc_page_slowpath is looping, apparently trying to rebalance.  It
> >> >> calls alloc_pages_direct_reclaim at a rate of about 155 times/second,
> >> >> and gets one page about once every 500 calls.  Did_some_progress is
> >> >> always set to true.  Then should_alloc_retry returns true (because
> >> >> order < PAGE_ALLOC_COSTLY_ORDER).
> >> >>
> >> >> - kswapd is asleep and is not woken up because alloc_page_slowpath
> >> >> never goes to the "restart" label.
> >> >>
> >> >> My questions are:
> >> >>
> >> >> 1. is it obvious to any of you what is going wrong?
> >> >> 1.1 is the allocation failing because nobody is waking up kswapd?  And
> >> >> if so, why not?
> >> >>
> >> >> 2. if it's not obvious, what are the next things to look into?
> >> >>
> >> >> 3. is there a better way of debugging this?
> >> >>
> >> >> Thanks!
> >> >> Luigi
> >> >>
> >> >> [    0.000000] Linux version 3.4.0
> >> >> (semenzato@luigi.mtv.corp.google.com) (gcc version 4.6.x-google
> >> >> 20120301 (prerelease) (gcc-4.6.3_cos_gg_2a32ae6) ) #26 SMP Tue Nov 20
> >> >> 14:27:15 PST 2012
> >> >> [    0.000000] CPU: ARMv7 Processor [410fc0f4] revision 4 (ARMv7), cr=10c5387d
> >> >> [    0.000000] CPU: PIPT / VIPT nonaliasing data cache, PIPT instruction cache
> >> >> [    0.000000] Machine: SAMSUNG EXYNOS5 (Flattened Device Tree),
> >> >> model: Google Snow
> >> >> ...
> >> >> [  198.564328] SysRq : Show Memory
> >> >> [  198.564347] Mem-info:
> >> >> [  198.564355] Normal per-cpu:
> >> >> [  198.564364] CPU    0: hi:  186, btch:  31 usd:   0
> >> >> [  198.564373] CPU    1: hi:  186, btch:  31 usd:   0
> >> >> [  198.564381] HighMem per-cpu:
> >> >> [  198.564389] CPU    0: hi:   90, btch:  15 usd:   0
> >> >> [  198.564397] CPU    1: hi:   90, btch:  15 usd:   0
> >> >> [  198.564411] active_anon:196868 inactive_anon:66835 isolated_anon:47
> >> >> [  198.564415]  active_file:13931 inactive_file:11043 isolated_file:0
> >> >> [  198.564419]  unevictable:0 dirty:4 writeback:1 unstable:0
> >> >> [  198.564423]  free:3409 slab_reclaimable:2583 slab_unreclaimable:3337
> >> >> [  198.564427]  mapped:137910 shmem:29899 pagetables:3972 bounce:0
> >> >> [  198.564449] Normal free:13384kB min:5380kB low:6724kB high:8068kB
> >> >> active_anon:782052kB inactive_anon:261808kB active_file:25020kB
> >> >> inactive_file:24900kB unevictable:0kB isolated(anon):16kB
> >> >> isolated(file):0kB present:1811520kB mlocked:0kB dirty:12kB
> >> >> writeback:0kB mapped:461296kB shmem:115892kB slab_reclaimable:10332kB
> >> >> slab_unreclaimable:13348kB kernel_stack:3008kB pagetables:15888kB
> >> >> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:107282320
> >> >> all_unreclaimable? no
> >> >> [  198.564474] lowmem_reserve[]: 0 2095 2095
> >> >> [  198.564499] HighMem free:252kB min:260kB low:456kB high:656kB
> >> >> active_anon:5420kB inactive_anon:5532kB active_file:30704kB
> >> >> inactive_file:19272kB unevictable:0kB isolated(anon):172kB
> >> >> isolated(file):0kB present:268224kB mlocked:0kB dirty:4kB
> >> >> writeback:4kB mapped:90344kB shmem:3704kB slab_reclaimable:0kB
> >> >> slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB
> >> >> bounce:0kB writeback_tmp:0kB pages_scanned:7081406 all_unreclaimable?
> >> >> no
> >> >> [  198.564523] lowmem_reserve[]: 0 0 0
> >> >> [  198.564536] Normal: 1570*4kB 6*8kB 1*16kB 0*32kB 0*64kB 1*128kB
> >> >> 1*256kB 1*512kB 0*1024kB 1*2048kB 1*4096kB = 13384kB
> >> >> [  198.564574] HighMem: 59*4kB 2*8kB 0*16kB 0*32kB 0*64kB 0*128kB
> >> >> 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 252kB
> >> >> [  198.564610] 123112 total pagecache pages
> >> >> [  198.564616] 68239 pages in swap cache
> >> >> [  198.564622] Swap cache stats: add 466115, delete 397876, find 31817/56350
> >> >> [  198.564630] Free swap  = 1952336kB
> >> >> [  198.564635] Total swap = 3028768kB
> >> >> [  198.564640] xxcount_nr_reclaimed 358488
> >> >> [  198.564646] xxcount_nr_reclaims 6201
> >> >> [  198.564651] xxcount_aborted_reclaim 0
> >> >> [  198.564656] xxcount_more_to_do 5137
> >> >> [  198.564662] xxcount_direct_reclaims 17065
> >> >> [  198.564667] xxcount_failed_direct_reclaims 10708
> >> >> [  198.564673] xxcount_no_progress 5696
> >> >> [  198.564678] xxcount_restarts 5696
> >> >> [  198.564683] xxcount_should_alloc_retry 5008
> >> >> [  198.564688] xxcount_direct_compact 1
> >> >> [  198.564693] xxcount_alloc_failed 115
> >> >> [  198.564699] xxcount_gfp_nofail 0
> >> >> [  198.564704] xxcount_costly_order 5009
> >> >> [  198.564709] xxcount_repeat 0
> >> >> [  198.564714] xxcount_kswapd_nap 2210
> >> >> [  198.564719] xxcount_kswapd_sleep 17
> >> >> [  198.564724] xxcount_kswapd_loop 2211
> >> >> [  198.564729] xxcount_kswapd_try_to_sleep 2210
> >> >> [  198.575349] 524288 pages of RAM
> >> >> [  198.575358] 4420 free pages
> >> >> [  198.575365] 7122 reserved pages
> >> >> [  198.575371] 4091 slab pages
> >> >> [  198.575378] 302549 pages shared
> >> >> [  198.575384] 68239 pages swap cached
> >> >>
> >> >> --
> >> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> >> see: http://www.linux-mm.org/ .
> >> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >> >
> >> > --
> >> > Kind regards,
> >> > Minchan Kim
> >
> > --
> > Kind Regards,
> > Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
