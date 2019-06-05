Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 572D2C282DE
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 10:06:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17859206B8
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 10:06:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17859206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC8646B000E; Wed,  5 Jun 2019 06:06:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A79326B0010; Wed,  5 Jun 2019 06:06:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98E596B0266; Wed,  5 Jun 2019 06:06:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F75B6B000E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 06:06:57 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 21so14481181pgl.5
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 03:06:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=gw1AnGYklzxJGBp1a1bdOMb9i8YZ42P936XCNomCzqk=;
        b=ZqbhvaNUMPsT9YZ47kkypkv7G1pMqC2SQ/FI/AtOdU/Qw5wbBwLUbNq88ONmCQceUE
         3a2FYN9+0qubqDFwgvMAi6mS19XvGDKO/wpPtVB0xoOi68actQJdgfbc+75pqH7MHxEE
         igqP/wAvy9DhIjknZGEB2aS3EgXoCJdaGIxZYnxqUTK644dKKT/K5BZxeZrPC8GQw916
         AN8wh+bwLZSaO0SYAQBzn3cCxVk9WN7Q0L1eP0YmiAnwTAB3YlKCnG8pWYQEFC6kXyyV
         RLOLvazO39+9PsaVEmuezA+2hVXok9rSSzlKUfm5qZlOxzD6Xl1ZwkQ/ztb+yKViVZ6J
         fWHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWciNd255diCZhnPApzykT9NpGm3zozpzDKgrRI9UTBPDE6tMMD
	TTE6u7a7htU5a1QJDWUk6TfRGaFgnD+CKcoVXzqhRqmLzVPpVXR5Rqf3DbUvZyyyBpMa73tHHk6
	N7rgvyzybDNHKV2Pvdtco5v2vb5yRD948AIddIGCm89m0PHqtzx6USSpixj2ftiv6Yw==
X-Received: by 2002:a62:ea04:: with SMTP id t4mr43389759pfh.47.1559729216770;
        Wed, 05 Jun 2019 03:06:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtJf0ze1jGvAuOCIruC0y7BVOU+RFYLNuqfgTKDnYLNeM8QkjsnSM0ranHT18/V0qzQVpf
X-Received: by 2002:a62:ea04:: with SMTP id t4mr43389613pfh.47.1559729215070;
        Wed, 05 Jun 2019 03:06:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559729215; cv=none;
        d=google.com; s=arc-20160816;
        b=FPOpjcUv40sSkM+qpCCyI2sLxelTDjg25PqqC/O3BPKSB3SityI138+bs2IewOwINg
         9IWWHyeSC2oX+EpdkJ7MhvfZpaGIt29cR/uN9SOaOb1aomabz6xryfYsPJ6y+vTt4zd9
         RGSdwxkvyy3bb7zUlNMzKGA/+XqA6VZtJRnYkb4YrzQSvQepZ8NYF1rkjw0EVjfN4Q1E
         DwC3mx+hX92oZvkly6TJr4IPiHU4poJofgGJhjXJW1Bppz15e/mtJX9ARjS4nh66ctat
         eEiqUpuibYKXqh1RCJDvvDfLRN0MtYuJ+rU8XvwdkLJEqKz8yWz0ba6+rYiy1132Lzb8
         60tg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=gw1AnGYklzxJGBp1a1bdOMb9i8YZ42P936XCNomCzqk=;
        b=CBdLwyrZEGG7+XSDhAnRosCC5tdShUPlpHrELiT8iurf5qDhAfrp50sIZW1li4yCcT
         2zA9ReAsuS5Q104WfDJfIhG1pcsHGE63za1MT3f/b2wrv8w/R0/ALiULCbD4XvCaYY1V
         MpxuZw1E1GFoeVcCn+Kn4R9cLbk9qNreiq0/kEjDLPpcANiaXP2bFsb0u19QU5bNeauw
         3RFltR4rn6ATIeJ+hwqEqf34JcBGHbyRMWzSY4RvYDSNvh749AhJRFPB/2fT0OnEGXz8
         K9hRVWaCxhyFi4n/kDE49+aZf2ZoTwADwCE0UgU1lu5Qp3O2ZQg9JC27cs3HanoZ8KUs
         w2SA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id b9si22215925pls.303.2019.06.05.03.06.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 03:06:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of teawaterz@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R121e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=teawaterz@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TTUHvst_1559729194;
Received: from localhost(mailfrom:teawaterz@linux.alibaba.com fp:SMTPD_---0TTUHvst_1559729194)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 05 Jun 2019 18:06:39 +0800
From: Hui Zhu <teawaterz@linux.alibaba.com>
To: ddstreet@ieee.org,
	minchan@kernel.org,
	ngupta@vflare.org,
	sergey.senozhatsky.work@gmail.com,
	sjenning@redhat.com,
	shakeelb@google.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Hui Zhu <teawaterz@linux.alibaba.com>
Subject: [PATCH V3 1/2] zpool: Add malloc_support_movable to zpool_driver
Date: Wed,  5 Jun 2019 18:06:29 +0800
Message-Id: <20190605100630.13293-1-teawaterz@linux.alibaba.com>
X-Mailer: git-send-email 2.21.0 (Apple Git-120)
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As a zpool_driver, zsmalloc can allocate movable memory because it
support migate pages.
But zbud and z3fold cannot allocate movable memory.

This commit adds malloc_support_movable to zpool_driver.
If a zpool_driver support allocate movable memory, set it to true.
And add zpool_malloc_support_movable check malloc_support_movable
to make sure if a zpool support allocate movable memory.

Signed-off-by: Hui Zhu <teawaterz@linux.alibaba.com>
---
 include/linux/zpool.h |  3 +++
 mm/zpool.c            | 16 ++++++++++++++++
 mm/zsmalloc.c         | 19 ++++++++++---------
 3 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index 7238865e75b0..51bf43076165 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -46,6 +46,8 @@ const char *zpool_get_type(struct zpool *pool);
 
 void zpool_destroy_pool(struct zpool *pool);
 
+bool zpool_malloc_support_movable(struct zpool *pool);
+
 int zpool_malloc(struct zpool *pool, size_t size, gfp_t gfp,
 			unsigned long *handle);
 
@@ -90,6 +92,7 @@ struct zpool_driver {
 			struct zpool *zpool);
 	void (*destroy)(void *pool);
 
+	bool malloc_support_movable;
 	int (*malloc)(void *pool, size_t size, gfp_t gfp,
 				unsigned long *handle);
 	void (*free)(void *pool, unsigned long handle);
diff --git a/mm/zpool.c b/mm/zpool.c
index a2dd9107857d..863669212070 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -238,6 +238,22 @@ const char *zpool_get_type(struct zpool *zpool)
 	return zpool->driver->type;
 }
 
+/**
+ * zpool_malloc_support_movable() - Check if the zpool support
+ * allocate movable memory
+ * @zpool:	The zpool to check
+ *
+ * This returns if the zpool support allocate movable memory.
+ *
+ * Implementations must guarantee this to be thread-safe.
+ *
+ * Returns: true if if the zpool support allocate movable memory, false if not
+ */
+bool zpool_malloc_support_movable(struct zpool *zpool)
+{
+	return zpool->driver->malloc_support_movable;
+}
+
 /**
  * zpool_malloc() - Allocate memory
  * @zpool:	The zpool to allocate from.
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 0787d33b80d8..8f3d9a4d46f4 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -437,15 +437,16 @@ static u64 zs_zpool_total_size(void *pool)
 }
 
 static struct zpool_driver zs_zpool_driver = {
-	.type =		"zsmalloc",
-	.owner =	THIS_MODULE,
-	.create =	zs_zpool_create,
-	.destroy =	zs_zpool_destroy,
-	.malloc =	zs_zpool_malloc,
-	.free =		zs_zpool_free,
-	.map =		zs_zpool_map,
-	.unmap =	zs_zpool_unmap,
-	.total_size =	zs_zpool_total_size,
+	.type =			  "zsmalloc",
+	.owner =		  THIS_MODULE,
+	.create =		  zs_zpool_create,
+	.destroy =		  zs_zpool_destroy,
+	.malloc_support_movable = true,
+	.malloc =		  zs_zpool_malloc,
+	.free =			  zs_zpool_free,
+	.map =			  zs_zpool_map,
+	.unmap =		  zs_zpool_unmap,
+	.total_size =		  zs_zpool_total_size,
 };
 
 MODULE_ALIAS("zpool-zsmalloc");
-- 
2.21.0 (Apple Git-120)

