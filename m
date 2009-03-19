Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E679D6B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 13:34:20 -0400 (EDT)
Message-ID: <49C281F1.4040005@redhat.com>
Date: Thu, 19 Mar 2009 19:33:37 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: Question about x86/mm/gup.c's use of disabled interrupts
References: <49C148AF.5050601@goop.org> <49C16411.2040705@redhat.com> <49C1665A.4080707@goop.org> <49C16A48.4090303@redhat.com> <49C17230.20109@goop.org> <49C17880.7080109@redhat.com> <49C17BD8.6050609@goop.org> <49C17E22.9040807@redhat.com> <49C18487.1020703@goop.org> <49C21473.2000702@redhat.com> <49C27E09.5070307@goop.org>
In-Reply-To: <49C27E09.5070307@goop.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Xen-devel <xen-devel@lists.xensource.com>, Jan Beulich <jbeulich@novell.com>, Ingo Molnar <mingo@elte.hu>, Keir Fraser <keir.fraser@eu.citrix.com>
List-ID: <linux-mm.kvack.org>

Jeremy Fitzhardinge wrote:
> Avi Kivity wrote:
>>> And the hypercall could result in no Xen-level IPIs at all, so it 
>>> could be very quick by comparison to an IPI-based Linux 
>>> implementation, in which case the flag polling would be particularly 
>>> harsh.
>>
>> Maybe we could bring these optimizations into Linux as well.  The 
>> only thing Xen knows that Linux doesn't is if a vcpu is not 
>> scheduled; all other information is shared.
>
> I don't think there's a guarantee that just because a vcpu isn't 
> running now, it won't need a tlb flush.  If a pcpu does runs vcpu 1 -> 
> idle -> vcpu 1, then there's no need for it to do a tlb flush, but the 
> hypercall can make force a flush when it reschedules vcpu 1 (if the 
> tlb hasn't already been flushed by some other means).

That's what I assumed you meant.  Also, if a vcpu has a different cr3 
loaded, the flush can be elided.  Looks like Linux does this 
(s/vcpu/process/).

> (I'm not sure to what extent Xen implements this now, but I wouldn't 
> want to over-constrain it.)

Well, kvm does this.


>> The nice thing about local_irq_disable() is that it scales so well.
>
> Right.  But it effectively puts the burden on the tlb-flusher to check 
> the state (implicitly, by trying to send an interrupt).  Putting an 
> explicit poll in gets the same effect, but its pure overhead just to 
> deal with the gup race.

I guess it hopes the flushes are much rarer.  Certainly for threaded 
databases doing O_DIRECT stuff, I'd expect lots of gupfs and no tlb flushes.


-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
