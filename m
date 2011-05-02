Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8B64790010C
	for <linux-mm@kvack.org>; Mon,  2 May 2011 06:30:23 -0400 (EDT)
Date: Mon, 2 May 2011 18:29:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation
 failures
Message-ID: <20110502102945.GA7688@localhost>
References: <20110426062535.GB19717@localhost>
 <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
 <20110426063421.GC19717@localhost>
 <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
 <20110426092029.GA27053@localhost>
 <20110426124743.e58d9746.akpm@linux-foundation.org>
 <20110428133644.GA12400@localhost>
 <20110429022824.GA8061@localhost>
 <20110430141741.GA4511@localhost>
 <20110501163542.GA3204@barrios-desktop>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
Content-Disposition: inline
In-Reply-To: <20110501163542.GA3204@barrios-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Li Shaohua <shaohua.li@intel.com>, Hugh Dickins <hughd@google.com>


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Minchan,

On Mon, May 02, 2011 at 12:35:42AM +0800, Minchan Kim wrote:
> Hi Wu,
> 
> On Sat, Apr 30, 2011 at 10:17:41PM +0800, Wu Fengguang wrote:
> > On Fri, Apr 29, 2011 at 10:28:24AM +0800, Wu Fengguang wrote:
> > > > Test results:
> > > >
> > > > - the failure rate is pretty sensible to the page reclaim size,
> > > >   from 282 (WMARK_HIGH) to 704 (WMARK_MIN) to 10496 (SWAP_CLUSTER_MAX)
> > > >
> > > > - the IPIs are reduced by over 100 times
> > >
> > > It's reduced by 500 times indeed.
> > >
> > > CAL:     220449     220246     220372     220558     220251     219740     220043     219968   Function call interrupts
> > > CAL:         93        463        410        540        298        282        272        306   Function call interrupts
> > >
> > > > base kernel: vanilla 2.6.39-rc3 + __GFP_NORETRY readahead page allocation patch
> > > > -------------------------------------------------------------------------------
> > > > nr_alloc_fail 10496
> > > > allocstall 1576602
> > >
> > > > patched (WMARK_MIN)
> > > > -------------------
> > > > nr_alloc_fail 704
> > > > allocstall 105551
> > >
> > > > patched (WMARK_HIGH)
> > > > --------------------
> > > > nr_alloc_fail 282
> > > > allocstall 53860
> > >
> > > > this patch (WMARK_HIGH, limited scan)
> > > > -------------------------------------
> > > > nr_alloc_fail 276
> > > > allocstall 54034
> > >
> > > There is a bad side effect though: the much reduced "allocstall" means
> > > each direct reclaim will take much more time to complete. A simple solution
> > > is to terminate direct reclaim after 10ms. I noticed that an 100ms
> > > time threshold can reduce the reclaim latency from 621ms to 358ms.
> > > Further lowering the time threshold to 20ms does not help reducing the
> > > real latencies though.
> >
> > Experiments going on...
> >
> > I tried the more reasonable terminate condition: stop direct reclaim
> > when the preferred zone is above high watermark (see the below chunk).
> >
> > This helps reduce the average reclaim latency to under 100ms in the
> > 1000-dd case.
> >
> > However nr_alloc_fail is around 5000 and not ideal. The interesting
> > thing is, even if zone watermark is high, the task still may fail to
> > get a free page..
> >
> > @@ -2067,8 +2072,17 @@ static unsigned long do_try_to_free_page
> >                         }
> >                 }
> >                 total_scanned += sc->nr_scanned;
> > -               if (sc->nr_reclaimed >= sc->nr_to_reclaim)
> > -                       goto out;
> > +               if (sc->nr_reclaimed >= min_reclaim) {
> > +                       if (sc->nr_reclaimed >= sc->nr_to_reclaim)
> > +                               goto out;
> > +                       if (total_scanned > 2 * sc->nr_to_reclaim)
> > +                               goto out;
> > +                       if (preferred_zone &&
> > +                           zone_watermark_ok_safe(preferred_zone, sc->order,
> > +                                       high_wmark_pages(preferred_zone),
> > +                                       zone_idx(preferred_zone), 0))
> > +                               goto out;
> > +               }
> >
> >                 /*
> >                  * Try to write back as many pages as we just scanned.  This
> >
> > Thanks,
> > Fengguang
> > ---
> > Subject: mm: cut down __GFP_NORETRY page allocation failures
> > Date: Thu Apr 28 13:46:39 CST 2011
> >
> > Concurrent page allocations are suffering from high failure rates.
> >
> > On a 8p, 3GB ram test box, when reading 1000 sparse files of size 1GB,
> > the page allocation failures are
> >
> > nr_alloc_fail 733     # interleaved reads by 1 single task
> > nr_alloc_fail 11799   # concurrent reads by 1000 tasks
> >
> > The concurrent read test script is:
> >
> >       for i in `seq 1000`
> >       do
> >               truncate -s 1G /fs/sparse-$i
> >               dd if=/fs/sparse-$i of=/dev/null &
> >       done
> >
> > In order for get_page_from_freelist() to get free page,
> >
> > (1) try_to_free_pages() should use much higher .nr_to_reclaim than the
> >     current SWAP_CLUSTER_MAX=32, in order to draw the zone out of the
> >     possible low watermark state as well as fill the pcp with enough free
> >     pages to overflow its high watermark.
> >
> > (2) the get_page_from_freelist() _after_ direct reclaim should use lower
> >     watermark than its normal invocations, so that it can reasonably
> >     "reserve" some free pages for itself and prevent other concurrent
> >     page allocators stealing all its reclaimed pages.
> 
> Do you see my old patch? The patch want't incomplet but it's not bad for showing an idea.
> http://marc.info/?l=linux-mm&m=129187231129887&w=4
> The idea is to keep a page at leat for direct reclaimed process.
> Could it mitigate your problem or could you enhacne the idea?
> I think it's very simple and fair solution.

No it's not helping my problem, nr_alloc_fail and CAL are still high:

root@fat /home/wfg# ./test-dd-sparse.sh
start time: 246
total time: 531
nr_alloc_fail 14097
allocstall 1578332
LOC:     542698     538947     536986     567118     552114     539605     541201     537623   Local timer interrupts
RES:       3368       1908       1474       1476       2809       1602       1500       1509   Rescheduling interrupts
CAL:     223844     224198     224268     224436     223952     224056     223700     223743   Function call interrupts
TLB:        381         27         22         19         96        404        111         67   TLB shootdowns

root@fat /home/wfg# getdelays -dip `pidof dd`
print delayacct stats ON
printing IO accounting
PID     5202


CPU             count     real total  virtual total    delay total
                 1132     3635447328     3627947550   276722091605
IO              count    delay total  delay average
                    2      187809974             62ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                 1334    35304580824             26ms
dd: read=278528, write=0, cancelled_write=0

I guess your patch is mainly fixing the high order allocations while
my workload is mainly order 0 readahead page allocations. There are
1000 forks, however the "start time: 246" seems to indicate that the
order-1 reclaim latency is not improved.

I'll try modifying your patch and see how it works out. The obvious
change is to apply it to the order-0 case. Hope this won't create much
more isolated pages.

Attached is your patch rebased to 2.6.39-rc3, after resolving some
merge conflicts and fixing a trivial NULL pointer bug.

> >
> > Some notes:
> >
> > - commit 9ee493ce ("mm: page allocator: drain per-cpu lists after direct
> >   reclaim allocation fails") has the same target, however is obviously
> >   costly and less effective. It seems more clean to just remove the
> >   retry and drain code than to retain it.
> 
> Tend to agree.
> My old patch can solve it, I think.

Sadly nope. See above.

> >
> > - it's a bit hacky to reclaim more than requested pages inside
> >   do_try_to_free_page(), and it won't help cgroup for now
> >
> > - it only aims to reduce failures when there are plenty of reclaimable
> >   pages, so it stops the opportunistic reclaim when scanned 2 times pages
> >
> > Test results:
> >
> > - the failure rate is pretty sensible to the page reclaim size,
> >   from 282 (WMARK_HIGH) to 704 (WMARK_MIN) to 10496 (SWAP_CLUSTER_MAX)
> >
> > - the IPIs are reduced by over 100 times
> >
> > base kernel: vanilla 2.6.39-rc3 + __GFP_NORETRY readahead page allocation patch
> > -------------------------------------------------------------------------------
> > nr_alloc_fail 10496
> > allocstall 1576602
> >
> > slabs_scanned 21632
> > kswapd_steal 4393382
> > kswapd_inodesteal 124
> > kswapd_low_wmark_hit_quickly 885
> > kswapd_high_wmark_hit_quickly 2321
> > kswapd_skip_congestion_wait 0
> > pageoutrun 29426
> >
> > CAL:     220449     220246     220372     220558     220251     219740     220043     219968   Function call interrupts
> >
> > LOC:     536274     532529     531734     536801     536510     533676     534853     532038   Local timer interrupts
> > RES:       3032       2128       1792       1765       2184       1703       1754       1865   Rescheduling interrupts
> > TLB:        189         15         13         17         64        294         97         63   TLB shootdowns
> >
> > patched (WMARK_MIN)
> > -------------------
> > nr_alloc_fail 704
> > allocstall 105551
> >
> > slabs_scanned 33280
> > kswapd_steal 4525537
> > kswapd_inodesteal 187
> > kswapd_low_wmark_hit_quickly 4980
> > kswapd_high_wmark_hit_quickly 2573
> > kswapd_skip_congestion_wait 0
> > pageoutrun 35429
> >
> > CAL:         93        286        396        754        272        297        275        281   Function call interrupts
> >
> > LOC:     520550     517751     517043     522016     520302     518479     519329     517179   Local timer interrupts
> > RES:       2131       1371       1376       1269       1390       1181       1409       1280   Rescheduling interrupts
> > TLB:        280         26         27         30         65        305        134         75   TLB shootdowns
> >
> > patched (WMARK_HIGH)
> > --------------------
> > nr_alloc_fail 282
> > allocstall 53860
> >
> > slabs_scanned 23936
> > kswapd_steal 4561178
> > kswapd_inodesteal 0
> > kswapd_low_wmark_hit_quickly 2760
> > kswapd_high_wmark_hit_quickly 1748
> > kswapd_skip_congestion_wait 0
> > pageoutrun 32639
> >
> > CAL:         93        463        410        540        298        282        272        306   Function call interrupts
> >
> > LOC:     513956     510749     509890     514897     514300     512392     512825     510574   Local timer interrupts
> > RES:       1174       2081       1411       1320       1742       2683       1380       1230   Rescheduling interrupts
> > TLB:        274         21         19         22         57        317        131         61   TLB shootdowns
> >
> > patched (WMARK_HIGH, limited scan)
> > ----------------------------------
> > nr_alloc_fail 276
> > allocstall 54034
> >
> > slabs_scanned 24320
> > kswapd_steal 4507482
> > kswapd_inodesteal 262
> > kswapd_low_wmark_hit_quickly 2638
> > kswapd_high_wmark_hit_quickly 1710
> > kswapd_skip_congestion_wait 0
> > pageoutrun 32182
> >
> > CAL:         69        443        421        567        273        279        269        334   Function call interrupts
> 
> Looks amazing.

Yeah, I have strong feelings against drain_all_pages() in the direct
reclaim path. The intuition is, once drain_all_pages() is called, the 
later on direct reclaims will have less chance to fill the drained
buffers and therefore forced into drain_all_pages() again and again.

drain_all_pages() is probably an overkill for preventing OOM.
Generally speaking, it's questionable to "squeeze the last page before
OOM".

A typical desktop enters thrashing storms before OOM, as Hugh pointed
out, this may well not the end users wanted. I agree with him and
personally prefer some applications to be OOM killed rather than the
whole system goes unusable thrashing like mad.

> > LOC:     514736     511698     510993     514069     514185     512986     513838     511229   Local timer interrupts
> > RES:       2153       1556       1126       1351       3047       1554       1131       1560   Rescheduling interrupts
> > TLB:        209         26         20         15         71        315        117         71   TLB shootdowns
> >
> > patched (WMARK_HIGH, limited scan, stop on watermark OK), 100 dd
> > ----------------------------------------------------------------
> >
> > start time: 3
> > total time: 50
> > nr_alloc_fail 162
> > allocstall 45523
> >
> > CPU             count     real total  virtual total    delay total
> >                   921     3024540200     3009244668    37123129525
> > IO              count    delay total  delay average
> >                     0              0              0ms
> > SWAP            count    delay total  delay average
> >                     0              0              0ms
> > RECLAIM         count    delay total  delay average
> >                   357     4891766796             13ms
> > dd: read=0, write=0, cancelled_write=0
> >
> > patched (WMARK_HIGH, limited scan, stop on watermark OK), 1000 dd
> > -----------------------------------------------------------------
> >
> > start time: 272
> > total time: 509
> > nr_alloc_fail 3913
> > allocstall 541789
> >
> > CPU             count     real total  virtual total    delay total
> >                  1044     3445476208     3437200482   229919915202
> > IO              count    delay total  delay average
> >                     0              0              0ms
> > SWAP            count    delay total  delay average
> >                     0              0              0ms
> > RECLAIM         count    delay total  delay average
> >                   452    34691441605             76ms
> > dd: read=0, write=0, cancelled_write=0
> >
> > patched (WMARK_HIGH, limited scan, stop on watermark OK, no time limit), 1000 dd
> > --------------------------------------------------------------------------------
> >
> > start time: 278
> > total time: 513
> > nr_alloc_fail 4737
> > allocstall 436392
> >
> >
> > CPU             count     real total  virtual total    delay total
> >                  1024     3371487456     3359441487   225088210977
> > IO              count    delay total  delay average
> >                     1      160631171            160ms
> > SWAP            count    delay total  delay average
> >                     0              0              0ms
> > RECLAIM         count    delay total  delay average
> >                   367    30809994722             83ms
> > dd: read=20480, write=0, cancelled_write=0
> >
> >
> > no cond_resched():
> 
> What's this?

I tried a modified patch that also removes the cond_resched() call in
__alloc_pages_direct_reclaim(), between try_to_free_pages() and
get_page_from_freelist(). It seems not helping noticeably.

It looks safe to remove that cond_resched() as we already have such
calls in shrink_page_list().

> >
> > start time: 263
> > total time: 516
> > nr_alloc_fail 5144
> > allocstall 436787
> >
> > CPU             count     real total  virtual total    delay total
> >                  1018     3305497488     3283831119   241982934044
> > IO              count    delay total  delay average
> >                     0              0              0ms
> > SWAP            count    delay total  delay average
> >                     0              0              0ms
> > RECLAIM         count    delay total  delay average
> >                   328    31398481378             95ms
> > dd: read=0, write=0, cancelled_write=0
> >
> > zone_watermark_ok_safe():
> >
> > start time: 266
> > total time: 513
> > nr_alloc_fail 4526
> > allocstall 440246
> >
> > CPU             count     real total  virtual total    delay total
> >                  1119     3640446568     3619184439   240945024724
> > IO              count    delay total  delay average
> >                     3      303620082            101ms
> > SWAP            count    delay total  delay average
> >                     0              0              0ms
> > RECLAIM         count    delay total  delay average
> >                   372    27320731898             73ms
> > dd: read=77824, write=0, cancelled_write=0
> >

> > start time: 275
> 
> What's meaing of start time?

It's the time taken to start 1000 dd's.
 
> > total time: 517
> 
> Total time is elapsed time on your experiment?

Yeah. They are generated with this script.

$ cat ~/bin/test-dd-sparse.sh
 
#!/bin/sh

mount /dev/sda7 /fs

tic=$(date +'%s')

for i in `seq 1000`
do
	truncate -s 1G /fs/sparse-$i
	dd if=/fs/sparse-$i of=/dev/null &>/dev/null &
done

tac=$(date +'%s')
echo start time: $((tac-tic))

wait

tac=$(date +'%s')
echo total time: $((tac-tic))

egrep '(nr_alloc_fail|allocstall)' /proc/vmstat
egrep '(CAL|RES|LOC|TLB)' /proc/interrupts

> > nr_alloc_fail 4694
> > allocstall 431021
> >
> >
> > CPU             count     real total  virtual total    delay total
> >                  1073     3534462680     3512544928   234056498221
> 
> What's meaning of CPU fields?

It's "waiting for a CPU (while being runnable)" as described in
Documentation/accounting/delay-accounting.txt.

> > IO              count    delay total  delay average
> >                     0              0              0ms
> > SWAP            count    delay total  delay average
> >                     0              0              0ms
> > RECLAIM         count    delay total  delay average
> >                   386    34751778363             89ms
> > dd: read=0, write=0, cancelled_write=0
> >
> 
> Where is vanilla data for comparing latency?
> Personally, It's hard to parse your data.

Sorry it's somehow too much data and kernel revisions.. The base kernel's
average latency is 29ms:

base kernel: vanilla 2.6.39-rc3 + __GFP_NORETRY readahead page allocation patch
-------------------------------------------------------------------------------

CPU             count     real total  virtual total    delay total
                 1122     3676441096     3656793547   274182127286
IO              count    delay total  delay average
                    3      291765493             97ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                 1350    39229752193             29ms
dd: read=45056, write=0, cancelled_write=0

start time: 245
total time: 526
nr_alloc_fail 14586
allocstall 1578343
LOC:     533981     529210     528283     532346     533392     531314     531705     528983   Local timer interrupts
RES:       3123       2177       1676       1580       2157       1974       1606       1696   Rescheduling interrupts
CAL:     218392     218631     219167     219217     218840     218985     218429     218440   Function call interrupts
TLB:        175         13         21         18         62        309        119         42   TLB shootdowns

> 
> > CC: Mel Gorman <mel@linux.vnet.ibm.com>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  fs/buffer.c          |    4 ++--
> >  include/linux/swap.h |    3 ++-
> >  mm/page_alloc.c      |   20 +++++---------------
> >  mm/vmscan.c          |   31 +++++++++++++++++++++++--------
> >  4 files changed, 32 insertions(+), 26 deletions(-)
> > --- linux-next.orig/mm/vmscan.c       2011-04-29 10:42:14.000000000 +0800
> > +++ linux-next/mm/vmscan.c    2011-04-30 21:59:33.000000000 +0800
> > @@ -2025,8 +2025,9 @@ static bool all_unreclaimable(struct zon
> >   * returns:  0, if no pages reclaimed
> >   *           else, the number of pages reclaimed
> >   */
> > -static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
> > -                                     struct scan_control *sc)
> > +static unsigned long do_try_to_free_pages(struct zone *preferred_zone,
> > +                                       struct zonelist *zonelist,
> > +                                       struct scan_control *sc)
> >  {
> >       int priority;
> >       unsigned long total_scanned = 0;
> > @@ -2034,6 +2035,7 @@ static unsigned long do_try_to_free_page
> >       struct zoneref *z;
> >       struct zone *zone;
> >       unsigned long writeback_threshold;
> > +     unsigned long min_reclaim = sc->nr_to_reclaim;
> 
> Hmm,
> 
> >
> >       get_mems_allowed();
> >       delayacct_freepages_start();
> > @@ -2041,6 +2043,9 @@ static unsigned long do_try_to_free_page
> >       if (scanning_global_lru(sc))
> >               count_vm_event(ALLOCSTALL);
> >
> > +     if (preferred_zone)
> > +             sc->nr_to_reclaim += preferred_zone->watermark[WMARK_HIGH];
> > +
> 
> Hmm, I don't like this idea.
> The goal of direct reclaim path is to reclaim pages asap, I beleive.
> Many thing should be achieve of background kswapd.
> If admin changes min_free_kbytes, it can affect latency of direct reclaim.
> It doesn't make sense to me.

Yeah, it does increase delays.. in the 1000 dd case, roughly from 30ms
to 90ms. This is a major drawback.

> >       for (priority = DEF_PRIORITY; priority >= 0; priority--) {
> >               sc->nr_scanned = 0;
> >               if (!priority)
> > @@ -2067,8 +2072,17 @@ static unsigned long do_try_to_free_page
> >                       }
> >               }
> >               total_scanned += sc->nr_scanned;
> > -             if (sc->nr_reclaimed >= sc->nr_to_reclaim)
> > -                     goto out;
> > +             if (sc->nr_reclaimed >= min_reclaim) {
> > +                     if (sc->nr_reclaimed >= sc->nr_to_reclaim)
> > +                             goto out;
> 
> I can't understand the logic.
> if nr_reclaimed is bigger than min_reclaim, it's always greater than
> nr_to_reclaim. What's meaning of min_reclaim?

In direct reclaim, min_reclaim will be the legacy SWAP_CLUSTER_MAX and
sc->nr_to_reclaim will be increased to the zone's high watermark and
is kind of "max to reclaim".

> 
> > +                     if (total_scanned > 2 * sc->nr_to_reclaim)
> > +                             goto out;
> 
> If there are lots of dirty pages in LRU?
> If there are lots of unevictable pages in LRU?
> If there are lots of mapped page in LRU but may_unmap = 0 cases?
> I means it's rather risky early conclusion.

That test means to avoid scanning too much on __GFP_NORETRY direct
reclaims. My assumption for __GFP_NORETRY is, it should fail fast when
the LRU pages seem hard to reclaim. And the problem in the 1000 dd
case is, it's all easy to reclaim LRU pages but __GFP_NORETRY still
fails from time to time, with lots of IPIs that may hurt large
machines a lot.

> 
> > +                     if (preferred_zone &&
> > +                         zone_watermark_ok_safe(preferred_zone, sc->order,
> > +                                     high_wmark_pages(preferred_zone),
> > +                                     zone_idx(preferred_zone), 0))
> > +                             goto out;
> > +             }
> 
> As I said, I think direct reclaim path sould be fast if possbile and
> it should not a function of min_free_kbytes.

Right.

> Of course, there are lots of tackle for keep direct reclaim path's consistent
> latency but at least, I don't want to add another source.

OK.

Thanks,
Fengguang

--GvXjxJ+pjyke8COw
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="mm-keep-freed-pages-in-direct-reclaim.patch"

Subject: Keep freed pages in direct reclaim
Date: Thu, 9 Dec 2010 14:01:32 +0900

From: Minchan Kim <minchan.kim@gmail.com>

direct reclaimed process often sleep and race with other processes.
Although direct reclaim proceess requires high order pags(order > 0) and
reclaims page successfully, other processes which require order-0 page
could steal the high order page for direct reclaimed process.

After all, direct reclaimed process try it again and it still has a
possibility of above scenario. It can make bad effects following as

1. direct reclaimed process latency is big
2. eviction working set page due to lumpy reclaim
3. continue to wake up kswapd

This patch solves it.

Fengguang:
fix 
[ 1514.892933] BUG: unable to handle kernel
[ 1514.892958] ---[ end trace be7cb17861e1d25b ]---
[ 1514.893589] NULL pointer dereference at           (null)
[ 1514.893968] IP: [<ffffffff81101b2e>] shrink_page_list+0x3dc/0x501

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/buffer.c          |    2 +-
 include/linux/swap.h |    4 +++-
 mm/page_alloc.c      |   27 +++++++++++++++++++++++----
 mm/vmscan.c          |   23 +++++++++++++++++++----
 4 files changed, 46 insertions(+), 10 deletions(-)

--- linux-next.orig/fs/buffer.c	2011-05-02 10:34:06.000000000 +0800
+++ linux-next/fs/buffer.c	2011-05-02 10:45:24.000000000 +0800
@@ -289,7 +289,7 @@ static void free_more_memory(void)
 						&zone);
 		if (zone)
 			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
-						GFP_NOFS, NULL);
+						GFP_NOFS, NULL, NULL);
 	}
 }
 
--- linux-next.orig/include/linux/swap.h	2011-05-02 10:34:06.000000000 +0800
+++ linux-next/include/linux/swap.h	2011-05-02 10:45:24.000000000 +0800
@@ -249,8 +249,10 @@ static inline void lru_cache_add_file(st
 #define ISOLATE_BOTH 2		/* Isolate both active and inactive pages. */
 
 /* linux/mm/vmscan.c */
+extern noinline_for_stack void free_page_list(struct list_head *free_pages);
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-					gfp_t gfp_mask, nodemask_t *mask);
+					gfp_t gfp_mask, nodemask_t *mask,
+					struct list_head *freed_pages);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 						  gfp_t gfp_mask, bool noswap,
 						  unsigned int swappiness);
--- linux-next.orig/mm/page_alloc.c	2011-05-02 10:34:06.000000000 +0800
+++ linux-next/mm/page_alloc.c	2011-05-02 10:45:26.000000000 +0800
@@ -1890,8 +1890,11 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
 {
 	struct page *page = NULL;
 	struct reclaim_state reclaim_state;
+	bool high_order;
 	bool drained = false;
+	LIST_HEAD(freed_pages);
 
+	high_order = order ? true : false;
 	cond_resched();
 
 	/* We now go into synchronous reclaim */
@@ -1901,16 +1904,31 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
 	reclaim_state.reclaimed_slab = 0;
 	current->reclaim_state = &reclaim_state;
 
-	*did_some_progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
-
+	/*
+	 * If request is high order, keep the pages which are reclaimed
+	 * in own list for preventing the lose by other processes.
+	 */
+	*did_some_progress = try_to_free_pages(zonelist, order, gfp_mask,
+				nodemask, high_order ? &freed_pages : NULL);
 	current->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();
 	current->flags &= ~PF_MEMALLOC;
 
+	if (high_order && !list_empty(&freed_pages)) {
+		free_page_list(&freed_pages);
+		drain_all_pages();
+		drained = true;
+		page = get_page_from_freelist(gfp_mask, nodemask, order,
+					zonelist, high_zoneidx,
+					alloc_flags, preferred_zone,
+					migratetype);
+		if (page)
+			goto out;
+	}
 	cond_resched();
 
 	if (unlikely(!(*did_some_progress)))
-		return NULL;
+		goto out;
 
 retry:
 	page = get_page_from_freelist(gfp_mask, nodemask, order,
@@ -1927,7 +1945,8 @@ retry:
 		drained = true;
 		goto retry;
 	}
-
+out:
+	VM_BUG_ON(!list_empty(&freed_pages));
 	return page;
 }
 
--- linux-next.orig/mm/vmscan.c	2011-05-02 10:34:06.000000000 +0800
+++ linux-next/mm/vmscan.c	2011-05-02 10:46:31.000000000 +0800
@@ -112,6 +112,9 @@ struct scan_control {
 	 * are scanned.
 	 */
 	nodemask_t	*nodemask;
+
+	/* keep freed pages */
+	struct list_head *freed_pages;
 };
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
@@ -681,7 +684,7 @@ static enum page_references page_check_r
 	return PAGEREF_RECLAIM;
 }
 
-static noinline_for_stack void free_page_list(struct list_head *free_pages)
+noinline_for_stack void free_page_list(struct list_head *free_pages)
 {
 	struct pagevec freed_pvec;
 	struct page *page, *tmp;
@@ -712,6 +715,10 @@ static unsigned long shrink_page_list(st
 	unsigned long nr_dirty = 0;
 	unsigned long nr_congested = 0;
 	unsigned long nr_reclaimed = 0;
+	struct list_head *free_list = &free_pages;
+
+	if (sc->freed_pages)
+		free_list = sc->freed_pages;
 
 	cond_resched();
 
@@ -904,7 +911,7 @@ free_it:
 		 * Is there need to periodically free_page_list? It would
 		 * appear not as the counts should be low
 		 */
-		list_add(&page->lru, &free_pages);
+		list_add(&page->lru, free_list);
 		continue;
 
 cull_mlocked:
@@ -940,7 +947,13 @@ keep_lumpy:
 	if (nr_dirty == nr_congested && nr_dirty != 0)
 		zone_set_flag(zone, ZONE_CONGESTED);
 
-	free_page_list(&free_pages);
+	/*
+	 * If reclaim is direct path and high order, caller should
+	 * free reclaimed pages. It is for preventing reclaimed pages
+	 * lose by other processes.
+	 */
+	if (!sc->freed_pages)
+		free_page_list(&free_pages);
 
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
@@ -2118,7 +2131,8 @@ out:
 }
 
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-				gfp_t gfp_mask, nodemask_t *nodemask)
+				gfp_t gfp_mask, nodemask_t *nodemask,
+				struct list_head *freed_pages)
 {
 	unsigned long nr_reclaimed;
 	struct scan_control sc = {
@@ -2131,6 +2145,7 @@ unsigned long try_to_free_pages(struct z
 		.order = order,
 		.mem_cgroup = NULL,
 		.nodemask = nodemask,
+		.freed_pages = freed_pages,
 	};
 
 	trace_mm_vmscan_direct_reclaim_begin(order,

--GvXjxJ+pjyke8COw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
