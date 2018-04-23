Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A60806B0068
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:48:04 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id a38-v6so19257893wra.10
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:48:04 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id p14si1489460edi.24.2018.04.23.08.48.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 08:48:03 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 31/37] x86/ldt: Reserve address-space range on 32 bit for the LDT
Date: Mon, 23 Apr 2018 17:47:34 +0200
Message-Id: <1524498460-25530-32-git-send-email-joro@8bytes.org>
In-Reply-To: <1524498460-25530-1-git-send-email-joro@8bytes.org>
References: <1524498460-25530-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Reserve 2MB/4MB of address-space for mapping the LDT to
user-space on 32 bit PTI kernels.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pgtable_32_types.h | 7 +++++--
 arch/x86/mm/dump_pagetables.c           | 9 +++++++++
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_32_types.h b/arch/x86/include/asm/pgtable_32_types.h
index e3225e8..1fa76c9 100644
--- a/arch/x86/include/asm/pgtable_32_types.h
+++ b/arch/x86/include/asm/pgtable_32_types.h
@@ -50,13 +50,16 @@ extern bool __vmalloc_start_set; /* set once high_memory is set */
 	((FIXADDR_TOT_START - PAGE_SIZE * (CPU_ENTRY_AREA_PAGES + 1))   \
 	 & PMD_MASK)
 
-#define PKMAP_BASE		\
+#define LDT_BASE_ADDR		\
 	((CPU_ENTRY_AREA_BASE - PAGE_SIZE) & PMD_MASK)
 
+#define PKMAP_BASE		\
+	((LDT_BASE_ADDR - PAGE_SIZE) & PMD_MASK)
+
 #ifdef CONFIG_HIGHMEM
 # define VMALLOC_END	(PKMAP_BASE - 2 * PAGE_SIZE)
 #else
-# define VMALLOC_END	(CPU_ENTRY_AREA_BASE - 2 * PAGE_SIZE)
+# define VMALLOC_END	(LDT_BASE_ADDR - 2 * PAGE_SIZE)
 #endif
 
 #define MODULES_VADDR	VMALLOC_START
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 23d24d1..db1d7a0 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -123,6 +123,9 @@ enum address_markers_idx {
 #ifdef CONFIG_HIGHMEM
 	PKMAP_BASE_NR,
 #endif
+#ifdef CONFIG_MODIFY_LDT_SYSCALL
+	LDT_NR,
+#endif
 	CPU_ENTRY_AREA_NR,
 	FIXADDR_START_NR,
 	END_OF_SPACE_NR,
@@ -136,6 +139,9 @@ static struct addr_marker address_markers[] = {
 #ifdef CONFIG_HIGHMEM
 	[PKMAP_BASE_NR]		= { 0UL,		"Persistent kmap() Area" },
 #endif
+#ifdef CONFIG_MODIFY_LDT_SYSCALL
+	[LDT_NR]		= { 0UL,		"LDT remap" },
+#endif
 	[CPU_ENTRY_AREA_NR]	= { 0UL,		"CPU entry area" },
 	[FIXADDR_START_NR]	= { 0UL,		"Fixmap area" },
 	[END_OF_SPACE_NR]	= { -1,			NULL }
@@ -609,6 +615,9 @@ static int __init pt_dump_init(void)
 # endif
 	address_markers[FIXADDR_START_NR].start_address = FIXADDR_START;
 	address_markers[CPU_ENTRY_AREA_NR].start_address = CPU_ENTRY_AREA_BASE;
+# ifdef CONFIG_MODIFY_LDT_SYSCALL
+	address_markers[LDT_NR].start_address = LDT_BASE_ADDR;
+# endif
 #endif
 	return 0;
 }
-- 
2.7.4
