Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id D46A86B0070
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 06:23:53 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id fp1so11260453pdb.4
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 03:23:53 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id gz1si15830288pbd.38.2015.01.19.03.23.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jan 2015 03:23:52 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 3/7] cgroup: release css->id after css_free
Date: Mon, 19 Jan 2015 14:23:21 +0300
Message-ID: <4d7447a920522c1085ff96c08b2be71e0eb5d896.1421664712.git.vdavydov@parallels.com>
In-Reply-To: <cover.1421664712.git.vdavydov@parallels.com>
References: <cover.1421664712.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Chinner <david@fromorbit.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Currently, we release css->id in css_release_work_fn, right before
calling css_free callback, so that when css_free is called, the id may
have already been reused for a new cgroup.

I am going to use css->id to create unique names for per memcg kmem
caches. Since kmem caches are destroyed only on css_free, I need css->id
to be freed after css_free was called to avoid name clashes. This patch
therefore moves css->id removal to css_free_work_fn. To prevent
css_from_id from returning a pointer to a stale css, it makes
css_release_work_fn replace the css ptr at css_idr:css->id with NULL.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 kernel/cgroup.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 6ffd3ae52bf8..7bd3e0f0f341 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4373,16 +4373,20 @@ static void css_free_work_fn(struct work_struct *work)
 {
 	struct cgroup_subsys_state *css =
 		container_of(work, struct cgroup_subsys_state, destroy_work);
+	struct cgroup_subsys *ss = css->ss;
 	struct cgroup *cgrp = css->cgroup;
 
 	percpu_ref_exit(&css->refcnt);
 
-	if (css->ss) {
+	if (ss) {
 		/* css free path */
+		int id = css->id;
+
 		if (css->parent)
 			css_put(css->parent);
 
-		css->ss->css_free(css);
+		ss->css_free(css);
+		cgroup_idr_remove(&ss->css_idr, id);
 		cgroup_put(cgrp);
 	} else {
 		/* cgroup free path */
@@ -4434,7 +4438,7 @@ static void css_release_work_fn(struct work_struct *work)
 
 	if (ss) {
 		/* css release path */
-		cgroup_idr_remove(&ss->css_idr, css->id);
+		cgroup_idr_replace(&ss->css_idr, NULL, css->id);
 		if (ss->css_released)
 			ss->css_released(css);
 	} else {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
