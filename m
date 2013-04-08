Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 8A4C16B0096
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 06:00:24 -0400 (EDT)
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH 2/2] mm: vmemmap: arm64: add vmemmap_verify check for hot-add node case
Date: Mon, 8 Apr 2013 17:56:40 +0800
Message-Id: <1365415000-10389-3-git-send-email-linfeng@cn.fujitsu.com>
In-Reply-To: <1365415000-10389-1-git-send-email-linfeng@cn.fujitsu.com>
References: <1365415000-10389-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, arnd@arndb.de, tony@atomide.com, ben@decadent.org.uk, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, isimatu.yasuaki@jp.fujitsu.com, Lin Feng <linfeng@cn.fujitsu.com>

In hot add node(memory) case, vmemmap pages are always allocated from other
node, but the current logic just skip vmemmap_verify check. 
So we should also issue "potential offnode page_structs" warning messages
if we are the case.

Cc: Christoph Lameter <cl@linux.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Tony Lindgren <tony@atomide.com>
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Reported-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 arch/arm64/mm/mmu.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 70b8cd4..9f1e417 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -427,8 +427,8 @@ int __meminit vmemmap_populate(struct page *start_page,
 				return -ENOMEM;
 
 			set_pmd(pmd, __pmd(__pa(p) | prot_sect_kernel));
-		} else
-			vmemmap_verify((pte_t *)pmd, node, addr, next);
+		}
+		vmemmap_verify((pte_t *)pmd, node, addr, next);
 	} while (addr = next, addr != end);
 
 	return 0;
-- 
1.8.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
