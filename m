Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14B71C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:03:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8A892175B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:03:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8A892175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7E736B0010; Thu, 21 Mar 2019 16:03:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9ECE6B0008; Thu, 21 Mar 2019 16:03:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76EF56B0008; Thu, 21 Mar 2019 16:03:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C26CC6B0008
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:03:00 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j10so6477341pff.5
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:03:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Of1nlBcwSQDxF7g8uZVRddiVCwLGPv/XHyS3dYVKxIk=;
        b=SuNvraQra0owJG8q8S5mHH9W0eBJKHhM52XPTfOGN7CRxoc8tSgpeVQBKGWszNgajT
         RooL97dSVVNErm83vLPhmnkG05dkumAD/5SmmwHbom7mLsoNbd6Yk+0IhdGOzj5xDn25
         C8DuOOWxzsE7D6DWnOf5o0dTkPPli3DwOSTbxQQJpAjWitSLf/P0TYoflEkumcEG2E/L
         R4r1tQ9eifIGVccUMjRxbvIOim9ACrx85Vx8BJXDl1z51j39yc4dEeapY6suv5Uid9a1
         DPDAwYYnvZclZl1y3GUHRYMChFS9vvf63CL6wZFMVc/bXFiU1xndi9bTjIoMke0rLzik
         rMXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUYBdcfG6nmvZHw/+V8j/RuDAWTO4Ude3fZa/3942P1tj9nCmM9
	5CPcx0U71jWC1PY8F4HgifvqPlRGO39nFx6BkLbFAWonwD2FdZVY/6Tr0MWB+6dp6d3s2TGhMv4
	UCaRF/s6s9RqhmosmRbbZnfWg/eK3+g6XqVV7hCsD3PC+fs4yQKTf9QGqu7yPEfbkAg==
X-Received: by 2002:a17:902:2ac3:: with SMTP id j61mr5428506plb.112.1553198579531;
        Thu, 21 Mar 2019 13:02:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQDNvH7MvJHTuqBpSSF+VOMaS2qWW9zFO8AzwmGHwY4zosZpBRaUQI6mA/o6C33bsIKFoo
X-Received: by 2002:a17:902:2ac3:: with SMTP id j61mr5428431plb.112.1553198578451;
        Thu, 21 Mar 2019 13:02:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553198578; cv=none;
        d=google.com; s=arc-20160816;
        b=wQbxBlac9FO7qBnAnP1YqLKHbL7yz/D7N1XeDG0O3hHDedJB9gZUtGE8I/YbFDBqlz
         e/T2VaPxl0dgsospVZoJbBAg2EV3/yMKNQ8kOvG8VgA90zHTAq1REyjN8HffjlnbbjSE
         4k/cUcIsWC0hbXoEZMYRPiCYqoKKWY/NGfFSdZgIYeqDEo+oQPcJPquiNeZmV+iBOmP4
         vdQ0NkxHKDpRntu+V5J8E8sste27Ic8SP9X8yWQDKLeit5aRW1ipTuVWptr7Pp6TcuQB
         jkWrEUySZiIpUmwYhGECYsrUKWWLqAJrHtKoSPkvGEGC4rsIkfGWAcGyQMef2mL4j0Lk
         ysJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Of1nlBcwSQDxF7g8uZVRddiVCwLGPv/XHyS3dYVKxIk=;
        b=xQsz6Ny9zefVdsafmssWBn3z6FPJ25huUp/rjqxenwssYwB9Pkynf46jl76N1fITzp
         Ag5XXyydHgWmjQVcLw1kK5pQ4HGTBAxaPtFsIchVrO9wFVzdwWc5wEyQlswPuU6cftPa
         5hKaahwGxun4mToV6ohpOsTgyxWPwD6Uza+gESmYUgUH1EWtZ6n3ohKKzmrtFNwFU23f
         PbSbrepNi7rZAA6rYW+pwtVlmq1janq0UjT9nERVNM5aLy0jIfxPR5YlOAMR/jYqQ0yn
         sIVJZYQ1jQos0UwoAdDTU42Pfy7ZUlcVFyovQVUxjAfU1a84dABqnGQJjYkWsgecpKif
         wy1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id r25si4703408pfd.91.2019.03.21.13.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 13:02:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Mar 2019 13:02:57 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,254,1549958400"; 
   d="scan'208";a="309246241"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by orsmga005.jf.intel.com with ESMTP; 21 Mar 2019 13:02:57 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCH 3/5] mm: Attempt to migrate page in lieu of discard
Date: Thu, 21 Mar 2019 14:01:55 -0600
Message-Id: <20190321200157.29678-4-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190321200157.29678-1-keith.busch@intel.com>
References: <20190321200157.29678-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If a memory node has a preferred migration path to demote cold pages,
attempt to move those inactive pages to that migration node before
reclaiming. This will better utilize available memory, provide a faster
tier than swapping or discarding, and allow such pages to be reused
immediately without IO to retrieve the data.

Some places we would like to see this used:

 1. Persistent memory being as a slower, cheaper DRAM replacement
 2. Remote memory-only "expansion" NUMA nodes
 3. Resolving memory imbalances where one NUMA node is seeing more
    allocation activity than another.  This helps keep more recent
    allocations closer to the CPUs on the node doing the allocating.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 include/linux/migrate.h        |  6 ++++++
 include/trace/events/migrate.h |  3 ++-
 mm/debug.c                     |  1 +
 mm/migrate.c                   | 45 ++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                    | 15 ++++++++++++++
 5 files changed, 69 insertions(+), 1 deletion(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index e13d9bf2f9a5..a004cb1b2dbb 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -25,6 +25,7 @@ enum migrate_reason {
 	MR_MEMPOLICY_MBIND,
 	MR_NUMA_MISPLACED,
 	MR_CONTIG_RANGE,
+	MR_DEMOTION,
 	MR_TYPES
 };
 
@@ -79,6 +80,7 @@ extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 extern int migrate_page_move_mapping(struct address_space *mapping,
 		struct page *newpage, struct page *page, enum migrate_mode mode,
 		int extra_count);
+extern bool migrate_demote_mapping(struct page *page);
 #else
 
 static inline void putback_movable_pages(struct list_head *l) {}
@@ -105,6 +107,10 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
 	return -ENOSYS;
 }
 
+static inline bool migrate_demote_mapping(struct page *page)
+{
+	return false;
+}
 #endif /* CONFIG_MIGRATION */
 
 #ifdef CONFIG_COMPACTION
diff --git a/include/trace/events/migrate.h b/include/trace/events/migrate.h
index 705b33d1e395..d25de0cc8714 100644
--- a/include/trace/events/migrate.h
+++ b/include/trace/events/migrate.h
@@ -20,7 +20,8 @@
 	EM( MR_SYSCALL,		"syscall_or_cpuset")		\
 	EM( MR_MEMPOLICY_MBIND,	"mempolicy_mbind")		\
 	EM( MR_NUMA_MISPLACED,	"numa_misplaced")		\
-	EMe(MR_CONTIG_RANGE,	"contig_range")
+	EM(MR_CONTIG_RANGE,	"contig_range")			\
+	EMe(MR_DEMOTION,	"demotion")
 
 /*
  * First define the enums in the above macros to be exported to userspace
diff --git a/mm/debug.c b/mm/debug.c
index c0b31b6c3877..53d499f65199 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -25,6 +25,7 @@ const char *migrate_reason_names[MR_TYPES] = {
 	"mempolicy_mbind",
 	"numa_misplaced",
 	"cma",
+	"demotion",
 };
 
 const struct trace_print_flags pageflag_names[] = {
diff --git a/mm/migrate.c b/mm/migrate.c
index 705b320d4b35..83fad87361bf 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1152,6 +1152,51 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	return rc;
 }
 
+/**
+ * migrate_demote_mapping() - Migrate this page and its mappings to its
+ * 			      demotion node.
+ * @page: An isolated, non-compound page that should move to
+ * 	  its current node's migration path.
+ *
+ * @returns: True if migrate demotion was successful, false otherwise
+ */
+bool migrate_demote_mapping(struct page *page)
+{
+	int rc, next_nid = next_migration_node(page_to_nid(page));
+	struct page *newpage;
+
+	/*
+	 * The flags are set to allocate only on the desired node in the
+	 * migration path, and to fail fast if not immediately available. We
+	 * are already in the memory reclaim path, we don't want heroic
+	 * efforts to get a page.
+	 */
+	gfp_t mask = GFP_NOWAIT	| __GFP_NOWARN | __GFP_NORETRY |
+		     __GFP_NOMEMALLOC | __GFP_THISNODE;
+
+	VM_BUG_ON_PAGE(PageCompound(page), page);
+	VM_BUG_ON_PAGE(PageLRU(page), page);
+
+	if (next_nid < 0)
+		return false;
+
+	newpage = alloc_pages_node(next_nid, mask, 0);
+	if (!newpage)
+		return false;
+
+	/*
+	 * MIGRATE_ASYNC is the most light weight and never blocks.
+	 */
+	rc = __unmap_and_move_locked(page, newpage, MIGRATE_ASYNC);
+	if (rc != MIGRATEPAGE_SUCCESS) {
+		__free_pages(newpage, 0);
+		return false;
+	}
+
+	set_page_owner_migrate_reason(newpage, MR_DEMOTION);
+	return true;
+}
+
 /*
  * gcc 4.7 and 4.8 on arm get an ICEs when inlining unmap_and_move().  Work
  * around it.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a5ad0b35ab8e..0a95804e946a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1261,6 +1261,21 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			; /* try to reclaim the page below */
 		}
 
+		if (!PageCompound(page)) {
+			if (migrate_demote_mapping(page)) {
+                                unlock_page(page);
+                                if (likely(put_page_testzero(page)))
+                                        goto free_it;
+
+                                /*
+				 * Speculative reference will free this page,
+				 * so leave it off the LRU.
+				 */
+                                nr_reclaimed++;
+                                continue;
+                        }
+		}
+
 		/*
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
-- 
2.14.4

