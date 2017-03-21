Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F1BB56B038A
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 03:17:30 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d66so1546227wmi.2
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 00:17:30 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id k8si11641677wmg.107.2017.03.21.00.17.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 00:17:29 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id u108so21216469wrb.2
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 00:17:29 -0700 (PDT)
Date: Tue, 21 Mar 2017 08:17:25 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH tip v2] x86/mm: Correct fixmap header usage on adaptable
 MODULES_END
Message-ID: <20170321071725.GA15782@gmail.com>
References: <20170320194024.60749-1-thgarnie@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170320194024.60749-1-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@suse.de>, Hugh Dickins <hughd@google.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, richard.weiyang@gmail.com


* Thomas Garnier <thgarnie@google.com> wrote:

> This patch removes fixmap headers on non-x86 code introduced by the
> adaptable MODULE_END change. It is also removed in the 32-bit pgtable
> header. Instead, it is added  by default in the pgtable generic header
> for both architectures.
> 
> Signed-off-by: Thomas Garnier <thgarnie@google.com>
> ---
>  arch/x86/include/asm/pgtable.h    | 1 +
>  arch/x86/include/asm/pgtable_32.h | 1 -
>  arch/x86/kernel/module.c          | 1 -
>  arch/x86/mm/dump_pagetables.c     | 1 -
>  arch/x86/mm/kasan_init_64.c       | 1 -
>  mm/vmalloc.c                      | 4 ----
>  6 files changed, 1 insertion(+), 8 deletions(-)

So I already have v1 and there's no explanation about the changes from v1 to v2.

The interdiff between v1 and v2 is below, it only affects x86, presumably it's 
done to simplify the header usage slightly: instead of including fixmap.h in both 
pgtable_32/64.h it's only included in the common pgtable.h file.

That's a sensible cleanup of the original patch and I'd rather not rebase it (as 
tip:x86/mm has other changes as well), so could I've applied the delta cleanup on 
top of the existing changes, with its own changelog.

Thanks,

	Ingo

============>
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 84f6ec4d47ec..9f6809545269 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -601,6 +601,7 @@ pte_t *populate_extra_pte(unsigned long vaddr);
 #include <linux/mm_types.h>
 #include <linux/mmdebug.h>
 #include <linux/log2.h>
+#include <asm/fixmap.h>
 
 static inline int pte_none(pte_t pte)
 {
diff --git a/arch/x86/include/asm/pgtable_32.h b/arch/x86/include/asm/pgtable_32.h
index fbc73360aea0..bfab55675c16 100644
--- a/arch/x86/include/asm/pgtable_32.h
+++ b/arch/x86/include/asm/pgtable_32.h
@@ -14,7 +14,6 @@
  */
 #ifndef __ASSEMBLY__
 #include <asm/processor.h>
-#include <asm/fixmap.h>
 #include <linux/threads.h>
 #include <asm/paravirt.h>
 
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 13709cf74ab6..1a4bc71534d4 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -13,7 +13,6 @@
 #include <asm/processor.h>
 #include <linux/bitops.h>
 #include <linux/threads.h>
-#include <asm/fixmap.h>
 
 extern pud_t level3_kernel_pgt[512];
 extern pud_t level3_ident_pgt[512];

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
