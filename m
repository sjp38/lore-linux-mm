Received: by wa-out-1112.google.com with SMTP id m33so586176wag.8
        for <linux-mm@kvack.org>; Wed, 09 Jan 2008 10:17:04 -0800 (PST)
Message-ID: <6934efce0801091017t7f9041abs62904de3722cadc@mail.gmail.com>
Date: Wed, 9 Jan 2008 10:17:04 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [rfc][patch 1/4] include: add callbacks to toggle reference counting for VM_MIXEDMAP pages
In-Reply-To: <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071214133817.GB28555@wotan.suse.de>
	 <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de>
	 <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de>
	 <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de>
	 <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com>
	 <1199891032.28689.9.camel@cotte.boeblingen.de.ibm.com>
	 <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte@de.ibm.com>
Cc: Nick Piggin <npiggin@suse.de>, carsteno@de.ibm.com, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Jan 9, 2008 7:14 AM, Carsten Otte <cotte@de.ibm.com> wrote:
> From: Carsten Otte <cotte@de.ibm.com>
>
> include: add callbacks to toggle reference counting for VM_MIXEDMAP pages
>
> This patch introduces two arch callbacks, which may optionally be implemented
> in case the architecutre does define __HAVE_ARCH_PTEP_NOREFCOUNT.
>
> The first callback, pte_set_norefcount(__pte) is called by core-vm to indicate
> that subject page table entry is going to be inserted into a VM_MIXEDMAP vma.
> default implementation:         noop
> s390 implementation:            set sw defined bit in pte
> proposed arm implementation:    noop
>
> The second callback, mixedmap_refcount_pte(__pte) is called by core-vm to
> figure out whether or not subject pte requires reference counting in the
> corresponding struct page entry. A non-zero result indicates reference counting
> is required.
> default implementation:         (1)

I think this should be:

default implementation:   convert pte_t to pfn, use pfn_valid()

Keep in mind the reason we are talking about using anything other than
pfn_valid() in vm_normal_page() is because s390 has a non-standard
pfn_valid() implementation.  It's s390 that's broken, not the rest of
the world.  So lets not break everything else to fix s390:)  Or am I
missing something?

> s390 implementation:            query sw defined bit in pte
> proposed arm implementation:    convert pte_t to pfn, use pfn_valid()

proposed arm implementation: default

> Signed-off-by: Carsten Otte <cotte@de.ibm.com>
> ---
> Index: linux-2.6/include/asm-generic/pgtable.h
> ===================================================================
> --- linux-2.6.orig/include/asm-generic/pgtable.h
> +++ linux-2.6/include/asm-generic/pgtable.h
> @@ -99,6 +99,11 @@ static inline void ptep_set_wrprotect(st
>  }
>  #endif
>
> +#ifndef __HAVE_ARCH_PTEP_NOREFCOUNT
> +#define pte_set_norefcount(__pte)      (__pte)
> +#define mixedmap_refcount_pte(__pte)   (1)

+#define mixedmap_refcount_pte(__pte)   pfn_valid(pte_pfn(__pte))

Should we rename "mixedmap_refcount_pte" to "mixedmap_normal_pte" or
something else more neutral?  To me "mixedmap_refcount_pte" sounds
like it's altering the pte.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
