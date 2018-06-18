Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 812BF6B0274
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 05:47:01 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g5-v6so5001369pgv.12
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 02:47:01 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0110.outbound.protection.outlook.com. [104.47.0.110])
        by mx.google.com with ESMTPS id a10-v6si14883437pls.480.2018.06.18.02.46.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Jun 2018 02:47:00 -0700 (PDT)
Subject: [PATCH v7 REBASED 12/17] mm: Export mem_cgroup_is_root()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 18 Jun 2018 12:46:50 +0300
Message-ID: <152931521067.28457.1399177856448274667.stgit@localhost.localdomain>
In-Reply-To: <152931506756.28457.5620076974981468927.stgit@localhost.localdomain>
References: <152931506756.28457.5620076974981468927.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

This will be used in next patch.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Tested-by: Shakeel Butt <shakeelb@google.com>
---
 include/linux/memcontrol.h |   10 ++++++++++
 mm/memcontrol.c            |    5 -----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 40401a73000e..7ef004c4f4af 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -318,6 +318,11 @@ struct mem_cgroup {
 
 extern struct mem_cgroup *root_mem_cgroup;
 
+static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
+{
+	return (memcg == root_mem_cgroup);
+}
+
 static inline bool mem_cgroup_disabled(void)
 {
 	return !cgroup_subsys_enabled(memory_cgrp_subsys);
@@ -771,6 +776,11 @@ void mem_cgroup_split_huge_fixup(struct page *head);
 
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
index 2b703c4130bb..a122572c0219 100644
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
