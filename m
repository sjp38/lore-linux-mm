Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4716290008B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 21:45:04 -0400 (EDT)
Received: by mail-yk0-f175.google.com with SMTP id q9so1861049ykb.20
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 18:45:04 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id w10si5915566ykw.163.2014.10.29.18.45.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 18:45:03 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm: initialize variable for mem_cgroup_end_page_stat
Date: Wed, 29 Oct 2014 21:44:24 -0400
Message-Id: <1414633464-19419-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, riel@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, peterz@infradead.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>

Commit "mm: memcontrol: fix missed end-writeback page accounting" has changed
the behaviour of mem_cgroup_begin_page_stat() to not always set the "locked"
parameter.

We should initialize it at the callers to prevent garbage being used in a
later call to mem_cgroup_end_page_stat().

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 mm/page-writeback.c |    4 ++--
 mm/rmap.c           |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 19ceae8..7a02c97 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2329,7 +2329,7 @@ int test_clear_page_writeback(struct page *page)
 	struct address_space *mapping = page_mapping(page);
 	unsigned long memcg_flags;
 	struct mem_cgroup *memcg;
-	bool locked;
+	bool locked = false;
 	int ret;
 
 	memcg = mem_cgroup_begin_page_stat(page, &locked, &memcg_flags);
@@ -2366,7 +2366,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 	struct address_space *mapping = page_mapping(page);
 	unsigned long memcg_flags;
 	struct mem_cgroup *memcg;
-	bool locked;
+	bool locked = false;
 	int ret;
 
 	memcg = mem_cgroup_begin_page_stat(page, &locked, &memcg_flags);
diff --git a/mm/rmap.c b/mm/rmap.c
index 19886fb..4a4dc84 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1044,7 +1044,7 @@ void page_add_file_rmap(struct page *page)
 {
 	struct mem_cgroup *memcg;
 	unsigned long flags;
-	bool locked;
+	bool locked = false;
 
 	memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
 	if (atomic_inc_and_test(&page->_mapcount)) {
@@ -1058,7 +1058,7 @@ static void page_remove_file_rmap(struct page *page)
 {
 	struct mem_cgroup *memcg;
 	unsigned long flags;
-	bool locked;
+	bool locked = false;
 
 	memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
