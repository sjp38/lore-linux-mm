Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2396B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 10:37:48 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id gc3so162443791obb.3
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 07:37:48 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id x185si24399559oix.117.2016.02.16.07.37.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 07:37:29 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH] devm_memremap_release: fix memremap'd addr handling
Date: Tue, 16 Feb 2016 09:30:27 -0700
Message-Id: <1455640227-21459-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com, akpm@linux-foundation.org
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

The pmem driver calls devm_memremap() to map a persistent memory
range.  When the pmem driver is unloaded, this memremap'd range
is not released.

Fix devm_memremap_release() to handle a given memremap'd address
properly.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 kernel/memremap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 2c468de..7a1b5c3 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -114,7 +114,7 @@ EXPORT_SYMBOL(memunmap);
 
 static void devm_memremap_release(struct device *dev, void *res)
 {
-	memunmap(res);
+	memunmap(*(void **)res);
 }
 
 static int devm_memremap_match(struct device *dev, void *res, void *match_data)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
