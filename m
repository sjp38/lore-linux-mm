Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id EBCB76B0035
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 07:17:33 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so5171237pbc.26
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 04:17:33 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xa2si12371193pab.258.2013.12.23.04.17.31
        for <linux-mm@kvack.org>;
        Mon, 23 Dec 2013 04:17:32 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] x86/tlb_info: detect more tlb configuration
Date: Mon, 23 Dec 2013 14:16:58 +0200
Message-Id: <1387801018-14499-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joseph Nuzman <joseph.nuzman@intel.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Software Developera??s Manual covers few more TLB configurations:

61H Instruction TLB: 4 KByte pages, fully associative, 48 entries
63H Data TLB: 1 GByte pages, 4-way set associative, 4 entries
76H Instruction TLB: 2M/4M pages, fully associative, 8 entries
B5H Instruction TLB: 4KByte pages, 8-way set associative, 64 entries
B6H Instruction TLB: 4KByte pages, 8-way set associative, 128 entries
C1H Shared 2nd-Level TLB: 4 KByte/2MByte pages, 8-way associative, 1024 entries
C2H DTLB DTLB: 2 MByte/$MByte pages, 4-way associative, 16 entries

Let's detect them as well.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/processor.h |  1 +
 arch/x86/kernel/cpu/common.c     |  7 ++++---
 arch/x86/kernel/cpu/intel.c      | 26 ++++++++++++++++++++++++++
 3 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 7b034a4057f9..1dd6260ed940 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -72,6 +72,7 @@ extern u16 __read_mostly tlb_lli_4m[NR_INFO];
 extern u16 __read_mostly tlb_lld_4k[NR_INFO];
 extern u16 __read_mostly tlb_lld_2m[NR_INFO];
 extern u16 __read_mostly tlb_lld_4m[NR_INFO];
+extern u16 __read_mostly tlb_lld_1g[NR_INFO];
 extern s8  __read_mostly tlb_flushall_shift;
 
 /*
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 6abc172b8258..24b6fd10625a 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -472,6 +472,7 @@ u16 __read_mostly tlb_lli_4m[NR_INFO];
 u16 __read_mostly tlb_lld_4k[NR_INFO];
 u16 __read_mostly tlb_lld_2m[NR_INFO];
 u16 __read_mostly tlb_lld_4m[NR_INFO];
+u16 __read_mostly tlb_lld_1g[NR_INFO];
 
 /*
  * tlb_flushall_shift shows the balance point in replacing cr3 write
@@ -486,13 +487,13 @@ void cpu_detect_tlb(struct cpuinfo_x86 *c)
 	if (this_cpu->c_detect_tlb)
 		this_cpu->c_detect_tlb(c);
 
-	printk(KERN_INFO "Last level iTLB entries: 4KB %d, 2MB %d, 4MB %d\n" \
-		"Last level dTLB entries: 4KB %d, 2MB %d, 4MB %d\n"	     \
+	printk(KERN_INFO "Last level iTLB entries: 4KB %d, 2MB %d, 4MB %d\n"
+		"Last level dTLB entries: 4KB %d, 2MB %d, 4MB %d, 1GB %d\n"
 		"tlb_flushall_shift: %d\n",
 		tlb_lli_4k[ENTRIES], tlb_lli_2m[ENTRIES],
 		tlb_lli_4m[ENTRIES], tlb_lld_4k[ENTRIES],
 		tlb_lld_2m[ENTRIES], tlb_lld_4m[ENTRIES],
-		tlb_flushall_shift);
+		tlb_lld_1g[ENTRIES], tlb_flushall_shift);
 }
 
 void detect_ht(struct cpuinfo_x86 *c)
diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index dc1ec0dff939..5c68eeb11435 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -505,6 +505,7 @@ static unsigned int intel_size_cache(struct cpuinfo_x86 *c, unsigned int size)
 #define TLB_DATA0_2M_4M	0x23
 
 #define STLB_4K		0x41
+#define STLB_4K_2M	0x42
 
 static const struct _tlb_table intel_tlb_table[] = {
 	{ 0x01, TLB_INST_4K,		32,	" TLB_INST 4 KByte pages, 4-way set associative" },
@@ -525,13 +526,20 @@ static const struct _tlb_table intel_tlb_table[] = {
 	{ 0x5b, TLB_DATA_4K_4M,		64,	" TLB_DATA 4 KByte and 4 MByte pages" },
 	{ 0x5c, TLB_DATA_4K_4M,		128,	" TLB_DATA 4 KByte and 4 MByte pages" },
 	{ 0x5d, TLB_DATA_4K_4M,		256,	" TLB_DATA 4 KByte and 4 MByte pages" },
+	{ 0x61, TLB_INST_4K,		48,	" TLB_INST 4 KByte pages, full associative" },
+	{ 0x63, TLB_DATA_1G,		4,	" TLB_DATA 1 GByte pages, 4-way set associative" },
+	{ 0x76, TLB_INST_2M_4M,		8,	" TLB_INST 2-MByte or 4-MByte pages, fully associative" },
 	{ 0xb0, TLB_INST_4K,		128,	" TLB_INST 4 KByte pages, 4-way set associative" },
 	{ 0xb1, TLB_INST_2M_4M,		4,	" TLB_INST 2M pages, 4-way, 8 entries or 4M pages, 4-way entries" },
 	{ 0xb2, TLB_INST_4K,		64,	" TLB_INST 4KByte pages, 4-way set associative" },
 	{ 0xb3, TLB_DATA_4K,		128,	" TLB_DATA 4 KByte pages, 4-way set associative" },
 	{ 0xb4, TLB_DATA_4K,		256,	" TLB_DATA 4 KByte pages, 4-way associative" },
+	{ 0xb5, TLB_INST_4K,		64,	" TLB_INST 4 KByte pages, 8-way set ssociative" },
+	{ 0xb6, TLB_INST_4K,		128,	" TLB_INST 4 KByte pages, 8-way set ssociative" },
 	{ 0xba, TLB_DATA_4K,		64,	" TLB_DATA 4 KByte pages, 4-way associative" },
 	{ 0xc0, TLB_DATA_4K_4M,		8,	" TLB_DATA 4 KByte and 4 MByte pages, 4-way associative" },
+	{ 0xc1, STLB_4K_2M,		1024,	" STLB 4 KByte and 2 MByte pages, 8-way associative" },
+	{ 0xc2, TLB_DATA_2M_4M,		16,	" DTLB 2 MByte/4MByte pages, 4-way associative" },
 	{ 0xca, STLB_4K,		512,	" STLB 4 KByte pages, 4-way associative" },
 	{ 0x00, 0, 0 }
 };
@@ -557,6 +565,20 @@ static void intel_tlb_lookup(const unsigned char desc)
 		if (tlb_lld_4k[ENTRIES] < intel_tlb_table[k].entries)
 			tlb_lld_4k[ENTRIES] = intel_tlb_table[k].entries;
 		break;
+	case STLB_4K_2M:
+		if (tlb_lli_4k[ENTRIES] < intel_tlb_table[k].entries)
+			tlb_lli_4k[ENTRIES] = intel_tlb_table[k].entries;
+		if (tlb_lld_4k[ENTRIES] < intel_tlb_table[k].entries)
+			tlb_lld_4k[ENTRIES] = intel_tlb_table[k].entries;
+		if (tlb_lli_2m[ENTRIES] < intel_tlb_table[k].entries)
+			tlb_lli_2m[ENTRIES] = intel_tlb_table[k].entries;
+		if (tlb_lld_2m[ENTRIES] < intel_tlb_table[k].entries)
+			tlb_lld_2m[ENTRIES] = intel_tlb_table[k].entries;
+		if (tlb_lli_4m[ENTRIES] < intel_tlb_table[k].entries)
+			tlb_lli_4m[ENTRIES] = intel_tlb_table[k].entries;
+		if (tlb_lld_4m[ENTRIES] < intel_tlb_table[k].entries)
+			tlb_lld_4m[ENTRIES] = intel_tlb_table[k].entries;
+		break;
 	case TLB_INST_ALL:
 		if (tlb_lli_4k[ENTRIES] < intel_tlb_table[k].entries)
 			tlb_lli_4k[ENTRIES] = intel_tlb_table[k].entries;
@@ -602,6 +624,10 @@ static void intel_tlb_lookup(const unsigned char desc)
 		if (tlb_lld_4m[ENTRIES] < intel_tlb_table[k].entries)
 			tlb_lld_4m[ENTRIES] = intel_tlb_table[k].entries;
 		break;
+	case TLB_DATA_1G:
+		if (tlb_lld_1g[ENTRIES] < intel_tlb_table[k].entries)
+			tlb_lld_1g[ENTRIES] = intel_tlb_table[k].entries;
+		break;
 	}
 }
 
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
