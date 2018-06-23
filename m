Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 82FBF6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 20:06:39 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m2-v6so2352154lfc.7
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 17:06:39 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id o196-v6si3666798lfe.260.2018.06.22.17.06.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 17:06:37 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH 2/2] mm: introduce mem_cgroup_put() helper
Date: Fri, 22 Jun 2018 17:06:00 -0700
Message-ID: <20180623000600.5818-2-guro@fb.com>
In-Reply-To: <20180623000600.5818-1-guro@fb.com>
References: <CALvZod7G-ggYTpmdDsNeQRf4upYa34ccOerVmEkEkLOVFrBr2w@mail.gmail.com>
 <20180623000600.5818-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, shakeelb@google.com, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, Roman Gushchin <guro@fb.com>

Introduce the mem_cgroup_put() helper, which helps to eliminate
guarding memcg css release with "#ifdef CONFIG_MEMCG" in multiple
places.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/memcontrol.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index cf1c3555328f..3607913032be 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -383,6 +383,11 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
 	return css ? container_of(css, struct mem_cgroup, css) : NULL;
 }
 
+static inline void mem_cgroup_put(struct mem_cgroup *memcg)
+{
+	css_put(&memcg->css);
+}
+
 #define mem_cgroup_from_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
@@ -852,6 +857,10 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
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
