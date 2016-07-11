Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id B41DC6B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 00:26:01 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id m62so218475914ywd.1
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 21:26:01 -0700 (PDT)
Received: from mail-vk0-x22c.google.com (mail-vk0-x22c.google.com. [2607:f8b0:400c:c05::22c])
        by mx.google.com with ESMTPS id 18si221333uad.62.2016.07.10.21.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jul 2016 21:26:00 -0700 (PDT)
Received: by mail-vk0-x22c.google.com with SMTP id b192so123049093vke.0
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 21:26:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160709083715.GA29939@gmail.com>
References: <20160707124719.3F04C882@viggo.jf.intel.com> <20160707124728.C1116BB1@viggo.jf.intel.com>
 <20160707144508.GZ11498@techsingularity.net> <577E924C.6010406@sr71.net>
 <20160708071810.GA27457@gmail.com> <577FD587.6050101@sr71.net> <20160709083715.GA29939@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sun, 10 Jul 2016 21:25:40 -0700
Message-ID: <CALCETrXJhVz6Za4=oidiM2Vfbb+XdggFBYiVyvOCcia+w064aQ@mail.gmail.com>
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-arch <linux-arch@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Dave Hansen <dave@sr71.net>, Arnd Bergmann <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hughd@google.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>

On Jul 9, 2016 1:37 AM, "Ingo Molnar" <mingo@kernel.org> wrote:
>
>
> * Dave Hansen <dave@sr71.net> wrote:
>
> > On 07/08/2016 12:18 AM, Ingo Molnar wrote:
> >
> > > So the question is, what is user-space going to do? Do any glibc patches
> > > exist? How are the user-space library side APIs going to look like?
> >
> > My goal at the moment is to get folks enabled to the point that they can start
> > modifying apps to use pkeys without having to patch their kernels.
> >  I don't have confidence that we can design good high-level userspace interfaces
> > without seeing some real apps try to use the low-level ones and seeing how they
> > struggle.
> >
> > I had some glibc code to do the pkey alloc/free operations, but those aren't
> > necessary if we're doing it in the kernel.  Other than getting the syscall
> > wrappers in place, I don't have any immediate plans to do anything in glibc.
> >
> > Was there something you were expecting to see?
>
> Yeah, so (as you probably guessed!) I'm starting to have second thoughts about the
> complexity of the alloc/free/set/get interface I suggested, and Mel's review
> certainly strengthened that feeling.
>
> I have two worries:
>
> 1)
>
> A technical worry I have is that the 'pkey allocation interface' does not seem to
> be taking the per thread property of pkeys into account - while that property
> would be useful for apps. That is a limitation that seems unjustified.
>
> The reason for this is that we are storing the key allocation bitmap in struct_mm,
> in mm->context.pkey_allocation_map - while we should be storing it in task_struct
> or thread_info.

Huh?  Doesn't this have to be per mm?  Sure, PKRU is per thread, but
the page tables are shared.

> 2)
>
> My main worry is that it appears at this stage that we are still pretty far away
> from completely shadowing the hardware pkey state in the kernel - and without that
> we cannot really force user-space to use the 'proper' APIs. They can just use the
> raw instructions, condition them on a CPUID and be done with it: everything can be
> organized in user-space.
>

My vote would be to keep the allocation mechanism but get rid of pkey_set.

Also, I think the debug poisoning feature is overcomplicated.  Let's
just forbid mprotect_key with an unallocated key.

There are still two issues that I think we need to address, though:

1. Signal delivery shouldn't unconditionally clear PKRU.  That's what
the current patches do, and it's unsafe.  I'd rather set PKRU to the
maximally locked down state on signal delivery (except for the
PROT_EXEC key), although that might cause its own set of problems.

2. When thread A allocates a pkey, how does it lock down thread B?

#2 could be addressed by using fully-locked-down as the initial state
post-exec() and copying the state on clone().  Dave, are there any
cases in practice where one thread would allocate a pkey and want
other threads to immediately have access to the memory with that key?

I find myself wondering whether we should stop using XSAVE for PKRU
sooner rather than later.  If we do anything like the above, we
completely lose the init optimization, and the code would be a good
deal simpler if we switched PKRU directly in switch_to and could
therefore treat it like a normal register everywhere else.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
