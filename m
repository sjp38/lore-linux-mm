Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 667426B0075
	for <linux-mm@kvack.org>; Sat, 26 Nov 2011 10:43:07 -0500 (EST)
Received: by iaek3 with SMTP id k3so8251182iae.14
        for <linux-mm@kvack.org>; Sat, 26 Nov 2011 07:43:04 -0800 (PST)
From: Ryota Ozaki <ozaki.ryota@gmail.com>
Subject: [PATCH] mm: Fix off-by-one bug in print_nodes_state
Date: Sun, 27 Nov 2011 00:42:53 +0900
Message-Id: <1322322173-14401-1-git-send-email-ozaki.ryota@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: stable@kernel.org

/sys/devices/system/node/{online,possible} involve a garbage byte
because print_nodes_state returns content size + 1. To fix the bug,
the patch changes the use of cpuset_sprintf_cpulist to follow the
use at other places, which is clearer and safer.

This bug was introduced since v2.6.24 (bde631a51876f23e9).

Signed-off-by: Ryota Ozaki <ozaki.ryota@gmail.com>
---
 drivers/base/node.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 5693ece..ef7c1f9 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -587,11 +587,9 @@ static ssize_t print_nodes_state(enum node_states state, char *buf)
 {
 	int n;
 
-	n = nodelist_scnprintf(buf, PAGE_SIZE, node_states[state]);
-	if (n > 0 && PAGE_SIZE > n + 1) {
-		*(buf + n++) = '\n';
-		*(buf + n++) = '\0';
-	}
+	n = nodelist_scnprintf(buf, PAGE_SIZE-2, node_states[state]);
+	buf[n++] = '\n';
+	buf[n] = '\0';
 	return n;
 }
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
