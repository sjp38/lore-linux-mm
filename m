From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:43:40 +0200
Message-Id: <20060712144340.16998.40017.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 34/39] mm: cart: CART-r policy implementation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Another CART based policy, this one extends CART to handle cyclic access.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_cart_data.h         |    8 ++++
 include/linux/mm_cart_policy.h       |   10 ++++-
 include/linux/mm_page_replace.h      |    2 -
 include/linux/mm_page_replace_data.h |    2 -
 mm/Kconfig                           |    6 +++
 mm/Makefile                          |    1 
 mm/cart.c                            |   66 +++++++++++++++++++++++++++++------
 7 files changed, 82 insertions(+), 13 deletions(-)

Index: linux-2.6/include/linux/mm_cart_data.h
===================================================================
--- linux-2.6.orig/include/linux/mm_cart_data.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_cart_data.h	2006-07-12 16:09:19.000000000 +0200
@@ -13,11 +13,15 @@ struct pgrep_data {
 	unsigned long		nr_T2;
 	unsigned long           nr_shortterm;
 	unsigned long           nr_p;
+#if defined CONFIG_MM_POLICY_CART_R
+	unsigned long		nr_r;
+#endif
 	unsigned long		flags;
 };
 
 #define CART_RECLAIMED_T1	0
 #define CART_SATURATED		1
+#define CART_CYCLIC		2
 
 #define ZoneReclaimedT1(z)	test_bit(CART_RECLAIMED_T1, &((z)->policy.flags))
 #define SetZoneReclaimedT1(z)	__set_bit(CART_RECLAIMED_T1, &((z)->policy.flags))
@@ -27,5 +31,9 @@ struct pgrep_data {
 #define SetZoneSaturated(z)	__set_bit(CART_SATURATED, &((z)->policy.flags))
 #define TestClearZoneSaturated(z)  __test_and_clear_bit(CART_SATURATED, &((z)->policy.flags))
 
+#define ZoneCyclic(z)		test_bit(CART_CYCLIC, &((z)->policy.flags))
+#define SetZoneCyclic(z)	__set_bit(CART_CYCLIC, &((z)->policy.flags))
+#define ClearZoneCyclic(z)	__clear_bit(CART_CYCLIC, &((z)->policy.flags))
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_CART_DATA_H_ */
Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:23.000000000 +0200
@@ -100,7 +100,7 @@ extern void __pgrep_counts(unsigned long
 #include <linux/mm_use_once_policy.h>
 #elif defined CONFIG_MM_POLICY_CLOCKPRO
 #include <linux/mm_clockpro_policy.h>
-#elif defined CONFIG_MM_POLICY_CART
+#elif defined CONFIG_MM_POLICY_CART || defined CONFIG_MM_POLICY_CART_R
 #include <linux/mm_cart_policy.h>
 #else
 #error no mm policy
Index: linux-2.6/include/linux/mm_page_replace_data.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace_data.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace_data.h	2006-07-12 16:11:23.000000000 +0200
@@ -7,7 +7,7 @@
 #include <linux/mm_use_once_data.h>
 #elif defined CONFIG_MM_POLICY_CLOCKPRO
 #include <linux/mm_clockpro_data.h>
-#elif defined CONFIG_MM_POLICY_CART
+#elif defined CONFIG_MM_POLICY_CART || defined CONFIG_MM_POLICY_CART_R
 #include <linux/mm_cart_data.h>
 #else
 #error no mm policy
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/Kconfig	2006-07-12 16:11:23.000000000 +0200
@@ -152,6 +152,12 @@ config MM_POLICY_CART
 	help
 	  This option selects a CART based policy
 
+config MM_POLICY_CART_R
+	bool "CART-r"
+	help
+	  This option selects a CART based policy modified to handle cyclic
+	  access patterns.
+
 endchoice
 
 #
Index: linux-2.6/mm/cart.c
===================================================================
--- linux-2.6.orig/mm/cart.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/cart.c	2006-07-12 16:11:22.000000000 +0200
@@ -64,6 +64,9 @@ void __init pgrep_init_zone(struct zone 
 	zone->policy.nr_T2 = 0;
 	zone->policy.nr_shortterm = 0;
 	zone->policy.nr_p = 0;
+#if defined CONFIG_MM_POLICY_CART_R
+	zone->policy.nr_r = 0;
+#endif
 	zone->policy.flags = 0;
 }
 
@@ -160,6 +163,30 @@ static inline void __cart_p_dec(struct z
 		zone->policy.nr_p = 0UL;
 }
 
+#if defined CONFIG_MM_POLICY_CART_R
+static inline void __cart_r_inc(struct zone *zone)
+{
+	unsigned long ratio;
+	ratio = (cart_longterm(zone) / (zone->policy.nr_shortterm + 1)) ?: 1;
+	zone->policy.nr_r += ratio;
+	if (zone->policy.nr_r > cart_c(zone))
+		zone->policy.nr_r = cart_c(zone);
+}
+
+static inline void __cart_r_dec(struct zone *zone)
+{
+	unsigned long ratio;
+	ratio = (zone->policy.nr_shortterm / (cart_longterm(zone) + 1)) ?: 1;
+	if (zone->policy.nr_r > ratio)
+		zone->policy.nr_r -= ratio;
+	else
+		zone->policy.nr_r = 0UL;
+}
+#else
+#define __cart_r_inc(z) do { } while (0)
+#define __cart_r_dec(z) do { } while (0)
+#endif
+
 static unsigned long list_count(struct list_head *list, int PG_flag, int result)
 {
 	unsigned long nr = 0;
@@ -230,6 +257,8 @@ void __pgrep_add(struct zone *zone, stru
 
 	if (rflags & NR_found) {
 		SetPageLongTerm(page);
+		__cart_r_dec(zone);
+
 		rflags &= NR_listid;
 		if (rflags == NR_b1) {
 			__cart_p_inc(zone);
@@ -240,6 +269,7 @@ void __pgrep_add(struct zone *zone, stru
 		/* ++cart_longterm(zone); */
 	} else {
 		ClearPageLongTerm(page);
+		__cart_r_inc(zone);
 		++zone->policy.nr_shortterm;
 	}
 	SetPageT1(page);
@@ -329,21 +359,30 @@ void pgrep_reinsert(struct list_head *pa
 
 static inline int cart_reclaim_T1(struct zone *zone, unsigned long nr_to_scan)
 {
+	int ret = 0;
 	int t1 = zone->policy.nr_T1 > zone->policy.nr_p &&
 		(zone->policy.nr_T1 > nr_to_scan ||
 		 zone->policy.nr_T1 > zone->policy.nr_T2);
 	int sat = TestClearZoneSaturated(zone);
 	int rec = ZoneReclaimedT1(zone);
+#if defined CONFIG_MM_POLICY_CART_R
+	int cyc = zone->policy.nr_r < cart_longterm(zone);
 
-	if (t1) {
-		if (sat && rec)
-			return 0;
-		return 1;
-	}
+	t1 |= cyc;
+#endif
+
+	if ((t1 && !(rec && sat)) ||
+	    (!t1 && (!rec && sat)))
+			ret = 1;
+
+#if defined CONFIG_MM_POLICY_CART_R
+	if (ret && cyc)
+		SetZoneCyclic(zone);
+	else
+		ClearZoneCyclic(zone);
+#endif
 
-	if (sat && !rec)
-		return 1;
-	return 0;
+	return ret;
 }
 
 
@@ -450,7 +489,8 @@ void __pgrep_rotate_reclaimable(struct z
 {
 	if (PageLRU(page)) {
 		if (PageLongTerm(page)) {
-			if (TestClearPageT1(page)) {
+			if (PageT1(page)) {
+				ClearPageT1(page);
 				--zone->policy.nr_T1;
 				++zone->policy.nr_T2;
 				__cart_q_dec(zone, 1);
@@ -520,7 +560,10 @@ void pgrep_zoneinfo(struct zone *zone, s
 		   "\n        T2         %lu"
 		   "\n        shortterm  %lu"
 		   "\n        p          %lu"
-		   "\n        flags      %lu"
+#if defined CONFIG_MM_POLICY_CART_R
+		   "\n        r          %lu"
+#endif
+		   "\n        flags      %lx"
 		   "\n        scanned    %lu"
 		   "\n        spanned    %lu"
 		   "\n        present    %lu",
@@ -532,6 +575,9 @@ void pgrep_zoneinfo(struct zone *zone, s
 		   zone->policy.nr_T2,
 		   zone->policy.nr_shortterm,
 		   zone->policy.nr_p,
+#if defined CONFIG_MM_POLICY_CART_R
+		   zone->policy.nr_r,
+#endif
 		   zone->policy.flags,
 		   zone->pages_scanned,
 		   zone->spanned_pages,
Index: linux-2.6/include/linux/mm_cart_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_cart_policy.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_cart_policy.h	2006-07-12 16:09:19.000000000 +0200
@@ -80,6 +80,13 @@ static inline void __pgrep_remove(struct
 
 static inline int pgrep_reclaimable(struct page *page)
 {
+#if defined CONFIG_MM_POLICY_CART_R
+	if (PageNew(page) && ZoneCyclic(page_zone(page))) {
+		ClearPageNew(page);
+		return RECLAIM_OK;
+	}
+#endif
+
 	if (page_referenced(page, 1, 0))
 		return RECLAIM_ACTIVATE;
 
@@ -98,10 +105,11 @@ static inline int fastcall pgrep_activat
 	/* just set PG_referenced, handle the rest in
 	 * pgrep_reinsert()
 	 */
-	if (!TestClearPageNew(page)) {
+	if (!PageNew(page)) {
 		SetPageReferenced(page);
 		return 1;
 	}
+	ClearPageNew(page);
 
 	return 0;
 }
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/Makefile	2006-07-12 16:11:23.000000000 +0200
@@ -15,6 +15,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
 obj-$(CONFIG_MM_POLICY_USEONCE) += useonce.o
 obj-$(CONFIG_MM_POLICY_CLOCKPRO) += nonresident.o clockpro.o
 obj-$(CONFIG_MM_POLICY_CART) += nonresident-cart.o cart.o
+obj-$(CONFIG_MM_POLICY_CART_R) += nonresident-cart.o cart.o
 
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
