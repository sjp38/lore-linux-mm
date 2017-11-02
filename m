Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E78CF6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 12:03:42 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u97so27872wrc.3
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 09:03:42 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 128si3111838wmr.119.2017.11.02.09.03.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 09:03:41 -0700 (PDT)
Date: Thu, 2 Nov 2017 17:03:38 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: KAISER memory layout (Re: [PATCH 06/23] x86, kaiser: introduce
 user-mapped percpu areas)
In-Reply-To: <65E6D547-2871-4D93-9E10-24C31DB10269@amacapital.net>
Message-ID: <alpine.DEB.2.20.1711021653240.2090@nanos>
References: <CALCETrXLJfmTg1MsQHKCL=WL-he_5wrOqeX2OatQCCqVE003VQ@mail.gmail.com> <alpine.DEB.2.20.1711021235290.2090@nanos> <89E52C9C-DBAB-4661-8172-0F6307857870@amacapital.net> <alpine.DEB.2.20.1711021343380.2090@nanos>
 <65E6D547-2871-4D93-9E10-24C31DB10269@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Josh Poimboeuf <jpoimboe@redhat.com>

On Thu, 2 Nov 2017, Andy Lutomirski wrote:
> > On Nov 2, 2017, at 1:45 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > Simpler is not the question. I want to avoid mapping the whole IST stacks.
> > 
> 
> OK, let's see.  We can have the IDT be different in the user tables and
> the kernel tables.  The user IDT could have IST-less entry stubs that do
> their own CR3 switch and then bounce to the IST stack.  I don't see why
> this wouldn't work aside from requiring a substantially larger entry
> stack, but I'm also not convinced it's worth the added complexity.  The
> NMI code would certainly need some careful thought to convince ourselves
> that it would still be correct.  #DF would be, um, interesting because of
> the silly ESPFIX64 thing.

> My inclination would be to deal with this later.  For the first upstream
> version, we map the IST stacks.  Later on, we have a separate user IDT
> that does whatever it needs to do.
>
> The argument to the contrary would be that Dave's CR3 code *and* my entry
> stack crap gets simpler if all the CR3 switches happen in special stubs.
>
> The argument against *that* is that this erase_kstack crap might also
> benefit from the magic stack switch.  OTOH that's the *exit* stack, which
> is totally independent.

My initial thought was: Use always IST stub stacks for entry and exit.

So the entry/exit stubs deal with the CR3 stuff and also with the extra
magic for espfix and nested NMIs, etc. Once that is done, you just flip
over to the relevant kernel internal stack and switch back to the user
visible one on return. Haven't thought that through completely, but in my
naive view it made stuff simpler.

> FWIW, I want to get rid of the #DB and #BP stacks entirely, but that does
> not deserve to block this series, I think.

Agreed.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
