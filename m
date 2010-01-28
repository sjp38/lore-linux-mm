Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D0D996B0089
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 10:50:12 -0500 (EST)
Message-ID: <4B61B00D.7070202@zytor.com>
Date: Thu, 28 Jan 2010 07:41:01 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [Security] DoS on x86_64
References: <144AC102-422A-4AA3-864D-F90183837EA3@googlemail.com> <20100128001802.8491e8c1.akpm@linux-foundation.org>
In-Reply-To: <20100128001802.8491e8c1.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mathias Krause <minipli@googlemail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, security@kernel.org, Mike Waychison <mikew@google.com>, Michael Davidson <md@google.com>, "Luck, Tony" <tony.luck@intel.com>, Roland McGrath <roland@redhat.com>, James Morris <jmorris@namei.org>
List-ID: <linux-mm.kvack.org>

On 01/28/2010 12:18 AM, Andrew Morton wrote:
> On Thu, 28 Jan 2010 08:34:02 +0100 Mathias Krause <minipli@googlemail.com> wrote:
> 
>> I found by accident an reliable way to panic the kernel on an x86_64  
>> system. Since this one can be triggered by an unprivileged user I  
>> CCed security@kernel.org. I also haven't found a corresponding bug on  
>> bugzilla.kernel.org. So, what to do to trigger the bug:
>>
>> 1. Enable core dumps
>> 2. Start an 32 bit program that tries to execve() an 64 bit program
>> 3. The 64 bit program cannot be started by the kernel because it  
>> can't find the interpreter, i.e. execve returns with an error
>> 4. Generate a segmentation fault
>> 5. panic
> 
> hrm, isn't this the same as "failed exec() leaves caller with incorrect
> personality", discussed in December? afacit nothing happened as a result
> of that.

Yes, it is.  We closed the ptrace-related hole which made it exploitable
as something more than a DoS, but it got stalled out a bit at that point.

Funny enough I talked to Ralf about the whole situation as late as
yesterday.  I did a bunch of digging into this about how to fix it
properly -- the code is infernally screwed up because of the compat
macro layer.

This is what it looks like from my point of view:

- At some point in the past, some personalities would play games with
the filename space in order to provide a separate namespace for
libraries.  As a result, we had to at least partially switch
personalities before looking up the interpreter.

- There is no cleanup macro!  The personality switch macro is supposed
to use an arch-specific deferred state change in order to handle
irreversible changes, but even setting a deferral bit can be a state
leak which could cause an exec to malfunction later.

- *As far as I have been able to discern*, there aren't actually any
architectures which use personalities which muck with the namespace
anymore.  The x86 layer in IA64, in particular, used to do it, but that
code has been dead for a while; similar with the iBCS2 layer in i386.

- In my opinion, we should defer the personality switch until we have
passed the point of no return.

- The actual point of no return in the case of binfmt_elf.c is inside
the subroutine flush_old_exec() [which makes sense - the actual process
switch shouldn't be dependent on the binfmt] which isn't subject to
compat-level macro munging.

- The "right thing" probably is replacing the compat macros with an ops
struct.  Replacing the SET_PERSONALITY() macro with a function pointer
would make it possible to pass it as a function pointer to
flush_old_exec() -- the current implementation as macros makes that
impossible.

- The only other realistic option seems to be to have a new macro to
clean up the effects of SET_PERSONALITY() and add it to all failure
paths.  This can be done more straightforward than it sounds by moving
SET_PERSONALITY() down to just before flush_old_exec(), and then the
cleanup macro would be executed onto the (retval).

- Either way, this is a panarchitectural change, involving some pretty
grotty code in the form of the compat macros.

I guess I should do the x86 implementation of one of these, but I don't
see any way to fix the actual problem without touching every architecture.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
