Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 704746B0071
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 06:42:05 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o68Ag21e018946
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 8 Jul 2010 19:42:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 30AC845DE4F
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 19:42:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E6D7D45DE4D
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 19:42:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C65AD1DB8038
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 19:42:01 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 74D541DB803B
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 19:41:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] reduce stack usage of node_read_meminfo()
In-Reply-To: <20100708181629.CD3C.A69D9226@jp.fujitsu.com>
References: <20100708181629.CD3C.A69D9226@jp.fujitsu.com>
Message-Id: <20100708194107.CD45.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  8 Jul 2010 19:41:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


Grr, I did sent old ver. right patch is here ;-)
sorry.

================================================
Subject: [PATCH] reduce stack usage of node_read_meminfo()

Now, cmpilation node_read_meminfo() output following warning. Because
it has very large sprintf() argument.

	drivers/base/node.c: In function 'node_read_meminfo':
	drivers/base/node.c:139: warning: the frame size of 848 bytes is
	larger than 512 bytes

This patch fixes it by splitting sprintf() in three parts.
This also reduce CONFIG_HIGHMEM mess a bit.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 drivers/base/node.c |   46 +++++++++++++++++++++++-----------------------
 1 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 2bdd8a9..2872e86 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -66,8 +66,7 @@ static ssize_t node_read_meminfo(struct sys_device * dev,
 	struct sysinfo i;
 
 	si_meminfo_node(&i, nid);
-
-	n = sprintf(buf, "\n"
+	n = sprintf(buf,
 		       "Node %d MemTotal:       %8lu kB\n"
 		       "Node %d MemFree:        %8lu kB\n"
 		       "Node %d MemUsed:        %8lu kB\n"
@@ -78,13 +77,33 @@ static ssize_t node_read_meminfo(struct sys_device * dev,
 		       "Node %d Active(file):   %8lu kB\n"
 		       "Node %d Inactive(file): %8lu kB\n"
 		       "Node %d Unevictable:    %8lu kB\n"
-		       "Node %d Mlocked:        %8lu kB\n"
+		       "Node %d Mlocked:        %8lu kB\n",
+		       nid, K(i.totalram),
+		       nid, K(i.freeram),
+		       nid, K(i.totalram - i.freeram),
+		       nid, K(node_page_state(nid, NR_ACTIVE_ANON) +
+				node_page_state(nid, NR_ACTIVE_FILE)),
+		       nid, K(node_page_state(nid, NR_INACTIVE_ANON) +
+				node_page_state(nid, NR_INACTIVE_FILE)),
+		       nid, K(node_page_state(nid, NR_ACTIVE_ANON)),
+		       nid, K(node_page_state(nid, NR_INACTIVE_ANON)),
+		       nid, K(node_page_state(nid, NR_ACTIVE_FILE)),
+		       nid, K(node_page_state(nid, NR_INACTIVE_FILE)),
+		       nid, K(node_page_state(nid, NR_UNEVICTABLE)),
+		       nid, K(node_page_state(nid, NR_MLOCK)));
+
 #ifdef CONFIG_HIGHMEM
+	n += sprintf(buf + n,
 		       "Node %d HighTotal:      %8lu kB\n"
 		       "Node %d HighFree:       %8lu kB\n"
 		       "Node %d LowTotal:       %8lu kB\n"
-		       "Node %d LowFree:        %8lu kB\n"
+		       "Node %d LowFree:        %8lu kB\n",
+		       nid, K(i.totalhigh),
+		       nid, K(i.freehigh),
+		       nid, K(i.totalram - i.totalhigh),
+		       nid, K(i.freeram - i.freehigh));
 #endif
+	n += sprintf(buf + n,
 		       "Node %d Dirty:          %8lu kB\n"
 		       "Node %d Writeback:      %8lu kB\n"
 		       "Node %d FilePages:      %8lu kB\n"
@@ -99,25 +118,6 @@ static ssize_t node_read_meminfo(struct sys_device * dev,
 		       "Node %d Slab:           %8lu kB\n"
 		       "Node %d SReclaimable:   %8lu kB\n"
 		       "Node %d SUnreclaim:     %8lu kB\n",
-		       nid, K(i.totalram),
-		       nid, K(i.freeram),
-		       nid, K(i.totalram - i.freeram),
-		       nid, K(node_page_state(nid, NR_ACTIVE_ANON) +
-				node_page_state(nid, NR_ACTIVE_FILE)),
-		       nid, K(node_page_state(nid, NR_INACTIVE_ANON) +
-				node_page_state(nid, NR_INACTIVE_FILE)),
-		       nid, K(node_page_state(nid, NR_ACTIVE_ANON)),
-		       nid, K(node_page_state(nid, NR_INACTIVE_ANON)),
-		       nid, K(node_page_state(nid, NR_ACTIVE_FILE)),
-		       nid, K(node_page_state(nid, NR_INACTIVE_FILE)),
-		       nid, K(node_page_state(nid, NR_UNEVICTABLE)),
-		       nid, K(node_page_state(nid, NR_MLOCK)),
-#ifdef CONFIG_HIGHMEM
-		       nid, K(i.totalhigh),
-		       nid, K(i.freehigh),
-		       nid, K(i.totalram - i.totalhigh),
-		       nid, K(i.freeram - i.freehigh),
-#endif
 		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
 		       nid, K(node_page_state(nid, NR_WRITEBACK)),
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
