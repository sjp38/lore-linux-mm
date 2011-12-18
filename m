Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 776666B004F
	for <linux-mm@kvack.org>; Sun, 18 Dec 2011 06:59:19 -0500 (EST)
Received: by iacb35 with SMTP id b35so6680140iac.14
        for <linux-mm@kvack.org>; Sun, 18 Dec 2011 03:59:18 -0800 (PST)
From: Ryota Ozaki <ozaki.ryota@gmail.com>
Subject: [PATCH][RESEND] mm: Fix off-by-one bug in print_nodes_state
Date: Sun, 18 Dec 2011 20:58:49 +0900
Message-Id: <1324209529-15892-1-git-send-email-ozaki.ryota@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>
Cc: linux-mm@kvack.org, stable@kernel.org

/sys/devices/system/node/{online,possible} involve a garbage byte
because print_nodes_state returns content size + 1. To fix the bug,
the patch changes the use of cpuset_sprintf_cpulist to follow the
use at other places, which is clearer and safer.

This bug was introduced since v2.6.24.

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
