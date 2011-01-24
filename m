Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 41BDE6B00E7
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 18:06:21 -0500 (EST)
From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [PATCH 4/9] vmalloc: use plain pte_clear() for unmaps
Date: Mon, 24 Jan 2011 14:56:02 -0800
Message-Id: <7a064a31021ba0b4adfc90061d7da2daa9b3d27e.1295653400.git.jeremy.fitzhardinge@citrix.com>
In-Reply-To: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
References: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
In-Reply-To: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
References: <cover.1295653400.git.jeremy.fitzhardinge@citrix.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Haavard Skinnemoen <hskinnemoen@atmel.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@kernel.dk>, Xen-devel <xen-devel@lists.xensource.com>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
List-ID: <linux-mm.kvack.org>

From: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>

ptep_get_and_clear() is potentially moderately expensive (at least
an atomic operation, or potentially a trap-and-fault when virtualized)
so use a plain pte_clear().

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
---
 mm/vmalloc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 5ddbdfe..c06dc1e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -39,8 +39,9 @@ static void vunmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end)
 
 	pte = pte_offset_kernel(pmd, addr);
 	do {
-		pte_t ptent = ptep_get_and_clear(&init_mm, addr, pte);
+		pte_t ptent = *pte;
 		WARN_ON(!pte_none(ptent) && !pte_present(ptent));
+		pte_clear(&init_mm, addr, pte);
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 }
 
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
