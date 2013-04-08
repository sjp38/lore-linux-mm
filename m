Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 135636B0095
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 06:00:24 -0400 (EDT)
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH 1/2] mm: vmemmap: x86: add vmemmap_verify check for hot-add node case
Date: Mon, 8 Apr 2013 17:56:39 +0800
Message-Id: <1365415000-10389-2-git-send-email-linfeng@cn.fujitsu.com>
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
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Reported-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 arch/x86/mm/init_64.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 474e28f..e2a7277 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1318,6 +1318,8 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
 			if (!p)
 				return -ENOMEM;
 
+			vmemmap_verify((pte_t *)p, node, addr, addr + PAGE_SIZE);
+
 			addr_end = addr + PAGE_SIZE;
 			p_end = p + PAGE_SIZE;
 		} else {
@@ -1347,8 +1349,8 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
 
 				addr_end = addr + PMD_SIZE;
 				p_end = p + PMD_SIZE;
-			} else
-				vmemmap_verify((pte_t *)pmd, node, addr, next);
+			}
+			vmemmap_verify((pte_t *)pmd, node, addr, next);
 		}
 
 	}
-- 
1.8.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
