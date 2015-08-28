Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0EE6B0257
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 11:25:44 -0400 (EDT)
Received: by ykay144 with SMTP id y144so3329337yka.2
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 08:25:43 -0700 (PDT)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id w127si1762325ywg.120.2015.08.28.08.25.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 08:25:37 -0700 (PDT)
Received: by ykdz80 with SMTP id z80so18624729ykd.0
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 08:25:36 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 4/4] memcg: always enable kmemcg on the default hierarchy
Date: Fri, 28 Aug 2015 11:25:30 -0400
Message-Id: <1440775530-18630-5-git-send-email-tj@kernel.org>
In-Reply-To: <1440775530-18630-1-git-send-email-tj@kernel.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com, Tejun Heo <tj@kernel.org>

On the default hierarchy, all memory consumption will be accounted
together and controlled by the same set of limits.  Always enable
kmemcg on the default hierarchy.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 mm/memcontrol.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c94b686..8a5dd01 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4362,6 +4362,13 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	if (ret)
 		return ret;
 
+	/* kmem is always accounted together on the default hierarchy */
+	if (cgroup_on_dfl(css->cgroup)) {
+		ret = memcg_activate_kmem(memcg, PAGE_COUNTER_MAX);
+		if (ret)
+			return ret;
+	}
+
 	/*
 	 * Make sure the memcg is initialized: mem_cgroup_iter()
 	 * orders reading memcg->initialized against its callers
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
