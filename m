Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D06606B0006
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 11:46:32 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id n10-v6so5451696qtp.11
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 08:46:32 -0700 (PDT)
Received: from frisell.zx2c4.com (frisell.zx2c4.com. [192.95.5.64])
        by mx.google.com with ESMTPS id j3-v6si1009674qtp.72.2018.06.22.08.46.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Jun 2018 08:46:32 -0700 (PDT)
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] kasan: depend on CONFIG_SLUB_DEBUG
Date: Fri, 22 Jun 2018 17:46:23 +0200
Message-Id: <20180622154623.25388-1-Jason@zx2c4.com>
In-Reply-To: <CALvZod7Rf0FZHqYBPd1OTkVuvA5QRrkYQku40QJtS2--g6PrQQ@mail.gmail.com>
References: <CALvZod7Rf0FZHqYBPd1OTkVuvA5QRrkYQku40QJtS2--g6PrQQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

KASAN depends on having access to some of the accounting that SLUB_DEBUG
does; without it, there are immediate crashes [1]. So, the natural thing
to do is to make KASAN select SLUB_DEBUG.

[1] http://lkml.kernel.org/r/CAHmME9rtoPwxUSnktxzKso14iuVCWT7BE_-_8PAC=pGw1iJnQg@mail.gmail.com

Fixes: f9e13c0a5a33 ("slab, slub: skip unnecessary kasan_cache_shutdown()")
Cc: Shakeel Butt <shakeelb@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: <stable@vger.kernel.org>
Cc: <linux-mm@kvack.org>
Cc: <linux-kernel@vger.kernel.org>
Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 lib/Kconfig.kasan | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 3d35d062970d..c253c1b46c6b 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -6,6 +6,7 @@ if HAVE_ARCH_KASAN
 config KASAN
 	bool "KASan: runtime memory debugger"
 	depends on SLUB || (SLAB && !DEBUG_SLAB)
+	select SLUB_DEBUG if SLUB
 	select CONSTRUCTORS
 	select STACKDEPOT
 	help
-- 
2.17.1
