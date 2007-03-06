Date: Tue, 6 Mar 2007 14:00:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC} memory unplug patchset prep [15/16] hot-unplug interface for
 ia64
Message-Id: <20070306140020.552d1c7f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Call offline pages from remove_memory().

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 arch/ia64/mm/init.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

Index: devel-tree-2.6.20-mm2/arch/ia64/mm/init.c
===================================================================
--- devel-tree-2.6.20-mm2.orig/arch/ia64/mm/init.c
+++ devel-tree-2.6.20-mm2/arch/ia64/mm/init.c
@@ -759,7 +759,18 @@ int arch_add_memory(int nid, u64 start, 
 
 int remove_memory(u64 start, u64 size)
 {
-	return -EINVAL;
+	unsigned long start_pfn, end_pfn;
+	unsigned long timeout = 120 * HZ;
+	int ret;
+	start_pfn = start >> PAGE_SHIFT;
+	end_pfn = start_pfn + (size >> PAGE_SHIFT);
+	ret = offline_pages(start_pfn, end_pfn, timeout);
+	if (ret)
+		goto out;
+	/* we can free mem_map at this point */
+out:
+	return ret;
 }
+
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
