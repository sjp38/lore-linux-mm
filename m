Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 42D8E6B0098
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 23:25:15 -0500 (EST)
From: KyongHo Cho <pullip.cho@samsung.com>
Subject: [RFCv2,2/8] mm: vcm: reference counting on a reservation added
Date: Fri, 17 Dec 2010 12:56:21 +0900
Message-Id: <1292558187-17348-3-git-send-email-pullip.cho@samsung.com>
In-Reply-To: <1292558187-17348-2-git-send-email-pullip.cho@samsung.com>
References: <1292558187-17348-1-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-2-git-send-email-pullip.cho@samsung.com>
Sender: owner-linux-mm@kvack.org
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, Inho Lee <ilho215.lee@samsung.com>, Inki Dae <inki.dae@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This commits adds vcm_ref_reserve() and refcnt member into vcm_res
structure. This feature is enabled by turnning on
CONFIG_VCM_RES_REFCNT. This enables the users of the vcm framework
not to care about the sequence of reserving and unreserving
in complex scenarios.

Signed-off-by: KyongHo Cho <pullip.cho@samsung.com>
---
 Documentation/virtual-contiguous-memory.txt |   47 +++++++++++++++++++++++++++
 include/linux/vcm.h                         |   23 +++++++++++++
 mm/Kconfig                                  |    7 ++++
 mm/vcm.c                                    |   17 ++++++++++
 4 files changed, 94 insertions(+), 0 deletions(-)

diff --git a/Documentation/virtual-contiguous-memory.txt b/Documentation/virtual-contiguous-memory.txt
index 9793a86..2008465 100644
--- a/Documentation/virtual-contiguous-memory.txt
+++ b/Documentation/virtual-contiguous-memory.txt
@@ -275,6 +275,34 @@ To deactivate the VCM context vcm_deactivate() function is used:
 Both of those functions can be called several times if all calls to
 vcm_activate() are paired with a later call to vcm_deactivate().
 
+** Aquiring and releasing ownership of a reservation
+
+Once a device driver reserve a reservation, it may want to pass other device
+drivers or attach the reservation in a data structre. Since the reservation
+may be shared among many device drivers, the VCM context is needed to provide
+a simple way to unreserve a reservation.
+
+Below 2 functions gives the ownership of a reservation to the caller:
+
+	struct vcm_res *__must_check
+	vcm_reserve(struct vcm *vcm, resource_size_t size, unsigned flags);
+
+	int __must_check vcm_ref_reserve(struct vcm_res *res);
+
+vcm_reserve() creates a new reservation, thus the first owner of the
+reservation is set to the caller of vcm_reservation(). It then passes to a
+function the reservation. The function that received the reservation calls
+vcm_ref_reserve() to acquire the ownership of the given reservation. If the
+function decides that it does not need the reservation any more, it calls
+vcm_release() to release the ownership of the reservation.
+
+	void vcm_unreserve(struct vcm_res *res);
+
+It is not required to determine if other functions and drivers still need to
+access the reservation because this function just release the ownership of the
+reservation. If vcm_unreserve() finds no one has the ownership of the given
+reservation, only then does it unreserve (remove) the given reservation.
+
 ** Device driver example
 
 The following is a simple, untested example of how platform and
@@ -706,6 +734,25 @@ automatically reflect new mappings on the hardware MMU.
 Neither of the operations are required and if missing, VCM will
 assume they are a no-operation and no warning will be generated.
 
+*** Ownership of a reservation
+
+When to aquire the ownership of a reservation:
+  - When creating a new reservation (having the ownership automatically)
+  - When assigning a reservation to a member of data structure
+  - When a reservation is passed from the caller function
+  - When requiring to access a reservation (that is a global variable)
+    at first in its context.
+The first one is done with vcm_reserve() and others with vcm_ref_reserve().
+
+When to release the ownership of a reservation:
+  - When a reservation is no longer needed in its context.
+  - When returning from a function and the function received a reservation
+    from its caller and acquired the ownership of the reservation.
+  - When removing a reservation from a data structure that includes a pointer
+    to the reservation
+It is not required as well unable to remove the reservation explicitly. The
+last call to vcm_unreserve() will cause the reservation to be removed.
+
 * Epilogue
 
 The initial version of the VCM framework was written by Zach Pfeffer
diff --git a/include/linux/vcm.h b/include/linux/vcm.h
index 965dc9b..3d54f18 100644
--- a/include/linux/vcm.h
+++ b/include/linux/vcm.h
@@ -52,6 +52,9 @@ struct vcm {
  * @bound_size:	number of bytes actually bound to the virtual address;
  *		read only.
  * @res_size:	size of the reserved address space in bytes; read only.
+ * @refcnt:	reference count of a reservation to pass ownership of
+ *		a reservation in a safe way; internal.
+ *		Implemented only when CONFIG_VCM_RES_REFCNT is enabled.
  * @vcm:	VCM context; internal, read only for MMU drivers.
  * @phys:	pointer to physical memory bound to this reservation; NULL
  *		if no physical memory is bound; read only.
@@ -65,6 +68,9 @@ struct vcm_res {
 	dma_addr_t		start;
 	resource_size_t		bound_size;
 	resource_size_t		res_size;
+#ifdef CONFIG_VCM_RES_REFCNT
+	atomic_t		refcnt;
+#endif
 
 	struct vcm		*vcm;
 	struct vcm_phys		*phys;
@@ -180,6 +186,23 @@ struct vcm_res *__must_check
 vcm_reserve(struct vcm *vcm, resource_size_t size, unsigned flags);
 
 /**
+ * vcm_ref_reserve() - acquires the ownership of a reservation.
+ * @res:	a valid reservation to access
+ *
+ * On success returns 0 and leads the same effect as vcm_reserve() in the
+ * context of the caller of this function. In other words, once a function
+ * acquire the ownership of a reservation with vcm_ref_reserve(), it must
+ * release the ownership with vcm_release() as soon as it does not need
+ * the reservation.
+ *
+ * On error returns -EINVAL. The only reason of the error is passing an invalid
+ * reservation like NULL or an unreserved reservation.
+ */
+#ifdef CONFIG_VCM_RES_REFCNT
+int __must_check vcm_ref_reserve(struct vcm_res *res);
+#endif
+
+/**
  * vcm_unreserve() - destroyers a virtual address space reservation
  * @res:	reservation to destroy.
  *
diff --git a/mm/Kconfig b/mm/Kconfig
index 7f0e4b1..b937f32 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -353,6 +353,13 @@ config VCM
  	  <Documentation/virtual-contiguous-memory.txt>.  If unsure, say
  	  "n".
 
+config VCM_RES_REFCNT
+	bool "Reference counting on reservations"
+	depends on VCM
+	help
+	  This enables reference counting on a reservation to make sharing
+	  and migrating the ownership of the reservation easier.
+
 #
 # UP and nommu archs use km based percpu allocator
 #
diff --git a/mm/vcm.c b/mm/vcm.c
index 1389ee6..5819f0f 100644
--- a/mm/vcm.c
+++ b/mm/vcm.c
@@ -156,10 +156,23 @@ vcm_reserve(struct vcm *vcm, resource_size_t size, unsigned flags)
 
 	__vcm_alloc_and_reserve(vcm, size, NULL, 0, &res, flags);
 
+#ifdef CONFIG_VCM_RES_REFCNT
+	if (!IS_ERR(res))
+		atomic_inc(&res->refcnt);
+#endif
+
 	return res;
 }
 EXPORT_SYMBOL_GPL(vcm_reserve);
 
+int __must_check vcm_ref_reserve(struct vcm_res *res)
+{
+	if (WARN_ON(!res) || (atomic_inc_return(&res->refcnt) < 2))
+		return -EINVAL;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(vcm_ref_reserve);
+
 struct vcm_res *__must_check
 vcm_map(struct vcm *vcm, struct vcm_phys *phys, unsigned flags)
 {
@@ -196,6 +209,10 @@ EXPORT_SYMBOL_GPL(vcm_map);
 void vcm_unreserve(struct vcm_res *res)
 {
 	if (!WARN_ON(!res)) {
+#ifdef CONFIG_VCM_RES_REFCNT
+		if (!atomic_dec_and_test(&res->refcnt))
+			return;
+#endif
 		if (WARN_ON(res->phys))
 			vcm_unbind(res);
 		if (!WARN_ON_ONCE(!res->vcm->driver->unreserve))
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
