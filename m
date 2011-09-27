Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 854499000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 21:32:17 -0400 (EDT)
Message-ID: <4E812797.1090207@hitachi.com>
Date: Tue, 27 Sep 2011 10:32:07 +0900
From: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 3.1.0-rc4-tip 8/26]   x86: analyze instruction and
 determine fixups.
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120127.25326.71509.sendpatchset@srdronam.in.ibm.com> <20110920171310.GC27959@stefanha-thinkpad.localdomain> <20110920181225.GA5149@infradead.org> <20110920205317.GA1508@stefanha-think <20110923165132.GA23870@stefanha-thinkpad.localdomain> <4E80D9B2.3010404@redhat.com>
In-Reply-To: <4E80D9B2.3010404@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Stone <jistone@redhat.com>
Cc: Stefan Hajnoczi <stefanha@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, SystemTap <systemtap@sourceware.org>

(2011/09/27 4:59), Josh Stone wrote:
> On 09/23/2011 04:53 AM, Masami Hiramatsu wrote:
>>> Masami looked at this and found that SystemTap sdt.h currently requires
>>> an extra userspace memory store in order to activate probes.  Each probe
>>> has a "semaphore" 16-bit counter which applications may test before
>>> hitting the probe itself.  This is used to avoid overhead in
>>> applications that do expensive argument processing (e.g. creating
>>> strings) for probes.
>> Indeed, originally, those semaphores designed for such use cases.
>> However, some applications *always* use it (e.g. qemu-kvm).
>
> I found that qemu-kvm generates its tracepoints like this:
>
>   static inline void trace_$name($args) {
>       if (QEMU_${nameupper}_ENABLED()) {
>           QEMU_${nameupper}($argnames);
>       }
>   }

Right, that's what I've said.

> In that case, the $args are always computed to call the inline, so
> you'll basically just get a memory read, jump, NOP.  There's no benefit
> from checking ENABLED() here, and removing it would leave only the NOP.
>  Even if you invent an improved mechanism for ENABLED(), that doesn't
> change the fact that it's doing useless work here.

Yeah, this use is totally meaningless...

> So in this case, it may be better to patch qemu, assuming my statements
> hold for DTrace's implementation on other platforms too.  The ENABLED()
> guard still does have other genuine uses though, as with the string
> preparation in Python's probes.

I agree with that qemu needs to be fixed. However, this is just for
the qemu case. Not the best solution.

> On 09/23/2011 09:51 AM, Stefan Hajnoczi wrote:
>>> I'm not sure that we should stick on the current implementation
>>> of the sdt.h. I think we'd better modify the sdt.h to replace
>>> such semaphores with checking whether the tracepoint is changed from nop.
>>
>> I like this option.  The only implication is that all userspace tracing
>> needs to go through uprobes if we want to support multiple consumers
>> tracing the same address.
>
> This limitation is practically true already, since sharing consumers
> have to negotiate the breakpoint anyway.
>
> If we can find a better way to handle semaphores, we at systemtap will
> welcome sdt.h improvements.  On the face of it, checking one's own NOP
> for modification sounds pretty elegant, but I'm not convinced that it's
> possible in practice.
>
> For one, it requires arch specific knowledge in sdt.h of what the NOP or
> breakpoint looks like, whereas sdt.h currently only knows whether to use
> NOP or NOP 0, without knowledge of how that's encoded.  And this gets
> trickier with archs like IA64 where you're part of a bundle.  So this
> much is hard, but not impossible.

Even though, we can start with x86, which is currently one and only one
platform supporting uprobes :)
Maybe we can prepare asm/sdt.h for describing arch-dep code.

> Another issue is that there's not an easy compile-time correlation
> between semaphore checks and probe locations, nor is it necessarily a
> 1:1 mapping.  The FOO_ENABLED() and PROBE_FOO() code blocks are
> distinct, and the compiler can do many tricks with them, loop unrolling,
> function specialization, etc.  And if we start placing constraints to
> prevent this, then I think we'll be impacting code-gen of the
> application more than we'd like.

Perhaps, we can use the constructor attribute for that purpose.

__attribute__((constructor)) FOO_init() {
	/* Search FOO tracepoint address from tracepoint table(like extable) */
	FOO_sem = __find_first_trace_point("FOO");
}

This sets the address of first tracepoint of FOO to FOO_sem. :)

Thank you,

-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt@hitachi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
