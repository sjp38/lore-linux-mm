Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4896B0083
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 07:58:18 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kq14so6664927pab.25
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 04:58:17 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id z3si1222945pdo.71.2014.09.11.04.58.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 11 Sep 2014 04:58:17 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NBQ00G7CK1RT330@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 11 Sep 2014 13:01:03 +0100 (BST)
Message-id: <54118CC9.8070405@samsung.com>
Date: Thu, 11 Sep 2014 15:51:37 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [RFC/PATCH v2 02/10] x86_64: add KASan support
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
 <1410359487-31938-3-git-send-email-a.ryabinin@samsung.com>
 <5410724B.8000803@intel.com>
 <CAPAsAGzm29VWz8ZvOu+fVGn4Vbj7bQZAnB11M5ZZXRTQTchj0w@mail.gmail.com>
 <5410D486.4060200@intel.com> <9E98939B-E2C6-4530-A822-ED550FC3B9D2@zytor.com>
 <54112512.6040409@oracle.com>
In-reply-to: <54112512.6040409@oracle.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

On 09/11/2014 08:29 AM, Sasha Levin wrote:
> On 09/11/2014 12:26 AM, H. Peter Anvin wrote:
>> Except you just broke PVop kernels.
> 
> So is this why v2 refuses to boot on my KVM guest? (was digging
> into that before I send a mail out).
> 

Maybe this will help?


From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH] x86_64: kasan: fix kernel boot with CONFIG_DEBUG_VIRTUAL=y

Use __pa_nodebug instead of __pa before shadow initialized.
__pa with CONFIG_DEBUG_VIRTUAL=y may result in __asan_load
call before shadow area initialized.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/x86/kernel/head64.c    | 6 +++---
 arch/x86/mm/kasan_init_64.c | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 9d97e3a..5669a8b 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -47,7 +47,7 @@ static void __init reset_early_page_tables(void)

 	next_early_pgt = 0;

-	write_cr3(__pa(early_level4_pgt));
+	write_cr3(__pa_nodebug(early_level4_pgt));
 }

 /* Create a new PMD entry */
@@ -60,7 +60,7 @@ int __init early_make_pgtable(unsigned long address)
 	pmdval_t pmd, *pmd_p;

 	/* Invalid address or early pgt is done ?  */
-	if (physaddr >= MAXMEM || read_cr3() != __pa(early_level4_pgt))
+	if (physaddr >= MAXMEM || read_cr3() != __pa_nodebug(early_level4_pgt))
 		return -1;

 again:
@@ -160,7 +160,7 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 	reset_early_page_tables();

 	kasan_map_zero_shadow(early_level4_pgt);
-	write_cr3(__pa(early_level4_pgt));
+	write_cr3(__pa_nodebug(early_level4_pgt));

 	/* clear bss before set_intr_gate with early_idt_handler */
 	clear_bss();
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index b7c857e..6615bf1 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -35,7 +35,7 @@ void __init kasan_map_zero_shadow(pgd_t *pgd)
 	unsigned long end = KASAN_SHADOW_END;

 	for (i = pgd_index(start); start < end; i++) {
-		pgd[i] = __pgd(__pa(zero_pud) | __PAGE_KERNEL_RO);
+		pgd[i] = __pgd(__pa_nodebug(zero_pud) | __PAGE_KERNEL_RO);
 		start += PGDIR_SIZE;
 	}
 }
-- 
2.1.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
