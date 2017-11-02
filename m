Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A80F56B0038
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 08:45:36 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v127so2901568wma.3
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 05:45:36 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m8si2657440wma.126.2017.11.02.05.45.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 05:45:35 -0700 (PDT)
Date: Thu, 2 Nov 2017 13:45:31 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: KAISER memory layout (Re: [PATCH 06/23] x86, kaiser: introduce
 user-mapped percpu areas)
In-Reply-To: <89E52C9C-DBAB-4661-8172-0F6307857870@amacapital.net>
Message-ID: <alpine.DEB.2.20.1711021343380.2090@nanos>
References: <CALCETrXLJfmTg1MsQHKCL=WL-he_5wrOqeX2OatQCCqVE003VQ@mail.gmail.com> <alpine.DEB.2.20.1711021235290.2090@nanos> <89E52C9C-DBAB-4661-8172-0F6307857870@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Josh Poimboeuf <jpoimboe@redhat.com>

On Thu, 2 Nov 2017, Andy Lutomirski wrote:
> > On Nov 2, 2017, at 12:48 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > 
> >> On Thu, 2 Nov 2017, Andy Lutomirski wrote:
> >> I think we're far enough along here that it may be time to nail down
> >> the memory layout for real.  I propose the following:
> >> 
> >> The user tables will contain the following:
> >> 
> >> - The GDT array.
> >> - The IDT.
> >> - The vsyscall page.  We can make this be _PAGE_USER.
> > 
> > I rather remove it for the kaiser case.
> > 
> >> - The TSS.
> >> - The per-cpu entry stack.  Let's make it one page with guard pages
> >> on either side.  This can replace rsp_scratch.
> >> - cpu_current_top_of_stack.  This could be in the same page as the TSS.
> >> - The entry text.
> >> - The percpu IST (aka "EXCEPTION") stacks.
> > 
> > Do you really want to put the full exception stacks into that user mapping?
> > I think we should not do that. There are two options:
> > 
> >  1) Always use the per-cpu entry stack and switch to the proper IST after
> >     the CR3 fixup
> 
> Can't -- it's microcode, not software, that does that switch.

Well, yes. The micro code does the stack switch to ISTs but software tells
it to do so. We write the IDT IIRC.

> >  2) Have separate per-cpu entry stacks for the ISTs and switch to the real
> >     ones after the CR3 fixup.
> 
> How is that simpler?

Simpler is not the question. I want to avoid mapping the whole IST stacks.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
