Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 04B806B003D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 19:32:30 -0400 (EDT)
Message-ID: <49C18487.1020703@goop.org>
Date: Wed, 18 Mar 2009 16:32:23 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Question about x86/mm/gup.c's use of disabled interrupts
References: <49C148AF.5050601@goop.org> <49C16411.2040705@redhat.com> <49C1665A.4080707@goop.org> <49C16A48.4090303@redhat.com> <49C17230.20109@goop.org> <49C17880.7080109@redhat.com> <49C17BD8.6050609@goop.org> <49C17E22.9040807@redhat.com>
In-Reply-To: <49C17E22.9040807@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xen-devel <xen-devel@lists.xensource.com>, Jan Beulich <jbeulich@novell.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
> Jeremy Fitzhardinge wrote:
>> Avi Kivity wrote:
>>>> Hm, awkward if flush_tlb_others doesn't IPI...
>>>>
>>>
>>> How can it avoid flushing the tlb on cpu [01]?  It's it's 
>>> gup_fast()ing a pte, it may as well load it into the tlb.
>>
>> xen_flush_tlb_others uses a hypercall rather than an IPI, so none of 
>> the logic which depends on there being an IPI will work.
>
> Right, of course, that's what we were talking about.  I thought 
> optimizations to avoid IPIs if an mm never visited a cpu.
>
>>
>>>> Simplest fix is to make gup_get_pte() a pvop, but that does seem 
>>>> like putting a red flag in front of an inner-loop hotspot, or 
>>>> something...
>>>>
>>>> The per-cpu tlb-flush exclusion flag might really be the way to go.
>>>
>>> I don't see how it will work, without changing Xen to look at the flag?
>>>
>>> local_irq_disable() is used here to lock out a remote cpu, I don't 
>>> see why deferring the flush helps.
>>
>> Well, no, not deferring.  Making xen_flush_tlb_others() spin waiting 
>> for "doing_gup" to clear on the target cpu.  Or add an explicit 
>> notion of a "pte update barrier" rather than implicitly relying on 
>> the tlb IPI (which is extremely convenient when available...).
>
> Pick up a percpu flag from all cpus and spin on each?  Nasty.

Yeah, not great.  Each of those flag fetches is likely to be cold, so a 
bunch of cache misses.  The only mitigating factor is that cross-cpu tlb 
flushes are expected to be expensive, but some workloads are apparently 
very sensitive to extra latency in that path.  And the hypercall could 
result in no Xen-level IPIs at all, so it could be very quick by 
comparison to an IPI-based Linux implementation, in which case the flag 
polling would be particularly harsh.

Also, the straightforward implementation of "poll until all target cpu's 
flags are clear" may never make progress, so you'd have to "scan flags, 
remove busy cpus from set, repeat until all cpus done".

All annoying because this race is pretty unlikely, and it seems a shame 
to slow down all tlb flushes to deal with it.  Some kind of global 
"doing gup_fast" counter would get flush_tlb_others bypass the check, at 
the cost of putting a couple of atomic ops around the outside of gup_fast.

> You could use the irq enabled flag; it's available and what native 
> spins on (but also means I'll need to add one if I implement this).

Yes, but then we'd end up spuriously polling on cpus which happened to 
disable interrupts for any reason.  And if the vcpu is not running then 
we could end up polling for a long time.  (Same applies for things in 
gup_fast, but I'm assuming that's a lot less common than disabling 
interrupts in general).

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
