Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id BFB106B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 10:54:43 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id a99so48462540oic.8
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 07:54:43 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40114.outbound.protection.outlook.com. [40.107.4.114])
        by mx.google.com with ESMTPS id g45si578223ote.249.2017.06.01.07.54.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 07:54:42 -0700 (PDT)
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
 <20170525203334.867-8-kirill.shutemov@linux.intel.com>
 <20170526221059.o4kyt3ijdweurz6j@node.shutemov.name>
 <CACT4Y+YyFWg3fbj4ta3tSKoeBaw7hbL2YoBatAFiFB1_cMg9=Q@mail.gmail.com>
 <71e11033-f95c-887f-4e4e-351bcc3df71e@virtuozzo.com>
 <CACT4Y+bSTOeJtDDZVmkff=qqJFesA_b6uTG__EAn4AvDLw0jzQ@mail.gmail.com>
 <c4f11000-6138-c6ab-d075-2c4bd6a14943@virtuozzo.com>
 <75acbed7-6a08-692f-61b5-2b44f66ec0d8@virtuozzo.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <bc95be68-8c68-2a45-c530-acbc6c90a231@virtuozzo.com>
Date: Thu, 1 Jun 2017 17:56:30 +0300
MIME-Version: 1.0
In-Reply-To: <75acbed7-6a08-692f-61b5-2b44f66ec0d8@virtuozzo.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>

On 05/29/2017 03:46 PM, Andrey Ryabinin wrote:
> On 05/29/2017 02:45 PM, Andrey Ryabinin wrote:
>>>>>> Looks like KASAN will be a problem for boot-time paging mode switching.
>>>>>> It wants to know CONFIG_KASAN_SHADOW_OFFSET at compile-time to pass to
>>>>>> gcc -fasan-shadow-offset=. But this value varies between paging modes...
>>>>>>
>>>>>> I don't see how to solve it. Folks, any ideas?
>>>>>
>>>>> +kasan-dev
>>>>>
>>>>> I wonder if we can use the same offset for both modes. If we use
>>>>> 0xFFDFFC0000000000 as start of shadow for 5 levels, then the same
>>>>> offset that we use for 4 levels (0xdffffc0000000000) will also work
>>>>> for 5 levels. Namely, ending of 5 level shadow will overlap with 4
>>>>> level mapping (both end at 0xfffffbffffffffff), but 5 level mapping
>>>>> extends towards lower addresses. The current 5 level start of shadow
>>>>> is actually close -- 0xffd8000000000000 and it seems that the required
>>>>> space after it is unused at the moment (at least looking at mm.txt).
>>>>> So just try to move it to 0xFFDFFC0000000000?
>>>>>
>>>>
>>>> Yeah, this should work, but note that 0xFFDFFC0000000000 is not PGDIR aligned address. Our init code
>>>> assumes that kasan shadow stars and ends on the PGDIR aligned address.
>>>> Fortunately this is fixable, we'd need two more pages for page tables to map unaligned start/end
>>>> of the shadow.
>>>
>>> I think we can extend the shadow backwards (to the current address),
>>> provided that it does not affect shadow offset that we pass to
>>> compiler.
>>
>> I thought about this. We can round down shadow start to 0xffdf000000000000, but we can't
>> round up shadow end, because in that case shadow would end at 0xffffffffffffffff.
>> So we still need at least one more page to cover unaligned end.
> 
> Actually, I'm wrong here. I assumed that we would need an additional page to store p4d entries,
> but in fact we don't need it, as such page should already exist. It's the same last pgd where kernel image
> is mapped.
> 


Something like bellow might work. It's just a proposal to demonstrate the idea, so some code might look ugly.
And it's only build-tested.

Based on top of: git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git la57/integration


---
 arch/x86/Kconfig            |  1 -
 arch/x86/mm/kasan_init_64.c | 74 ++++++++++++++++++++++++++++++++-------------
 2 files changed, 53 insertions(+), 22 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 11bd0498f64c..3456f2fdda52 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -291,7 +291,6 @@ config ARCH_SUPPORTS_DEBUG_PAGEALLOC
 config KASAN_SHADOW_OFFSET
 	hex
 	depends on KASAN
-	default 0xdff8000000000000 if X86_5LEVEL
 	default 0xdffffc0000000000
 
 config HAVE_INTEL_TXT
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 88215ac16b24..d79a7ea83d05 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -15,6 +15,10 @@
 extern pgd_t early_top_pgt[PTRS_PER_PGD];
 extern struct range pfn_mapped[E820_MAX_ENTRIES];
 
+#if CONFIG_PGTABLE_LEVELS == 5
+p4d_t tmp_p4d_table[PTRS_PER_P4D] __initdata __aligned(PAGE_SIZE);
+#endif
+
 static int __init map_range(struct range *range)
 {
 	unsigned long start;
@@ -35,8 +39,9 @@ static void __init clear_pgds(unsigned long start,
 			unsigned long end)
 {
 	pgd_t *pgd;
+	unsigned long pgd_end = end & PGDIR_MASK;
 
-	for (; start < end; start += PGDIR_SIZE) {
+	for (; start < pgd_end; start += PGDIR_SIZE) {
 		pgd = pgd_offset_k(start);
 		/*
 		 * With folded p4d, pgd_clear() is nop, use p4d_clear()
@@ -47,29 +52,50 @@ static void __init clear_pgds(unsigned long start,
 		else
 			pgd_clear(pgd);
 	}
+
+	pgd = pgd_offset_k(start);
+	for (; start < end; start += P4D_SIZE)
+		p4d_clear(p4d_offset(pgd, start));
+}
+
+static void __init kasan_early_p4d_populate(pgd_t *pgd,
+					unsigned long addr,
+					unsigned long end)
+{
+	p4d_t *p4d;
+	unsigned long next;
+
+	if (pgd_none(*pgd))
+		set_pgd(pgd, __pgd(_KERNPG_TABLE | __pa_nodebug(kasan_zero_p4d)));
+
+	/* early p4d_offset()
+	 * TODO: we need helpers for this shit
+	 */
+	if (CONFIG_PGTABLE_LEVELS == 5)
+		p4d = ((p4d_t*)((__pa_nodebug(pgd->pgd) & PTE_PFN_MASK) + __START_KERNEL_map))
+			+ p4d_index(addr);
+	else
+		p4d = (p4d_t*)pgd;
+	do {
+		next = p4d_addr_end(addr, end);
+
+		if (p4d_none(*p4d))
+			set_p4d(p4d, __p4d(_KERNPG_TABLE |
+					__pa_nodebug(kasan_zero_pud)));
+	} while (p4d++, addr = next, addr != end && p4d_none(*p4d));
 }
 
 static void __init kasan_map_early_shadow(pgd_t *pgd)
 {
-	int i;
-	unsigned long start = KASAN_SHADOW_START;
+	unsigned long addr = KASAN_SHADOW_START & PGDIR_MASK;
 	unsigned long end = KASAN_SHADOW_END;
+	unsigned long next;
 
-	for (i = pgd_index(start); start < end; i++) {
-		switch (CONFIG_PGTABLE_LEVELS) {
-		case 4:
-			pgd[i] = __pgd(__pa_nodebug(kasan_zero_pud) |
-					_KERNPG_TABLE);
-			break;
-		case 5:
-			pgd[i] = __pgd(__pa_nodebug(kasan_zero_p4d) |
-					_KERNPG_TABLE);
-			break;
-		default:
-			BUILD_BUG();
-		}
-		start += PGDIR_SIZE;
-	}
+	pgd = pgd + pgd_index(addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		kasan_early_p4d_populate(pgd, addr, next);
+	} while (pgd++, addr = next, addr != end);
 }
 
 #ifdef CONFIG_KASAN_INLINE
@@ -120,14 +146,20 @@ void __init kasan_init(void)
 #ifdef CONFIG_KASAN_INLINE
 	register_die_notifier(&kasan_die_notifier);
 #endif
-
 	memcpy(early_top_pgt, init_top_pgt, sizeof(early_top_pgt));
+#if CONFIG_PGTABLE_LEVELS == 5
+	memcpy(tmp_p4d_table, (void*)pgd_page_vaddr(*pgd_offset_k(KASAN_SHADOW_END)),
+		sizeof(tmp_p4d_table));
+	set_pgd(&early_top_pgt[pgd_index(KASAN_SHADOW_END)],
+		__pgd(__pa(tmp_p4d_table) | _KERNPG_TABLE));
+#endif
+
 	load_cr3(early_top_pgt);
 	__flush_tlb_all();
 
-	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
+	clear_pgds(KASAN_SHADOW_START & PGDIR_MASK, KASAN_SHADOW_END);
 
-	kasan_populate_zero_shadow((void *)KASAN_SHADOW_START,
+	kasan_populate_zero_shadow((void *)(KASAN_SHADOW_START & PGDIR_MASK),
 			kasan_mem_to_shadow((void *)PAGE_OFFSET));
 
 	for (i = 0; i < E820_MAX_ENTRIES; i++) {
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
