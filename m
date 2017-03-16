Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 825226B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 04:10:19 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l37so7091777wrc.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 01:10:19 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id 88si5631608wrb.315.2017.03.16.01.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 01:10:18 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id u132so8298663wmg.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 01:10:18 -0700 (PDT)
Date: Thu, 16 Mar 2017 09:10:13 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v7 1/3] x86/mm: Adapt MODULES_END based on Fixmap section
 size
Message-ID: <20170316081013.GB7815@gmail.com>
References: <20170314170508.100882-1-thgarnie@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170314170508.100882-1-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Jonathan Corbet <corbet@lwn.net>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Kees Cook <keescook@chromium.org>, Juergen Gross <jgross@suse.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, Andy Lutomirski <luto@amacapital.net>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Jiri Kosina <jikos@kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Rusty Russell <rusty@rustcorp.com.au>, Paolo Bonzini <pbonzini@redhat.com>, Borislav Petkov <bp@suse.de>, Christian Borntraeger <borntraeger@de.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Stanislaw Gruszka <sgruszka@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Joerg Roedel <joro@8bytes.org>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, lguest@lists.ozlabs.org, kvm@vger.kernel.org, kernel-hardening@lists.openwall.com


* Thomas Garnier <thgarnie@google.com> wrote:

> This patch aligns MODULES_END to the beginning of the Fixmap section.
> It optimizes the space available for both sections. The address is
> pre-computed based on the number of pages required by the Fixmap
> section.
> 
> It will allow GDT remapping in the Fixmap section. The current
> MODULES_END static address does not provide enough space for the kernel
> to support a large number of processors.
> 
> Signed-off-by: Thomas Garnier <thgarnie@google.com>
> ---
> Based on next-20170308
> ---
>  Documentation/x86/x86_64/mm.txt         | 5 ++++-
>  arch/x86/include/asm/pgtable_64_types.h | 3 ++-
>  arch/x86/kernel/module.c                | 1 +
>  arch/x86/mm/dump_pagetables.c           | 1 +
>  arch/x86/mm/kasan_init_64.c             | 1 +
>  mm/vmalloc.c                            | 1 +

> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -35,6 +35,7 @@
>  #include <linux/uaccess.h>
>  #include <asm/tlbflush.h>
>  #include <asm/shmparam.h>
> +#include <asm/fixmap.h>
>  
>  #include "internal.h"

Note that asm/fixmap.h is an x86-ism that isn't present in many other 
architectures, so this hunk will break the build.

To make progress with these patches I've fixed it up with an ugly #ifdef 
CONFIG_X86, but it needs a real solution instead before this can be pushed 
upstream.

Thanks,

	Ingo

=====================>
 mm/vmalloc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index dabea6a29fad..b7d2a23349f4 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -35,7 +35,10 @@
 #include <linux/uaccess.h>
 #include <asm/tlbflush.h>
 #include <asm/shmparam.h>
-#include <asm/fixmap.h>
+
+#ifdef CONFIG_X86
+# include <asm/fixmap.h>
+#endif
 
 #include "internal.h"
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
