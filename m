Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4056B026E
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:22:23 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so173972608pgc.2
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:22:23 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 71si29425514pgb.147.2016.12.08.08.22.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 08:22:21 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [QEMU, PATCH] x86: implement la57 paging mode
Date: Thu,  8 Dec 2016 19:21:22 +0300
Message-Id: <20161208162150.148763-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, qemu-devel@nongnu.org

The new paging more is extension of IA32e mode with more additional page
table level.

It brings support of 57-bit vitrual address space (128PB) and 52-bit
physical address space (4PB).

The structure of new page table level is identical to pml4.

The feature is enumerated with CPUID.(EAX=07H, ECX=0):ECX[bit 16].

CR4.LA57[bit 12] need to be set when pageing enables to activate 5-level
paging mode.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: qemu-devel@nongnu.org
---
 target-i386/arch_memory_mapping.c |  42 ++++++++--
 target-i386/cpu.c                 |  16 ++--
 target-i386/cpu.h                 |   2 +
 target-i386/helper.c              |  54 ++++++++++--
 target-i386/monitor.c             | 167 ++++++++++++++++++++++++++++++++------
 target-i386/translate.c           |   2 +
 6 files changed, 238 insertions(+), 45 deletions(-)

diff --git a/target-i386/arch_memory_mapping.c b/target-i386/arch_memory_mapping.c
index 88f341e1bbd0..826aee597b13 100644
--- a/target-i386/arch_memory_mapping.c
+++ b/target-i386/arch_memory_mapping.c
@@ -220,7 +220,8 @@ static void walk_pdpe(MemoryMappingList *list, AddressSpace *as,
 
 /* IA-32e Paging */
 static void walk_pml4e(MemoryMappingList *list, AddressSpace *as,
-                       hwaddr pml4e_start_addr, int32_t a20_mask)
+                       hwaddr pml4e_start_addr, int32_t a20_mask,
+                       target_ulong start_line_addr)
 {
     hwaddr pml4e_addr, pdpe_start_addr;
     uint64_t pml4e;
@@ -236,11 +237,34 @@ static void walk_pml4e(MemoryMappingList *list, AddressSpace *as,
             continue;
         }
 
-        line_addr = ((i & 0x1ffULL) << 39) | (0xffffULL << 48);
+        line_addr = start_line_addr | ((i & 0x1ffULL) << 39);
         pdpe_start_addr = (pml4e & PLM4_ADDR_MASK) & a20_mask;
         walk_pdpe(list, as, pdpe_start_addr, a20_mask, line_addr);
     }
 }
+
+static void walk_pml5e(MemoryMappingList *list, AddressSpace *as,
+                       hwaddr pml5e_start_addr, int32_t a20_mask)
+{
+    hwaddr pml5e_addr, pml4e_start_addr;
+    uint64_t pml5e;
+    target_ulong line_addr;
+    int i;
+
+    for (i = 0; i < 512; i++) {
+        pml5e_addr = (pml5e_start_addr + i * 8) & a20_mask;
+        pml5e = address_space_ldq(as, pml5e_addr, MEMTXATTRS_UNSPECIFIED,
+                                  NULL);
+        if (!(pml5e & PG_PRESENT_MASK)) {
+            /* not present */
+            continue;
+        }
+
+        line_addr = (0x7fULL << 57) | ((i & 0x1ffULL) << 48);
+        pml4e_start_addr = (pml5e & PLM4_ADDR_MASK) & a20_mask;
+        walk_pml4e(list, as, pml4e_start_addr, a20_mask, line_addr);
+    }
+}
 #endif
 
 void x86_cpu_get_memory_mapping(CPUState *cs, MemoryMappingList *list,
@@ -257,10 +281,18 @@ void x86_cpu_get_memory_mapping(CPUState *cs, MemoryMappingList *list,
     if (env->cr[4] & CR4_PAE_MASK) {
 #ifdef TARGET_X86_64
         if (env->hflags & HF_LMA_MASK) {
-            hwaddr pml4e_addr;
+            if (env->cr[4] & CR4_LA57_MASK) {
+                hwaddr pml5e_addr;
+
+                pml5e_addr = (env->cr[3] & PLM4_ADDR_MASK) & env->a20_mask;
+                walk_pml5e(list, cs->as, pml5e_addr, env->a20_mask);
+            } else {
+                hwaddr pml4e_addr;
 
-            pml4e_addr = (env->cr[3] & PLM4_ADDR_MASK) & env->a20_mask;
-            walk_pml4e(list, cs->as, pml4e_addr, env->a20_mask);
+                pml4e_addr = (env->cr[3] & PLM4_ADDR_MASK) & env->a20_mask;
+                walk_pml4e(list, cs->as, pml4e_addr, env->a20_mask,
+                        0xffffULL << 48);
+            }
         } else
 #endif
         {
diff --git a/target-i386/cpu.c b/target-i386/cpu.c
index de1f30eeda63..a4b9832b5916 100644
--- a/target-i386/cpu.c
+++ b/target-i386/cpu.c
@@ -238,7 +238,8 @@ static void x86_cpu_vendor_words2str(char *dst, uint32_t vendor1,
           CPUID_7_0_EBX_HLE, CPUID_7_0_EBX_AVX2,
           CPUID_7_0_EBX_INVPCID, CPUID_7_0_EBX_RTM,
           CPUID_7_0_EBX_RDSEED */
-#define TCG_7_0_ECX_FEATURES (CPUID_7_0_ECX_PKU | CPUID_7_0_ECX_OSPKE)
+#define TCG_7_0_ECX_FEATURES (CPUID_7_0_ECX_PKU | CPUID_7_0_ECX_OSPKE | \
+          CPUID_7_0_ECX_LA57)
 #define TCG_7_0_EDX_FEATURES 0
 #define TCG_APM_FEATURES 0
 #define TCG_6_EAX_FEATURES CPUID_6_EAX_ARAT
@@ -435,7 +436,7 @@ static FeatureWordInfo feature_word_info[FEATURE_WORDS] = {
             "ospke", NULL, NULL, NULL,
             NULL, NULL, NULL, NULL,
             NULL, NULL, NULL, NULL,
-            NULL, NULL, NULL, NULL,
+            "la57", NULL, NULL, NULL,
             NULL, NULL, "rdpid", NULL,
             NULL, NULL, NULL, NULL,
             NULL, NULL, NULL, NULL,
@@ -2742,10 +2743,13 @@ void cpu_x86_cpuid(CPUX86State *env, uint32_t index, uint32_t count,
     case 0x80000008:
         /* virtual & phys address size in low 2 bytes. */
         if (env->features[FEAT_8000_0001_EDX] & CPUID_EXT2_LM) {
-            /* 64 bit processor, 48 bits virtual, configurable
-             * physical bits.
-             */
-            *eax = 0x00003000 + cpu->phys_bits;
+            /* 64 bit processor */
+            *eax = cpu->phys_bits; /* configurable physical bits */
+            if  (env->features[FEAT_7_0_ECX] & CPUID_7_0_ECX_LA57) {
+                *eax |= 0x00003900; /* 57 bits virtual */
+            } else {
+                *eax |= 0x00003000; /* 48 bits virtual */
+            }
         } else {
             *eax = cpu->phys_bits;
         }
diff --git a/target-i386/cpu.h b/target-i386/cpu.h
index c60572402272..0ba880fc2632 100644
--- a/target-i386/cpu.h
+++ b/target-i386/cpu.h
@@ -224,6 +224,7 @@
 #define CR4_OSFXSR_SHIFT 9
 #define CR4_OSFXSR_MASK (1U << CR4_OSFXSR_SHIFT)
 #define CR4_OSXMMEXCPT_MASK  (1U << 10)
+#define CR4_LA57_MASK   (1U << 12)
 #define CR4_VMXE_MASK   (1U << 13)
 #define CR4_SMXE_MASK   (1U << 14)
 #define CR4_FSGSBASE_MASK (1U << 16)
@@ -628,6 +629,7 @@ typedef uint32_t FeatureWordArray[FEATURE_WORDS];
 #define CPUID_7_0_ECX_UMIP     (1U << 2)
 #define CPUID_7_0_ECX_PKU      (1U << 3)
 #define CPUID_7_0_ECX_OSPKE    (1U << 4)
+#define CPUID_7_0_ECX_LA57     (1U << 16)
 #define CPUID_7_0_ECX_RDPID    (1U << 22)
 
 #define CPUID_7_0_EDX_AVX512_4VNNIW (1U << 2) /* AVX512 Neural Network Instructions */
diff --git a/target-i386/helper.c b/target-i386/helper.c
index 4ecc0912a48a..43e87ddba001 100644
--- a/target-i386/helper.c
+++ b/target-i386/helper.c
@@ -651,11 +651,11 @@ void cpu_x86_update_cr4(CPUX86State *env, uint32_t new_cr4)
     uint32_t hflags;
 
 #if defined(DEBUG_MMU)
-    printf("CR4 update: CR4=%08x\n", (uint32_t)env->cr[4]);
+    printf("CR4 update: %08x -> %08x\n", (uint32_t)env->cr[4], new_cr4);
 #endif
     if ((new_cr4 ^ env->cr[4]) &
         (CR4_PGE_MASK | CR4_PAE_MASK | CR4_PSE_MASK |
-         CR4_SMEP_MASK | CR4_SMAP_MASK)) {
+         CR4_SMEP_MASK | CR4_SMAP_MASK | CR4_LA57_MASK)) {
         tlb_flush(CPU(cpu), 1);
     }
 
@@ -757,19 +757,41 @@ int x86_cpu_handle_mmu_fault(CPUState *cs, vaddr addr,
 
 #ifdef TARGET_X86_64
         if (env->hflags & HF_LMA_MASK) {
+            bool la57 = env->cr[4] & CR4_LA57_MASK;
+            uint64_t pml5e_addr, pml5e;
             uint64_t pml4e_addr, pml4e;
             int32_t sext;
 
             /* test virtual address sign extension */
-            sext = (int64_t)addr >> 47;
+            sext = la57 ? (int64_t)addr >> 56 : (int64_t)addr >> 47;
             if (sext != 0 && sext != -1) {
                 env->error_code = 0;
                 cs->exception_index = EXCP0D_GPF;
                 return 1;
             }
 
-            pml4e_addr = ((env->cr[3] & ~0xfff) + (((addr >> 39) & 0x1ff) << 3)) &
-                env->a20_mask;
+            if (la57) {
+                pml5e_addr = ((env->cr[3] & ~0xfff) +
+                        (((addr >> 48) & 0x1ff) << 3)) & env->a20_mask;
+                pml5e = x86_ldq_phys(cs, pml5e_addr);
+                if (!(pml5e & PG_PRESENT_MASK)) {
+                    goto do_fault;
+                }
+                if (pml5e & (rsvd_mask | PG_PSE_MASK)) {
+                    goto do_fault_rsvd;
+                }
+                if (!(pml5e & PG_ACCESSED_MASK)) {
+                    pml5e |= PG_ACCESSED_MASK;
+                    x86_stl_phys_notdirty(cs, pml5e_addr, pml5e);
+                }
+                ptep = pml5e ^ PG_NX_MASK;
+            } else {
+                pml5e = env->cr[3];
+                ptep = PG_NX_MASK | PG_USER_MASK | PG_RW_MASK;
+            }
+
+            pml4e_addr = ((pml5e & PG_ADDRESS_MASK) +
+                    (((addr >> 39) & 0x1ff) << 3)) & env->a20_mask;
             pml4e = x86_ldq_phys(cs, pml4e_addr);
             if (!(pml4e & PG_PRESENT_MASK)) {
                 goto do_fault;
@@ -781,7 +803,7 @@ int x86_cpu_handle_mmu_fault(CPUState *cs, vaddr addr,
                 pml4e |= PG_ACCESSED_MASK;
                 x86_stl_phys_notdirty(cs, pml4e_addr, pml4e);
             }
-            ptep = pml4e ^ PG_NX_MASK;
+            ptep &= pml4e ^ PG_NX_MASK;
             pdpe_addr = ((pml4e & PG_ADDRESS_MASK) + (((addr >> 30) & 0x1ff) << 3)) &
                 env->a20_mask;
             pdpe = x86_ldq_phys(cs, pdpe_addr);
@@ -1024,16 +1046,30 @@ hwaddr x86_cpu_get_phys_page_debug(CPUState *cs, vaddr addr)
 
 #ifdef TARGET_X86_64
         if (env->hflags & HF_LMA_MASK) {
+            bool la57 = env->cr[4] & CR4_LA57_MASK;
+            uint64_t pml5e_addr, pml5e;
             uint64_t pml4e_addr, pml4e;
             int32_t sext;
 
             /* test virtual address sign extension */
-            sext = (int64_t)addr >> 47;
+            sext = la57 ? (int64_t)addr >> 56 : (int64_t)addr >> 47;
             if (sext != 0 && sext != -1) {
                 return -1;
             }
-            pml4e_addr = ((env->cr[3] & ~0xfff) + (((addr >> 39) & 0x1ff) << 3)) &
-                env->a20_mask;
+
+            if (la57) {
+                pml5e_addr = ((env->cr[3] & ~0xfff) +
+                        (((addr >> 48) & 0x1ff) << 3)) & env->a20_mask;
+                pml5e = x86_ldq_phys(cs, pml5e_addr);
+                if (!(pml5e & PG_PRESENT_MASK)) {
+                    return -1;
+                }
+            } else {
+                pml5e = env->cr[3];
+            }
+
+            pml4e_addr = ((pml5e & PG_ADDRESS_MASK) +
+                    (((addr >> 39) & 0x1ff) << 3)) & env->a20_mask;
             pml4e = x86_ldq_phys(cs, pml4e_addr);
             if (!(pml4e & PG_PRESENT_MASK)) {
                 return -1;
diff --git a/target-i386/monitor.c b/target-i386/monitor.c
index 9a3b4d746e8d..ae2d2f66b6fa 100644
--- a/target-i386/monitor.c
+++ b/target-i386/monitor.c
@@ -30,13 +30,18 @@
 #include "hmp.h"
 
 
-static void print_pte(Monitor *mon, hwaddr addr,
-                      hwaddr pte,
-                      hwaddr mask)
+static void print_pte(Monitor *mon, CPUArchState *env, hwaddr addr,
+                      hwaddr pte, hwaddr mask)
 {
 #ifdef TARGET_X86_64
-    if (addr & (1ULL << 47)) {
-        addr |= -1LL << 48;
+    if (env->cr[4] & CR4_LA57_MASK) {
+        if (addr & (1ULL << 56)) {
+            addr |= -1LL << 57;
+        }
+    } else {
+        if (addr & (1ULL << 47)) {
+            addr |= -1LL << 48;
+        }
     }
 #endif
     monitor_printf(mon, TARGET_FMT_plx ": " TARGET_FMT_plx
@@ -66,13 +71,13 @@ static void tlb_info_32(Monitor *mon, CPUArchState *env)
         if (pde & PG_PRESENT_MASK) {
             if ((pde & PG_PSE_MASK) && (env->cr[4] & CR4_PSE_MASK)) {
                 /* 4M pages */
-                print_pte(mon, (l1 << 22), pde, ~((1 << 21) - 1));
+                print_pte(mon, env, (l1 << 22), pde, ~((1 << 21) - 1));
             } else {
                 for(l2 = 0; l2 < 1024; l2++) {
                     cpu_physical_memory_read((pde & ~0xfff) + l2 * 4, &pte, 4);
                     pte = le32_to_cpu(pte);
                     if (pte & PG_PRESENT_MASK) {
-                        print_pte(mon, (l1 << 22) + (l2 << 12),
+                        print_pte(mon, env, (l1 << 22) + (l2 << 12),
                                   pte & ~PG_PSE_MASK,
                                   ~0xfff);
                     }
@@ -100,7 +105,7 @@ static void tlb_info_pae32(Monitor *mon, CPUArchState *env)
                 if (pde & PG_PRESENT_MASK) {
                     if (pde & PG_PSE_MASK) {
                         /* 2M pages with PAE, CR4.PSE is ignored */
-                        print_pte(mon, (l1 << 30 ) + (l2 << 21), pde,
+                        print_pte(mon, env, (l1 << 30 ) + (l2 << 21), pde,
                                   ~((hwaddr)(1 << 20) - 1));
                     } else {
                         pt_addr = pde & 0x3fffffffff000ULL;
@@ -108,7 +113,7 @@ static void tlb_info_pae32(Monitor *mon, CPUArchState *env)
                             cpu_physical_memory_read(pt_addr + l3 * 8, &pte, 8);
                             pte = le64_to_cpu(pte);
                             if (pte & PG_PRESENT_MASK) {
-                                print_pte(mon, (l1 << 30 ) + (l2 << 21)
+                                print_pte(mon, env, (l1 << 30 ) + (l2 << 21)
                                           + (l3 << 12),
                                           pte & ~PG_PSE_MASK,
                                           ~(hwaddr)0xfff);
@@ -122,13 +127,13 @@ static void tlb_info_pae32(Monitor *mon, CPUArchState *env)
 }
 
 #ifdef TARGET_X86_64
-static void tlb_info_64(Monitor *mon, CPUArchState *env)
+static void tlb_info_la48(Monitor *mon, CPUArchState *env,
+        uint64_t l0, uint64_t pml4_addr)
 {
     uint64_t l1, l2, l3, l4;
     uint64_t pml4e, pdpe, pde, pte;
-    uint64_t pml4_addr, pdp_addr, pd_addr, pt_addr;
+    uint64_t pdp_addr, pd_addr, pt_addr;
 
-    pml4_addr = env->cr[3] & 0x3fffffffff000ULL;
     for (l1 = 0; l1 < 512; l1++) {
         cpu_physical_memory_read(pml4_addr + l1 * 8, &pml4e, 8);
         pml4e = le64_to_cpu(pml4e);
@@ -140,8 +145,8 @@ static void tlb_info_64(Monitor *mon, CPUArchState *env)
                 if (pdpe & PG_PRESENT_MASK) {
                     if (pdpe & PG_PSE_MASK) {
                         /* 1G pages, CR4.PSE is ignored */
-                        print_pte(mon, (l1 << 39) + (l2 << 30), pdpe,
-                                  0x3ffffc0000000ULL);
+                        print_pte(mon, env, (l0 << 48) + (l1 << 39) + (l2 << 30),
+                                pdpe, 0x3ffffc0000000ULL);
                     } else {
                         pd_addr = pdpe & 0x3fffffffff000ULL;
                         for (l3 = 0; l3 < 512; l3++) {
@@ -150,9 +155,9 @@ static void tlb_info_64(Monitor *mon, CPUArchState *env)
                             if (pde & PG_PRESENT_MASK) {
                                 if (pde & PG_PSE_MASK) {
                                     /* 2M pages, CR4.PSE is ignored */
-                                    print_pte(mon, (l1 << 39) + (l2 << 30) +
-                                              (l3 << 21), pde,
-                                              0x3ffffffe00000ULL);
+                                    print_pte(mon, env, (l0 << 48) + (l1 << 39) +
+                                            (l2 << 30) + (l3 << 21), pde,
+                                            0x3ffffffe00000ULL);
                                 } else {
                                     pt_addr = pde & 0x3fffffffff000ULL;
                                     for (l4 = 0; l4 < 512; l4++) {
@@ -161,11 +166,11 @@ static void tlb_info_64(Monitor *mon, CPUArchState *env)
                                                                  &pte, 8);
                                         pte = le64_to_cpu(pte);
                                         if (pte & PG_PRESENT_MASK) {
-                                            print_pte(mon, (l1 << 39) +
-                                                      (l2 << 30) +
-                                                      (l3 << 21) + (l4 << 12),
-                                                      pte & ~PG_PSE_MASK,
-                                                      0x3fffffffff000ULL);
+                                            print_pte(mon, env, (l0 << 48) +
+                                                    (l1 << 39) + (l2 << 30) +
+                                                    (l3 << 21) + (l4 << 12),
+                                                    pte & ~PG_PSE_MASK,
+                                                    0x3fffffffff000ULL);
                                         }
                                     }
                                 }
@@ -177,6 +182,22 @@ static void tlb_info_64(Monitor *mon, CPUArchState *env)
         }
     }
 }
+
+static void tlb_info_la57(Monitor *mon, CPUArchState *env)
+{
+    uint64_t l0;
+    uint64_t pml5e;
+    uint64_t pml5_addr;
+
+    pml5_addr = env->cr[3] & 0x3fffffffff000ULL;
+    for (l0 = 0; l0 < 512; l0++) {
+        cpu_physical_memory_read(pml5_addr + l0 * 8, &pml5e, 8);
+        pml5e = le64_to_cpu(pml5e);
+        if (pml5e & PG_PRESENT_MASK) {
+            tlb_info_la48(mon, env, l0, pml5e & 0x3fffffffff000ULL);
+        }
+    }
+}
 #endif /* TARGET_X86_64 */
 
 void hmp_info_tlb(Monitor *mon, const QDict *qdict)
@@ -192,7 +213,11 @@ void hmp_info_tlb(Monitor *mon, const QDict *qdict)
     if (env->cr[4] & CR4_PAE_MASK) {
 #ifdef TARGET_X86_64
         if (env->hflags & HF_LMA_MASK) {
-            tlb_info_64(mon, env);
+            if (env->cr[4] & CR4_LA57_MASK) {
+                tlb_info_la57(mon, env);
+            } else {
+                tlb_info_la48(mon, env, 0, env->cr[3] & 0x3fffffffff000ULL);
+            }
         } else
 #endif
         {
@@ -324,7 +349,7 @@ static void mem_info_pae32(Monitor *mon, CPUArchState *env)
 
 
 #ifdef TARGET_X86_64
-static void mem_info_64(Monitor *mon, CPUArchState *env)
+static void mem_info_la48(Monitor *mon, CPUArchState *env)
 {
     int prot, last_prot;
     uint64_t l1, l2, l3, l4;
@@ -400,6 +425,94 @@ static void mem_info_64(Monitor *mon, CPUArchState *env)
     /* Flush last range */
     mem_print(mon, &start, &last_prot, (hwaddr)1 << 48, 0);
 }
+
+static void mem_info_la57(Monitor *mon, CPUArchState *env)
+{
+    int prot, last_prot;
+    uint64_t l0, l1, l2, l3, l4;
+    uint64_t pml5e, pml4e, pdpe, pde, pte;
+    uint64_t pml5_addr, pml4_addr, pdp_addr, pd_addr, pt_addr, start, end;
+
+    pml5_addr = env->cr[3] & 0x3fffffffff000ULL;
+    last_prot = 0;
+    start = -1;
+    for (l0 = 0; l0 < 512; l0++) {
+        cpu_physical_memory_read(pml5_addr + l0 * 8, &pml5e, 8);
+        pml4e = le64_to_cpu(pml5e);
+        end = l0 << 48;
+        if (pml5e & PG_PRESENT_MASK) {
+            pml4_addr = pml5e & 0x3fffffffff000ULL;
+            for (l1 = 0; l1 < 512; l1++) {
+                cpu_physical_memory_read(pml4_addr + l1 * 8, &pml4e, 8);
+                pml4e = le64_to_cpu(pml4e);
+                end = (l0 << 48) + (l1 << 39);
+                if (pml4e & PG_PRESENT_MASK) {
+                    pdp_addr = pml4e & 0x3fffffffff000ULL;
+                    for (l2 = 0; l2 < 512; l2++) {
+                        cpu_physical_memory_read(pdp_addr + l2 * 8, &pdpe, 8);
+                        pdpe = le64_to_cpu(pdpe);
+                        end = (l0 << 48) + (l1 << 39) + (l2 << 30);
+                        if (pdpe & PG_PRESENT_MASK) {
+                            if (pdpe & PG_PSE_MASK) {
+                                prot = pdpe & (PG_USER_MASK | PG_RW_MASK |
+                                               PG_PRESENT_MASK);
+                                prot &= pml4e;
+                                mem_print(mon, &start, &last_prot, end, prot);
+                            } else {
+                                pd_addr = pdpe & 0x3fffffffff000ULL;
+                                for (l3 = 0; l3 < 512; l3++) {
+                                    cpu_physical_memory_read(pd_addr + l3 * 8, &pde, 8);
+                                    pde = le64_to_cpu(pde);
+                                    end = (l0 << 48) + (l1 << 39) + (l2 << 30) + (l3 << 21);
+                                    if (pde & PG_PRESENT_MASK) {
+                                        if (pde & PG_PSE_MASK) {
+                                            prot = pde & (PG_USER_MASK | PG_RW_MASK |
+                                                          PG_PRESENT_MASK);
+                                            prot &= pml4e & pdpe;
+                                            mem_print(mon, &start, &last_prot, end, prot);
+                                        } else {
+                                            pt_addr = pde & 0x3fffffffff000ULL;
+                                            for (l4 = 0; l4 < 512; l4++) {
+                                                cpu_physical_memory_read(pt_addr
+                                                                         + l4 * 8,
+                                                                         &pte, 8);
+                                                pte = le64_to_cpu(pte);
+                                                end = (l0 << 48) + (l1 << 39) + (l2 << 30) +
+                                                    (l3 << 21) + (l4 << 12);
+                                                if (pte & PG_PRESENT_MASK) {
+                                                    prot = pte & (PG_USER_MASK | PG_RW_MASK |
+                                                                  PG_PRESENT_MASK);
+                                                    prot &= pml4e & pdpe & pde;
+                                                } else {
+                                                    prot = 0;
+                                                }
+                                                mem_print(mon, &start, &last_prot, end, prot);
+                                            }
+                                        }
+                                    } else {
+                                        prot = 0;
+                                        mem_print(mon, &start, &last_prot, end, prot);
+                                    }
+                                }
+                            }
+                        } else {
+                            prot = 0;
+                            mem_print(mon, &start, &last_prot, end, prot);
+                        }
+                    }
+                } else {
+                    prot = 0;
+                    mem_print(mon, &start, &last_prot, end, prot);
+                }
+            }
+        } else {
+            prot = 0;
+            mem_print(mon, &start, &last_prot, end, prot);
+        }
+    }
+    /* Flush last range */
+    mem_print(mon, &start, &last_prot, (hwaddr)1 << 57, 0);
+}
 #endif /* TARGET_X86_64 */
 
 void hmp_info_mem(Monitor *mon, const QDict *qdict)
@@ -415,7 +528,11 @@ void hmp_info_mem(Monitor *mon, const QDict *qdict)
     if (env->cr[4] & CR4_PAE_MASK) {
 #ifdef TARGET_X86_64
         if (env->hflags & HF_LMA_MASK) {
-            mem_info_64(mon, env);
+            if (env->cr[4] & CR4_LA57_MASK) {
+                mem_info_la57(mon, env);
+            } else {
+                mem_info_la48(mon, env);
+            }
         } else
 #endif
         {
diff --git a/target-i386/translate.c b/target-i386/translate.c
index 324103c88521..d2aec5c9bf06 100644
--- a/target-i386/translate.c
+++ b/target-i386/translate.c
@@ -137,6 +137,7 @@ typedef struct DisasContext {
     int cpuid_ext2_features;
     int cpuid_ext3_features;
     int cpuid_7_0_ebx_features;
+    int cpuid_7_0_ecx_features;
     int cpuid_xsave_features;
 } DisasContext;
 
@@ -8350,6 +8351,7 @@ void gen_intermediate_code(CPUX86State *env, TranslationBlock *tb)
     dc->cpuid_ext2_features = env->features[FEAT_8000_0001_EDX];
     dc->cpuid_ext3_features = env->features[FEAT_8000_0001_ECX];
     dc->cpuid_7_0_ebx_features = env->features[FEAT_7_0_EBX];
+    dc->cpuid_7_0_ecx_features = env->features[FEAT_7_0_ECX];
     dc->cpuid_xsave_features = env->features[FEAT_XSAVE];
 #ifdef TARGET_X86_64
     dc->lma = (flags >> HF_LMA_SHIFT) & 1;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
