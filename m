Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 588876B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 10:50:49 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id r68so259393290qka.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 07:50:49 -0700 (PDT)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id e61si1103219uae.209.2016.07.11.07.50.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 07:50:48 -0700 (PDT)
Received: by mail-vk0-x230.google.com with SMTP id x130so14820162vkc.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 07:50:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160711073534.GA19615@gmail.com>
References: <20160707124719.3F04C882@viggo.jf.intel.com> <20160707124728.C1116BB1@viggo.jf.intel.com>
 <20160707144508.GZ11498@techsingularity.net> <577E924C.6010406@sr71.net>
 <20160708071810.GA27457@gmail.com> <577FD587.6050101@sr71.net>
 <20160709083715.GA29939@gmail.com> <CALCETrXJhVz6Za4=oidiM2Vfbb+XdggFBYiVyvOCcia+w064aQ@mail.gmail.com>
 <20160711073534.GA19615@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 11 Jul 2016 07:50:28 -0700
Message-ID: <CALCETrU2DcEdb5RoYqDtfSP+bwTULsBP8VL_qK3wwibyBL8SYg@mail.gmail.com>
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-arch <linux-arch@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux API <linux-api@vger.kernel.org>, Dave Hansen <dave@sr71.net>, Arnd Bergmann <arnd@arndb.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hughd@google.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon, Jul 11, 2016 at 12:35 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Andy Lutomirski <luto@amacapital.net> wrote:
>
>> On Jul 9, 2016 1:37 AM, "Ingo Molnar" <mingo@kernel.org> wrote:
>> >
>> >
>> > * Dave Hansen <dave@sr71.net> wrote:
>> >
>> > > On 07/08/2016 12:18 AM, Ingo Molnar wrote:
>> > >
>> > > > So the question is, what is user-space going to do? Do any glibc patches
>> > > > exist? How are the user-space library side APIs going to look like?
>> > >
>> > > My goal at the moment is to get folks enabled to the point that they can start
>> > > modifying apps to use pkeys without having to patch their kernels.
>> > >  I don't have confidence that we can design good high-level userspace interfaces
>> > > without seeing some real apps try to use the low-level ones and seeing how they
>> > > struggle.
>> > >
>> > > I had some glibc code to do the pkey alloc/free operations, but those aren't
>> > > necessary if we're doing it in the kernel.  Other than getting the syscall
>> > > wrappers in place, I don't have any immediate plans to do anything in glibc.
>> > >
>> > > Was there something you were expecting to see?
>> >
>> > Yeah, so (as you probably guessed!) I'm starting to have second thoughts about the
>> > complexity of the alloc/free/set/get interface I suggested, and Mel's review
>> > certainly strengthened that feeling.
>> >
>> > I have two worries:
>> >
>> > 1)
>> >
>> > A technical worry I have is that the 'pkey allocation interface' does not seem to
>> > be taking the per thread property of pkeys into account - while that property
>> > would be useful for apps. That is a limitation that seems unjustified.
>> >
>> > The reason for this is that we are storing the key allocation bitmap in struct_mm,
>> > in mm->context.pkey_allocation_map - while we should be storing it in task_struct
>> > or thread_info.
>>
>> Huh?  Doesn't this have to be per mm?  Sure, PKRU is per thread, but
>> the page tables are shared.
>
> But the keys are not shared, and they carry meaningful per thread information.
>
> mprotect_pkey()'s effects are per MM, but the system calls related to managing the
> keys (alloc/free/get/set) are fundamentally per CPU.
>
> Here's an example of how this could matter to applications:
>
>  - 'writer thread' gets a RW- key into index 1 to a specific data area
>  - a pool of 'reader threads' may get the same pkey index 1 R-- to read the data
>    area.

Sure, but this means you allocate index 1 once and then use it in both
threads.  If you allocate separately in each thread, nothing
guarantees you'll get the same index both times, and if you don't then
the code doesn't work.

>
>> There are still two issues that I think we need to address, though:
>>
>> 1. Signal delivery shouldn't unconditionally clear PKRU.  That's what
>> the current patches do, and it's unsafe.  I'd rather set PKRU to the
>> maximally locked down state on signal delivery (except for the
>> PROT_EXEC key), although that might cause its own set of problems.
>
> Right now the historic pattern for signal handlers is that they safely and
> transparently stack on top of existing FPU related resources and do a save/restore
> of them. In that sense saving+clearing+restoring the pkeys state would be the
> correct approach that follows that pattern. There are two extra considerations:
>
> - If we think of pkeys as a temporary register that can be used to access/unaccess
>   normally unaccessible memory regions then this makes sense, in fact it's more
>   secure: signal handlers cannot accidentally stomp on an encryption key or on a
>   database area, unless they intentionally gain access to them.
>

That how I think I would think of them, but for this to be fully safe,
we'd want to lock them down in signal handlers by default, which is
what I'm suggesting.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
