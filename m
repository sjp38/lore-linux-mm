Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5RFJNFY014649
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 11:19:23 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5RFItb3201370
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 11:18:55 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5RFIlIp005193
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 11:18:52 -0400
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 27 Jun 2008 20:48:38 +0530
Message-Id: <20080627151838.31664.51492.sendpatchset@balbir-laptop>
In-Reply-To: <20080627151808.31664.36047.sendpatchset@balbir-laptop>
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop>
Subject: [RFC 3/5] Replacement policy on heap overfull
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


This patch adds a policy parameter to heap_insert. While inserting an element
if the heap is full, the policy determines which element to replace.
The default earlier is now obtained by passing the policy as HEAP_REP_TOP.
The new HEAP_REP_LEAF policy, replaces a leaf node (the last element).

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 include/linux/prio_heap.h |    9 ++++++++-
 kernel/cgroup.c           |    2 +-
 lib/prio_heap.c           |   31 +++++++++++++++++++++++--------
 3 files changed, 32 insertions(+), 10 deletions(-)

diff -puN include/linux/prio_heap.h~prio_heap_replace_leaf include/linux/prio_heap.h
--- linux-2.6.26-rc5/include/linux/prio_heap.h~prio_heap_replace_leaf	2008-06-27 20:43:09.000000000 +0530
+++ linux-2.6.26-rc5-balbir/include/linux/prio_heap.h	2008-06-27 20:43:09.000000000 +0530
@@ -22,6 +22,11 @@ struct ptr_heap {
 	int (*gt)(void *, void *);
 };
 
+enum heap_replacement_policy {
+	HEAP_REP_LEAF,
+	HEAP_REP_TOP,
+};
+
 /**
  * heap_init - initialize an empty heap with a given memory size
  * @heap: the heap structure to be initialized
@@ -42,6 +47,8 @@ void heap_free(struct ptr_heap *heap);
  * heap_insert - insert a value into the heap and return any overflowed value
  * @heap: the heap to be operated on
  * @p: the pointer to be inserted
+ * @policy: Heap replacement policy, when heap is full. Replace the top
+ * of the heap or the leaf at the end of the array
  *
  * Attempts to insert the given value into the priority heap. If the
  * heap is full prior to the insertion, then the resulting heap will
@@ -51,7 +58,7 @@ void heap_free(struct ptr_heap *heap);
  * (i.e. no change to the heap) if the new element is greater than all
  * elements currently in the heap.
  */
-extern void *heap_insert(struct ptr_heap *heap, void *p);
+extern void *heap_insert(struct ptr_heap *heap, void *p, int policy);
 
 /**
  * heap_delete_max - delete the maximum element from the top of the heap
diff -puN lib/prio_heap.c~prio_heap_replace_leaf lib/prio_heap.c
--- linux-2.6.26-rc5/lib/prio_heap.c~prio_heap_replace_leaf	2008-06-27 20:43:09.000000000 +0530
+++ linux-2.6.26-rc5-balbir/lib/prio_heap.c	2008-06-27 20:43:09.000000000 +0530
@@ -46,7 +46,17 @@ static void heap_adjust(struct ptr_heap 
 	}
 }
 
-void *heap_insert(struct ptr_heap *heap, void *p)
+static void heap_insert_at(struct ptr_heap *heap, void *p, int pos)
+{
+	void **ptrs = heap->ptrs;
+	while (pos > 0 && heap->gt(p, ptrs[(pos-1)/2])) {
+		ptrs[pos] = ptrs[(pos-1)/2];
+		pos = (pos-1)/2;
+	}
+	ptrs[pos] = p;
+}
+
+void *heap_insert(struct ptr_heap *heap, void *p, int policy)
 {
 	void *res;
 	void **ptrs = heap->ptrs;
@@ -54,19 +64,24 @@ void *heap_insert(struct ptr_heap *heap,
 	if (heap->size < heap->max) {
 		/* Heap insertion */
 		int pos = heap->size++;
-		while (pos > 0 && heap->gt(p, ptrs[(pos-1)/2])) {
-			ptrs[pos] = ptrs[(pos-1)/2];
-			pos = (pos-1)/2;
-		}
-		ptrs[pos] = p;
+		heap_insert_at(heap, p, pos);
 		return NULL;
 	}
 
 	/* The heap is full, so something will have to be dropped */
 
 	/* If the new pointer is greater than the current max, drop it */
-	if (heap->gt(p, ptrs[0]))
-		return p;
+	if (policy == HEAP_REP_TOP)
+		if (heap->gt(p, ptrs[0]))
+			return p;
+
+	if (policy == HEAP_REP_LEAF) {
+		/* Heap insertion */
+		int pos = heap->size - 1;
+		res = ptrs[pos];
+		heap_insert_at(heap, p, pos);
+		return res;
+	}
 
 	/* Replace the current max and heapify */
 	res = ptrs[0];
diff -puN kernel/cgroup.c~prio_heap_replace_leaf kernel/cgroup.c
--- linux-2.6.26-rc5/kernel/cgroup.c~prio_heap_replace_leaf	2008-06-27 20:43:09.000000000 +0530
+++ linux-2.6.26-rc5-balbir/kernel/cgroup.c	2008-06-27 20:43:09.000000000 +0530
@@ -1976,7 +1976,7 @@ int cgroup_scan_tasks(struct cgroup_scan
 		 */
 		if (!started_after_time(p, &latest_time, latest_task))
 			continue;
-		dropped = heap_insert(heap, p);
+		dropped = heap_insert(heap, p, HEAP_REP_TOP);
 		if (dropped == NULL) {
 			/*
 			 * The new task was inserted; the heap wasn't
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
