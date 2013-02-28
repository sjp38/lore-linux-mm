Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 6BE566B0009
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 00:25:32 -0500 (EST)
Received: by mail-qe0-f45.google.com with SMTP id b4so1145015qen.32
        for <linux-mm@kvack.org>; Wed, 27 Feb 2013 21:25:31 -0800 (PST)
From: kosaki.motohiro@gmail.com
Subject: [PATCH 1/2] mempolicy: fix wrong sp_node insertion
Date: Thu, 28 Feb 2013 00:25:06 -0500
Message-Id: <1362029107-3908-1-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <CAJd=RBBxTutPsF+XPZGt44eT1f0uPAQfCvQj_UmwdDg82J=F+A@mail.gmail.com>
References: <CAJd=RBBxTutPsF+XPZGt44eT1f0uPAQfCvQj_UmwdDg82J=F+A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, Hillf Danton <dhillf@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

From: Hillf Danton <dhillf@gmail.com>

n->end is accessed in sp_insert(). Thus it should be update
before calling sp_insert(). This mistake may make kernel panic.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mempolicy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 31d2663..868d08f 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2391,8 +2391,8 @@ static int shared_policy_replace(struct shared_policy *sp, unsigned long start,
 				*mpol_new = *n->policy;
 				atomic_set(&mpol_new->refcnt, 1);
 				sp_node_init(n_new, n->end, end, mpol_new);
-				sp_insert(sp, n_new);
 				n->end = start;
+				sp_insert(sp, n_new);
 				n_new = NULL;
 				mpol_new = NULL;
 				break;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
