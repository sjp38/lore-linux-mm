Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4AAE68E0001
	for <linux-mm@kvack.org>; Tue, 25 Dec 2018 21:06:05 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a199so19161666qkb.23
        for <linux-mm@kvack.org>; Tue, 25 Dec 2018 18:06:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p126sor12255775qkd.106.2018.12.25.18.06.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Dec 2018 18:06:04 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH -mmotm] arm64: skip kmemleak for KASAN again
Date: Tue, 25 Dec 2018 21:05:50 -0500
Message-Id: <20181226020550.63712-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com, will.deacon@arm.com, andreyknvl@google.com, dvyukov@google.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>

Due to 871ac3d540f (kasan: initialize shadow to 0xff for tag-based
mode), kmemleak is broken again with KASAN. It needs a similar fix
from e55058c2983 (mm/memblock.c: skip kmemleak for kasan_init()).

Signed-off-by: Qian Cai <cai@lca.pw>
---
 arch/arm64/mm/kasan_init.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 48d8f2fa0d14..4b55b15707a3 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -47,8 +47,7 @@ static phys_addr_t __init kasan_alloc_raw_page(int node)
 {
 	void *p = memblock_alloc_try_nid_raw(PAGE_SIZE, PAGE_SIZE,
 						__pa(MAX_DMA_ADDRESS),
-						MEMBLOCK_ALLOC_ACCESSIBLE,
-						node);
+						MEMBLOCK_ALLOC_KASAN, node);
 	return __pa(p);
 }
 
-- 
2.17.2 (Apple Git-113)
