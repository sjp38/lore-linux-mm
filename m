Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D42FE6B0007
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:42:10 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g7-v6so11842067wrb.19
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 23:42:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x40si6088801edx.299.2018.04.23.23.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 23:42:09 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3O6d45i038660
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:42:08 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hhy9y8q37-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 02:42:08 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Apr 2018 07:42:06 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/2] mm/ksm: move [set_]page_stable_node from ksm.h to ksm.c
Date: Tue, 24 Apr 2018 09:41:46 +0300
In-Reply-To: <1524552106-7356-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524552106-7356-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1524552106-7356-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>

The page_stable_node() and set_page_stable_node() are only used in mm/ksm.c
and there is no point to keep them in the include/linux/ksm.h

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/ksm.h | 11 -----------
 mm/ksm.c            | 12 ++++++++++++
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index bbdfca3..161e816 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -37,17 +37,6 @@ static inline void ksm_exit(struct mm_struct *mm)
 		__ksm_exit(mm);
 }
 
-static inline struct stable_node *page_stable_node(struct page *page)
-{
-	return PageKsm(page) ? page_rmapping(page) : NULL;
-}
-
-static inline void set_page_stable_node(struct page *page,
-					struct stable_node *stable_node)
-{
-	page->mapping = (void *)((unsigned long)stable_node | PAGE_MAPPING_KSM);
-}
-
 /*
  * When do_swap_page() first faults in from swap what used to be a KSM page,
  * no problem, it will be assigned to this vma's anon_vma; but thereafter,
diff --git a/mm/ksm.c b/mm/ksm.c
index 16451a2..58c2741 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -827,6 +827,18 @@ static int unmerge_ksm_pages(struct vm_area_struct *vma,
 /*
  * Only called through the sysfs control interface:
  */
+
+static inline struct stable_node *page_stable_node(struct page *page)
+{
+	return PageKsm(page) ? page_rmapping(page) : NULL;
+}
+
+static inline void set_page_stable_node(struct page *page,
+					struct stable_node *stable_node)
+{
+	page->mapping = (void *)((unsigned long)stable_node | PAGE_MAPPING_KSM);
+}
+
 static int remove_stable_node(struct stable_node *stable_node)
 {
 	struct page *page;
-- 
2.7.4
