Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 69F486B003C
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 09:05:53 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id gf5so135934lab.8
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 06:05:52 -0700 (PDT)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id ad3si48825565lbc.1.2014.07.03.06.05.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 06:05:52 -0700 (PDT)
Received: by mail-la0-f45.google.com with SMTP id hr17so139687lab.18
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 06:05:52 -0700 (PDT)
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH] mm readahead: Fix sys_readahead breakage by reverting 2MB limit (bug 79111)
Date: Thu,  3 Jul 2014 18:32:27 +0530
Message-Id: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, rientjes@google.com, Linus <torvalds@linux-foundation.org>, nacc@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

commit 6d2be915 (mm/readahead.c: fix readahead failure for memoryless NUMA nodes
and limit readahead pages) imposed 2MB limits to readahed that yielded good
performance since it avoided unnecessay page caching.

However it broke sys_readahead semantics: 'readahead() blocks until the specified
data has been read'

This patch still retains the fix for memoryless nodes which used to return zero
and limits its readahead to 2MB to avoid unnecessary page cache thrashing but
reverts to old sanitized readahead for cpu with memory nodes.

link: https://bugzilla.kernel.org/show_bug.cgi?id=79111

Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
 mm/readahead.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/mm/readahead.c b/mm/readahead.c
index 0ca36a7..4514cf6 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -239,6 +239,24 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
  */
 unsigned long max_sane_readahead(unsigned long nr)
 {
+	unsigned long local_free_page;
+	int nid;
+
+	nid = numa_node_id();
+	if (node_present_pages(nid)) {
+		/*
+		 * We sanitize readahead size depending on free memory in
+		 * the local node.
+		 */
+		local_free_page = node_page_state(nid, NR_INACTIVE_FILE)
+				 + node_page_state(nid, NR_FREE_PAGES);
+		return min(nr, local_free_page / 2);
+	}
+	/*
+	 * Readahead onto remote memory is better than no readahead when local
+	 * numa node does not have memory. We limit the readahead to 2MB to
+	 * avoid trashing page cache.
+	 */
 	return min(nr, MAX_READAHEAD);
 }
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
