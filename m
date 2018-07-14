Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4237F6B0007
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 04:32:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v25-v6so13932272pfm.11
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 01:32:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2-v6sor6483125pge.88.2018.07.14.01.32.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Jul 2018 01:32:31 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH] mm: avoid bothering interrupted task when charge memcg in softirq
Date: Sat, 14 Jul 2018 16:32:02 +0800
Message-Id: <1531557122-12540-1-git-send-email-laoar.shao@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yafang Shao <laoar.shao@gmail.com>

try_charge maybe executed in packet receive path, which is in interrupt
context.
In this situation, the 'current' is the interrupted task, which may has
no relation to the rx softirq, So it is nonsense to use 'current'.

Avoid bothering the interrupted if page_counter_try_charge failes.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 mm/memcontrol.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 68ef266..13f95db 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2123,6 +2123,9 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		goto retry;
 	}
 
+	if (in_softirq())
+		goto nomem;
+
 	/*
 	 * Unlike in global OOM situations, memcg is not in a physical
 	 * memory shortage.  Allow dying and OOM-killed tasks to
-- 
1.8.3.1
