Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DFBCC8E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:42:21 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id n95so45228133qte.16
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 09:42:21 -0800 (PST)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id q129si5080899qkb.189.2019.01.04.09.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 04 Jan 2019 09:42:20 -0800 (PST)
Date: Fri, 4 Jan 2019 17:42:20 +0000
From: Christopher Lameter <cl@linux.com>
Subject: [FIX] slab: Alien caches must not be initialized if the allocation
 of the alien cache failed
Message-ID: <0100016819f5682e-a7e2541c-4390-4e14-ac65-8793243215c6-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: linux-mm@kvack.org, Dmitry Vyukov <dvyukov@google.com>, stable@kernel.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Christoph Lameter <cl@linux.com>

Callers of __alloc_alien() check for NULL.
We must do the same check in __alloc_alien() after the allocation of
the alien cache to avoid potential NULL pointer dereferences
should the  allocation fail.

Fixes: 49dfc304ba241b315068023962004542c5118103 ("slab: use the lock on alien_cache, instead of the lock on array_cache")
Fixes: c8522a3a5832b843570a3315674f5a3575958a5 ("Slab: introduce alloc_alien")
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c
+++ linux/mm/slab.c
@@ -666,8 +666,10 @@ static struct alien_cache *__alloc_alien
 	struct alien_cache *alc = NULL;

 	alc = kmalloc_node(memsize, gfp, node);
-	init_arraycache(&alc->ac, entries, batch);
-	spin_lock_init(&alc->lock);
+	if (alc) {
+		init_arraycache(&alc->ac, entries, batch);
+		spin_lock_init(&alc->lock);
+	}
 	return alc;
 }
