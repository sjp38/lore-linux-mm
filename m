Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id BD14D6B0037
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 20:29:54 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so9768242pdj.4
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 17:29:54 -0800 (PST)
Received: from mail-pb0-x236.google.com (mail-pb0-x236.google.com [2607:f8b0:400e:c01::236])
        by mx.google.com with ESMTPS id gz8si150132pac.259.2014.02.12.17.29.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Feb 2014 17:29:53 -0800 (PST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so10156734pbc.27
        for <linux-mm@kvack.org>; Wed, 12 Feb 2014 17:29:53 -0800 (PST)
Date: Wed, 12 Feb 2014 17:29:09 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/2] memcg: barriers to see memcgs as fully initialized
In-Reply-To: <alpine.LSU.2.11.1402121717420.5917@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1402121727050.5917@eggly.anvils>
References: <alpine.LSU.2.11.1402121717420.5917@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit d8ad30559715 ("mm/memcg: iteration skip memcgs not yet fully
initialized") is not bad, but Greg Thelen asks "Are barriers needed?"

Yes, I'm afraid so: this makes it a little heavier than the original,
but there's no point in guaranteeing that mem_cgroup_iter() returns only
fully initialized memcgs, if we don't guarantee that the initialization
is visible.

If we move online_css()'s setting CSS_ONLINE after rcu_assign_pointer()
(I don't see why not), we can reasonably rely on the smp_wmb() in that.
But I can't find a pre-existing barrier at the mem_cgroup_iter() end,
so add an smp_rmb() where __mem_cgroup_iter_next() returns non-NULL.

Fixes: d8ad30559715 ("mm/memcg: iteration skip memcgs not yet fully initialized")
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org # 3.12+
---
I'd have been happier not to have to add this patch: maybe you can see
a better placement, or a way we can avoid this altogether.

 kernel/cgroup.c |    8 +++++++-
 mm/memcontrol.c |   11 +++++++++--
 2 files changed, 16 insertions(+), 3 deletions(-)

--- 3.14-rc2+/kernel/cgroup.c	2014-02-02 18:49:07.737302111 -0800
+++ linux/kernel/cgroup.c	2014-02-12 11:59:52.804041895 -0800
@@ -4063,9 +4063,15 @@ static int online_css(struct cgroup_subs
 	if (ss->css_online)
 		ret = ss->css_online(css);
 	if (!ret) {
-		css->flags |= CSS_ONLINE;
 		css->cgroup->nr_css++;
 		rcu_assign_pointer(css->cgroup->subsys[ss->subsys_id], css);
+		/*
+		 * Set CSS_ONLINE after rcu_assign_pointer(), so that its
+		 * smp_wmb() will guarantee that those seeing CSS_ONLINE
+		 * can see the initialization done in ss->css_online() - if
+		 * they provide an smp_rmb(), as in __mem_cgroup_iter_next().
+		 */
+		css->flags |= CSS_ONLINE;
 	}
 	return ret;
 }
--- 3.14-rc2+/mm/memcontrol.c	2014-02-12 11:55:02.836035004 -0800
+++ linux/mm/memcontrol.c	2014-02-12 11:59:52.804041895 -0800
@@ -1128,9 +1128,16 @@ skip_node:
 	 */
 	if (next_css) {
 		if ((next_css == &root->css) ||
-		    ((next_css->flags & CSS_ONLINE) && css_tryget(next_css)))
+		    ((next_css->flags & CSS_ONLINE) && css_tryget(next_css))) {
+			/*
+			 * Ensure that all memcg initialization, done before
+			 * CSS_ONLINE was set, will be visible to our caller.
+			 * This matches the smp_wmb() in online_css()'s
+			 * rcu_assign_pointer(), before it set CSS_ONLINE.
+			 */
+			smp_rmb();
 			return mem_cgroup_from_css(next_css);
-
+		}
 		prev_css = next_css;
 		goto skip_node;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
