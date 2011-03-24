Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 487988D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:15:58 -0400 (EDT)
Date: Thu, 24 Mar 2011 13:15:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
In-Reply-To: <AANLkTi=KZQd-GrXaq4472V3XnEGYqnCheYcgrdPFE0LJ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1103241312280.32226@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger> <20110324142146.GA11682@elte.hu> <alpine.DEB.2.00.1103240940570.32226@router.home> <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com> <20110324172653.GA28507@elte.hu>
 <alpine.DEB.2.00.1103241242450.32226@router.home> <AANLkTimMcP-GikCCndQppNBsS7y=4beesZ4PaD6yh5y5@mail.gmail.com> <alpine.DEB.2.00.1103241300420.32226@router.home> <AANLkTi=KZQd-GrXaq4472V3XnEGYqnCheYcgrdPFE0LJ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 24 Mar 2011, Pekka Enberg wrote:

> > I forced the fallback to the _emu function to occur but could not trigger
> > the bug in kvm.
>
> That's not the problem. I'm sure the fallback is just fine. What I'm
> saying is that the fallback is *not patched* to kernel text on Ingo's
> machines because alternative_instructions() happens late in the boot!
> So the problem is that on Ingo's boxes (that presumably have old AMD
> CPUs) we execute cmpxchg16b, not the fallback code.

But then we would get the bug in kmem_cache_alloc() and not in the
*_emu() function. So the _emu is executing but failing on Ingo's system
but not on mine. Question is why.

For some reason the first reference to %gs:(%rsi) wont work right on his
system:

>From arch/x86/lib/cmpxchg16b_emu

#
# Emulate 'cmpxchg16b %gs:(%rsi)' except we return the result in %al not
# via the ZF.  Caller will access %al to get result.
#
# Note that this is only useful for a cpuops operation.  Meaning that we
# do *not* have a fully atomic operation but just an operation that is
# *atomic* on a single cpu (as provided by the this_cpu_xx class of
# macros).
#
this_cpu_cmpxchg16b_emu:
        pushf
        cli

        cmpq %gs:(%rsi), %rax
        jne not_same
        cmpq %gs:8(%rsi), %rdx
        jne not_same

        movq %rbx, %gs:(%rsi)
        movq %rcx, %gs:8(%rsi)

        popf
        mov $1, %al
        ret

 not_same:
        popf
        xor %al,%al
        ret

CFI_ENDPROC




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
