Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3496B0530
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 12:43:36 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j186so4750800pge.12
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 09:43:36 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10115.outbound.protection.outlook.com. [40.107.1.115])
        by mx.google.com with ESMTPS id l74si270459pfb.386.2017.07.11.09.43.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 11 Jul 2017 09:43:35 -0700 (PDT)
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
References: <75acbed7-6a08-692f-61b5-2b44f66ec0d8@virtuozzo.com>
 <bc95be68-8c68-2a45-c530-acbc6c90a231@virtuozzo.com>
 <20170710123346.7y3jnftqgpingim3@node.shutemov.name>
 <CACT4Y+aRbC7_wvDv8ahH_JwY6P6SFoLg-kdwWHJx5j1stX_P_w@mail.gmail.com>
 <20170710141713.7aox3edx6o7lrrie@node.shutemov.name>
 <03A6D7ED-300C-4431-9EB5-67C7A3EA4A2E@amacapital.net>
 <20170710184704.realchrhzpblqqlk@node.shutemov.name>
 <CALCETrVJQ_u-agPm8fFHAW1UJY=VLowdbM+gXyjFCb586r0V3g@mail.gmail.com>
 <20170710212403.7ycczkhhki3vrgac@node.shutemov.name>
 <CALCETrW6pWzpdf1MVx_ytaYYuVGBsF7R+JowEsKqd3i=vCwJ_w@mail.gmail.com>
 <20170711103548.mkv5w7dd5gpdenne@node.shutemov.name>
 <CALCETrVpNUq3-zEu1Q1O77N8r4kv4kFdefXp7XEs3Hpf-JPAjg@mail.gmail.com>
 <d3caf8c4-4575-c1b5-6b0f-95527efaf2f9@virtuozzo.com>
Message-ID: <f11d9e07-6b31-1add-7677-6a29d15ab608@virtuozzo.com>
Date: Tue, 11 Jul 2017 19:45:48 +0300
MIME-Version: 1.0
In-Reply-To: <d3caf8c4-4575-c1b5-6b0f-95527efaf2f9@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>

On 07/11/2017 06:15 PM, Andrey Ryabinin wrote:
> 
> I reproduced this, and this is kasan bug:
> 
>    a??0xffffffff84864897 <x86_early_init_platform_quirks+5>   mov    $0xffffffff83f1d0b8,%rdi 
>    a??0xffffffff8486489e <x86_early_init_platform_quirks+12>  movabs $0xdffffc0000000000,%rax 
>    a??0xffffffff848648a8 <x86_early_init_platform_quirks+22>  push   %rbp
>    a??0xffffffff848648a9 <x86_early_init_platform_quirks+23>  mov    %rdi,%rdx  
>    a??0xffffffff848648ac <x86_early_init_platform_quirks+26>  shr    $0x3,%rdx
>    a??0xffffffff848648b0 <x86_early_init_platform_quirks+30>  mov    %rsp,%rbp
>   >a??0xffffffff848648b3 <x86_early_init_platform_quirks+33>  mov    (%rdx,%rax,1),%al
> 
> we crash on the last move which is a read from shadow


Ughh, I forgot about phys_base.
Plus, I added KASAN_SANITIZE_paravirt.o :=n because with PARAVIRTY=y set_pgd() calls native_set_pgd()
from paravirt.c translation unit.



---
 arch/x86/kernel/Makefile    | 1 +
 arch/x86/mm/kasan_init_64.c | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 4b994232cb57..5a1f18b87fb2 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -24,6 +24,7 @@ KASAN_SANITIZE_head$(BITS).o				:= n
 KASAN_SANITIZE_dumpstack.o				:= n
 KASAN_SANITIZE_dumpstack_$(BITS).o			:= n
 KASAN_SANITIZE_stacktrace.o := n
+KASAN_SANITIZE_paravirt.o				:= n
 
 OBJECT_FILES_NON_STANDARD_head_$(BITS).o		:= y
 OBJECT_FILES_NON_STANDARD_relocate_kernel_$(BITS).o	:= y
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index d79a7ea83d05..d5743fd37df9 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -72,7 +72,8 @@ static void __init kasan_early_p4d_populate(pgd_t *pgd,
 	 * TODO: we need helpers for this shit
 	 */
 	if (CONFIG_PGTABLE_LEVELS == 5)
-		p4d = ((p4d_t*)((__pa_nodebug(pgd->pgd) & PTE_PFN_MASK) + __START_KERNEL_map))
+		p4d = ((p4d_t*)((__pa_nodebug(pgd->pgd) & PTE_PFN_MASK)
+					+ __START_KERNEL_map - phys_base))
 			+ p4d_index(addr);
 	else
 		p4d = (p4d_t*)pgd;
-- 
2.13.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
