Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id A96106B00BA
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 05:18:37 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH v2 05/13] x86, numa, acpi, memory-hotplug: Consider hotplug info when cleanup numa_meminfo.
Date: Tue, 30 Apr 2013 17:21:15 +0800
Message-Id: <1367313683-10267-6-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1367313683-10267-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, laijs@cn.fujitsu.com, davem@davemloft.net, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Since we have introduced hotplug info into struct numa_meminfo, we need
to consider it when cleanup numa_meminfo.

The original logic in numa_cleanup_meminfo() is:
Merge blocks on the same node, holes between which don't overlap with
memory on other nodes.

This patch modifies numa_cleanup_meminfo() logic like this:
Merge blocks with the same hotpluggable type on the same node, holes
between which don't overlap with memory on other nodes.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/numa.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index ecf37fd..26d1800 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -296,18 +296,22 @@ int __init numa_cleanup_meminfo(struct numa_meminfo *mi)
 			}
 
 			/*
-			 * Join together blocks on the same node, holes
-			 * between which don't overlap with memory on other
-			 * nodes.
+			 * Join together blocks on the same node, with the same
+			 * hotpluggable flags, holes between which don't overlap
+			 * with memory on other nodes.
 			 */
 			if (bi->nid != bj->nid)
 				continue;
+			if (bi->hotpluggable != bj->hotpluggable)
+				continue;
+
 			start = min(bi->start, bj->start);
 			end = max(bi->end, bj->end);
 			for (k = 0; k < mi->nr_blks; k++) {
 				struct numa_memblk *bk = &mi->blk[k];
 
-				if (bi->nid == bk->nid)
+				if (bi->nid == bk->nid &&
+				    bi->hotpluggable == bk->hotpluggable)
 					continue;
 				if (start < bk->end && end > bk->start)
 					break;
@@ -327,6 +331,7 @@ int __init numa_cleanup_meminfo(struct numa_meminfo *mi)
 	for (i = mi->nr_blks; i < ARRAY_SIZE(mi->blk); i++) {
 		mi->blk[i].start = mi->blk[i].end = 0;
 		mi->blk[i].nid = NUMA_NO_NODE;
+		mi->blk[i].hotpluggable = false;
 	}
 
 	return 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
