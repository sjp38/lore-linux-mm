Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id D37106B0037
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 05:46:16 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e49so3957778eek.15
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 02:46:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l44si8628356eem.19.2014.01.21.02.46.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 02:46:16 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -mm 2/2] memcg: fix css reference leak and endless loop in mem_cgroup_iter
Date: Tue, 21 Jan 2014 11:45:43 +0100
Message-Id: <1390301143-9541-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1390301143-9541-1-git-send-email-mhocko@suse.cz>
References: <20140121083454.GA1894@dhcp22.suse.cz>
 <1390301143-9541-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

19f39402864e (memcg: simplify mem_cgroup_iter) has reorganized
mem_cgroup_iter code in order to simplify it. A part of that change was
dropping an optimization which didn't call css_tryget on the root of
the walked tree. The patch however didn't change the css_put part in
mem_cgroup_iter which excludes root.
This wasn't an issue at the time because __mem_cgroup_iter_next bailed
out for root early without taking a reference as cgroup iterators
(css_next_descendant_pre) didn't visit root themselves.

Nevertheless cgroup iterators have been reworked to visit root by
bd8815a6d802 (cgroup: make css_for_each_descendant() and friends include
the origin css in the iteration) when the root bypass have been dropped
in __mem_cgroup_iter_next. This means that css_put is not called for
root and so css along with mem_cgroup and other cgroup internal object
tied by css lifetime are never freed.

Fix the issue by reintroducing root check in __mem_cgroup_iter_next
and do not take css reference for it.

This reference counting magic protects us also from another issue, an
endless loop reported by Hugh Dickins when reclaim races with root
removal and css_tryget called by iterator internally would fail. There
would be no other nodes to visit so __mem_cgroup_iter_next would return
NULL and mem_cgroup_iter would interpret it as "start looping from root
again" and so mem_cgroup_iter would loop forever internally.

Cc: stable@vger.kernel.org # mem_leak part 3.12+
Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 45786dc129dc..55bb1f8c6907 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1076,14 +1076,22 @@ skip_node:
 	 * skipped and we should continue the tree walk.
 	 * last_visited css is safe to use because it is
 	 * protected by css_get and the tree walk is rcu safe.
+	 *
+	 * We do not take a reference on the root of the tree walk
+	 * because we might race with the root removal when it would
+	 * be the only node in the iterated hierarchy and mem_cgroup_iter
+	 * would end up in an endless loop because it expects that at
+	 * least one valid node will be returned. Root cannot disappear
+	 * because caller of the iterator should hold it already so
+	 * skipping css reference should be safe.
 	 */
 	if (next_css) {
-		if ((next_css->flags & CSS_ONLINE) && css_tryget(next_css))
+		if ((next_css->flags & CSS_ONLINE) &&
+				(next_css == &root->css || css_tryget(next_css)))
 			return mem_cgroup_from_css(next_css);
-		else {
-			prev_css = next_css;
-			goto skip_node;
-		}
+
+		prev_css = next_css;
+		goto skip_node;
 	}
 
 	return NULL;
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
