Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A20138E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 15:27:38 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id i3so8236143pfj.4
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:27:38 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l81si2650671pfj.230.2019.01.17.12.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 12:27:37 -0800 (PST)
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A299620868
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 20:27:36 +0000 (UTC)
Received: by mail-wm1-f53.google.com with SMTP id d15so2442499wmb.3
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:27:36 -0800 (PST)
MIME-Version: 1.0
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com> <20190117003259.23141-7-rick.p.edgecombe@intel.com>
In-Reply-To: <20190117003259.23141-7-rick.p.edgecombe@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 17 Jan 2019 12:27:23 -0800
Message-ID: <CALCETrUMAsXoZogEJg7ssv0CO56vzBV2C7VotmWcwNM7iH9Wqw@mail.gmail.com>
Subject: Re: [PATCH 06/17] x86/alternative: use temporary mm for text poking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, linux-integrity <linux-integrity@vger.kernel.org>, LSM List <linux-security-module@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Kristen Carlson Accardi <kristen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, Nadav Amit <namit@vmware.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>, Masami Hiramatsu <mhiramat@kernel.org>

On Wed, Jan 16, 2019 at 4:33 PM Rick Edgecombe
<rick.p.edgecombe@intel.com> wrote:
>
> From: Nadav Amit <namit@vmware.com>
>
> text_poke() can potentially compromise the security as it sets temporary
> PTEs in the fixmap. These PTEs might be used to rewrite the kernel code
> from other cores accidentally or maliciously, if an attacker gains the
> ability to write onto kernel memory.

i think this may be sufficient, but barely.

> +       pte_clear(poking_mm, poking_addr, ptep);
> +
> +       /*
> +        * __flush_tlb_one_user() performs a redundant TLB flush when PTI is on,
> +        * as it also flushes the corresponding "user" address spaces, which
> +        * does not exist.
> +        *
> +        * Poking, however, is already very inefficient since it does not try to
> +        * batch updates, so we ignore this problem for the time being.
> +        *
> +        * Since the PTEs do not exist in other kernel address-spaces, we do
> +        * not use __flush_tlb_one_kernel(), which when PTI is on would cause
> +        * more unwarranted TLB flushes.
> +        *
> +        * There is a slight anomaly here: the PTE is a supervisor-only and
> +        * (potentially) global and we use __flush_tlb_one_user() but this
> +        * should be fine.
> +        */
> +       __flush_tlb_one_user(poking_addr);
> +       if (cross_page_boundary) {
> +               pte_clear(poking_mm, poking_addr + PAGE_SIZE, ptep + 1);
> +               __flush_tlb_one_user(poking_addr + PAGE_SIZE);
> +       }

In principle, another CPU could still have the old translation.  Your
mutex probably makes this impossible, but it makes me nervous.
Ideally you'd use flush_tlb_mm_range(), but I guess you can't do that
with IRQs off.  Hmm.  I think you should add an inc_mm_tlb_gen() here.
Arguably, if you did that, you could omit the flushes, but maybe
that's silly.

If we start getting new users of use_temporary_mm(), we should give
some serious thought to the SMP semantics.

Also, you're using PAGE_KERNEL.  Please tell me that the global bit
isn't set in there.

--Andy
