Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE706B01B3
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 14:51:12 -0400 (EDT)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 19 Mar 2010 14:59:58 -0400
Message-Id: <20100319185958.21430.93050.sendpatchset@localhost.localdomain>
In-Reply-To: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
References: <20100319185933.21430.72039.sendpatchset@localhost.localdomain>
Subject: [PATCH 4/6] Mempolicy: factor mpol_shared_policy_init() return paths
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ravikiran Thirumalai <kiran@scalex86.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Factor out duplicate put/frees in mpol_shared_policy_init() to
a common return path.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mempolicy.c |   16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

Index: linux-2.6.34-rc1-mmotm-100311-1313/mm/mempolicy.c
===================================================================
--- linux-2.6.34-rc1-mmotm-100311-1313.orig/mm/mempolicy.c	2010-03-19 09:03:22.000000000 -0400
+++ linux-2.6.34-rc1-mmotm-100311-1313/mm/mempolicy.c	2010-03-19 09:06:09.000000000 -0400
@@ -2001,26 +2001,22 @@ void mpol_shared_policy_init(struct shar
 			return;
 		/* contextualize the tmpfs mount point mempolicy */
 		new = mpol_new(mpol->mode, mpol->flags, &mpol->w.user_nodemask);
-		if (IS_ERR(new)) {
-			mpol_put(mpol);	/* drop our ref on sb mpol */
-			NODEMASK_SCRATCH_FREE(scratch);
-			return;		/* no valid nodemask intersection */
-		}
+		if (IS_ERR(new))
+			goto put_free; /* no valid nodemask intersection */
 
 		task_lock(current);
 		ret = mpol_set_nodemask(new, &mpol->w.user_nodemask, scratch);
 		task_unlock(current);
 		mpol_put(mpol);	/* drop our ref on sb mpol */
-		if (ret) {
-			NODEMASK_SCRATCH_FREE(scratch);
-			mpol_put(new);
-			return;
-		}
+		if (ret)
+			goto put_free;
 
 		/* Create pseudo-vma that contains just the policy */
 		memset(&pvma, 0, sizeof(struct vm_area_struct));
 		pvma.vm_end = TASK_SIZE;	/* policy covers entire file */
 		mpol_set_shared_policy(sp, &pvma, new); /* adds ref */
+
+put_free:
 		mpol_put(new);			/* drop initial ref */
 		NODEMASK_SCRATCH_FREE(scratch);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
