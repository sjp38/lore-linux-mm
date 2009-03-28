Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3D66A6B0047
	for <linux-mm@kvack.org>; Sat, 28 Mar 2009 08:36:50 -0400 (EDT)
Subject: Re: [PATCH 1/2] x86/mm: maintain a percpu "in get_user_pages_fast"
 flag
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <49CDD7B4.4020701@cosmosbay.com>
References: <49CD37B8.4070109@goop.org> <49CD9E25.2090407@redhat.com>
	 <49CDAF17.5060207@goop.org>  <49CDD7B4.4020701@cosmosbay.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 28 Mar 2009 13:31:58 +0100
Message-Id: <1238243518.4039.725.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Avi Kivity <avi@redhat.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2009-03-28 at 08:54 +0100, Eric Dumazet wrote:
> Jeremy Fitzhardinge a A(C)crit :
> > Avi Kivity wrote:
> >> Jeremy Fitzhardinge wrote:
> >>> get_user_pages_fast() relies on cross-cpu tlb flushes being a barrier
> >>> between clearing and setting a pte, and before freeing a pagetable page.
> >>> It usually does this by disabling interrupts to hold off IPIs, but
> >>> some tlb flush implementations don't use IPIs for tlb flushes, and
> >>> must use another mechanism.
> >>>
> >>> In this change, add in_gup_cpumask, which is a cpumask of cpus currently
> >>> performing a get_user_pages_fast traversal of a pagetable.  A cross-cpu
> >>> tlb flush function can use this to determine whether it should hold-off
> >>> on the flush until the gup_fast has finished.
> >>>
> >>> @@ -255,6 +260,10 @@ int get_user_pages_fast(unsigned long start, int
> >>> nr_pages, int write,
> >>>      * address down to the the page and take a ref on it.
> >>>      */
> >>>     local_irq_disable();
> >>> +
> >>> +    cpu = smp_processor_id();
> >>> +    cpumask_set_cpu(cpu, in_gup_cpumask);
> >>> +
> >>
> >> This will bounce a cacheline, every time.  Please wrap in CONFIG_XEN
> >> and skip at runtime if Xen is not enabled.
> > 
> > Every time?  Only when running successive gup_fasts on different cpus,
> > and only twice per gup_fast. (What's the typical page count?  I see that
> > kvm and lguest are page-at-a-time users, but presumably direct IO has
> > larger batches.)
> 
> If I am not mistaken, shared futexes where hitting hard mm semaphore.
> Then gup_fast was introduced in kernel/futex.c to remove this contention point.
> Yet, this contention point was process specific, not a global one :)
> 
> And now, you want to add a global hot point, that would slow
> down unrelated processes, only because they use shared futexes, thousand
> times per second...

Yet another reason to turn all this virt muck off :-) I just wish I
could turn off the paravirt code impact, it makes finding functions in
the x86 code a terrible pain.

> > Alternatively, it could have per-cpu flags and the other side could
> > construct the mask (I originally had that, but this was simpler).
> 
> Simpler but would be a regression for legacy applications still using shared
> futexes (because statically linked with old libc)

Still doesn't help those apps that really use shared futexes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
