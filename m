Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4566B0009
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:16:25 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id r29so2957121wra.13
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 08:16:25 -0800 (PST)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.15])
        by mx.google.com with ESMTPS id p15si747225wrh.498.2018.02.20.08.16.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 08:16:23 -0800 (PST)
From: =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>
Subject: [PATCH 1/6] powerpc/mm/32: Use pfn_valid to check if pointer is in RAM
Date: Tue, 20 Feb 2018 17:14:19 +0100
Message-Id: <20180220161424.5421-2-j.neuschaefer@gmx.net>
In-Reply-To: <20180220161424.5421-1-j.neuschaefer@gmx.net>
References: <20180220161424.5421-1-j.neuschaefer@gmx.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>, =?UTF-8?q?Jonathan=20Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christophe Leroy <christophe.leroy@c-s.fr>, Balbir Singh <bsingharora@gmail.com>, Guenter Roeck <linux@roeck-us.net>

The Nintendo Wii has a memory layout that places two chunks of RAM at
non-adjacent addresses, and MMIO between them. Currently, the allocation
of these MMIO areas is made possible by declaring the MMIO hole as
reserved memory and allowing reserved memory to be allocated (cf.
wii_memory_fixups).

This patch is the first step towards proper support for discontiguous
memory on PPC32 by using pfn_valid to check if a pointer points into
RAM, rather than open-coding the check. It should result in no
functional difference.

Signed-off-by: Jonathan NeuschA?fer <j.neuschaefer@gmx.net>
---
 arch/powerpc/mm/pgtable_32.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/mm/pgtable_32.c b/arch/powerpc/mm/pgtable_32.c
index d35d9ad3c1cd..b5c009893a44 100644
--- a/arch/powerpc/mm/pgtable_32.c
+++ b/arch/powerpc/mm/pgtable_32.c
@@ -147,7 +147,7 @@ __ioremap_caller(phys_addr_t addr, unsigned long size, unsigned long flags,
 	 * Don't allow anybody to remap normal RAM that we're using.
 	 * mem_init() sets high_memory so only do the check after that.
 	 */
-	if (slab_is_available() && (p < virt_to_phys(high_memory)) &&
+	if (slab_is_available() && pfn_valid(__phys_to_pfn(p)) &&
 	    !(__allow_ioremap_reserved && memblock_is_region_reserved(p, size))) {
 		printk("__ioremap(): phys addr 0x%llx is RAM lr %ps\n",
 		       (unsigned long long)p, __builtin_return_address(0));
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
