Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0C10360021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 04:23:51 -0500 (EST)
Message-ID: <4B1E1B68.5050503@kernel.org>
Date: Tue, 08 Dec 2009 18:24:56 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com>	 <20091207153552.0fadf335.akpm@linux-foundation.org> <10f740e80912080111l57b0562doebedb1f878592105@mail.gmail.com>
In-Reply-To: <10f740e80912080111l57b0562doebedb1f878592105@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Beulich <JBeulich@novell.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,

Geert Uytterhoeven wrote:
> Rename to m68k_vmalloc_{end,start}?
> Hmm, sounds better than introducing allcaps variables...

We definitely can do that too but I don't know.  It still has the risk
of aliasing behind both the developer's and compiler's back.  Aliasing
a macro directly to a macro just isn't a very good idea.  We can
definitely make it more complex - make the prefix more unlikely,
prevent it from being used as lvalue and so on but given that it's a
pretty special case anyway, I think all caps variable isn't too bad
here.

But you're the maintainer, if you prefer the following version, I'll
go forward with it.

Thanks.

diff --git a/arch/m68k/include/asm/pgtable_mm.h b/arch/m68k/include/asm/pgtable_mm.h
index fe60e1a..2db057f 100644
--- a/arch/m68k/include/asm/pgtable_mm.h
+++ b/arch/m68k/include/asm/pgtable_mm.h
@@ -83,9 +83,9 @@
 #define VMALLOC_START (((unsigned long) high_memory + VMALLOC_OFFSET) & ~(VMALLOC_OFFSET-1))
 #define VMALLOC_END KMAP_START
 #else
-extern unsigned long vmalloc_end;
 #define VMALLOC_START 0x0f800000
-#define VMALLOC_END vmalloc_end
+extern unsigned long m68k_vmalloc_end;
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
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
