Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 840E36B027C
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:09:46 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id h67-v6so2423077qke.18
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:09:46 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0119.outbound.protection.outlook.com. [104.47.0.119])
        by mx.google.com with ESMTPS id r62-v6si1306341qkd.14.2018.07.03.08.09.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 03 Jul 2018 08:09:44 -0700 (PDT)
Subject: [PATCH v8 06/17] mm: Refactoring in workingset_init()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 03 Jul 2018 18:09:36 +0300
Message-ID: <153063057666.1818.17625951186610808734.stgit@localhost.localdomain>
In-Reply-To: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
References: <153063036670.1818.16010062622751502.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com, akpm@linux-foundation.org, ktkhai@virtuozzo.com

Use prealloc_shrinker()/register_shrinker_prepared()
instead of register_shrinker(). This will be used
in next patch.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Tested-by: Shakeel Butt <shakeelb@google.com>
---
 mm/workingset.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index a466e731231d..b16489c60471 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -507,16 +507,17 @@ static int __init workingset_init(void)
 	pr_info("workingset: timestamp_bits=%d max_order=%d bucket_order=%u\n",
 	       timestamp_bits, max_order, bucket_order);
 
-	/* list_lru lock nests inside the IRQ-safe i_pages lock */
-	ret = __list_lru_init(&shadow_nodes, true, true, &shadow_nodes_key);
+	ret = prealloc_shrinker(&workingset_shadow_shrinker);
 	if (ret)
 		goto err;
-	ret = register_shrinker(&workingset_shadow_shrinker);
+	/* list_lru lock nests inside the IRQ-safe i_pages lock */
+	ret = __list_lru_init(&shadow_nodes, true, true, &shadow_nodes_key);
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
