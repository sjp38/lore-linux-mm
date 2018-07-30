Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B9BCF6B026D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 14:02:26 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id k21-v6so10902508qtj.23
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:02:26 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id a44-v6si5773946qtc.270.2018.07.30.11.01.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 11:01:58 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH 1/3] mm: introduce mem_cgroup_put() helper
Date: Mon, 30 Jul 2018 11:00:58 -0700
Message-ID: <20180730180100.25079-2-guro@fb.com>
In-Reply-To: <20180730180100.25079-1-guro@fb.com>
References: <20180730180100.25079-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>

Introduce the mem_cgroup_put() helper, which helps to eliminate guarding
memcg css release with "#ifdef CONFIG_MEMCG" in multiple places.

Link: http://lkml.kernel.org/r/20180623000600.5818-2-guro@fb.com
Signed-off-by: Roman Gushchin <guro@fb.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
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
