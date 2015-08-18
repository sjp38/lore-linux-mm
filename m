Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 16C2F6B0038
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 15:21:47 -0400 (EDT)
Received: by qkfj126 with SMTP id j126so62128192qkf.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 12:21:46 -0700 (PDT)
Received: from mail-qg0-x229.google.com (mail-qg0-x229.google.com. [2607:f8b0:400d:c04::229])
        by mx.google.com with ESMTPS id 77si6100968qhu.22.2015.08.18.12.21.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 12:21:46 -0700 (PDT)
Received: by qgeg42 with SMTP id g42so125828118qge.1
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 12:21:46 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] zswap: move zswap_pool frequently-used fields together
Date: Tue, 18 Aug 2015 15:21:41 -0400
Message-Id: <1439925701-29678-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>

Move the "tfm" field in struct zswap_pool to the top, after the "zpool"
field.

As suggested by Sergey Senozhatsky:

>> > ->tfm will be access pretty often, right? did you intentionally put it
>> > at the bottom offset of `struct zswap_pool'?
>>
>> no it wasn't intentional; does moving it up provide a benefit?
>
> well, I just prefer to keep 'read mostly' pointers together. all
> those cache lines, etc.
>
> gcc 5.1, x86_64
>
>  struct zswap_pool {
>         struct zpool *zpool;
> +       struct crypto_comp * __percpu *tfm;
>         struct kref kref;
>         struct list_head list;
>         struct rcu_head rcu_head;
>         struct notifier_block notifier;
>         char tfm_name[CRYPTO_MAX_ALG_NAME];
> -       struct crypto_comp * __percpu *tfm;
>  };
>
> ../scripts/bloat-o-meter zswap.o.old zswap.o
> add/remove: 0/0 grow/shrink: 0/6 up/down: 0/-27 (-27)
> function                                     old     new   delta
> zswap_writeback_entry                        659     656      -3
> zswap_frontswap_store                       1445    1442      -3
> zswap_frontswap_load                         417     414      -3
> zswap_pool_create                            438     432      -6
> __zswap_cpu_comp_notifier.part               152     146      -6
> __zswap_cpu_comp_notifier                    122     116      -6

Suggested-by: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---
 mm/zswap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index b198081..4043df7 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -120,12 +120,12 @@ module_param_named(max_pool_percent, zswap_max_pool_percent, uint, 0644);
 
 struct zswap_pool {
 	struct zpool *zpool;
+	struct crypto_comp * __percpu *tfm;
 	struct kref kref;
 	struct list_head list;
 	struct rcu_head rcu_head;
 	struct notifier_block notifier;
 	char tfm_name[CRYPTO_MAX_ALG_NAME];
-	struct crypto_comp * __percpu *tfm;
 };
 
 /*
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
