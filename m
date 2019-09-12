Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05A5EECDE2A
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 06:03:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9208208E4
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 06:03:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9208208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BEC76B0007; Thu, 12 Sep 2019 02:03:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 670346B0008; Thu, 12 Sep 2019 02:03:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 586606B000A; Thu, 12 Sep 2019 02:03:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0041.hostedemail.com [216.40.44.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3411D6B0007
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 02:03:12 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id CA4F9180AD804
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 06:03:11 +0000 (UTC)
X-FDA: 75925225782.27.unit51_1bc6a83500026
X-HE-Tag: unit51_1bc6a83500026
X-Filterd-Recvd-Size: 4923
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 06:03:10 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 954A81570;
	Wed, 11 Sep 2019 23:03:09 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.41.127])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 4DD8B3F71F;
	Wed, 11 Sep 2019 23:05:36 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-kernel@vger.kernel.org
Subject: [PATCH V2 1/2] mm/hugetlb: Make alloc_gigantic_page() available for general use
Date: Thu, 12 Sep 2019 11:32:52 +0530
Message-Id: <1568268173-31302-2-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
References: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

alloc_gigantic_page() implements an allocation method where it scans over
various zones looking for a large contiguous memory block which could not
have been allocated through the buddy allocator. A subsequent patch which
tests arch page table helpers needs such a method to allocate PUD_SIZE
sized memory block. In the future such methods might have other use cases
as well. So alloc_gigantic_page() has been split carving out actual memory
allocation method and made available via new alloc_gigantic_page_order().

Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
Should we move alloc_gigantic_page_order() to page_alloc.c and declarations
to include/linux/gfp.h instead ? This is still very much HugeTLB specific.

 include/linux/hugetlb.h |  9 +++++++++
 mm/hugetlb.c            | 24 ++++++++++++++++++++++--
 2 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 53fc34f930d0..cc50d5ad4885 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -299,6 +299,9 @@ static inline bool is_file_hugepages(struct file *file)
 }
 
 
+struct page *
+alloc_gigantic_page_order(unsigned int order, gfp_t gfp_mask,
+			  int nid, nodemask_t *nodemask);
 #else /* !CONFIG_HUGETLBFS */
 
 #define is_file_hugepages(file)			false
@@ -310,6 +313,12 @@ hugetlb_file_setup(const char *name, size_t size, vm_flags_t acctflag,
 	return ERR_PTR(-ENOSYS);
 }
 
+static inline struct page *
+alloc_gigantic_page_order(unsigned int order, gfp_t gfp_mask,
+			  int nid, nodemask_t *nodemask)
+{
+	return NULL;
+}
 #endif /* !CONFIG_HUGETLBFS */
 
 #ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ef37c85423a5..3fb81252f52b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1112,10 +1112,9 @@ static bool zone_spans_last_pfn(const struct zone *zone,
 	return zone_spans_pfn(zone, last_pfn);
 }
 
-static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
+struct page *alloc_gigantic_page_order(unsigned int order, gfp_t gfp_mask,
 		int nid, nodemask_t *nodemask)
 {
-	unsigned int order = huge_page_order(h);
 	unsigned long nr_pages = 1 << order;
 	unsigned long ret, pfn, flags;
 	struct zonelist *zonelist;
@@ -1151,6 +1150,14 @@ static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
 	return NULL;
 }
 
+static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
+					int nid, nodemask_t *nodemask)
+{
+	unsigned int order = huge_page_order(h);
+
+	return alloc_gigantic_page_order(order, gfp_mask, nid, nodemask);
+}
+
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
 static void prep_compound_gigantic_page(struct page *page, unsigned int order);
 #else /* !CONFIG_CONTIG_ALLOC */
@@ -1159,6 +1166,12 @@ static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
 {
 	return NULL;
 }
+
+struct page *alloc_gigantic_page_order(unsigned int order, gfp_t gfp_mask,
+				       int nid, nodemask_t *nodemask)
+{
+	return NULL;
+}
 #endif /* CONFIG_CONTIG_ALLOC */
 
 #else /* !CONFIG_ARCH_HAS_GIGANTIC_PAGE */
@@ -1167,6 +1180,13 @@ static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
 {
 	return NULL;
 }
+
+struct page *alloc_gigantic_page_order(unsigned int order, gfp_t gfp_mask,
+				       int nid, nodemask_t *nodemask)
+{
+	return NULL;
+}
+
 static inline void free_gigantic_page(struct page *page, unsigned int order) { }
 static inline void destroy_compound_gigantic_page(struct page *page,
 						unsigned int order) { }
-- 
2.20.1


