Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74B216B000A
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 20:32:44 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id p8-v6so92315ljg.10
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 17:32:44 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 13-v6si155955lfz.188.2018.08.01.17.32.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 17:32:43 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v2 1/3] mm: introduce mem_cgroup_put() helper
Date: Wed, 1 Aug 2018 17:31:59 -0700
Message-ID: <20180802003201.817-2-guro@fb.com>
In-Reply-To: <20180802003201.817-1-guro@fb.com>
References: <20180802003201.817-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>

Introduce the mem_cgroup_put() helper, which helps to eliminate guarding
memcg css release with "#ifdef CONFIG_MEMCG" in multiple places.

Link: http://lkml.kernel.org/r/20180623000600.5818-2-guro@fb.com
Signed-off-by: Roman Gushchin <guro@fb.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/linux/memcontrol.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6c6fb116e925..e53e00cdbe3f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -375,6 +375,11 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
 	return css ? container_of(css, struct mem_cgroup, css) : NULL;
 }
 
+static inline void mem_cgroup_put(struct mem_cgroup *memcg)
+{
+	css_put(&memcg->css);
+}
+
 #define mem_cgroup_from_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
@@ -837,6 +842,10 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
 	return true;
 }
 
+static inline void mem_cgroup_put(struct mem_cgroup *memcg)
+{
+}
+
 static inline struct mem_cgroup *
 mem_cgroup_iter(struct mem_cgroup *root,
 		struct mem_cgroup *prev,
-- 
2.14.4
