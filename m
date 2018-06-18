Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 26E5D6B0269
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 05:45:59 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id h15-v6so12889126qkj.17
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 02:45:59 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30119.outbound.protection.outlook.com. [40.107.3.119])
        by mx.google.com with ESMTPS id b36-v6si4992067qvd.78.2018.06.18.02.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Jun 2018 02:45:58 -0700 (PDT)
Subject: [PATCH v7 REBASED 06/17] mm: Refactoring in workingset_init()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 18 Jun 2018 12:45:47 +0300
Message-ID: <152931514789.28457.4737374354831959330.stgit@localhost.localdomain>
In-Reply-To: <152931506756.28457.5620076974981468927.stgit@localhost.localdomain>
References: <152931506756.28457.5620076974981468927.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

Use prealloc_shrinker()/register_shrinker_prepared()
instead of register_shrinker(). This will be used
in next patch.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Tested-by: Shakeel Butt <shakeelb@google.com>
---
 mm/workingset.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index 40ee02c83978..c3a4fe145bb7 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -528,15 +528,16 @@ static int __init workingset_init(void)
 	pr_info("workingset: timestamp_bits=%d max_order=%d bucket_order=%u\n",
 	       timestamp_bits, max_order, bucket_order);
 
-	ret = __list_lru_init(&shadow_nodes, true, &shadow_nodes_key);
+	ret = prealloc_shrinker(&workingset_shadow_shrinker);
 	if (ret)
 		goto err;
-	ret = register_shrinker(&workingset_shadow_shrinker);
+	ret = __list_lru_init(&shadow_nodes, true, &shadow_nodes_key);
 	if (ret)
 		goto err_list_lru;
+	register_shrinker_prepared(&workingset_shadow_shrinker);
 	return 0;
 err_list_lru:
-	list_lru_destroy(&shadow_nodes);
+	free_prealloced_shrinker(&workingset_shadow_shrinker);
 err:
 	return ret;
 }
