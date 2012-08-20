From: wujianguo <wujianguo106@gmail.com>
Subject: [PATCH]mm: fix-up zone present pages
Date: Mon, 20 Aug 2012 14:38:10 +0800
Message-ID: <5031DB52.9030806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-ia64-owner@vger.kernel.org>
Sender: linux-ia64-owner@vger.kernel.org
To: tony.luck@intel.com, fenghua.yu@intel.com, dhowells@redhat.com, tj@kernel.org, mgorman@suse.de, yinghai@kernel.org, minchan.kim@gmail.com
Cc: akpm@linux-foundation.org, viro@zeniv.linux.org.uk, aarcange@redhat.com, davem@davemloft.net, hannes@cmpxchg.org, liuj97@gmail.com, wency@cn.fujitsu.com, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ptesarik@suse.cz, jiang.liu@huawei.com, guohanjun@huawei.com, qiuxishi@huawei.com
List-Id: linux-mm.kvack.org

=46rom: Jianguo Wu <wujianguo@huawei.com>

Hi all,
	I think zone->present_pages indicates pages that buddy system can mana=
gement,
it should be:
	zone->present_pages =3D spanned pages - absent pages - bootmem pages,
but now:
	zone->present_pages =3D spanned pages - absent pages - memmap pages.
spanned pages=EF=BC=9Atotal size, including holes.
absent pages: holes.
bootmem pages: pages used in system boot, managed by bootmem allocator.
memmap pages: pages used by page structs.

This may cause zone->present_pages less than it should be.
=46or example, numa node 1 has ZONE_NORMAL and ZONE_MOVABLE,
it's memmap and other bootmem will be allocated from ZONE_MOVABLE,
so ZONE_NORMAL's present_pages should be spanned pages - absent pages,
but now it also minus memmap pages(free_area_init_core), which are actu=
ally allocated
from ZONE_MOVABLE. When offline all memory of a zone, This will cause z=
one->present_pages
less than 0, because present_pages is unsigned long type, it is actuall=
y
a very large integer, it indirectly caused zone->watermark[WMARK_MIN]
become a large integer(setup_per_zone_wmarks()), than cause totalreserv=
e_pages
become a large integer(calculate_totalreserve_pages()), and finally cau=
se memory
allocating failure when fork process(__vm_enough_memory()).

[root@localhost ~]# dmesg
-bash: fork: Cannot allocate memory

I think bug described in http://marc.info/?l=3Dlinux-mm&m=3D13450218271=
4186&w=3D2 is also
caused by wrong zone present pages.

This patch intends to fix-up zone->present_pages when memory are freed =
to
buddy system in x86_64 and IA64 platform.

Thanks.

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 arch/ia64/mm/init.c |    1 +
 include/linux/mm.h  |    4 ++++
 mm/bootmem.c        |    9 ++++++++-
 mm/memory_hotplug.c |    7 +++++++
 mm/nobootmem.c      |    3 +++
 mm/page_alloc.c     |   34 ++++++++++++++++++++++++++++++++++
 6 files changed, 57 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index b960ba0..c78e3fd 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -640,6 +640,7 @@ mem_init (void)
 	free_floating_node_bootmem();
 #endif

+	reset_zone_present_pages();
 	for_each_online_pgdat(pgdat)
 		if (pgdat->bdata->node_bootmem_map)
 			totalram_pages +=3D free_all_bootmem_node(pgdat);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 311be90..a1bd8ea 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1662,5 +1662,9 @@ static inline unsigned int debug_guardpage_minord=
er(void) { return 0; }
 static inline bool page_is_guard(struct page *page) { return false; }
 #endif /* CONFIG_DEBUG_PAGEALLOC */

+extern void reset_zone_present_pages(void);
+extern void fixup_zone_present_pages(int nid, unsigned long start_pfn,
+				unsigned long end_pfn);
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/mm/bootmem.c b/mm/bootmem.c
index bcb63ac..e00b491 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -198,6 +198,8 @@ static unsigned long __init free_all_bootmem_core(b=
ootmem_data_t *bdata)
 			int order =3D ilog2(BITS_PER_LONG);

 			__free_pages_bootmem(pfn_to_page(start), order);
+			fixup_zone_present_pages(page_to_nid(pfn_to_page(start)),
+					start, start + BITS_PER_LONG);
 			count +=3D BITS_PER_LONG;
 			start +=3D BITS_PER_LONG;
 		} else {
@@ -208,6 +210,8 @@ static unsigned long __init free_all_bootmem_core(b=
ootmem_data_t *bdata)
 				if (vec & 1) {
 					page =3D pfn_to_page(start + off);
 					__free_pages_bootmem(page, 0);
+					fixup_zone_present_pages(page_to_nid(page),
+							start + off, start + off + 1);
 					count++;
 				}
 				vec >>=3D 1;
@@ -221,8 +225,11 @@ static unsigned long __init free_all_bootmem_core(=
bootmem_data_t *bdata)
 	pages =3D bdata->node_low_pfn - bdata->node_min_pfn;
 	pages =3D bootmem_bootmap_pages(pages);
 	count +=3D pages;
-	while (pages--)
+	while (pages--) {
+		fixup_zone_present_pages(page_to_nid(page),
+				page_to_pfn(page), page_to_pfn(page) + 1);
 		__free_pages_bootmem(page++, 0);
+	}

 	bdebug("nid=3D%td released=3D%lx\n", bdata - bootmem_node_data, count=
);

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 3ad25f9..bc7e7a2 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -106,6 +106,7 @@ static void get_page_bootmem(unsigned long info,  s=
truct page *page,
 void __ref put_page_bootmem(struct page *page)
 {
 	unsigned long type;
+	struct zone *zone;

 	type =3D (unsigned long) page->lru.next;
 	BUG_ON(type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
@@ -116,6 +117,12 @@ void __ref put_page_bootmem(struct page *page)
 		set_page_private(page, 0);
 		INIT_LIST_HEAD(&page->lru);
 		__free_pages_bootmem(page, 0);
+
+		zone =3D page_zone(page);
+		zone_span_writelock(zone);
+		zone->present_pages++;
+		zone_span_writeunlock(zone);
+		totalram_pages++;
 	}

 }
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 4055730..8027861 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -116,6 +116,8 @@ static unsigned long __init __free_memory_core(phys=
_addr_t start,
 		return 0;

 	__free_pages_memory(start_pfn, end_pfn);
+	fixup_zone_present_pages(pfn_to_nid(start >> PAGE_SHIFT),
+			start_pfn, end_pfn);

 	return end_pfn - start_pfn;
 }
@@ -126,6 +128,7 @@ unsigned long __init free_low_memory_core_early(int=
 nodeid)
 	phys_addr_t start, end, size;
 	u64 i;

+	reset_zone_present_pages();
 	for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL)
 		count +=3D __free_memory_core(start, end);

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fcb0932..36c35bb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6074,3 +6074,37 @@ void dump_page(struct page *page)
 	dump_page_flags(page->flags);
 	mem_cgroup_print_bad_page(page);
 }
+
+/* reset zone->present_pages */
+void reset_zone_present_pages(void)
+{
+	struct zone *z;
+	int i, nid;
+
+	for_each_node_state(nid, N_HIGH_MEMORY) {
+		for (i =3D 0; i < MAX_NR_ZONES; i++) {
+			z =3D NODE_DATA(nid)->node_zones + i;
+			z->present_pages =3D 0;
+		}
+	}
+}
+
+/* calculate zone's present pages in buddy system */
+void fixup_zone_present_pages(int nid, unsigned long start_pfn,
+				unsigned long end_pfn)
+{
+	struct zone *z;
+	unsigned long zone_start_pfn, zone_end_pfn;
+	int i;
+
+	for (i =3D 0; i < MAX_NR_ZONES; i++) {
+		z =3D NODE_DATA(nid)->node_zones + i;
+		zone_start_pfn =3D z->zone_start_pfn;
+		zone_end_pfn =3D zone_start_pfn + z->spanned_pages;
+
+		/* if the two regions intersect */
+		if (!(zone_start_pfn >=3D end_pfn	|| zone_end_pfn <=3D start_pfn))
+			z->present_pages +=3D min(end_pfn, zone_end_pfn) -
+								max(start_pfn, zone_start_pfn);
+	}
+}
--=20
1.7.6.1



=2E
--
To unsubscribe from this list: send the line "unsubscribe linux-ia64" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
