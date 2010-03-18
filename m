Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AE0256B010C
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 08:48:07 -0400 (EDT)
Received: by pxi34 with SMTP id 34so1510389pxi.22
        for <linux-mm@kvack.org>; Thu, 18 Mar 2010 05:48:06 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 2/2] mempolicy: remove redundant check
Date: Thu, 18 Mar 2010 20:47:43 +0800
Message-Id: <1268916463-8757-1-git-send-email-user@bob-laptop>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

From: Bob Liu <lliubbo@gmail.com>

Lee's patch "mempolicy: use MPOL_PREFERRED for system-wide
default policy" has made the MPOL_DEFAULT only used in the
memory policy APIs. So, no need to check in __mpol_equal also.
Also get rid of mpol_match_intent() and move its logic directly
into __mpol_equal().

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/mempolicy.c |   16 +++++-----------
 1 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index b88e914..17df048 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1787,16 +1787,6 @@ struct mempolicy *__mpol_cond_copy(struct mempolicy *tompol,
 	return tompol;
 }
 
-static int mpol_match_intent(const struct mempolicy *a,
-			     const struct mempolicy *b)
-{
-	if (a->flags != b->flags)
-		return 0;
-	if (!mpol_store_user_nodemask(a))
-		return 1;
-	return nodes_equal(a->w.user_nodemask, b->w.user_nodemask);
-}
-
 /* Slow path of a mempolicy comparison */
 int __mpol_equal(struct mempolicy *a, struct mempolicy *b)
 {
@@ -1804,7 +1794,11 @@ int __mpol_equal(struct mempolicy *a, struct mempolicy *b)
 		return 0;
 	if (a->mode != b->mode)
 		return 0;
-	if (a->mode != MPOL_DEFAULT && !mpol_match_intent(a, b))
+	if (a->flags != b->flags)
+		return 0;
+	if (mpol_store_user_nodemask(a))
+		return 0;
+	if (!nodes_equal(a->w.user_nodemask, b->w.user_nodemask))
 		return 0;
 	switch (a->mode) {
 	case MPOL_BIND:
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
