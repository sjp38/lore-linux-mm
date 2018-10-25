Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E72666B000C
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 21:27:56 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s56-v6so7732924qtk.2
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 18:27:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o68-v6sor7650920qte.4.2018.10.24.18.27.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Oct 2018 18:27:56 -0700 (PDT)
From: Rafael David Tinoco <rafael.tinoco@linaro.org>
Subject: [PATCH 2/2] mm/zsmalloc.c: fix zsmalloc ARM LPAE support
Date: Wed, 24 Oct 2018 22:27:45 -0300
Message-Id: <20181025012745.20884-2-rafael.tinoco@linaro.org>
In-Reply-To: <20181025012745.20884-1-rafael.tinoco@linaro.org>
References: <20181025012745.20884-1-rafael.tinoco@linaro.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Rafael David Tinoco <rafael.tinoco@linaro.org>, Russell King <linux@armlinux.org.uk>, Mark Brown <broonie@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>

Since commit 02390b87a945 ("mm/zsmalloc: Prepare to variable
MAX_PHYSMEM_BITS"), an architecture has to define this value in order to
guarantee that zsmalloc will be able to encode and decode the obj value
properly.

Similar to that change, this one sets the value for ARM LPAE, fixing a
possible null-ptr-deref in zs_map_object() when using ARM LPAE and
HIGHMEM pages located above the 4GB watermark.

Link: https://bugs.linaro.org/show_bug.cgi?id=3765#c17
Signed-off-by: Rafael David Tinoco <rafael.tinoco@linaro.org>
---
 arch/arm/include/asm/pgtable-3level-types.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/include/asm/pgtable-3level-types.h b/arch/arm/include/asm/pgtable-3level-types.h
index 921aa30259c4..bd4994f98700 100644
--- a/arch/arm/include/asm/pgtable-3level-types.h
+++ b/arch/arm/include/asm/pgtable-3level-types.h
@@ -67,4 +67,6 @@ typedef pteval_t pgprot_t;
 
 #endif	/* STRICT_MM_TYPECHECKS */
 
+#define MAX_POSSIBLE_PHYSMEM_BITS	36
+
 #endif	/* _ASM_PGTABLE_3LEVEL_TYPES_H */
-- 
2.19.1
