Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0FC856B004A
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 11:43:22 -0400 (EDT)
Date: Fri, 22 Oct 2010 11:43:16 -0400
From: Dean Nelson <dnelson@redhat.com>
Message-Id: <20101022154315.3643.86047.send-patch@localhost6.localdomain6>
Subject: [PATCH] Add missing spin_lock() to hugetlb_cow()
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Add missing spin_lock() of the page_table_lock before an error return in
hugetlb_cow(). Callers of hugtelb_cow() expect it to be held upon return.

Signed-off-by: Dean Nelson <dnelson@redhat.com>
CC: stable@kernel.org

---

Sorry for the noise, if there has already been a patch posted to fix this
issue. I didn't see one.

 mm/hugetlb.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c032738..8ee804b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2380,8 +2380,11 @@ retry_avoidcopy:
 	 * When the original hugepage is shared one, it does not have
 	 * anon_vma prepared.
 	 */
-	if (unlikely(anon_vma_prepare(vma)))
+	if (unlikely(anon_vma_prepare(vma))) {
+		/* Caller expects lock to be held */
+		spin_lock(&mm->page_table_lock);
 		return VM_FAULT_OOM;
+	}
 
 	copy_huge_page(new_page, old_page, address, vma);
 	__SetPageUptodate(new_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
