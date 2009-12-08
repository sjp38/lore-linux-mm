Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id ED5BF60021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 01:56:25 -0500 (EST)
Message-ID: <4B1DF8D4.2010202@novell.com>
Date: Tue, 08 Dec 2009 15:57:24 +0900
From: Tejun Heo <teheo@novell.com>
MIME-Version: 1.0
Subject: [PATCH] m68k: don't alias VMALLOC_END to vmalloc_end
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com> <20091207153552.0fadf335.akpm@linux-foundation.org> <4B1DA06A.1050004@kernel.org>
In-Reply-To: <4B1DA06A.1050004@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Beulich <JBeulich@novell.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Roman Zippel <zippel@linux-m68k.org>
List-ID: <linux-mm.kvack.org>

On SUN3, m68k defines macro VMALLOC_END as unsigned long variable
vmalloc_end which is adjusted from mmu_emu_init().  This becomes
problematic if a local variables vmalloc_end is defined in some
function (not very unlikely) and VMALLOC_END is used in the function -
the function thinks its referencing the global VMALLOC_END value but
would be referencing its own local vmalloc_end variable.

There's no reason VMALLOC_END should be a macro.  Just define it as an
unsigned long variable to avoid nasty surprises.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Roman Zippel <zippel@linux-m68k.org>
---
Okay, here it is.  Compile tested.  Geert, Roman, if you guys don't
object, I'd like to push it with the rest of percpu changes to Linus.
What do you think?

Thanks.

 arch/m68k/include/asm/pgtable_mm.h |    3 +--
 arch/m68k/sun3/mmu_emu.c           |    8 ++++----
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/arch/m68k/include/asm/pgtable_mm.h b/arch/m68k/include/asm/pgtable_mm.h
index fe60e1a..0ea9f09 100644
--- a/arch/m68k/include/asm/pgtable_mm.h
+++ b/arch/m68k/include/asm/pgtable_mm.h
@@ -83,9 +83,8 @@
 #define VMALLOC_START (((unsigned long) high_memory + VMALLOC_OFFSET) & ~(VMALLOC_OFFSET-1))
 #define VMALLOC_END KMAP_START
 #else
-extern unsigned long vmalloc_end;
 #define VMALLOC_START 0x0f800000
-#define VMALLOC_END vmalloc_end
+extern unsigned long VMALLOC_END;
 #endif /* CONFIG_SUN3 */
 
 /* zero page used for uninitialized stuff */
diff --git a/arch/m68k/sun3/mmu_emu.c b/arch/m68k/sun3/mmu_emu.c
index 3cd1939..25e2b14 100644
--- a/arch/m68k/sun3/mmu_emu.c
+++ b/arch/m68k/sun3/mmu_emu.c
@@ -45,8 +45,8 @@
 ** Globals
 */
 
-unsigned long vmalloc_end;
-EXPORT_SYMBOL(vmalloc_end);
+unsigned long VMALLOC_END;
+EXPORT_SYMBOL(VMALLOC_END);
 
 unsigned long pmeg_vaddr[PMEGS_NUM];
 unsigned char pmeg_alloc[PMEGS_NUM];
@@ -172,8 +172,8 @@ void mmu_emu_init(unsigned long bootmem_end)
 #endif
 			// the lowest mapping here is the end of our
 			// vmalloc region
-			if(!vmalloc_end)
-				vmalloc_end = seg;
+			if (!VMALLOC_END)
+				VMALLOC_END = seg;
 
 			// mark the segmap alloc'd, and reserve any
 			// of the first 0xbff pages the hardware is

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
