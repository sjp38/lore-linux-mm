Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 206CF6B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 05:27:17 -0500 (EST)
Received: by bwz16 with SMTP id 16so730436bwz.14
        for <linux-mm@kvack.org>; Tue, 14 Dec 2010 02:27:15 -0800 (PST)
Message-ID: <4D07467D.7080809@gmail.com>
Date: Tue, 14 Dec 2010 12:27:09 +0200
From: "Volodymyr G. Lukiianyk" <volodymyrgl@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] set correct numa_zonelist_order string when configured on
 the kernel command line
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

When numa_zonelist_order parameter is set to "node" or "zone" on the command line
it's still showing as "default" in sysctl. That's because early_param parsing
function changes only user_zonelist_order variable. Fix this by copying
user-provided string to numa_zonelist_order if it was successfully parsed.

Signed-off-by: Volodymyr G Lukiianyk <volodymyrgl@gmail.com>

---

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ff7e158..ddb81af 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2585,9 +2585,16 @@ static int __parse_numa_zonelist_order(char *s)

 static __init int setup_numa_zonelist_order(char *s)
 {
-	if (s)
-		return __parse_numa_zonelist_order(s);
-	return 0;
+	int ret;
+
+	if (!s)
+		return 0;
+
+	ret = __parse_numa_zonelist_order(s);
+	if (ret == 0)
+		strlcpy(numa_zonelist_order, s, NUMA_ZONELIST_ORDER_LEN);
+
+	return ret;
 }
 early_param("numa_zonelist_order", setup_numa_zonelist_order);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
