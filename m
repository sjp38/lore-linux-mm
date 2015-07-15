Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id AFB352802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 18:44:39 -0400 (EDT)
Received: by iggf3 with SMTP id f3so693108igg.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:44:39 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com. [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id x6si74471igl.12.2015.07.15.15.44.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 15:44:37 -0700 (PDT)
Received: by ieik3 with SMTP id k3so44495625iei.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:44:37 -0700 (PDT)
Date: Wed, 15 Jul 2015 15:44:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, oom: move oom notifiers to page allocator
In-Reply-To: <20150715094240.GF5101@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1507151543270.14906@chino.kir.corp.google.com>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com> <1436360661-31928-3-git-send-email-mhocko@suse.com> <alpine.DEB.2.10.1507081636180.16585@chino.kir.corp.google.com> <20150709085505.GB13872@dhcp22.suse.cz> <alpine.DEB.2.10.1507091404200.17177@chino.kir.corp.google.com>
 <20150710074032.GA7343@dhcp22.suse.cz> <alpine.DEB.2.10.1507141458350.16182@chino.kir.corp.google.com> <20150715094240.GF5101@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

OOM notifiers exist to give one last chance at reclaiming memory before
the oom killer does its work.

Thus, they don't actually belong in the oom killer proper, but rather in
the page allocator where reclaim is invoked.

Move the oom notifiers to their proper place: before out_of_memory(),
which now deals solely with providing access to memory reserves and
ensuring a process is exiting to free its memory.

This also fixes an issue that invoked the oom notifiers and aborted oom
kill when triggered manually with sysrq+f.  Sysrq+f now properly triggers
an oom kill in all instances.

Such callbacks should use register_shrinker() so they are a part of
reclaim, and there should be no need for oom notifiers at all.  Thus,
add a new comment directed to reclaim rather than continuing to use this
interface.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c   | 20 --------------------
 mm/page_alloc.c | 22 ++++++++++++++++++++++
 2 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -615,20 +615,6 @@ void check_panic_on_oom(struct oom_control *oc, enum oom_constraint constraint,
 		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
 }
 
-static BLOCKING_NOTIFIER_HEAD(oom_notify_list);
-
-int register_oom_notifier(struct notifier_block *nb)
-{
-	return blocking_notifier_chain_register(&oom_notify_list, nb);
-}
-EXPORT_SYMBOL_GPL(register_oom_notifier);
-
-int unregister_oom_notifier(struct notifier_block *nb)
-{
-	return blocking_notifier_chain_unregister(&oom_notify_list, nb);
-}
-EXPORT_SYMBOL_GPL(unregister_oom_notifier);
-
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  * @oc: pointer to struct oom_control
@@ -642,18 +628,12 @@ bool out_of_memory(struct oom_control *oc)
 {
 	struct task_struct *p;
 	unsigned long totalpages;
-	unsigned long freed = 0;
 	unsigned int uninitialized_var(points);
 	enum oom_constraint constraint = CONSTRAINT_NONE;
 
 	if (oom_killer_disabled)
 		return false;
 
-	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
-	if (freed > 0)
-		/* Got some memory back in the last second. */
-		return true;
-
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2676,6 +2676,23 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 		show_mem(filter);
 }
 
+static BLOCKING_NOTIFIER_HEAD(oom_notify_list);
+/*
+ * Deprecated -- no new callers of this interface should be added.  Instead,
+ * use reclaim shrinkers: see register_shrinker().
+ */
+int register_oom_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_register(&oom_notify_list, nb);
+}
+EXPORT_SYMBOL_GPL(register_oom_notifier);
+
+int unregister_oom_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_unregister(&oom_notify_list, nb);
+}
+EXPORT_SYMBOL_GPL(unregister_oom_notifier);
+
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	const struct alloc_context *ac, unsigned long *did_some_progress)
@@ -2736,6 +2753,11 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		if (gfp_mask & __GFP_THISNODE)
 			goto out;
 	}
+
+	blocking_notifier_call_chain(&oom_notify_list, 0, did_some_progress);
+	if (*did_some_progress > 0)
+		goto out;
+
 	/* Exhausted what can be done so it's blamo time */
 	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL))
 		*did_some_progress = 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
