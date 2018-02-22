Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 031D76B02B7
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 07:15:38 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id o23so3485537wrc.9
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 04:15:37 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.18])
        by mx.google.com with ESMTPS id y20si10145249wra.369.2018.02.22.04.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 04:15:36 -0800 (PST)
From: =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: [PATCH 1/5] powerpc: mm: Simplify page_is_ram by using memblock_is_memory
Date: Thu, 22 Feb 2018 13:15:12 +0100
Message-Id: <20180222121516.23415-2-j.neuschaefer@gmx.net>
In-Reply-To: <20180222121516.23415-1-j.neuschaefer@gmx.net>
References: <20180222121516.23415-1-j.neuschaefer@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>, Christophe LEROY <christophe.leroy@c-s.fr>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Joe Perches <joe@perches.com>, Oliver O'Halloran <oohall@gmail.com>

Instead of open-coding the search in page_is_ram, call memblock_is_memory.

Signed-off-by: Jonathan NeuschA?fer <j.neuschaefer@gmx.net>
---
 arch/powerpc/mm/mem.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index fe8c61149fb8..da4e1555d61d 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -85,13 +85,7 @@ int page_is_ram(unsigned long pfn)
 #ifndef CONFIG_PPC64	/* XXX for now */
 	return pfn < max_pfn;
 #else
-	unsigned long paddr = (pfn << PAGE_SHIFT);
-	struct memblock_region *reg;
-
-	for_each_memblock(memory, reg)
-		if (paddr >= reg->base && paddr < (reg->base + reg->size))
-			return 1;
-	return 0;
+	return memblock_is_memory(__pfn_to_phys(pfn));
 #endif
 }
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
