Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C369E6B026E
	for <linux-mm@kvack.org>; Wed, 30 May 2018 07:29:42 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x21-v6so10661536pfn.23
        for <linux-mm@kvack.org>; Wed, 30 May 2018 04:29:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s65-v6sor11478205pfj.137.2018.05.30.04.29.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 May 2018 04:29:41 -0700 (PDT)
From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH] mm: dmapool: Check the dma pool name
Date: Wed, 30 May 2018 19:28:43 +0800
Message-Id: <59623b15001e5a20ac32b1a393db88722be2e718.1527679621.git.baolin.wang@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, arnd@arndb.de, broonie@kernel.org, baolin.wang@linaro.org

It will be crash if we pass one NULL name when creating one dma pool,
so we should check the passing name when copy it to dma pool.

Moreover this patch replaces kmalloc_node() with kzalloc_node() to make
sure the name array of dma pool is initialized in case the passing name
is NULL.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 mm/dmapool.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index 4d90a64..349f13d 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -155,11 +155,12 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
 	else if ((boundary < size) || (boundary & (boundary - 1)))
 		return NULL;
 
-	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
+	retval = kzalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
 	if (!retval)
 		return retval;
 
-	strlcpy(retval->name, name, sizeof(retval->name));
+	if (name)
+		strlcpy(retval->name, name, sizeof(retval->name));
 
 	retval->dev = dev;
 
-- 
1.7.9.5
