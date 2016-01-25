Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 37CF16B0254
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 12:35:57 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id vt7so121963972obb.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:35:57 -0800 (PST)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id li7si18383577oeb.50.2016.01.25.09.35.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 09:35:56 -0800 (PST)
Received: by mail-oi0-x22f.google.com with SMTP id p187so92052684oia.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:35:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1453742717-10326-3-git-send-email-matthew.r.wilcox@intel.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com> <1453742717-10326-3-git-send-email-matthew.r.wilcox@intel.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 25 Jan 2016 09:35:36 -0800
Message-ID: <CALCETrWQdJFBMz+O3TtVfMwAapY1tJFg3PE+-Gjp7fOWkzrAAA@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: Convert vm_insert_pfn_prot to vmf_insert_pfn_prot
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jan 25, 2016 at 9:25 AM, Matthew Wilcox
<matthew.r.wilcox@intel.com> wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
>
> Other than the name, the vmf_ version takes a pfn_t parameter, and
> returns a VM_FAULT_ code suitable for returning from a fault handler.
>
> This patch also prevents vm_insert_pfn() from returning -EBUSY.
> This is a good thing as several callers handled it incorrectly (and
> none intentionally treat -EBUSY as a different case from 0).
>
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> ---
>  arch/x86/entry/vdso/vma.c |  6 +++---
>  include/linux/mm.h        |  4 ++--
>  mm/memory.c               | 31 ++++++++++++++++++-------------
>  3 files changed, 23 insertions(+), 18 deletions(-)
>
> diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
> index 7c912fe..660bb69 100644
> --- a/arch/x86/entry/vdso/vma.c
> +++ b/arch/x86/entry/vdso/vma.c
> @@ -9,6 +9,7 @@
>  #include <linux/sched.h>
>  #include <linux/slab.h>
>  #include <linux/init.h>
> +#include <linux/pfn_t.h>
>  #include <linux/random.h>
>  #include <linux/elf.h>
>  #include <linux/cpu.h>
> @@ -131,10 +132,9 @@ static int vvar_fault(const struct vm_special_mapping *sm,
>         } else if (sym_offset == image->sym_hpet_page) {
>  #ifdef CONFIG_HPET_TIMER
>                 if (hpet_address && vclock_was_used(VCLOCK_HPET)) {
> -                       ret = vm_insert_pfn_prot(
> -                               vma,
> +                       return vmf_insert_pfn_prot(vma,
>                                 (unsigned long)vmf->virtual_address,
> -                               hpet_address >> PAGE_SHIFT,
> +                               phys_to_pfn_t(hpet_address, PFN_DEV),
>                                 pgprot_noncached(PAGE_READONLY));
>                 }

This would be even nicer if you added vmf_insert_pfn as well :)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
