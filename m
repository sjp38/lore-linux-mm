Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 762436B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 03:35:41 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so49614538wma.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 00:35:41 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id i87si13511563wmc.101.2016.07.11.00.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 00:35:39 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id f65so52513982wmi.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 00:35:39 -0700 (PDT)
Date: Mon, 11 Jul 2016 09:35:35 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
Message-ID: <20160711073534.GA19615@gmail.com>
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124728.C1116BB1@viggo.jf.intel.com>
 <20160707144508.GZ11498@techsingularity.net>
 <577E924C.6010406@sr71.net>
 <20160708071810.GA27457@gmail.com>
 <577FD587.6050101@sr71.net>
 <20160709083715.GA29939@gmail.com>
 <CALCETrXJhVz6Za4=oidiM2Vfbb+XdggFBYiVyvOCcia+w064aQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXJhVz6Za4=oidiM2Vfbb+XdggFBYiVyvOCcia+w064aQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-arch <linux-arch@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Dave Hansen <dave@sr71.net>, Arnd Bergmann <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hughd@google.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>


* Andy Lutomirski <luto@amacapital.net> wrote:

> On Jul 9, 2016 1:37 AM, "Ingo Molnar" <mingo@kernel.org> wrote:
> >
> >
> > * Dave Hansen <dave@sr71.net> wrote:
> >
> > > On 07/08/2016 12:18 AM, Ingo Molnar wrote:
> > >
> > > > So the question is, what is user-space going to do? Do any glibc patches
> > > > exist? How are the user-space library side APIs going to look like?
> > >
> > > My goal at the moment is to get folks enabled to the point that they can start
> > > modifying apps to use pkeys without having to patch their kernels.
> > >  I don't have confidence that we can design good high-level userspace interfaces
> > > without seeing some real apps try to use the low-level ones and seeing how they
> > > struggle.
> > >
> > > I had some glibc code to do the pkey alloc/free operations, but those aren't
> > > necessary if we're doing it in the kernel.  Other than getting the syscall
> > > wrappers in place, I don't have any immediate plans to do anything in glibc.
> > >
> > > Was there something you were expecting to see?
> >
> > Yeah, so (as you probably guessed!) I'm starting to have second thoughts about the
> > complexity of the alloc/free/set/get interface I suggested, and Mel's review
> > certainly strengthened that feeling.
> >
> > I have two worries:
> >
> > 1)
> >
> > A technical worry I have is that the 'pkey allocation interface' does not seem to
> > be taking the per thread property of pkeys into account - while that property
> > would be useful for apps. That is a limitation that seems unjustified.
> >
> > The reason for this is that we are storing the key allocation bitmap in struct_mm,
> > in mm->context.pkey_allocation_map - while we should be storing it in task_struct
> > or thread_info.
> 
> Huh?  Doesn't this have to be per mm?  Sure, PKRU is per thread, but
> the page tables are shared.

But the keys are not shared, and they carry meaningful per thread information.

mprotect_pkey()'s effects are per MM, but the system calls related to managing the 
keys (alloc/free/get/set) are fundamentally per CPU.

Here's an example of how this could matter to applications:

 - 'writer thread' gets a RW- key into index 1 to a specific data area
 - a pool of 'reader threads' may get the same pkey index 1 R-- to read the data 
   area.

Same page tables, same index, two protections and two purposes.

With a global, per MM allocation of keys we'd have to use two indices: index 1 and 2.

Depending on how scarce the index space turns out to be making the key indices per 
thread is probably the right model.

> There are still two issues that I think we need to address, though:
> 
> 1. Signal delivery shouldn't unconditionally clear PKRU.  That's what
> the current patches do, and it's unsafe.  I'd rather set PKRU to the
> maximally locked down state on signal delivery (except for the
> PROT_EXEC key), although that might cause its own set of problems.

Right now the historic pattern for signal handlers is that they safely and 
transparently stack on top of existing FPU related resources and do a save/restore 
of them. In that sense saving+clearing+restoring the pkeys state would be the 
correct approach that follows that pattern. There are two extra considerations:

- If we think of pkeys as a temporary register that can be used to access/unaccess 
  normally unaccessible memory regions then this makes sense, in fact it's more 
  secure: signal handlers cannot accidentally stomp on an encryption key or on a
  database area, unless they intentionally gain access to them.

- If we think of pkeys as permanent memory mappings that enhance existing MM
  permissions then it would be correct to let them leak into signal handler state. 
  The globl true-PROT_EXEC key would fall into this category.

So I agree, mostly: the correct approach is to save+clear+restore the first 14 
pkey indices, and to leave alone the two 'global' indices.

> 2. When thread A allocates a pkey, how does it lock down thread B?

So see above, I think the temporary key space should be per thread, so there would 
be no inter thread interactions: each thread is responsible for its own key 
management (via per thread management data in the library that implments it).

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
