Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD62A6B0006
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 21:25:43 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id a1-v6so7947038oti.8
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 18:25:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h185-v6sor4612602oib.220.2018.06.16.18.25.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Jun 2018 18:25:42 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH 1/2] consolidate get_user_pages error handling
Date: Sat, 16 Jun 2018 18:25:09 -0700
Message-Id: <20180617012510.20139-2-jhubbard@nvidia.com>
In-Reply-To: <20180617012510.20139-1-jhubbard@nvidia.com>
References: <20180617012510.20139-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

In preparation for a subsequent patch, consolidate the error handling
for __get_user_pages(). This provides a single location (the "out:" label)
for operating on the collected set of pages that are about to be returned.

As long as we are already touching every use of the "ret" variable, fix
its name: "ret" --> "err". This also gets rid of two shadowed variable
declarations, as tiny beneficial a side effect.

Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/gup.c | 37 ++++++++++++++++++++++---------------
 1 file changed, 22 insertions(+), 15 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index b70d7ba7cc13..73f0b3316fa7 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -660,6 +660,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		struct vm_area_struct **vmas, int *nonblocking)
 {
 	long i = 0;
+	int err = 0;
 	unsigned int page_mask;
 	struct vm_area_struct *vma = NULL;
 
@@ -685,18 +686,19 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		if (!vma || start >= vma->vm_end) {
 			vma = find_extend_vma(mm, start);
 			if (!vma && in_gate_area(mm, start)) {
-				int ret;
-				ret = get_gate_page(mm, start & PAGE_MASK,
+				err = get_gate_page(mm, start & PAGE_MASK,
 						gup_flags, &vma,
 						pages ? &pages[i] : NULL);
-				if (ret)
-					return i ? : ret;
+				if (err)
+					goto out;
 				page_mask = 0;
 				goto next_page;
 			}
 
-			if (!vma || check_vma_flags(vma, gup_flags))
-				return i ? : -EFAULT;
+			if (!vma || check_vma_flags(vma, gup_flags)) {
+				err = -EFAULT;
+				goto out;
+			}
 			if (is_vm_hugetlb_page(vma)) {
 				i = follow_hugetlb_page(mm, vma, pages, vmas,
 						&start, &nr_pages, i,
@@ -709,23 +711,25 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		 * If we have a pending SIGKILL, don't keep faulting pages and
 		 * potentially allocating memory.
 		 */
-		if (unlikely(fatal_signal_pending(current)))
-			return i ? i : -ERESTARTSYS;
+		if (unlikely(fatal_signal_pending(current))) {
+			err = -ERESTARTSYS;
+			goto out;
+		}
 		cond_resched();
 		page = follow_page_mask(vma, start, foll_flags, &page_mask);
 		if (!page) {
-			int ret;
-			ret = faultin_page(tsk, vma, start, &foll_flags,
+			err = faultin_page(tsk, vma, start, &foll_flags,
 					nonblocking);
-			switch (ret) {
+			switch (err) {
 			case 0:
 				goto retry;
 			case -EFAULT:
 			case -ENOMEM:
 			case -EHWPOISON:
-				return i ? i : ret;
+				goto out;
 			case -EBUSY:
-				return i;
+				err = 0;
+				goto out;
 			case -ENOENT:
 				goto next_page;
 			}
@@ -737,7 +741,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			 */
 			goto next_page;
 		} else if (IS_ERR(page)) {
-			return i ? i : PTR_ERR(page);
+			err = PTR_ERR(page);
+			goto out;
 		}
 		if (pages) {
 			pages[i] = page;
@@ -757,7 +762,9 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		start += page_increm * PAGE_SIZE;
 		nr_pages -= page_increm;
 	} while (nr_pages);
-	return i;
+
+out:
+	return i ? i : err;
 }
 
 static bool vma_permits_fault(struct vm_area_struct *vma,
-- 
2.17.1
