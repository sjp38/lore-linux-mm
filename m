Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 80B626B0037
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 02:30:56 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ma3so4614310pbc.27
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 23:30:56 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id rb6si22164126pab.149.2014.04.21.23.30.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Apr 2014 23:30:55 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id bj1so4596528pad.30
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 23:30:55 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH 2/4] mm/memcontrol.c: use accessor to get id from css
Date: Tue, 22 Apr 2014 14:30:41 +0800
Message-Id: <2c63c535f8202c6b605300a834cdf1c07d1bafc3.1398147734.git.nasa4836@gmail.com>
In-Reply-To: <cover.1398147734.git.nasa4836@gmail.com>
References: <cover.1398147734.git.nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, nasa4836@gmail.com

This is a prepared patch for converting from per-cgroup id to
per-subsystem id.

We should not access per-cgroup id directly, since this is implemetation
detail. Use the accessor css_from_id() instead.

This patch has no functional change.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/memcontrol.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 80d9e38..46333cb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -528,10 +528,10 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
 static inline unsigned short mem_cgroup_id(struct mem_cgroup *memcg)
 {
 	/*
-	 * The ID of the root cgroup is 0, but memcg treat 0 as an
-	 * invalid ID, so we return (cgroup_id + 1).
+	 * The ID of css for the root cgroup is 0, but memcg treat 0 as an
+	 * invalid ID, so we return (id + 1).
 	 */
-	return memcg->css.cgroup->id + 1;
+	return css_to_id(&memcg->css) + 1;
 }
 
 static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
@@ -6407,7 +6407,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup *parent = mem_cgroup_from_css(css_parent(css));
 
-	if (css->cgroup->id > MEM_CGROUP_ID_MAX)
+	if (css_to_id(css) > MEM_CGROUP_ID_MAX)
 		return -ENOSPC;
 
 	if (!parent)
-- 
2.0.0-rc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
