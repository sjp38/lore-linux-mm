Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F29136B0260
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 02:31:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v2so2881122pfa.10
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 23:31:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d92sor2271404pld.1.2017.10.17.23.31.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Oct 2017 23:31:36 -0700 (PDT)
From: Balbir Singh <bsingharora@gmail.com>
Subject: [rfc 1/2] mm/hmm: Allow smaps to see zone device public pages
Date: Wed, 18 Oct 2017 17:31:22 +1100
Message-Id: <20171018063123.21983-1-bsingharora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, mhocko@suse.com, Balbir Singh <bsingharora@gmail.com>

vm_normal_page() normally does not return zone device public
pages. In the absence of the visibility the output from smaps
is limited and confusing. It's hard to figure out where the
pages are. This patch uses _vm_normal_page() to expose them
for accounting

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 fs/proc/task_mmu.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 5589b4bd4b85..9f1e2b2b5f5a 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -528,7 +528,7 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
 	struct page *page = NULL;
 
 	if (pte_present(*pte)) {
-		page = vm_normal_page(vma, addr, *pte);
+		page = _vm_normal_page(vma, addr, *pte, true);
 	} else if (is_swap_pte(*pte)) {
 		swp_entry_t swpent = pte_to_swp_entry(*pte);
 
@@ -708,7 +708,7 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
 	struct page *page = NULL;
 
 	if (pte_present(*pte)) {
-		page = vm_normal_page(vma, addr, *pte);
+		page = _vm_normal_page(vma, addr, *pte, true);
 	} else if (is_swap_pte(*pte)) {
 		swp_entry_t swpent = pte_to_swp_entry(*pte);
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
