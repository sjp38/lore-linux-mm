Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id D66E76B00DE
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 13:46:11 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id gq1so7672371obb.9
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 10:46:11 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ml3si3246563oeb.26.2014.11.24.10.46.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 10:46:10 -0800 (PST)
Message-ID: <54737CD7.7080908@oracle.com>
Date: Mon, 24 Nov 2014 13:45:43 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 03/12] x86_64: add KASan support
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1416852146-9781-1-git-send-email-a.ryabinin@samsung.com> <1416852146-9781-4-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1416852146-9781-4-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

On 11/24/2014 01:02 PM, Andrey Ryabinin wrote:
> +static int kasan_die_handler(struct notifier_block *self,
> +			     unsigned long val,
> +			     void *data)
> +{
> +	if (val == DIE_GPF) {
> +		pr_emerg("CONFIG_KASAN_INLINE enabled\n");
> +		pr_emerg("GPF could be caused by NULL-ptr deref or user memory access\n");
> +	}
> +	return NOTIFY_OK;
> +}
> +
> +static struct notifier_block kasan_die_notifier = {
> +	.notifier_call = kasan_die_handler,
> +};

This part fails to compile:

  CC      arch/x86/mm/kasan_init_64.o
arch/x86/mm/kasan_init_64.c: In function ?kasan_die_handler?:
arch/x86/mm/kasan_init_64.c:72:13: error: ?DIE_GPF? undeclared (first use in this function)
  if (val == DIE_GPF) {
             ^
arch/x86/mm/kasan_init_64.c:72:13: note: each undeclared identifier is reported only once for each function it appears in
arch/x86/mm/kasan_init_64.c: In function ?kasan_init?:
arch/x86/mm/kasan_init_64.c:89:2: error: implicit declaration of function ?register_die_notifier? [-Werror=implicit-function-declaration]
  register_die_notifier(&kasan_die_notifier);
  ^
cc1: some warnings being treated as errors
make[1]: *** [arch/x86/mm/kasan_init_64.o] Error 1


Simple fix:

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 70041fd..c8f7f3e 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -5,6 +5,7 @@
 #include <linux/vmalloc.h>

 #include <asm/tlbflush.h>
+#include <linux/kdebug.h>

 extern pgd_t early_level4_pgt[PTRS_PER_PGD];
 extern struct range pfn_mapped[E820_X_MAX];


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
