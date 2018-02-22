Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A4E9C6B02C0
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 07:15:51 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id b142so497650wma.4
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 04:15:51 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.21])
        by mx.google.com with ESMTPS id a186si172412wmf.50.2018.02.22.04.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 04:15:50 -0800 (PST)
From: =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: [PATCH 4/5] powerpc: wii: Don't rely on the reserved memory hack
Date: Thu, 22 Feb 2018 13:15:15 +0100
Message-Id: <20180222121516.23415-5-j.neuschaefer@gmx.net>
In-Reply-To: <20180222121516.23415-1-j.neuschaefer@gmx.net>
References: <20180222121516.23415-1-j.neuschaefer@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>, Christophe LEROY <christophe.leroy@c-s.fr>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

Signed-off-by: Jonathan NeuschA?fer <j.neuschaefer@gmx.net>
---
 arch/powerpc/platforms/embedded6xx/wii.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/arch/powerpc/platforms/embedded6xx/wii.c b/arch/powerpc/platforms/embedded6xx/wii.c
index 4682327f76a9..fc00d82691e1 100644
--- a/arch/powerpc/platforms/embedded6xx/wii.c
+++ b/arch/powerpc/platforms/embedded6xx/wii.c
@@ -81,21 +81,9 @@ void __init wii_memory_fixups(void)
 	BUG_ON(memblock.memory.cnt != 2);
 	BUG_ON(!page_aligned(p[0].base) || !page_aligned(p[1].base));
 
-	/* trim unaligned tail */
-	memblock_remove(ALIGN(p[1].base + p[1].size, PAGE_SIZE),
-			(phys_addr_t)ULLONG_MAX);
-
-	/* determine hole, add & reserve them */
+	/* determine hole */
 	wii_hole_start = ALIGN(p[0].base + p[0].size, PAGE_SIZE);
 	wii_hole_size = p[1].base - wii_hole_start;
-	memblock_add(wii_hole_start, wii_hole_size);
-	memblock_reserve(wii_hole_start, wii_hole_size);
-
-	BUG_ON(memblock.memory.cnt != 1);
-	__memblock_dump_all();
-
-	/* allow ioremapping the address space in the hole */
-	__allow_ioremap_reserved = 1;
 }
 
 unsigned long __init wii_mmu_mapin_mem2(unsigned long top)
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
