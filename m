Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0E4B160021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 03:46:42 -0500 (EST)
Message-ID: <4B1F6433.3090006@novell.com>
Date: Wed, 09 Dec 2009 17:47:47 +0900
From: Tejun Heo <teheo@novell.com>
MIME-Version: 1.0
Subject: [PATCH] m68k: rename global variable vmalloc_end to m68k_vmalloc_end
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com>	 <20091207153552.0fadf335.akpm@linux-foundation.org> <10f740e80912080111l57b0562doebedb1f878592105@mail.gmail.com> <4B1E1B68.5050503@kernel.org>
In-Reply-To: <4B1E1B68.5050503@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Beulich <JBeulich@novell.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On SUN3, m68k defines macro VMALLOC_END as unsigned long variable
vmalloc_end which is adjusted from mmu_emu_init().  This becomes
problematic if a local variables vmalloc_end is defined in some
function (not very unlikely) and VMALLOC_END is used in the function -
the function thinks its referencing the global VMALLOC_END value but
would be referencing its own local vmalloc_end variable.

Rename the global variable to m68k_vmlloc_end which is much less
likely to be used as local variable name.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Roman Zippel <zippel@linux-m68k.org>
---
This patch has been queued to percpu#for-linus.  Thanks.

 arch/m68k/include/asm/pgtable_mm.h |    4 ++--
 arch/m68k/sun3/mmu_emu.c           |    8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/m68k/include/asm/pgtable_mm.h b/arch/m68k/include/asm/pgtable_mm.h
index fe60e1a..aca0e28 100644
--- a/arch/m68k/include/asm/pgtable_mm.h
+++ b/arch/m68k/include/asm/pgtable_mm.h
@@ -83,9 +83,9 @@
 #define VMALLOC_START (((unsigned long) high_memory + VMALLOC_OFFSET) & ~(VMALLOC_OFFSET-1))
 #define VMALLOC_END KMAP_START
 #else
-extern unsigned long vmalloc_end;
+extern unsigned long m68k_vmalloc_end;
 #define VMALLOC_START 0x0f800000
-#define VMALLOC_END vmalloc_end
+#define VMALLOC_END m68k_vmalloc_end
 #endif /* CONFIG_SUN3 */
 
 /* zero page used for uninitialized stuff */
diff --git a/arch/m68k/sun3/mmu_emu.c b/arch/m68k/sun3/mmu_emu.c
index 3cd1939..94f81ec 100644
--- a/arch/m68k/sun3/mmu_emu.c
+++ b/arch/m68k/sun3/mmu_emu.c
@@ -45,8 +45,8 @@
 ** Globals
 */
 
-unsigned long vmalloc_end;
-EXPORT_SYMBOL(vmalloc_end);
+unsigned long m68k_vmalloc_end;
+EXPORT_SYMBOL(m68k_vmalloc_end);
 
 unsigned long pmeg_vaddr[PMEGS_NUM];
 unsigned char pmeg_alloc[PMEGS_NUM];
@@ -172,8 +172,8 @@ void mmu_emu_init(unsigned long bootmem_end)
 #endif
 			// the lowest mapping here is the end of our
 			// vmalloc region
-			if(!vmalloc_end)
-				vmalloc_end = seg;
+			if (!m68k_vmalloc_end)
+				m68k_vmalloc_end = seg;
 
 			// mark the segmap alloc'd, and reserve any
 			// of the first 0xbff pages the hardware is
-- 
1.6.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
