Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 470EA6B000A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 17:56:38 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a124so1574407qkb.19
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 14:56:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 16sor11001468qtp.35.2018.04.17.14.56.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Apr 2018 14:56:37 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mceier+kernel@gmail.com
In-Reply-To: <20180417211304.7B3F1FDB@viggo.jf.intel.com>
References: <20180417211302.421F6442@viggo.jf.intel.com> <20180417211304.7B3F1FDB@viggo.jf.intel.com>
From: Mariusz Ceier <mceier+kernel@gmail.com>
Date: Tue, 17 Apr 2018 23:56:36 +0200
Message-ID: <CAJTyqKMLh4QoNYUF1BZ5D51L8ZEt_fxqNRWYBON+27icavY8tQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] x86, pti: fix boot warning from Global-bit setting
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Aaro Koskinen <aaro.koskinen@nokia.com>, aarcange@redhat.com, luto@kernel.org, arjan@linux.intel.com, Borislav Petkov <bp@alien8.de>, dan.j.williams@intel.com, dwmw2@infradead.org, gregkh@linuxfoundation.org, hughd@google.com, jpoimboe@redhat.com, jgross@suse.com, keescook@google.com, Linus Torvalds <torvalds@linux-foundation.org>, namit@vmware.com, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>

On 17 April 2018 at 23:13, Dave Hansen <dave.hansen@linux.intel.com> wrote:
>
> These are _very_ lightly tested.  I'm throwing them out there for
> folks are looking for a fix.
>
> ---
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> pageattr.c is not friendly when it encounters empty (zero) PTEs.  The
> kernel linear map is exempt from these checks, but kernel text is not.
> This patch adds the code to also exempt kernel text from these checks.
> The proximate cause of these warnings was most likely an __init area
> that spanned a 2MB page boundary that resulted in a "zero" PMD.
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Fixes: 39114b7a7 (x86/pti: Never implicitly clear _PAGE_GLOBAL for kernel image)
> Reported-by: Mariusz Ceier <mceier@gmail.com>
> Reported-by: Aaro Koskinen <aaro.koskinen@nokia.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Arjan van de Ven <arjan@linux.intel.com>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: David Woodhouse <dwmw2@infradead.org>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Josh Poimboeuf <jpoimboe@redhat.com>
> Cc: Juergen Gross <jgross@suse.com>
> Cc: Kees Cook <keescook@google.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Nadav Amit <namit@vmware.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: linux-mm@kvack.org
> ---
>
>  b/arch/x86/mm/pageattr.c |   17 +++++++++++++++--
>  1 file changed, 15 insertions(+), 2 deletions(-)
>
> diff -puN arch/x86/mm/pageattr.c~pti-glb-warning-inpageattr arch/x86/mm/pageattr.c
> --- a/arch/x86/mm/pageattr.c~pti-glb-warning-inpageattr 2018-04-17 14:10:22.695395554 -0700
> +++ b/arch/x86/mm/pageattr.c    2018-04-17 14:10:22.721395554 -0700
> @@ -1151,6 +1151,16 @@ static int populate_pgd(struct cpa_data
>         return 0;
>  }
>
> +bool __cpa_pfn_in_highmap(unsigned long pfn)
> +{
> +       /*
> +        * Kernel text has an alias mapping at a high address, known
> +        * here as "highmap".
> +        */
> +       return within_inclusive(pfn, highmap_start_pfn(),
> +                       highmap_end_pfn());
> +}
> +
>  static int __cpa_process_fault(struct cpa_data *cpa, unsigned long vaddr,
>                                int primary)
>  {
> @@ -1183,6 +1193,10 @@ static int __cpa_process_fault(struct cp
>                 cpa->numpages = 1;
>                 cpa->pfn = __pa(vaddr) >> PAGE_SHIFT;
>                 return 0;
> +
> +       } else if (__cpa_pfn_in_highmap(cpa->pfn)) {
> +               /* Faults in the highmap are OK, so do not warn: */
> +               return -EFAULT;
>         } else {
>                 WARN(1, KERN_WARNING "CPA: called for zero pte. "
>                         "vaddr = %lx cpa->vaddr = %lx\n", vaddr,
> @@ -1335,8 +1349,7 @@ static int cpa_process_alias(struct cpa_
>          * to touch the high mapped kernel as well:
>          */
>         if (!within(vaddr, (unsigned long)_text, _brk_end) &&
> -           within_inclusive(cpa->pfn, highmap_start_pfn(),
> -                            highmap_end_pfn())) {
> +           __cpa_pfn_in_highmap(cpa->pfn)) {
>                 unsigned long temp_cpa_vaddr = (cpa->pfn << PAGE_SHIFT) +
>                                                __START_KERNEL_map - phys_base;
>                 alias_cpa = *cpa;
> _


I confirm that these 2 patches fix the BUG for me in kernel 4.17.0-rc1.

Thanks
