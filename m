Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7BF1B6B01AD
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 14:50:55 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 19 Mar 2010 14:59:40 -0400
Message-Id: <20100319185940.21430.38739.sendpatchset@localhost.localdomain>
In-Reply-To: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
References: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
Subject: [PATCH 1/6] Mempolicy: Don't call mpol_set_nodemask() when no_context
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ravikiran Thirumalai <kiran@scalex86.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Atop Kosaki Motohiro's mpol_parse_str() cleanup series.

No need to call mpol_set_nodemask() when we have no context for
the mempolicy.  This can occur when we're parsing a tmpfs 'mpol'
mount option.  Just save the raw nodemask in the mempolicy's
w.user_nodemask member for use when a tmpfs/shmem file is
created.  mpol_shared_policy_init() will "contextualize" the
policy for the new file based on the creating task's context.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

Index: linux-2.6.34-rc1-mmotm-100311-1313/mm/mempolicy.c
===================================================================
--- linux-2.6.34-rc1-mmotm-100311-1313.orig/mm/mempolicy.c	2010-03-19 09:03:14.000000000 -0400
+++ linux-2.6.34-rc1-mmotm-100311-1313/mm/mempolicy.c	2010-03-19 09:03:17.000000000 -0400
@@ -2245,7 +2245,10 @@ int mpol_parse_str(char *str, struct mem
 	if (IS_ERR(new))
 		goto out;
 
-	{
+	if (no_context) {
+		/* save for contextualization */
+		new->w.user_nodemask = nodes;
+	} else {
 		int ret;
 		NODEMASK_SCRATCH(scratch);
 		if (scratch) {
@@ -2261,10 +2264,6 @@ int mpol_parse_str(char *str, struct mem
 		}
 	}
 	err = 0;
-	if (no_context) {
-		/* save for contextualization */
-		new->w.user_nodemask = nodes;
-	}
 
 out:
 	/* Restore string for error message */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
