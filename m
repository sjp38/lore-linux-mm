Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 350A6C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7D9320896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7D9320896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 866538E0008; Thu, 13 Jun 2019 19:30:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 815D78E0002; Thu, 13 Jun 2019 19:30:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72DD28E0008; Thu, 13 Jun 2019 19:30:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3795A8E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:30:49 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s195so438664pgs.13
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:30:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=kRKtKXN9Ruak/c7ToZZ3XfPYKZNVzcu9jLGB925/+eY=;
        b=hrJmKwNptXPdGmVwXsXv6e59M+jyuZ3L0/ATcc6feDe0zB9wWc2kiA2wFYoegejWfZ
         R21kTSLzsFtLpVtbUC+Bzez68Mg3zyJwqt7v55CObxyAIuzoHDc5xRfn6JMiAdalojoR
         XwJbDTh0ynRAjaZlFipnmE6v3hoEwX3ukzcmdz/CXlqvMDD3pXWTnfXawSl1xmUv0Ldp
         EUzG/EkSKvdmSF8E3V/YSEYrsBHvmkdShY41o6TvAEjCcGdyAwdXk1fGPVD6UJyPiROt
         PVvkbvY/TuV33rDJc5aSsV99Y426EgEevXERhja4dByKd05/r6sojHq0F9x+6ilFW4cm
         OyhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX662hdIBbfoTnoNgaF8/ZF9bw/jzPhTjvkhj+vZpDxYnnk1dYA
	9V4U/bcZ8jGGbaP8ex6yF4ohfXpxdnoYH6CKrC7vk6y9mKpntbWBu+jh5LvhTkkCAZpjDYmNomz
	HhAIcpuQl51/pKU67PwJZqF32qDdpudRpEyrEawFxL4qDpocvPZTQXBxciJeoqeKVww==
X-Received: by 2002:a62:ce05:: with SMTP id y5mr4575906pfg.166.1560468648818;
        Thu, 13 Jun 2019 16:30:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQAqVWcSekV6JEsYfSBH1zzuLJxU4C6K8MmTPMEKMixybv+Xr2sMrH5Y1WrNWEHZyiTtIc
X-Received: by 2002:a62:ce05:: with SMTP id y5mr4575778pfg.166.1560468647057;
        Thu, 13 Jun 2019 16:30:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560468647; cv=none;
        d=google.com; s=arc-20160816;
        b=lUp39rvRy13r0xEoezS81TQR6tC7G5IZb9I4PTPNJAXg7YU3x7v0OgSW3l2B+n2zwT
         N52oiwfqcgVRWCvxslFLuJK93L6gjlUxHNVyy56zqc6Vms3irv+73VnOV+Frp1GpDchJ
         c3mnzONxNKqMbYE6pqAErJrHkjGCE/wewmHgyCtmBCmJye1Un04znXLsg8SVynA8wO/p
         N3o87QG3TJbvfsf8McCbUeFQNYw5eZvMCl9kjGAC1zJyVcgDaIVaRZNLPD+3cUnaWod/
         Q/0om5q2TSMkAVx4gKmDMWLuPl99sWwI3lYpUVwaT4xv7ovR/jqXl/UmZyMaOeKAmhmP
         Xekg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=kRKtKXN9Ruak/c7ToZZ3XfPYKZNVzcu9jLGB925/+eY=;
        b=i4/BXlL5xdH8OvmY6W+WZgPcyHRjDHf9LNhAuBanFJrtfhKOHMnxKEDxpyuWIZPFII
         pAX4Hrwj6glSCWJ2fRLa73HUleKvbsZcr0GhP7z+f5ppGjm8i3xpB21v7VM1cFckJpmk
         y4i/Y5bqlyBytkeym38LiZ2PVjAVP4FwQE6EmZTn15zk2eNZB85K4lT2N0xk1631wyHc
         OQj9asHrEkD93oQGWDzbYE8kVkrAZPgU2mq7Gmr/CF3PczUM2/NDlappSapiAnSAr5ID
         3vBq/Y5CmrWCARTI3qzMgk1agZ4pKE09RZk3wlDBJk42Z5ABl09Uw0n7g/aju5v7cVO1
         UvTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id 66si888948pgg.199.2019.06.13.16.30.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 16:30:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R271e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TU6DYEz_1560468591;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU6DYEz_1560468591)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 14 Jun 2019 07:29:59 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	mgorman@techsingularity.net,
	riel@surriel.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org,
	dave.hansen@intel.com,
	keith.busch@intel.com,
	dan.j.williams@intel.com,
	fengguang.wu@intel.com,
	fan.du@intel.com,
	ying.huang@intel.com,
	ziy@nvidia.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH 4/9] mm: migrate: make migrate_pages() return nr_succeeded
Date: Fri, 14 Jun 2019 07:29:32 +0800
Message-Id: <1560468577-101178-5-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The migrate_pages() returns the number of pages that were not migrated,
or an error code.  When returning an error code, there is no way to know
how many pages were migrated or not migrated.

In the following patch, migrate_pages() is used to demote pages to PMEM
node, we need account how many pages are reclaimed (demoted) since page
reclaim behavior depends on this.  Add *nr_succeeded parameter to make
migrate_pages() return how many pages are demoted successfully for all
cases.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/migrate.h |  5 +++--
 mm/compaction.c         |  3 ++-
 mm/gup.c                |  4 +++-
 mm/memory-failure.c     |  7 +++++--
 mm/memory_hotplug.c     |  4 +++-
 mm/mempolicy.c          |  7 +++++--
 mm/migrate.c            | 18 ++++++++++--------
 mm/page_alloc.c         |  4 +++-
 8 files changed, 34 insertions(+), 18 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index e13d9bf..837fdd1 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -66,7 +66,8 @@ extern int migrate_page(struct address_space *mapping,
 			struct page *newpage, struct page *page,
 			enum migrate_mode mode);
 extern int migrate_pages(struct list_head *l, new_page_t new, free_page_t free,
-		unsigned long private, enum migrate_mode mode, int reason);
+		unsigned long private, enum migrate_mode mode, int reason,
+		unsigned int *nr_succeeded);
 extern int isolate_movable_page(struct page *page, isolate_mode_t mode);
 extern void putback_movable_page(struct page *page);
 
@@ -84,7 +85,7 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
 static inline void putback_movable_pages(struct list_head *l) {}
 static inline int migrate_pages(struct list_head *l, new_page_t new,
 		free_page_t free, unsigned long private, enum migrate_mode mode,
-		int reason)
+		int reason, unsigned int *nr_succeeded)
 	{ return -ENOSYS; }
 static inline int isolate_movable_page(struct page *page, isolate_mode_t mode)
 	{ return -EBUSY; }
diff --git a/mm/compaction.c b/mm/compaction.c
index 9febc8c..c1723e5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2074,6 +2074,7 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 	unsigned long last_migrated_pfn;
 	const bool sync = cc->mode != MIGRATE_ASYNC;
 	bool update_cached;
+	unsigned int nr_succeeded = 0;
 
 	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	ret = compaction_suitable(cc->zone, cc->order, cc->alloc_flags,
@@ -2182,7 +2183,7 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
 				compaction_free, (unsigned long)cc, cc->mode,
-				MR_COMPACTION);
+				MR_COMPACTION, &nr_succeeded);
 
 		trace_mm_compaction_migratepages(cc->nr_migratepages, err,
 							&cc->migratepages);
diff --git a/mm/gup.c b/mm/gup.c
index 2c08248..446ce25 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1337,6 +1337,7 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 	long i;
 	bool drain_allow = true;
 	bool migrate_allow = true;
+	unsigned int nr_succeeded = 0;
 	LIST_HEAD(cma_page_list);
 
 check_again:
@@ -1377,7 +1378,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 			put_page(pages[i]);
 
 		if (migrate_pages(&cma_page_list, new_non_cma_page,
-				  NULL, 0, MIGRATE_SYNC, MR_CONTIG_RANGE)) {
+				  NULL, 0, MIGRATE_SYNC, MR_CONTIG_RANGE,
+				  &nr_succeeded)) {
 			/*
 			 * some of the pages failed migration. Do get_user_pages
 			 * without migration.
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index fc8b517..b5d8a8f 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1686,6 +1686,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
 	struct page *hpage = compound_head(page);
+	unsigned int nr_succeeded = 0;
 	LIST_HEAD(pagelist);
 
 	/*
@@ -1713,7 +1714,7 @@ static int soft_offline_huge_page(struct page *page, int flags)
 	}
 
 	ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
-				MIGRATE_SYNC, MR_MEMORY_FAILURE);
+				MIGRATE_SYNC, MR_MEMORY_FAILURE, &nr_succeeded);
 	if (ret) {
 		pr_info("soft offline: %#lx: hugepage migration failed %d, type %lx (%pGp)\n",
 			pfn, ret, page->flags, &page->flags);
@@ -1742,6 +1743,7 @@ static int __soft_offline_page(struct page *page, int flags)
 {
 	int ret;
 	unsigned long pfn = page_to_pfn(page);
+	unsigned int nr_succeeded = 0;
 
 	/*
 	 * Check PageHWPoison again inside page lock because PageHWPoison
@@ -1801,7 +1803,8 @@ static int __soft_offline_page(struct page *page, int flags)
 						page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
 		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
-					MIGRATE_SYNC, MR_MEMORY_FAILURE);
+					MIGRATE_SYNC, MR_MEMORY_FAILURE,
+					&nr_succeeded);
 		if (ret) {
 			if (!list_empty(&pagelist))
 				putback_movable_pages(&pagelist);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7c29282..1192d08 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1360,6 +1360,7 @@ static struct page *new_node_page(struct page *page, unsigned long private)
 	unsigned long pfn;
 	struct page *page;
 	int ret = 0;
+	unsigned int nr_succeeded = 0;
 	LIST_HEAD(source);
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
@@ -1416,7 +1417,8 @@ static struct page *new_node_page(struct page *page, unsigned long private)
 	if (!list_empty(&source)) {
 		/* Allocate a new page from the nearest neighbor node */
 		ret = migrate_pages(&source, new_node_page, NULL, 0,
-					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
+					MIGRATE_SYNC, MR_MEMORY_HOTPLUG,
+					&nr_succeeded);
 		if (ret) {
 			list_for_each_entry(page, &source, lru) {
 				pr_warn("migrating pfn %lx failed ret:%d ",
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2219e74..b7bc60b 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -988,6 +988,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 	nodemask_t nmask;
 	LIST_HEAD(pagelist);
 	int err = 0;
+	unsigned int nr_succeeded = 0;
 
 	nodes_clear(nmask);
 	node_set(source, nmask);
@@ -1003,7 +1004,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
 
 	if (!list_empty(&pagelist)) {
 		err = migrate_pages(&pagelist, alloc_new_node_page, NULL, dest,
-					MIGRATE_SYNC, MR_SYSCALL);
+					MIGRATE_SYNC, MR_SYSCALL, &nr_succeeded);
 		if (err)
 			putback_movable_pages(&pagelist);
 	}
@@ -1182,6 +1183,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	struct mempolicy *new;
 	unsigned long end;
 	int err;
+	unsigned int nr_succeeded = 0;
 	LIST_HEAD(pagelist);
 
 	if (flags & ~(unsigned long)MPOL_MF_VALID)
@@ -1254,7 +1256,8 @@ static long do_mbind(unsigned long start, unsigned long len,
 		if (!list_empty(&pagelist)) {
 			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
 			nr_failed = migrate_pages(&pagelist, new_page, NULL,
-				start, MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
+				start, MIGRATE_SYNC, MR_MEMPOLICY_MBIND,
+				&nr_succeeded);
 			if (nr_failed)
 				putback_movable_pages(&pagelist);
 		}
diff --git a/mm/migrate.c b/mm/migrate.c
index f2ecc28..bc4242a 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1392,6 +1392,7 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
  * @mode:		The migration mode that specifies the constraints for
  *			page migration, if any.
  * @reason:		The reason for page migration.
+ * @nr_succeeded:	The number of pages migrated successfully.
  *
  * The function returns after 10 attempts or if no pages are movable any more
  * because the list has become empty or no retryable pages exist any more.
@@ -1402,11 +1403,10 @@ static int unmap_and_move_huge_page(new_page_t get_new_page,
  */
 int migrate_pages(struct list_head *from, new_page_t get_new_page,
 		free_page_t put_new_page, unsigned long private,
-		enum migrate_mode mode, int reason)
+		enum migrate_mode mode, int reason, unsigned int *nr_succeeded)
 {
 	int retry = 1;
 	int nr_failed = 0;
-	int nr_succeeded = 0;
 	int pass = 0;
 	struct page *page;
 	struct page *page2;
@@ -1460,7 +1460,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 				retry++;
 				break;
 			case MIGRATEPAGE_SUCCESS:
-				nr_succeeded++;
+				(*nr_succeeded)++;
 				break;
 			default:
 				/*
@@ -1477,11 +1477,11 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 	nr_failed += retry;
 	rc = nr_failed;
 out:
-	if (nr_succeeded)
-		count_vm_events(PGMIGRATE_SUCCESS, nr_succeeded);
+	if (*nr_succeeded)
+		count_vm_events(PGMIGRATE_SUCCESS, *nr_succeeded);
 	if (nr_failed)
 		count_vm_events(PGMIGRATE_FAIL, nr_failed);
-	trace_mm_migrate_pages(nr_succeeded, nr_failed, mode, reason);
+	trace_mm_migrate_pages(*nr_succeeded, nr_failed, mode, reason);
 
 	if (!swapwrite)
 		current->flags &= ~PF_SWAPWRITE;
@@ -1506,12 +1506,13 @@ static int do_move_pages_to_node(struct mm_struct *mm,
 		struct list_head *pagelist, int node)
 {
 	int err;
+	unsigned int nr_succeeded = 0;
 
 	if (list_empty(pagelist))
 		return 0;
 
 	err = migrate_pages(pagelist, alloc_new_node_page, NULL, node,
-			MIGRATE_SYNC, MR_SYSCALL);
+			MIGRATE_SYNC, MR_SYSCALL, &nr_succeeded);
 	if (err)
 		putback_movable_pages(pagelist);
 	return err;
@@ -1944,6 +1945,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	pg_data_t *pgdat = NODE_DATA(node);
 	int isolated;
 	int nr_remaining;
+	unsigned int nr_succeeded = 0;
 	LIST_HEAD(migratepages);
 
 	/*
@@ -1968,7 +1970,7 @@ int migrate_misplaced_page(struct page *page, struct vm_area_struct *vma,
 	list_add(&page->lru, &migratepages);
 	nr_remaining = migrate_pages(&migratepages, alloc_misplaced_dst_page,
 				     NULL, node, MIGRATE_ASYNC,
-				     MR_NUMA_MISPLACED);
+				     MR_NUMA_MISPLACED, &nr_succeeded);
 	if (nr_remaining) {
 		if (!list_empty(&migratepages)) {
 			list_del(&page->lru);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 917f64d..7e95a66 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8209,6 +8209,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 	unsigned long pfn = start;
 	unsigned int tries = 0;
 	int ret = 0;
+	unsigned int nr_succeeded = 0;
 
 	migrate_prep();
 
@@ -8236,7 +8237,8 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 		cc->nr_migratepages -= nr_reclaimed;
 
 		ret = migrate_pages(&cc->migratepages, alloc_migrate_target,
-				    NULL, 0, cc->mode, MR_CONTIG_RANGE);
+				    NULL, 0, cc->mode, MR_CONTIG_RANGE,
+				    &nr_succeeded);
 	}
 	if (ret < 0) {
 		putback_movable_pages(&cc->migratepages);
-- 
1.8.3.1

