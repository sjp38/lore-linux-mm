Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC02E6B0289
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:10:57 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c27-v6so802506qkj.3
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:10:57 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10126.outbound.protection.outlook.com. [40.107.1.126])
        by mx.google.com with ESMTPS id f26-v6si1295234qte.45.2018.07.03.08.10.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 08:10:56 -0700 (PDT)
Subject: [PATCH v8 12/17] mm: Export mem_cgroup_is_root()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 03 Jul 2018 18:10:43 +0300
Message-ID: <153063064347.1818.1987011484100392706.stgit@localhost.localdomain>
In-Reply-To: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com, akpm@linux-foundation.org, ktkhai@virtuozzo.com

This will be used in next patch.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Tested-by: Shakeel Butt <shakeelb@google.com>
---
 include/linux/memcontrol.h |   10 ++++++++++
 mm/memcontrol.c            |    5 -----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d8c38eafa251..2c52b4313117 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -327,6 +327,11 @@ struct mem_cgroup {
 
 extern struct mem_cgroup *root_mem_cgroup;
 
+static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
+{
+	return (memcg == root_mem_cgroup);
+}
+
 static inline bool mem_cgroup_disabled(void)
 {
 	return !cgroup_subsys_enabled(memory_cgrp_subsys);
@@ -800,6 +805,11 @@ void mem_cgroup_split_huge_fixup(struct page *head);
 
 struct mem_cgroup;
 
+static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
+{
+	return true;
+}
+
 static inline bool mem_cgroup_disabled(void)
 {
 	return true;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 510c435a15dd..1a6c61814dbc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -261,11 +261,6 @@ struct cgroup_subsys_state *vmpressure_to_css(struct vmpressure *vmpr)
 	return &container_of(vmpr, struct mem_cgroup, vmpressure)->css;
 }
 
-static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
-{
-	return (memcg == root_mem_cgroup);
-}
-
 #ifdef CONFIG_MEMCG_KMEM
 /*
  * This will be the memcg's index in each cache's ->memcg_params.memcg_caches.
