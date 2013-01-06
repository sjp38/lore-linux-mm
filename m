Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 26AD26B005D
	for <linux-mm@kvack.org>; Sun,  6 Jan 2013 02:22:54 -0500 (EST)
From: Jason Liu <r64343@freescale.com>
Subject: [PATCH] mm: compaction: fix echo 1 > compact_memory return error issue
Date: Sun, 6 Jan 2013 15:44:33 +0800
Message-ID: <1357458273-28558-1-git-send-email-r64343@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mgorman@suse.de, akpm@linux-foundation.org, riel@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

when run the folloing command under shell, it will return error
sh/$ echo 1 > /proc/sys/vm/compact_memory
sh/$ sh: write error: Bad address

After strace, I found the following log:
...
write(1, "1\n", 2)               = 3
write(1, "", 4294967295)         = -1 EFAULT (Bad address)
write(2, "echo: write error: Bad address\n", 31echo: write error: Bad address
) = 31

This tells system return 3(COMPACT_COMPLETE) after write data to compact_memory.

The fix is to make the system just return 0 instead 3(COMPACT_COMPLETE) from
sysctl_compaction_handler after compaction_nodes finished.

Suggested-by:David Rientjes <rientjes@google.com>
Cc:Mel Gorman <mgorman@suse.de>
Cc:Andrew Morton <akpm@linux-foundation.org>
Cc:Rik van Riel <riel@redhat.com>
Cc:Minchan Kim <minchan@kernel.org>
Cc:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Jason Liu <r64343@freescale.com>
---
 mm/compaction.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 6b807e4..f8f5c11 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1210,7 +1210,7 @@ static int compact_node(int nid)
 }
 
 /* Compact all nodes in the system */
-static int compact_nodes(void)
+static void compact_nodes(void)
 {
 	int nid;
 
@@ -1219,8 +1219,6 @@ static int compact_nodes(void)
 
 	for_each_online_node(nid)
 		compact_node(nid);
-
-	return COMPACT_COMPLETE;
 }
 
 /* The written value is actually unused, all memory is compacted */
@@ -1231,7 +1229,7 @@ int sysctl_compaction_handler(struct ctl_table *table, int write,
 			void __user *buffer, size_t *length, loff_t *ppos)
 {
 	if (write)
-		return compact_nodes();
+		compact_nodes();
 
 	return 0;
 }
-- 
1.7.5.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
