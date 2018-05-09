Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id BBF3C6B02F5
	for <linux-mm@kvack.org>; Tue,  8 May 2018 20:42:46 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 72-v6so2749791pld.19
        for <linux-mm@kvack.org>; Tue, 08 May 2018 17:42:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4-v6sor8268419plo.93.2018.05.08.17.42.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 17:42:45 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 07/13] treewide: Use struct_size() for vmalloc()-family
Date: Tue,  8 May 2018 17:42:23 -0700
Message-Id: <20180509004229.36341-8-keescook@chromium.org>
In-Reply-To: <20180509004229.36341-1-keescook@chromium.org>
References: <20180509004229.36341-1-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Kees Cook <keescook@chromium.org>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

This only finds one hit in the entire tree, but here's the Coccinelle:

// Directly refer to structure's field
@@
identifier alloc =~ "vmalloc|vzalloc";
identifier VAR, ELEMENT;
expression COUNT;
@@

- alloc(sizeof(*VAR) + COUNT * sizeof(*VAR->ELEMENT))
+ alloc(struct_size(VAR, ELEMENT, COUNT))

// mr = kzalloc(sizeof(*mr) + m * sizeof(mr->map[0]), GFP_KERNEL);
@@
identifier alloc =~ "vmalloc|vzalloc";
identifier VAR, ELEMENT;
expression COUNT;
@@

- alloc(sizeof(*VAR) + COUNT * sizeof(VAR->ELEMENT[0]))
+ alloc(struct_size(VAR, ELEMENT, COUNT))

// Same pattern, but can't trivially locate the trailing element name,
// or variable name.
@@
identifier alloc =~ "vmalloc|vzalloc";
expression SOMETHING, COUNT, ELEMENT;
@@

- alloc(sizeof(SOMETHING) + COUNT * sizeof(ELEMENT))
+ alloc(CHECKME_struct_size(&SOMETHING, ELEMENT, COUNT))

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/gpu/drm/nouveau/nvkm/core/ramht.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/gpu/drm/nouveau/nvkm/core/ramht.c b/drivers/gpu/drm/nouveau/nvkm/core/ramht.c
index ccba4ae73cc5..8162e3d2359c 100644
--- a/drivers/gpu/drm/nouveau/nvkm/core/ramht.c
+++ b/drivers/gpu/drm/nouveau/nvkm/core/ramht.c
@@ -144,8 +144,7 @@ nvkm_ramht_new(struct nvkm_device *device, u32 size, u32 align,
 	struct nvkm_ramht *ramht;
 	int ret, i;
 
-	if (!(ramht = *pramht = vzalloc(sizeof(*ramht) +
-					(size >> 3) * sizeof(*ramht->data))))
+	if (!(ramht = *pramht = vzalloc(struct_size(ramht, data, (size >> 3)))))
 		return -ENOMEM;
 
 	ramht->device = device;
-- 
2.17.0
