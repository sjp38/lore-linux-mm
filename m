Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id F39C36B0033
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 20:02:39 -0400 (EDT)
Received: by mail-gh0-f177.google.com with SMTP id f20so334664ghb.22
        for <linux-mm@kvack.org>; Tue, 06 Aug 2013 17:02:38 -0700 (PDT)
Date: Tue, 6 Aug 2013 21:02:23 -0300
From: Mauro Dreissig <mukadr@gmail.com>
Subject: [PATCH] mm: numa: fix NULL pointer dereference
Message-ID: <20130807000154.GA3507@z460>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mukadr@gmail.com

From: Mauro Dreissig <mukadr@gmail.com>

The "pol->mode" field is accessed even when no mempolicy
is assigned to the "pol" variable.

Signed-off-by: Mauro Dreissig <mukadr@gmail.com>
---
 mm/mempolicy.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 6b1d426..105fff0 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -127,12 +127,16 @@ static struct mempolicy *get_task_policy(struct task_struct *p)
 
 	if (!pol) {
 		node = numa_node_id();
-		if (node != NUMA_NO_NODE)
+		if (node != NUMA_NO_NODE) {
 			pol = &preferred_node_policy[node];
 
-		/* preferred_node_policy is not initialised early in boot */
-		if (!pol->mode)
-			pol = NULL;
+			/*
+			 * preferred_node_policy is not initialised early
+			 * in boot
+			 */
+			if (!pol->mode)
+				pol = NULL;
+		}
 	}
 
 	return pol;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
