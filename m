Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 895C66B0003
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 12:42:26 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id y7so8404249qkd.10
        for <linux-mm@kvack.org>; Mon, 12 Mar 2018 09:42:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w5si65328qte.262.2018.03.12.09.42.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Mar 2018 09:42:25 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2CGdYfg009415
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 12:42:24 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gnvfxjnt1-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 12:42:24 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <imbrenda@linux.vnet.ibm.com>;
	Mon, 12 Mar 2018 16:42:22 -0000
From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: [PATCH v1 1/1] mm/ksm: fix interaction with THP
Date: Mon, 12 Mar 2018 17:42:17 +0100
Message-Id: <1520872937-15351-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, minchan@kernel.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, hughd@google.com, pholasek@redhat.com, borntraeger@de.ibm.com, gerald.schaefer@de.ibm.com

This patch fixes a corner case for KSM. When two pages belong or
belonged to the same transparent hugepage, and they should be merged,
KSM fails to split the page, and therefore no merging happens.

This bug can be reproduced by:
* making sure ksm is running (in case disabling ksmtuned)
* enabling transparent hugepages
* allocating a THP-aligned 1-THP-sized buffer
  e.g. on amd64: posix_memalign(&p, 1<<21, 1<<21)
* filling it with the same values
  e.g. memset(p, 42, 1<<21)
* performing madvise to make it mergeable
  e.g. madvise(p, 1<<21, MADV_MERGEABLE)
* waiting for KSM to perform a few scans

The expected outcome is that the all the pages get merged (1 shared and
the rest sharing); the actual outcome is that no pages get merged (1
unshared and the rest volatile)

The reason of this behaviour is that we increase the reference count
once for both pages we want to merge, but if they belong to the same
hugepage (or compound page), the reference counter used in both cases
is the one of the head of the compound page.
This means that split_huge_page will find a value of the reference
counter too high and will fail.

This patch solves this problem by testing if the two pages to merge
belong to the same hugepage when attempting to merge them. If so, the
hugepage is split safely. This means that the hugepage is not split if
not necessary.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Signed-off-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
---
 mm/ksm.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 293721f..7a826fa 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2001,7 +2001,7 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	struct page *kpage;
 	unsigned int checksum;
 	int err;
-	bool max_page_sharing_bypass = false;
+	bool split, max_page_sharing_bypass = false;
 
 	stable_node = page_stable_node(page);
 	if (stable_node) {
@@ -2084,6 +2084,8 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	if (tree_rmap_item) {
 		kpage = try_to_merge_two_pages(rmap_item, page,
 						tree_rmap_item, tree_page);
+		split = PageTransCompound(page) && PageTransCompound(tree_page)
+			&& compound_head(page) == compound_head(tree_page);
 		put_page(tree_page);
 		if (kpage) {
 			/*
@@ -2110,6 +2112,11 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 				break_cow(tree_rmap_item);
 				break_cow(rmap_item);
 			}
+		} else if (split) {
+			if (!trylock_page(page))
+				return;
+			split_huge_page(page);
+			unlock_page(page);
 		}
 	}
 }
-- 
2.7.4
