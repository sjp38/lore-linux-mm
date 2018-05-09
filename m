Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 878406B04F6
	for <linux-mm@kvack.org>; Wed,  9 May 2018 07:57:39 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z16-v6so10221054pgv.16
        for <linux-mm@kvack.org>; Wed, 09 May 2018 04:57:39 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40131.outbound.protection.outlook.com. [40.107.4.131])
        by mx.google.com with ESMTPS id f85si27091081pfj.125.2018.05.09.04.57.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 May 2018 04:57:38 -0700 (PDT)
Subject: [PATCH v4 04/13] mm: Refactoring in workingset_init()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Wed, 09 May 2018 14:57:27 +0300
Message-ID: <152586704715.3048.16683522879894119893.stgit@localhost.localdomain>
In-Reply-To: <152586686544.3048.15776787801312398314.stgit@localhost.localdomain>
References: <152586686544.3048.15776787801312398314.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vdavydov.dev@gmail.com, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, ktkhai@virtuozzo.com, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

Use prealloc_shrinker()/register_shrinker_prepared()
instead of register_shrinker(). This will be used
in next patch.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
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
