Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6730F6B004D
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 10:22:15 -0400 (EDT)
Date: Sun, 28 Jun 2009 22:22:40 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Found the commit that causes the OOMs
Message-ID: <20090628142239.GA20986@localhost>
References: <32411.1245336412@redhat.com> <20090517022327.280096109@intel.com> <2015.1245341938@redhat.com> <20090618095729.d2f27896.akpm@linux-foundation.org> <7561.1245768237@redhat.com> <26537.1246086769@redhat.com> <20090627125412.GA1667@cmpxchg.org> <20090628113246.GA18409@localhost> <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com> <28c262360906280636l93130ffk14086314e2a6dcb7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360906280636l93130ffk14086314e2a6dcb7@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 28, 2009 at 09:36:49PM +0800, Minchan Kim wrote:
> On Sun, Jun 28, 2009 at 10:30 PM, Minchan Kim<minchan.kim@gmail.com> wrote:
> > HI, Wu.
> >
> > On Sun, Jun 28, 2009 at 8:32 PM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> >> On Sat, Jun 27, 2009 at 08:54:12PM +0800, Johannes Weiner wrote:
> >>> On Sat, Jun 27, 2009 at 08:12:49AM +0100, David Howells wrote:
> >>> >
> >>> > I've managed to bisect things to find the commit that causes the OOMs. A It's:
> >>> >
> >>> > A  A  commit 69c854817566db82c362797b4a6521d0b00fe1d8
> >>> > A  A  Author: MinChan Kim <minchan.kim@gmail.com>
> >>> > A  A  Date: A  Tue Jun 16 15:32:44 2009 -0700
> >>> >
> >>> > A  A  A  A  vmscan: prevent shrinking of active anon lru list in case of no swap space V3
> >>> >
> >>> > A  A  A  A  shrink_zone() can deactivate active anon pages even if we don't have a
> >>> > A  A  A  A  swap device. A Many embedded products don't have a swap device. A So the
> >>> > A  A  A  A  deactivation of anon pages is unnecessary.
> >>> >
> >>> > A  A  A  A  This patch prevents unnecessary deactivation of anon lru pages. A But, it
> >>> > A  A  A  A  don't prevent aging of anon pages to swap out.
> >>> >
> >>> > A  A  A  A  Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> >>> > A  A  A  A  Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >>> > A  A  A  A  Cc: Johannes Weiner <hannes@cmpxchg.org>
> >>> > A  A  A  A  Acked-by: Rik van Riel <riel@redhat.com>
> >>> > A  A  A  A  Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> >>> > A  A  A  A  Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> >>> >
> >>> > This exhibits the problem. A The previous commit:
> >>> >
> >>> > A  A  commit 35282a2de4e5e4e173ab61aa9d7015886021a821
> >>> > A  A  Author: Brice Goglin <Brice.Goglin@ens-lyon.org>
> >>> > A  A  Date: A  Tue Jun 16 15:32:43 2009 -0700
> >>> >
> >>> > A  A  A  A  migration: only migrate_prep() once per move_pages()
> >>> >
> >>> > survives 16 iterations of the LTP syscall testsuite without exhibiting the
> >>> > problem.
> >>>
> >>> Here is the patch in question:
> >>>
> >>> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >>> index 7592d8e..879d034 100644
> >>> --- a/mm/vmscan.c
> >>> +++ b/mm/vmscan.c
> >>> @@ -1570,7 +1570,7 @@ static void shrink_zone(int priority, struct zone *zone,
> >>> A  A  A  A * Even if we did not try to evict anon pages at all, we want to
> >>> A  A  A  A * rebalance the anon lru active/inactive ratio.
> >>> A  A  A  A */
> >>> - A  A  if (inactive_anon_is_low(zone, sc))
> >>> + A  A  if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
> >>> A  A  A  A  A  A  A  shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
> >>>
> >>> A  A  A  throttle_vm_writeout(sc->gfp_mask);
> >>>
> >>> When this was discussed, I think we missed that nr_swap_pages can
> >>> actually get zero on swap systems as well and this should have been
> >>> total_swap_pages - otherwise we also stop balancing the two anon lists
> >>> when swap is _full_ which was not the intention of this change at all.
> >>
> >> Exactly. In Jesse's OOM case, the swap is exhausted.
> >> total_swap_pages is the better choice in this situation.
> >>
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426766] Active_anon:290797 active_file:28 inactive_anon:97034
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426767] A inactive_file:61 unevictable:11322 dirty:0 writeback:0 unstable:0
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426768] A free:3341 slab:13776 mapped:5880 pagetables:6851 bounce:0
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426772] DMA free:7776kB min:40kB low:48kB high:60kB active_anon:556kB inactive_anon:524kB
> >> +active_file:16kB inactive_file:0kB unevictable:0kB present:15340kB pages_scanned:30 all_unreclaimable? no
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426775] lowmem_reserve[]: 0 1935 1935 1935
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426781] DMA32 free:5588kB min:5608kB low:7008kB high:8412kB active_anon:1162632kB
> >> +inactive_anon:387612kB active_file:96kB inactive_file:256kB unevictable:45288kB present:1982128kB pages_scanned:980
> >> +all_unreclaimable? no
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426784] lowmem_reserve[]: 0 0 0 0
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426787] DMA: 64*4kB 77*8kB 45*16kB 18*32kB 4*64kB 2*128kB 2*256kB 3*512kB 1*1024kB
> >> +1*2048kB 0*4096kB = 7800kB
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426796] DMA32: 871*4kB 149*8kB 1*16kB 2*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB
> >> +0*2048kB 0*4096kB = 5588kB
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426804] 151250 total pagecache pages
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426806] 18973 pages in swap cache
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426808] Swap cache stats: add 610640, delete 591667, find 144356/181468
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426810] Free swap A = 0kB
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.426811] Total swap = 979956kB
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.434828] 507136 pages RAM
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.434831] 23325 pages reserved
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.434832] 190892 pages shared
> >> Jun 18 07:44:53 jbarnes-g45 kernel: [64377.434833] 248816 pages non-shared
> >>
> >>
> >> In David's OOM case, there are two symptoms:
> >> 1) 70000 unaccounted/leaked pages as found by Andrew
> >> A  (plus rather big number of PG_buddy and pagetable pages)
> >> 2) almost zero active_file/inactive_file; small inactive_anon;
> >> A  many slab and active_anon pages.
> >>
> >> In the situation of (2), the slab cache is _under_ scanned. So David
> >> got OOM when vmscan should have squeezed some free pages from the slab
> >> cache. Which is one important side effect of MinChan's patch?
> >
> > My patch's side effect is (2).
> >
> > My guessing is following as.
> >
> > 1. The number of page scanned in shrink_slab is increased in shrink_page_list.
> > And it is doubled for mapped page or swapcache.
> > 2. shrink_page_list is called by shrink_inactive_list
> > 3. shrink_inactive_list is called by shrink_list
> >
> > Look at the shrink_list.
> > If inactive lru list is low, it always call shrink_active_list not
> > shrink_inactive_list in case of anon.
> 
> I missed most important point.
> My patch's side effect is that it keeps inactive anon's lru low.
> So I think it is caused by my patch's side effect.

Yes, smaller inactive_anon means smaller (pointless) nr_scanned,
and therefore less slab scans. Strictly speaking, it's not the fault
of your patch. It indicates that the slab scan ratio algorithm should
be updated too :)

We could refine the estimation of "reclaimable" pages like this:

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 416f748..e9c5b0e 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -167,14 +167,7 @@ static inline unsigned long zone_page_state(struct zone *zone,
 }
 
 extern unsigned long global_lru_pages(void);
-
-static inline unsigned long zone_lru_pages(struct zone *zone)
-{
-	return (zone_page_state(zone, NR_ACTIVE_ANON)
-		+ zone_page_state(zone, NR_ACTIVE_FILE)
-		+ zone_page_state(zone, NR_INACTIVE_ANON)
-		+ zone_page_state(zone, NR_INACTIVE_FILE));
-}
+extern unsigned long zone_lru_pages(void);
 
 #ifdef CONFIG_NUMA
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 026f452..4281c6f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2123,10 +2123,31 @@ void wakeup_kswapd(struct zone *zone, int order)
 
 unsigned long global_lru_pages(void)
 {
-	return global_page_state(NR_ACTIVE_ANON)
-		+ global_page_state(NR_ACTIVE_FILE)
-		+ global_page_state(NR_INACTIVE_ANON)
-		+ global_page_state(NR_INACTIVE_FILE);
+	int nr;
+
+	nr = global_page_state(zone, NR_ACTIVE_FILE) +
+	     global_page_state(zone, NR_INACTIVE_FILE);
+
+	if (total_swap_pages)
+		nr += global_page_state(zone, NR_ACTIVE_ANON) +
+		      global_page_state(zone, NR_INACTIVE_ANON);
+
+	return nr;
+}
+
+
+unsigned long zone_lru_pages(struct zone *zone)
+{
+	int nr;
+
+	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
+	     zone_page_state(zone, NR_INACTIVE_FILE);
+
+	if (total_swap_pages)
+		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
+		      zone_page_state(zone, NR_INACTIVE_ANON);
+
+	return nr;
 }
 
 #ifdef CONFIG_HIBERNATION

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
