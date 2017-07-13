Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DBF7E440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 08:56:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v26so54095429pfa.0
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 05:56:14 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0110.outbound.protection.outlook.com. [104.47.1.110])
        by mx.google.com with ESMTPS id 41si1036068plf.204.2017.07.13.05.56.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Jul 2017 05:56:13 -0700 (PDT)
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
References: <20170710184704.realchrhzpblqqlk@node.shutemov.name>
 <CALCETrVJQ_u-agPm8fFHAW1UJY=VLowdbM+gXyjFCb586r0V3g@mail.gmail.com>
 <20170710212403.7ycczkhhki3vrgac@node.shutemov.name>
 <CALCETrW6pWzpdf1MVx_ytaYYuVGBsF7R+JowEsKqd3i=vCwJ_w@mail.gmail.com>
 <20170711103548.mkv5w7dd5gpdenne@node.shutemov.name>
 <CALCETrVpNUq3-zEu1Q1O77N8r4kv4kFdefXp7XEs3Hpf-JPAjg@mail.gmail.com>
 <d3caf8c4-4575-c1b5-6b0f-95527efaf2f9@virtuozzo.com>
 <f11d9e07-6b31-1add-7677-6a29d15ab608@virtuozzo.com>
 <20170711170332.wlaudicepkg35dmm@node.shutemov.name>
 <e9a395f4-018e-4c8c-2098-170172e438f3@virtuozzo.com>
 <20170711190554.zxkpjeg2bt65wtir@black.fi.intel.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <20939b37-efd8-2d32-0040-3682fff927c2@virtuozzo.com>
Date: Thu, 13 Jul 2017 15:58:29 +0300
MIME-Version: 1.0
In-Reply-To: <20170711190554.zxkpjeg2bt65wtir@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>

On 07/11/2017 10:05 PM, Kirill A. Shutemov wrote:
>>> Can use your Signed-off-by for a [cleaned up version of your] patch?
>>
>> Sure.
> 
> Another KASAN-releated issue: dumping page tables for KASAN shadow memory
> region takes unreasonable time due to kasan_zero_p?? mapped there.
> 
> The patch below helps. Any objections?
> 

Well, page tables dump doesn't work at all on 5-level paging.
E.g. I've got this nonsense: 

....
---[ Kernel Space ]---
0xffff800000000000-0xffff808000000000         512G                               pud
---[ Low Kernel Mapping ]---
0xffff808000000000-0xffff810000000000         512G                               pud
---[ vmalloc() Area ]---
0xffff810000000000-0xffff818000000000         512G                               pud
---[ Vmemmap ]---
0xffff818000000000-0xffffff0000000000      128512G                               pud
---[ ESPfix Area ]---
0xffffff0000000000-0x0000000000000000           1T                               pud
0x0000000000000000-0x0000000000000000           0E                               pgd
0x0000000000000000-0x0000000000001000           4K     RW     PCD         GLB NX pte
0x0000000000001000-0x0000000000002000           4K                               pte
0x0000000000002000-0x0000000000003000           4K     ro                 GLB NX pte
0x0000000000003000-0x0000000000004000           4K                               pte
0x0000000000004000-0x0000000000007000          12K     RW                 GLB NX pte
0x0000000000007000-0x0000000000008000           4K                               pte
0x0000000000008000-0x0000000000108000           1M     RW                 GLB NX pte
0x0000000000108000-0x0000000000109000           4K                               pte
0x0000000000109000-0x0000000000189000         512K     RW                 GLB NX pte
0x0000000000189000-0x000000000018a000           4K                               pte
0x000000000018a000-0x000000000018e000          16K     RW                 GLB NX pte
0x000000000018e000-0x000000000018f000           4K                               pte
0x000000000018f000-0x0000000000193000          16K     RW                 GLB NX pte
0x0000000000193000-0x0000000000194000           4K                               pte
... 304 entries skipped ... 
---[ EFI Runtime Services ]---
0xffffffef00000000-0xffffffff80000000          66G                               pud
---[ High Kernel Mapping ]---
0xffffffff80000000-0xffffffffc0000000           1G                               pud
...



As for KASAN, I think it would be better just to make it work faster, the patch below demonstrates the idea.



---
 arch/x86/mm/dump_pagetables.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 0470826d2bdc..36515fba86b0 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -13,6 +13,7 @@
  */
 
 #include <linux/debugfs.h>
+#include <linux/kasan.h>
 #include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/sched.h>
@@ -307,16 +308,19 @@ static void walk_pte_level(struct seq_file *m, struct pg_state *st, pmd_t addr,
 static void walk_pmd_level(struct seq_file *m, struct pg_state *st, pud_t addr, unsigned long P)
 {
 	int i;
-	pmd_t *start;
+	pmd_t *start, *pmd_addr;
 	pgprotval_t prot;
 
-	start = (pmd_t *)pud_page_vaddr(addr);
+	pmd_addr = start = (pmd_t *)pud_page_vaddr(addr);
 	for (i = 0; i < PTRS_PER_PMD; i++) {
 		st->current_address = normalize_addr(P + i * PMD_LEVEL_MULT);
 		if (!pmd_none(*start)) {
 			if (pmd_large(*start) || !pmd_present(*start)) {
 				prot = pmd_flags(*start);
 				note_page(m, st, __pgprot(prot), 3);
+			} else if (__pa(pmd_addr) == __pa(kasan_zero_pmd)) {
+				prot = pte_flags(kasan_zero_pte[0]);
+				note_page(m, st, __pgprot(prot), 4);
 			} else {
 				walk_pte_level(m, st, *start,
 					       P + i * PMD_LEVEL_MULT);
@@ -349,11 +353,11 @@ static bool pud_already_checked(pud_t *prev_pud, pud_t *pud, bool checkwx)
 static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr, unsigned long P)
 {
 	int i;
-	pud_t *start;
+	pud_t *start, *pud_addr;
 	pgprotval_t prot;
 	pud_t *prev_pud = NULL;
 
-	start = (pud_t *)p4d_page_vaddr(addr);
+	pud_addr = start = (pud_t *)p4d_page_vaddr(addr);
 
 	for (i = 0; i < PTRS_PER_PUD; i++) {
 		st->current_address = normalize_addr(P + i * PUD_LEVEL_MULT);
@@ -362,6 +366,9 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr,
 			if (pud_large(*start) || !pud_present(*start)) {
 				prot = pud_flags(*start);
 				note_page(m, st, __pgprot(prot), 2);
+			} else if (__pa(pud_addr) == __pa(kasan_zero_pud)) {
+				prot = pte_flags(kasan_zero_pte[0]);
+				note_page(m, st, __pgprot(prot), 4);
 			} else {
 				walk_pmd_level(m, st, *start,
 					       P + i * PUD_LEVEL_MULT);
@@ -385,10 +392,10 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr,
 static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr, unsigned long P)
 {
 	int i;
-	p4d_t *start;
+	p4d_t *start, *p4d_addr;
 	pgprotval_t prot;
 
-	start = (p4d_t *)pgd_page_vaddr(addr);
+	p4d_addr = start = (p4d_t *)pgd_page_vaddr(addr);
 
 	for (i = 0; i < PTRS_PER_P4D; i++) {
 		st->current_address = normalize_addr(P + i * P4D_LEVEL_MULT);
@@ -396,6 +403,9 @@ static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
 			if (p4d_large(*start) || !p4d_present(*start)) {
 				prot = p4d_flags(*start);
 				note_page(m, st, __pgprot(prot), 2);
+			} else if (__pa(p4d_addr) == __pa(kasan_zero_p4d)) {
+				prot = pte_flags(kasan_zero_pte[0]);
+				note_page(m, st, __pgprot(prot), 4);
 			} else {
 				walk_pud_level(m, st, *start,
 					       P + i * P4D_LEVEL_MULT);
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
