Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 82CC59000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 23:00:27 -0400 (EDT)
Message-ID: <4E813C29.1030604@redhat.com>
Date: Mon, 26 Sep 2011 19:59:53 -0700
From: Josh Stone <jistone@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 3.1.0-rc4-tip 8/26]   x86: analyze instruction and
 determine fixups.
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120127.25326.71509.sendpatchset@srdronam.in.ibm.com> <20110920171310.GC27959@stefanha-thinkpad.localdomain> <20110920181225.GA5149@infradead.org> <20110920205317.GA1508@stefanha-think <20110923165132.GA23870@stefanha-thinkpad.localdomain> <4E80D9B2.3010404@redhat.com> <4E812797.1090207@hitachi.com>
In-Reply-To: <4E812797.1090207@hitachi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Stefan Hajnoczi <stefanha@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, SystemTap <systemtap@sourceware.org>, LKML <linux-kernel@vger.kernel.org>

On 09/26/2011 06:32 PM, Masami Hiramatsu wrote:
>> On 09/23/2011 09:51 AM, Stefan Hajnoczi wrote:
>>>> I'm not sure that we should stick on the current implementation
>>>> of the sdt.h. I think we'd better modify the sdt.h to replace
>>>> such semaphores with checking whether the tracepoint is changed from nop.
>>>
>>> I like this option.  The only implication is that all userspace tracing
>>> needs to go through uprobes if we want to support multiple consumers
>>> tracing the same address.
>>
>> This limitation is practically true already, since sharing consumers
>> have to negotiate the breakpoint anyway.
>>
>> If we can find a better way to handle semaphores, we at systemtap will
>> welcome sdt.h improvements.  On the face of it, checking one's own NOP
>> for modification sounds pretty elegant, but I'm not convinced that it's
>> possible in practice.
>>
>> For one, it requires arch specific knowledge in sdt.h of what the NOP or
>> breakpoint looks like, whereas sdt.h currently only knows whether to use
>> NOP or NOP 0, without knowledge of how that's encoded.  And this gets
>> trickier with archs like IA64 where you're part of a bundle.  So this
>> much is hard, but not impossible.
> 
> Even though, we can start with x86, which is currently one and only one
> platform supporting uprobes :)

This inode-based uprobes only supports x86 so far.  The utrace-based
uprobes also supports s390 and ppc, which you can bet Srikar will be
tasked with here before long...

But uprobes is not the only sdt.h consumer anyway.  GDB also supports
sdt.h in its targets, covering x86, ppc, s390, and arm so far IIRC.

> Maybe we can prepare asm/sdt.h for describing arch-dep code.

In sys/sdt.h itself, these would probably be short enough snippets that
we can just add each arch's check directly.  I'm just averse to adding
arch-dependent stuff unless we have to, but maybe we need it.

>> Another issue is that there's not an easy compile-time correlation
>> between semaphore checks and probe locations, nor is it necessarily a
>> 1:1 mapping.  The FOO_ENABLED() and PROBE_FOO() code blocks are
>> distinct, and the compiler can do many tricks with them, loop unrolling,
>> function specialization, etc.  And if we start placing constraints to
>> prevent this, then I think we'll be impacting code-gen of the
>> application more than we'd like.
> 
> Perhaps, we can use the constructor attribute for that purpose.
> 
> __attribute__((constructor)) FOO_init() {
> 	/* Search FOO tracepoint address from tracepoint table(like extable) */
> 	FOO_sem = __find_first_trace_point("FOO");
> }
> 
> This sets the address of first tracepoint of FOO to FOO_sem. :)

This works as long as all FOO instances are enabled altogether, and as
long as FOO events are not in constructors themselves.  Those are minor
and probably reasonable limitations, just need to be acknowledged.  And
I'm not sure how complicated __find_first_trace_point will be.

This adds a bit of start-up overhead too, but the libraries that
strongly care about this (like glibc and libgcc) are not the ones who
are using ENABLED() checks.

So OK, can you flesh out or prototype what __find_first_trace_point and
its tracepoint table should look like?  If you can demonstrate these,
then I'd be willing to try modifying bin/dtrace and sys/sdt.h.

The good news is that if we figure this out, then the kernel can be
completely SDT-agnostic -- it's just like any other address to probe.  I
hope we can also make it transparent to existing sdt.h consumers, so it
just looks like there's no semaphore-counter to manipulate.


Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
