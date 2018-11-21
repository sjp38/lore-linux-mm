Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 922F46B248B
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 01:21:54 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id g22so5751767qke.15
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 22:21:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o51si22641710qtj.204.2018.11.20.22.21.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 22:21:53 -0800 (PST)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH RFC v3 4/4] mm: gup: allow VM_FAULT_RETRY for multiple times
Date: Wed, 21 Nov 2018 14:21:03 +0800
Message-Id: <20181121062103.18835-5-peterx@redhat.com>
In-Reply-To: <20181121062103.18835-1-peterx@redhat.com>
References: <20181121062103.18835-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Keith Busch <keith.busch@intel.com>, Jerome Glisse <jglisse@redhat.com>, peterx@redhat.com, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Huang Ying <ying.huang@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Michael S. Tsirkin" <mst@redhat.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>

This is the gup counterpart of the change that allows the VM_FAULT_RETRY
to happen for more than once.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/gup.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index a40111c742ba..7c3b3ab6be88 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -528,7 +528,10 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	if (*flags & FOLL_NOWAIT)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
 	if (*flags & FOLL_TRIED) {
-		VM_WARN_ON_ONCE(fault_flags & FAULT_FLAG_ALLOW_RETRY);
+		/*
+		 * Note: FAULT_FLAG_ALLOW_RETRY and FAULT_FLAG_TRIED
+		 * can co-exist
+		 */
 		fault_flags |= FAULT_FLAG_TRIED;
 	}
 
@@ -944,17 +947,23 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 		/* VM_FAULT_RETRY triggered, so seek to the faulting offset */
 		pages += ret;
 		start += ret << PAGE_SHIFT;
+		lock_dropped = true;
 
+retry:
 		/*
 		 * Repeat on the address that fired VM_FAULT_RETRY
-		 * without FAULT_FLAG_ALLOW_RETRY but with
+		 * with both FAULT_FLAG_ALLOW_RETRY and
 		 * FAULT_FLAG_TRIED.
 		 */
 		*locked = 1;
-		lock_dropped = true;
 		down_read(&mm->mmap_sem);
 		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
-				       pages, NULL, NULL);
+				       pages, NULL, locked);
+		if (!*locked) {
+			/* Continue to retry until we succeeded */
+			BUG_ON(ret != 0);
+			goto retry;
+		}
 		if (ret != 1) {
 			BUG_ON(ret > 1);
 			if (!pages_done)
-- 
2.17.1
