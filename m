Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 30B1D6B01B5
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 14:51:19 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 19 Mar 2010 15:00:04 -0400
Message-Id: <20100319190004.21430.86684.sendpatchset@localhost.localdomain>
In-Reply-To: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
References: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
Subject: [BUGFIX][PATCH 5/6] Mempolicy: fix get_mempolicy() for relative and static nodes
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ravikiran Thirumalai <kiran@scalex86.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Discovered while testing other mempolicy changes:

get_mempolicy() does not handle static/relative mode flags correctly.
Return the value that the user specified so that it can be restored
via set_mempolicy() if desired.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

Index: linux-2.6.34-rc1-mmotm-100311-1313/mm/mempolicy.c
===================================================================
--- linux-2.6.34-rc1-mmotm-100311-1313.orig/mm/mempolicy.c	2010-03-19 09:06:09.000000000 -0400
+++ linux-2.6.34-rc1-mmotm-100311-1313/mm/mempolicy.c	2010-03-19 09:23:29.000000000 -0400
@@ -806,9 +806,13 @@ static long do_get_mempolicy(int *policy
 
 	err = 0;
 	if (nmask) {
-		task_lock(current);
-		get_policy_nodemask(pol, nmask);
-		task_unlock(current);
+		if (mpol_store_user_nodemask(pol)) {
+			*nmask = pol->w.user_nodemask;
+		} else {
+			task_lock(current);
+			get_policy_nodemask(pol, nmask);
+			task_unlock(current);
+		}
 	}
 
  out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
