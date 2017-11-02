Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7346B0261
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 07:48:24 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z52so2889656wrc.5
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 04:48:24 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v13si2726791wmc.146.2017.11.02.04.48.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 04:48:22 -0700 (PDT)
Date: Thu, 2 Nov 2017 12:48:20 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: KAISER memory layout (Re: [PATCH 06/23] x86, kaiser: introduce
 user-mapped percpu areas)
In-Reply-To: <CALCETrXLJfmTg1MsQHKCL=WL-he_5wrOqeX2OatQCCqVE003VQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1711021235290.2090@nanos>
References: <CALCETrXLJfmTg1MsQHKCL=WL-he_5wrOqeX2OatQCCqVE003VQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Josh Poimboeuf <jpoimboe@redhat.com>

On Thu, 2 Nov 2017, Andy Lutomirski wrote:
> I think we're far enough along here that it may be time to nail down
> the memory layout for real.  I propose the following:
> 
> The user tables will contain the following:
> 
>  - The GDT array.
>  - The IDT.
>  - The vsyscall page.  We can make this be _PAGE_USER.

I rather remove it for the kaiser case.

>  - The TSS.
>  - The per-cpu entry stack.  Let's make it one page with guard pages
> on either side.  This can replace rsp_scratch.
>  - cpu_current_top_of_stack.  This could be in the same page as the TSS.
>  - The entry text.
>  - The percpu IST (aka "EXCEPTION") stacks.

Do you really want to put the full exception stacks into that user mapping?
I think we should not do that. There are two options:

  1) Always use the per-cpu entry stack and switch to the proper IST after
     the CR3 fixup

  2) Have separate per-cpu entry stacks for the ISTs and switch to the real
     ones after the CR3 fixup.

> We can either try to move all of the above into the fixmap or we can
> have the user tables be sparse a la Dave's current approach.  If we do
> it the latter way, I think we'll want to add a mechanism to have holes
> in the percpu space to give the entry stack a guard page.
> 
> I would *much* prefer moving everything into the fixmap, but that's a
> wee bit awkward because we can't address per-cpu data in the fixmap
> using %gs, which makes the SYSCALL code awkward.  But we could alias
> the SYSCALL entry text itself per-cpu into the fixmap, which lets us
> use %rip-relative addressing, which is quite nice.
>
> So I guess my preference is to actually try the fixmap approach.  We
> give the TSS the same aliasing treatment we gave the GDT, and I can
> try to make the entry trampoline work through the fixmap and thus not
> need %gs-based addressing until CR3 gets updated.  (This actually
> saves several cycles of latency.)

Makes a lot of sense.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
