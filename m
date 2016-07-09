Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C55826B0253
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 04:37:20 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n127so25961292wme.1
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 01:37:20 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id ip8si3435839wjb.181.2016.07.09.01.37.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 01:37:19 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id f126so37086244wma.1
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 01:37:19 -0700 (PDT)
Date: Sat, 9 Jul 2016 10:37:15 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
Message-ID: <20160709083715.GA29939@gmail.com>
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124728.C1116BB1@viggo.jf.intel.com>
 <20160707144508.GZ11498@techsingularity.net>
 <577E924C.6010406@sr71.net>
 <20160708071810.GA27457@gmail.com>
 <577FD587.6050101@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <577FD587.6050101@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, hughd@google.com, viro@zeniv.linux.org.uk, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Dave Hansen <dave@sr71.net> wrote:

> On 07/08/2016 12:18 AM, Ingo Molnar wrote:
>
> > So the question is, what is user-space going to do? Do any glibc patches 
> > exist? How are the user-space library side APIs going to look like?
> 
> My goal at the moment is to get folks enabled to the point that they can start 
> modifying apps to use pkeys without having to patch their kernels.
>  I don't have confidence that we can design good high-level userspace interfaces 
> without seeing some real apps try to use the low-level ones and seeing how they 
> struggle.
> 
> I had some glibc code to do the pkey alloc/free operations, but those aren't 
> necessary if we're doing it in the kernel.  Other than getting the syscall 
> wrappers in place, I don't have any immediate plans to do anything in glibc.
> 
> Was there something you were expecting to see?

Yeah, so (as you probably guessed!) I'm starting to have second thoughts about the 
complexity of the alloc/free/set/get interface I suggested, and Mel's review 
certainly strengthened that feeling.

I have two worries:

1)

A technical worry I have is that the 'pkey allocation interface' does not seem to 
be taking the per thread property of pkeys into account - while that property 
would be useful for apps. That is a limitation that seems unjustified.

The reason for this is that we are storing the key allocation bitmap in struct_mm, 
in mm->context.pkey_allocation_map - while we should be storing it in task_struct 
or thread_info.

We could solve this by moving the allocation bitmap to the task struct, but:

2)

My main worry is that it appears at this stage that we are still pretty far away 
from completely shadowing the hardware pkey state in the kernel - and without that 
we cannot really force user-space to use the 'proper' APIs. They can just use the 
raw instructions, condition them on a CPUID and be done with it: everything can be 
organized in user-space.

Furthermore, implementing it in a high performance fashion would be pretty complex 
- at minimum we'd have to register a per thread read-write user-space data area 
where the kernel could store pkeys management data so that vsyscalls can access it 
... None of that facility exists today.

And without vsyscall optimizations user-space might legitimately use its own 
implementation for performance reasons and we'd end up with twice the complexity 
and a largely unused piece of kernel infrastructure ...

So how about the following minimalistic approach instead, to get the ball rolling 
without making ABI decisions we might regret:

 - There are 16 pkey indices on x86 currently. We already use index 15 for the 
   true PROT_EXEC implementation. Let's set aside another pkey index for the 
   kernel's potential future use (index 14), and clear it explicitly in the 
   FPU context on every context switch if CONFIG_X86_DEBUG_FPU is enabled to make 
   sure it remains unallocated.

 - Expose just the new mprotect_pkey() system call to install a pkey index into 
   the page tables - but we let user-space organize its key allocations.

 - Give user-space an idea about limits:

     "ALL THESE WORLDS ARE YOURSa??EXCEPT EUROPA ATTEMPT NO LANDING THERE"

   Ooops, wrong one. Lets try this instead:

     Expose the current maximum user-space usable pkeys index in some
     programmatically accessible fashion. Maybe mprotect_pkey() could reject a 
     permanently allocated kernel pkey index via a distinctive error code?

   I.e. this pattern:

     ret = pkey_mprotect(NULL, PAGE_SIZE, real_prot, pkey);

   ... would validate the pkey and we'd return -EOPNOTSUPP for pkey that is not 
   available? This would allow maximum future flexibility as it would not define 
   kernel allocated pkeys as a 'range'.

 - ... and otherwise leave the remaining 14 pkey indices for user-space to manage.

If in the future user-space pkeys usage grows to such a level that kernel 
arbitration becomes desirable then we can still implement the get/set/alloc/free 
system calls as well: the first use of those system calls would switch on the 
kernel's pkey management facilities and from that point on user-space is supposed 
to use the published system calls only. Applications using pkey instructions 
directly would still work just fine: they'd never use the new system calls.

I.e. we can actually keep a bigger ABI flexibility by introducing the simplest 
possible ABI at this stage. Maybe user-space usage of this hardware feature will 
never grow beyond that simple ABI - in which case we've saved quite a bit of 
ongoing maintenance complexity...

And yes, I realize that we've come a full round since the very first version of 
this patch set, but I think the extra hoops were still worth it, because the 
true-PROT_EXEC feature came out of it which is very useful IMHO. But my more 
complex pkey management syscall ideas don't seem to be all that useful anymore.

So what do you think about this direction? This would simplify the patch set quite 
a bit and would touch very little MM code beyond the mprotect_pkey() bits.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
