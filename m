Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E65656B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 17:47:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 4so1881948wrt.8
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:47:59 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id a80si566830wma.35.2017.11.01.14.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 14:47:58 -0700 (PDT)
Date: Wed, 1 Nov 2017 22:47:54 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 06/23] x86, kaiser: introduce user-mapped percpu areas
In-Reply-To: <20171031223158.A60B4068@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.20.1711012231250.1942@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223158.A60B4068@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On Tue, 31 Oct 2017, Dave Hansen wrote:

> 
> These patches are based on work from a team at Graz University of
> Technology posted here: https://github.com/IAIK/KAISER
> 
> The KAISER approach keeps two copies of the page tables: one for running
> in the kernel and one for running userspace.  But, there are a few
> structures that are needed for switching in and out of the kernel and
> a good subset of *those* are per-cpu data.
> 
> This patch creates a new kind of per-cpu data that is mapped and can be
> used no matter which copy of the page tables we are using.

Please split out the percpu-defs.h change into a seperate patch.
 
> -DECLARE_PER_CPU_PAGE_ALIGNED(struct gdt_page, gdt_page);
> +DECLARE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(struct gdt_page, gdt_page);

Ok.

>  /* Provide the original GDT */
>  static inline struct desc_struct *get_cpu_gdt_rw(unsigned int cpu)
> diff -puN arch/x86/include/asm/hw_irq.h~kaiser-prep-user-mapped-percpu arch/x86/include/asm/hw_irq.h
> --- a/arch/x86/include/asm/hw_irq.h~kaiser-prep-user-mapped-percpu	2017-10-31 15:03:51.048146366 -0700
> +++ b/arch/x86/include/asm/hw_irq.h	2017-10-31 15:03:51.066147217 -0700
> @@ -160,7 +160,7 @@ extern char irq_entries_start[];
>  #define VECTOR_RETRIGGERED	((void *)~0UL)
>  
>  typedef struct irq_desc* vector_irq_t[NR_VECTORS];
> -DECLARE_PER_CPU(vector_irq_t, vector_irq);
> +DECLARE_PER_CPU_USER_MAPPED(vector_irq_t, vector_irq);

Why? The vector_irq array has nothing to do with user space. It's a
software handled storage which is used in the irq dispatcher way after the
exception entry happened.

I think you confused that with the IDT, which is missing here.

> -DECLARE_PER_CPU_SHARED_ALIGNED(struct tss_struct, cpu_tss);
> +DECLARE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(struct tss_struct, cpu_tss);

Ok.

> -DEFINE_PER_CPU_PAGE_ALIGNED(struct gdt_page, gdt_page) = { .gdt = {
> +DEFINE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(struct gdt_page, gdt_page) = { .gdt = {

Ok.

> -static DEFINE_PER_CPU_PAGE_ALIGNED(char, exception_stacks
> +DEFINE_PER_CPU_PAGE_ALIGNED_USER_MAPPED(char, exception_stacks
>  	[(N_EXCEPTION_STACKS - 1) * EXCEPTION_STKSZ + DEBUG_STKSZ]);

Hmm. I don't think that's a good idea. We discussed that in Prague with
Andy and the Peters and came to the conclusion that we want a stub stack in
the user mapping and switch to the kernel stacks in software after
switching back to the kernel mappings. Andys 'Pile o' entry...' series
paves the way to that already. So can we please put kaiser on top of those
and do it proper right away?

> -DEFINE_PER_CPU(vector_irq_t, vector_irq) = {
> +DEFINE_PER_CPU_USER_MAPPED(vector_irq_t, vector_irq) = {
>  	[0 ... NR_VECTORS - 1] = VECTOR_UNUSED,
>  };

See above.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
