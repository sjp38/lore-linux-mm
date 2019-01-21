Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC83D8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 02:59:33 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id k66so18724869qkf.1
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 23:59:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o63si2294025qka.164.2019.01.20.23.59.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Jan 2019 23:59:33 -0800 (PST)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH RFC 15/24] mm: export wp_page_copy()
Date: Mon, 21 Jan 2019 15:57:13 +0800
Message-Id: <20190121075722.7945-16-peterx@redhat.com>
In-Reply-To: <20190121075722.7945-1-peterx@redhat.com>
References: <20190121075722.7945-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, peterx@redhat.com, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

Export this function for usages outside page fault handlers.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/mm.h | 2 ++
 mm/memory.c        | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 89345b51d8bd..bf04e187fafe 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -378,6 +378,8 @@ struct vm_fault {
 					 */
 };
 
+vm_fault_t wp_page_copy(struct vm_fault *vmf);
+
 /* page entry size for vm->huge_fault() */
 enum page_entry_size {
 	PE_SIZE_PTE = 0,
diff --git a/mm/memory.c b/mm/memory.c
index 7f276158683b..ef823c07f635 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2239,7 +2239,7 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
  *   held to the old page, as well as updating the rmap.
  * - In any case, unlock the PTL and drop the reference we took to the old page.
  */
-static vm_fault_t wp_page_copy(struct vm_fault *vmf)
+vm_fault_t wp_page_copy(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct mm_struct *mm = vma->vm_mm;
-- 
2.17.1
