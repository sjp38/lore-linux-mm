Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4344F6B0010
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:16:46 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id z14so5030059wrh.1
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 08:16:46 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.22])
        by mx.google.com with ESMTPS id 16si19694025wry.155.2018.02.20.08.16.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 08:16:45 -0800 (PST)
From: =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: [PATCH 6/6] powerpc: wii: Don't rely on reserved memory hack if DISCONTIGMEM is set
Date: Tue, 20 Feb 2018 17:14:24 +0100
Message-Id: <20180220161424.5421-7-j.neuschaefer@gmx.net>
In-Reply-To: <20180220161424.5421-1-j.neuschaefer@gmx.net>
References: <20180220161424.5421-1-j.neuschaefer@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

Signed-off-by: Jonathan NeuschA?fer <j.neuschaefer@gmx.net>
---
 arch/powerpc/platforms/embedded6xx/wii.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/platforms/embedded6xx/wii.c b/arch/powerpc/platforms/embedded6xx/wii.c
index 4682327f76a9..589ac87a3ce0 100644
--- a/arch/powerpc/platforms/embedded6xx/wii.c
+++ b/arch/powerpc/platforms/embedded6xx/wii.c
@@ -81,13 +81,16 @@ void __init wii_memory_fixups(void)
 	BUG_ON(memblock.memory.cnt != 2);
 	BUG_ON(!page_aligned(p[0].base) || !page_aligned(p[1].base));
 
+	/* determine hole */
+	wii_hole_start = ALIGN(p[0].base + p[0].size, PAGE_SIZE);
+	wii_hole_size = p[1].base - wii_hole_start;
+
+#ifndef CONFIG_DISCONTIGMEM
 	/* trim unaligned tail */
 	memblock_remove(ALIGN(p[1].base + p[1].size, PAGE_SIZE),
 			(phys_addr_t)ULLONG_MAX);
 
-	/* determine hole, add & reserve them */
-	wii_hole_start = ALIGN(p[0].base + p[0].size, PAGE_SIZE);
-	wii_hole_size = p[1].base - wii_hole_start;
+	/* add & reserve hole */
 	memblock_add(wii_hole_start, wii_hole_size);
 	memblock_reserve(wii_hole_start, wii_hole_size);
 
@@ -96,6 +99,7 @@ void __init wii_memory_fixups(void)
 
 	/* allow ioremapping the address space in the hole */
 	__allow_ioremap_reserved = 1;
+#endif
 }
 
 unsigned long __init wii_mmu_mapin_mem2(unsigned long top)
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
