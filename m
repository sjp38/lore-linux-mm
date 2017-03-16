Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A89CB831CC
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:34:56 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id r141so52206774ita.6
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:34:56 -0700 (PDT)
Received: from mail-it0-x232.google.com (mail-it0-x232.google.com. [2607:f8b0:4001:c0b::232])
        by mx.google.com with ESMTPS id n71si3812077itg.29.2017.03.16.08.34.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:34:55 -0700 (PDT)
Received: by mail-it0-x232.google.com with SMTP id w124so74843126itb.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:34:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170316081013.GB7815@gmail.com>
References: <20170314170508.100882-1-thgarnie@google.com> <20170316081013.GB7815@gmail.com>
From: Thomas Garnier <thgarnie@google.com>
Date: Thu, 16 Mar 2017 08:33:32 -0700
Message-ID: <CAJcbSZEB09inR2KLF_puOnmAK7QUv-zJHcguiF0qucUYTtg1Pw@mail.gmail.com>
Subject: Re: [PATCH v7 1/3] x86/mm: Adapt MODULES_END based on Fixmap section size
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Jonathan Corbet <corbet@lwn.net>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Kees Cook <keescook@chromium.org>, Juergen Gross <jgross@suse.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, Andy Lutomirski <luto@amacapital.net>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Jiri Kosina <jikos@kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Rusty Russell <rusty@rustcorp.com.au>, Paolo Bonzini <pbonzini@redhat.com>, Borislav Petkov <bp@suse.de>, Christian Borntraeger <borntraeger@de.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Stanislaw Gruszka <sgruszka@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Joerg Roedel <joro@8bytes.org>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, Linux PM list <linux-pm@vger.kernel.org>, linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, lguest@lists.ozlabs.org, kvm list <kvm@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Thu, Mar 16, 2017 at 1:10 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> Note that asm/fixmap.h is an x86-ism that isn't present in many other
> architectures, so this hunk will break the build.
>
> To make progress with these patches I've fixed it up with an ugly #ifdef
> CONFIG_X86, but it needs a real solution instead before this can be pushed
> upstream.

I also saw an error on x86 tip on special configuration. I found this
new patch below to be a good solution to both.

Let me know what you think.

=====

This patch aligns MODULES_END to the beginning of the Fixmap section.
It optimizes the space available for both sections. The address is
pre-computed based on the number of pages required by the Fixmap
section.

It will allow GDT remapping in the Fixmap section. The current
MODULES_END static address does not provide enough space for the kernel
to support a large number of processors.

Signed-off-by: Thomas Garnier <thgarnie@google.com>
---
Based on next-20170308
---
 Documentation/x86/x86_64/mm.txt         | 5 ++++-
 arch/x86/include/asm/pgtable_64.h       | 1 +
 arch/x86/include/asm/pgtable_64_types.h | 3 ++-
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/Documentation/x86/x86_64/mm.txt b/Documentation/x86/x86_64/mm.txt
index 5724092db811..ee3f9c30957c 100644
--- a/Documentation/x86/x86_64/mm.txt
+++ b/Documentation/x86/x86_64/mm.txt
@@ -19,7 +19,7 @@ ffffff0000000000 - ffffff7fffffffff (=39 bits) %esp
fixup stacks
 ffffffef00000000 - fffffffeffffffff (=64 GB) EFI region mapping space
 ... unused hole ...
 ffffffff80000000 - ffffffff9fffffff (=512 MB)  kernel text mapping, from phys 0
-ffffffffa0000000 - ffffffffff5fffff (=1526 MB) module mapping space
+ffffffffa0000000 - ffffffffff5fffff (=1526 MB) module mapping space (variable)
 ffffffffff600000 - ffffffffffdfffff (=8 MB) vsyscalls
 ffffffffffe00000 - ffffffffffffffff (=2 MB) unused hole

@@ -39,6 +39,9 @@ memory window (this size is arbitrary, it can be
raised later if needed).
 The mappings are not part of any other kernel PGD and are only available
 during EFI runtime calls.

+The module mapping space size changes based on the CONFIG requirements for the
+following fixmap section.
+
 Note that if CONFIG_RANDOMIZE_MEMORY is enabled, the direct mapping of all
 physical memory, vmalloc/ioremap space and virtual memory map are randomized.
 Their order is preserved but their base will be offset early at boot time.
diff --git a/arch/x86/include/asm/pgtable_64.h
b/arch/x86/include/asm/pgtable_64.h
index 73c7ccc38912..67608d4abc2c 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -13,6 +13,7 @@
 #include <asm/processor.h>
 #include <linux/bitops.h>
 #include <linux/threads.h>
+#include <asm/fixmap.h>

 extern pud_t level3_kernel_pgt[512];
 extern pud_t level3_ident_pgt[512];
diff --git a/arch/x86/include/asm/pgtable_64_types.h
b/arch/x86/include/asm/pgtable_64_types.h
index 3a264200c62f..bb05e21cf3c7 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -67,7 +67,8 @@ typedef struct { pteval_t pte; } pte_t;
 #endif /* CONFIG_RANDOMIZE_MEMORY */
 #define VMALLOC_END (VMALLOC_START + _AC((VMALLOC_SIZE_TB << 40) - 1, UL))
 #define MODULES_VADDR    (__START_KERNEL_map + KERNEL_IMAGE_SIZE)
-#define MODULES_END      _AC(0xffffffffff000000, UL)
+/* The module sections ends with the start of the fixmap */
+#define MODULES_END   __fix_to_virt(__end_of_fixed_addresses + 1)
 #define MODULES_LEN   (MODULES_END - MODULES_VADDR)
 #define ESPFIX_PGD_ENTRY _AC(-2, UL)
 #define ESPFIX_BASE_ADDR (ESPFIX_PGD_ENTRY << PGDIR_SHIFT)
-- 
2.12.0.367.g23dc2f6d3c-goog

-- 
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
