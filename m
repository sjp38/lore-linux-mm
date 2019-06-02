Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D64D9C282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 09:46:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D3FF278AB
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 09:46:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D3FF278AB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BF836B000E; Sun,  2 Jun 2019 05:46:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2476E6B0010; Sun,  2 Jun 2019 05:46:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1100E6B0266; Sun,  2 Jun 2019 05:46:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD6E26B000E
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 05:46:29 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id n1so2550089plk.11
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 02:46:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=2AkO3LxaNyQOB+mW9ZqnbZ02q46v1QMPGKcJa9dKCYY=;
        b=adQxRTOAFtdBfY0SMOfSWPjCgooNII2oyOJsFyr065dco1seYdSZpct4YT/dm/h/Jn
         DLdrP6x4ZmUJllmVwP2cS3TA4u1en6NxMUaAiqoKXaZzbzxdyBxmKm6tD6F5yXyWQWDX
         xEwo0rYrxkgpsPE1r4iF3mz+H8tUZi6p7wSIIju7b1o475iZiVpWuLhwcOc9nlMWgaK0
         sHHtqIBtsGwWKaGLmtbzSGf4cKKzq//IHdVUmznWDP2LKUyOkiajO9NXemgmR82/ro1y
         d4nmBt1TAb/u54qv7UWtIEMGZcx/D1TvH1fZ/WHmmKv2cU6kKa2tl4ap0YASv0e3aIRL
         8bvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWSELBMR+okzUyQ2i/CTp/ic+JCsd4YpH/LqO60BCZN1fkX+pwn
	Cs7Culh/dOL2ari6pMV+FLPgj+8v4uAR32t4DyWHh0Nm2FoXO2hAjGzaMlstmxJHN0TMhClWlw6
	LRM2jiHcgfFrK25QiaYINNU1rHYUdfmjp+W7zBmp6gTX6MNmbZIsiC+Zxt+0Cz+8jHw==
X-Received: by 2002:a63:5024:: with SMTP id e36mr21463225pgb.220.1559468789314;
        Sun, 02 Jun 2019 02:46:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySMKzzPEH/Ew+qIxKpE68zlkAYuJhyYYhVcQ90B2xJ4IB75b5PYuMYx1spK3K/+Ai80H8s
X-Received: by 2002:a63:5024:: with SMTP id e36mr21463174pgb.220.1559468787963;
        Sun, 02 Jun 2019 02:46:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559468787; cv=none;
        d=google.com; s=arc-20160816;
        b=RBnE1JGuAt0+FiYKbnXlJqmhVcc5638ZoV44FKkGXxvZ5ag6iy+WXnezjmflx7+vPb
         ehCNIw0Qtw48V2gBEwAFSzd2T0yHl/fhRkzzI2/FLVjrqaTyX9W3DNy4KaeS3iB4q/oY
         ECiRaPs4AfDKbrXtMt0CY3EN30YcCSMvj3LTpcEASUbmi0tpVpkDE7rOrDdZ6pCyno1+
         keCpFCvlWBuLaccw5HtmILemVpLtnvcdysdiwZXdo9CWeeuapwzbfoYCnZgPRHfCTOCu
         e+Bx85YZXnu5pUBIE5FBT53aV+DRi7Wpgdzcl3tDKlDcVBlLoBLnYXhSYm2uLcMwe1sJ
         Y7tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=2AkO3LxaNyQOB+mW9ZqnbZ02q46v1QMPGKcJa9dKCYY=;
        b=jRvAPNw1Y9vNYpyiqA9+ivXjZ3o0GweELryKWDPheImEvnXDVbSK41Nl9tcGRIv8Dl
         iyFI2OZKXk2F8h2RPSpGLEfrWXp+GdfBejd741eWwm7jJDMQUFZPKZrj5WoyV/d0PoR8
         zKJMRjkYhUusl2NB2uO3PLXYGUcPKSgDMpQOZoYYryzky+kw5cNsyWbfXvSonG2/jmfc
         kkqxP7pZmxW9S793RfKG4lLrLEWlyf9q+6GwT+2UjlueSZ7K8ZO03H0tYkisUZ0w3Tqo
         MvGgwmZmHKEIsnG1AJAoQoPb9aFVIgxyUC9HsnO7rlTctpOd6ASS7oANwwaivmtfQG9o
         xKDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id q42si488054pjc.103.2019.06.02.02.46.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 02:46:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of teawaterz@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=teawaterz@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R521e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=teawaterz@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TTD1lNX_1559468776;
Received: from localhost(mailfrom:teawaterz@linux.alibaba.com fp:SMTPD_---0TTD1lNX_1559468776)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sun, 02 Jun 2019 17:46:25 +0800
From: Hui Zhu <teawaterz@linux.alibaba.com>
To: ddstreet@ieee.org,
	minchan@kernel.org,
	ngupta@vflare.org,
	sergey.senozhatsky.work@gmail.com,
	sjenning@redhat.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Hui Zhu <teawaterz@linux.alibaba.com>
Subject: [PATCH V2 1/2] zpool: Add malloc_support_movable to zpool_driver
Date: Sun,  2 Jun 2019 17:46:06 +0800
Message-Id: <20190602094607.41840-1-teawaterz@linux.alibaba.com>
X-Mailer: git-send-email 2.20.1 (Apple Git-117)
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
2.20.1 (Apple Git-117)

