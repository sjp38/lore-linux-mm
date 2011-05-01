Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 01473900001
	for <linux-mm@kvack.org>; Sun,  1 May 2011 03:47:47 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 917D03EE0AE
	for <linux-mm@kvack.org>; Sun,  1 May 2011 16:47:44 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C0F545DE93
	for <linux-mm@kvack.org>; Sun,  1 May 2011 16:47:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 628D045DE91
	for <linux-mm@kvack.org>; Sun,  1 May 2011 16:47:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 553C1E08001
	for <linux-mm@kvack.org>; Sun,  1 May 2011 16:47:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 17DFC1DB8037
	for <linux-mm@kvack.org>; Sun,  1 May 2011 16:47:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mmotm 2011-04-29-16-25 uploaded
In-Reply-To: <20110430094616.1fd43735.rdunlap@xenotime.net>
References: <201104300002.p3U02Ma2026266@imap1.linux-foundation.org> <20110430094616.1fd43735.rdunlap@xenotime.net>
Message-Id: <20110501164918.75E0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Sun,  1 May 2011 16:47:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

> On Fri, 29 Apr 2011 16:26:16 -0700 akpm@linux-foundation.org wrote:
>=20
> > The mm-of-the-moment snapshot 2011-04-29-16-25 has been uploaded to
> >=20
> >    http://userweb.kernel.org/~akpm/mmotm/
> >=20
> > and will soon be available at
> >=20
> >    git://zen-kernel.org/kernel/mmotm.git
> >=20
> > It contains the following patches against 2.6.39-rc5:
>=20
>=20
> mm-per-node-vmstat-show-proper-vmstats.patch
>=20
> when CONFIG_PROC_FS is not enabled:
>=20
> drivers/built-in.o: In function `node_read_vmstat':
> node.c:(.text+0x1e995): undefined reference to `vmstat_text'
>=20
> from drivers/base/node.c


Thank you for finding that!



=46rom 63ad7c06f082f8423c033b9f54070e14d561db7e Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sun, 1 May 2011 16:00:09 +0900
Subject: [PATCH] vmstat: fix build error when SYSFS=3Dy and PROC_FS=3Dn

Randy Dunlap pointed out node.c makes build error when
PROC_FS=3Dn. Because node.c#node_read_vmstat() uses vmstat_text
and it depend on PROC_FS.

Thus, this patch change it to depend both SYSFS and PROC_FS.

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmstat.c |  261 ++++++++++++++++++++++++++++++-------------------------=
----
 1 files changed, 132 insertions(+), 129 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index a2b7344..20c18b7 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -659,6 +659,138 @@ static void walk_zones_in_node(struct seq_file *m, pg=
_data_t *pgdat,
 }
 #endif
=20
+#if defined(CONFIG_PROC_FS) || defined(CONFIG_SYSFS)
+#ifdef CONFIG_ZONE_DMA
+#define TEXT_FOR_DMA(xx) xx "_dma",
+#else
+#define TEXT_FOR_DMA(xx)
+#endif
+
+#ifdef CONFIG_ZONE_DMA32
+#define TEXT_FOR_DMA32(xx) xx "_dma32",
+#else
+#define TEXT_FOR_DMA32(xx)
+#endif
+
+#ifdef CONFIG_HIGHMEM
+#define TEXT_FOR_HIGHMEM(xx) xx "_high",
+#else
+#define TEXT_FOR_HIGHMEM(xx)
+#endif
+
+#define TEXTS_FOR_ZONES(xx) TEXT_FOR_DMA(xx) TEXT_FOR_DMA32(xx) xx "_norma=
l", \
+					TEXT_FOR_HIGHMEM(xx) xx "_movable",
+
+const char * const vmstat_text[] =3D {
+	/* Zoned VM counters */
+	"nr_free_pages",
+	"nr_inactive_anon",
+	"nr_active_anon",
+	"nr_inactive_file",
+	"nr_active_file",
+	"nr_unevictable",
+	"nr_mlock",
+	"nr_anon_pages",
+	"nr_mapped",
+	"nr_file_pages",
+	"nr_dirty",
+	"nr_writeback",
+	"nr_slab_reclaimable",
+	"nr_slab_unreclaimable",
+	"nr_page_table_pages",
+	"nr_kernel_stack",
+	"nr_unstable",
+	"nr_bounce",
+	"nr_vmscan_write",
+	"nr_writeback_temp",
+	"nr_isolated_anon",
+	"nr_isolated_file",
+	"nr_shmem",
+	"nr_dirtied",
+	"nr_written",
+
+#ifdef CONFIG_NUMA
+	"numa_hit",
+	"numa_miss",
+	"numa_foreign",
+	"numa_interleave",
+	"numa_local",
+	"numa_other",
+#endif
+	"nr_anon_transparent_hugepages",
+	"nr_dirty_threshold",
+	"nr_dirty_background_threshold",
+
+#ifdef CONFIG_VM_EVENT_COUNTERS
+	"pgpgin",
+	"pgpgout",
+	"pswpin",
+	"pswpout",
+
+	TEXTS_FOR_ZONES("pgalloc")
+
+	"pgfree",
+	"pgactivate",
+	"pgdeactivate",
+
+	"pgfault",
+	"pgmajfault",
+
+	TEXTS_FOR_ZONES("pgrefill")
+	TEXTS_FOR_ZONES("pgsteal")
+	TEXTS_FOR_ZONES("pgscan_kswapd")
+	TEXTS_FOR_ZONES("pgscan_direct")
+
+#ifdef CONFIG_NUMA
+	"zone_reclaim_failed",
+#endif
+	"pginodesteal",
+	"slabs_scanned",
+	"kswapd_steal",
+	"kswapd_inodesteal",
+	"kswapd_low_wmark_hit_quickly",
+	"kswapd_high_wmark_hit_quickly",
+	"kswapd_skip_congestion_wait",
+	"pageoutrun",
+	"allocstall",
+
+	"pgrotated",
+
+#ifdef CONFIG_COMPACTION
+	"compact_blocks_moved",
+	"compact_pages_moved",
+	"compact_pagemigrate_failed",
+	"compact_stall",
+	"compact_fail",
+	"compact_success",
+#endif
+
+#ifdef CONFIG_HUGETLB_PAGE
+	"htlb_buddy_alloc_success",
+	"htlb_buddy_alloc_fail",
+#endif
+	"unevictable_pgs_culled",
+	"unevictable_pgs_scanned",
+	"unevictable_pgs_rescued",
+	"unevictable_pgs_mlocked",
+	"unevictable_pgs_munlocked",
+	"unevictable_pgs_cleared",
+	"unevictable_pgs_stranded",
+	"unevictable_pgs_mlockfreed",
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	"thp_fault_alloc",
+	"thp_fault_fallback",
+	"thp_collapse_alloc",
+	"thp_collapse_alloc_failed",
+	"thp_split",
+#endif
+
+#endif /* CONFIG_VM_EVENTS_COUNTERS */
+};
+#endif /* CONFIG_PROC_FS || CONFIG_SYSFS */
+
+
 #ifdef CONFIG_PROC_FS
 static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 						struct zone *zone)
@@ -831,135 +963,6 @@ static const struct file_operations pagetypeinfo_file=
_ops =3D {
 	.release	=3D seq_release,
 };
=20
-#ifdef CONFIG_ZONE_DMA
-#define TEXT_FOR_DMA(xx) xx "_dma",
-#else
-#define TEXT_FOR_DMA(xx)
-#endif
-
-#ifdef CONFIG_ZONE_DMA32
-#define TEXT_FOR_DMA32(xx) xx "_dma32",
-#else
-#define TEXT_FOR_DMA32(xx)
-#endif
-
-#ifdef CONFIG_HIGHMEM
-#define TEXT_FOR_HIGHMEM(xx) xx "_high",
-#else
-#define TEXT_FOR_HIGHMEM(xx)
-#endif
-
-#define TEXTS_FOR_ZONES(xx) TEXT_FOR_DMA(xx) TEXT_FOR_DMA32(xx) xx "_norma=
l", \
-					TEXT_FOR_HIGHMEM(xx) xx "_movable",
-
-const char * const vmstat_text[] =3D {
-	/* Zoned VM counters */
-	"nr_free_pages",
-	"nr_inactive_anon",
-	"nr_active_anon",
-	"nr_inactive_file",
-	"nr_active_file",
-	"nr_unevictable",
-	"nr_mlock",
-	"nr_anon_pages",
-	"nr_mapped",
-	"nr_file_pages",
-	"nr_dirty",
-	"nr_writeback",
-	"nr_slab_reclaimable",
-	"nr_slab_unreclaimable",
-	"nr_page_table_pages",
-	"nr_kernel_stack",
-	"nr_unstable",
-	"nr_bounce",
-	"nr_vmscan_write",
-	"nr_writeback_temp",
-	"nr_isolated_anon",
-	"nr_isolated_file",
-	"nr_shmem",
-	"nr_dirtied",
-	"nr_written",
-
-#ifdef CONFIG_NUMA
-	"numa_hit",
-	"numa_miss",
-	"numa_foreign",
-	"numa_interleave",
-	"numa_local",
-	"numa_other",
-#endif
-	"nr_anon_transparent_hugepages",
-	"nr_dirty_threshold",
-	"nr_dirty_background_threshold",
-
-#ifdef CONFIG_VM_EVENT_COUNTERS
-	"pgpgin",
-	"pgpgout",
-	"pswpin",
-	"pswpout",
-
-	TEXTS_FOR_ZONES("pgalloc")
-
-	"pgfree",
-	"pgactivate",
-	"pgdeactivate",
-
-	"pgfault",
-	"pgmajfault",
-
-	TEXTS_FOR_ZONES("pgrefill")
-	TEXTS_FOR_ZONES("pgsteal")
-	TEXTS_FOR_ZONES("pgscan_kswapd")
-	TEXTS_FOR_ZONES("pgscan_direct")
-
-#ifdef CONFIG_NUMA
-	"zone_reclaim_failed",
-#endif
-	"pginodesteal",
-	"slabs_scanned",
-	"kswapd_steal",
-	"kswapd_inodesteal",
-	"kswapd_low_wmark_hit_quickly",
-	"kswapd_high_wmark_hit_quickly",
-	"kswapd_skip_congestion_wait",
-	"pageoutrun",
-	"allocstall",
-
-	"pgrotated",
-
-#ifdef CONFIG_COMPACTION
-	"compact_blocks_moved",
-	"compact_pages_moved",
-	"compact_pagemigrate_failed",
-	"compact_stall",
-	"compact_fail",
-	"compact_success",
-#endif
-
-#ifdef CONFIG_HUGETLB_PAGE
-	"htlb_buddy_alloc_success",
-	"htlb_buddy_alloc_fail",
-#endif
-	"unevictable_pgs_culled",
-	"unevictable_pgs_scanned",
-	"unevictable_pgs_rescued",
-	"unevictable_pgs_mlocked",
-	"unevictable_pgs_munlocked",
-	"unevictable_pgs_cleared",
-	"unevictable_pgs_stranded",
-	"unevictable_pgs_mlockfreed",
-
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	"thp_fault_alloc",
-	"thp_fault_fallback",
-	"thp_collapse_alloc",
-	"thp_collapse_alloc_failed",
-	"thp_split",
-#endif
-
-#endif /* CONFIG_VM_EVENTS_COUNTERS */
-};
-
 static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 							struct zone *zone)
 {
--=20
1.7.3.1




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
