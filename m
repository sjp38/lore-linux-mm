Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 8E09D6B0071
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 06:33:43 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so634462dad.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 03:33:42 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [RFC PATCH 3/6] mm: rearrange vm_area_struct for fewer cache misses
Date: Wed, 31 Oct 2012 03:33:22 -0700
Message-Id: <1351679605-4816-4-git-send-email-walken@google.com>
In-Reply-To: <1351679605-4816-1-git-send-email-walken@google.com>
References: <1351679605-4816-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@surriel.com>

From: Rik van Riel <riel@surriel.com>

The kernel walks the VMA rbtree in various places, including
the page fault path.  However, the vm_rb node spanned two
cache lines, on 64 bit systems with 64 byte cache lines (most
x86 systems).

Rearrange vm_area_struct a little, so all the information we
need to do a VMA tree walk is in the first cache line.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Michel Lespinasse <walken@google.com>

---
 include/linux/mm_types.h |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 94fa52b28ee8..528da4abf8ee 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -224,7 +224,8 @@ struct vm_region {
  * library, the executable area etc).
  */
 struct vm_area_struct {
-	struct mm_struct * vm_mm;	/* The address space we belong to. */
+	/* The first cache line has the info for VMA tree walking. */
+
 	unsigned long vm_start;		/* Our start address within vm_mm. */
 	unsigned long vm_end;		/* The first byte after our end address
 					   within vm_mm. */
@@ -232,9 +233,6 @@ struct vm_area_struct {
 	/* linked list of VM areas per task, sorted by address */
 	struct vm_area_struct *vm_next, *vm_prev;
 
-	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
-	unsigned long vm_flags;		/* Flags, see mm.h. */
-
 	struct rb_node vm_rb;
 
 	/*
@@ -245,6 +243,12 @@ struct vm_area_struct {
 	 */
 	unsigned long rb_subtree_gap;
 
+	/* Second cache line starts here. */
+
+	struct mm_struct * vm_mm;	/* The address space we belong to. */
+	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
+	unsigned long vm_flags;		/* Flags, see mm.h. */
+
 	/*
 	 * For areas with an address space and backing store,
 	 * linkage into the address_space->i_mmap interval tree, or
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
