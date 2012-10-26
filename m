Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 51A346B0074
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 00:23:47 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id dq12so1568679wgb.26
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 21:23:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <508A0A0D.4090001@redhat.com>
References: <20121025121617.617683848@chello.nl> <20121025124832.840241082@chello.nl>
 <CA+55aFxRh43832cEW39t0+d1Sdz46Up6Za9w641jpWukmi4zFw@mail.gmail.com>
 <5089F5B5.1050206@redhat.com> <CA+55aFwcj=nh1RUmEXUk6W3XwfbdQdQofkkCstbLGVo1EoKryA@mail.gmail.com>
 <508A0A0D.4090001@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 25 Oct 2012 21:23:25 -0700
Message-ID: <CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com>
Subject: Re: [PATCH 05/31] x86/mm: Reduce tlb flushes from ptep_set_access_flags()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Thu, Oct 25, 2012 at 8:57 PM, Rik van Riel <riel@redhat.com> wrote:
>
> That may not even be needed.  Apparently Intel chips
> automatically flush an entry from the TLB when it
> causes a page fault.  I assume AMD chips do the same,
> because flush_tlb_fix_spurious_fault evaluates to
> nothing on x86.

Yes. It's not architected as far as I know, though. But I agree, it's
possible - even likely - we could avoid TLB flushing entirely on x86.

If you want to try it, I would seriously suggest you do it as a
separate commit though, just in case.

> Are there architectures where we do need to flush
> remote TLBs on upgrading the permissions on a PTE?

I *suspect* that whole TLB flush just magically became an SMP one
without anybody ever really thinking about it.

So it's quite possible we could do this to the pgtable-generic.c code
too. However, we don't actually have any generic way to do a local
single-address flush (the __flush_tlb_one() thing is
architecture-specific, although it exists on a few architectures).
We'd need to add a local_flush_tlb_page(vma, address) function.

Alternatively, we could decide to use the "tlb_fix_spurious_fault()"
thing in there. Possibly just do it unconditionally in the caller - or
even just specify that the fault handler has to do it. And stop
returning a value at all from ptep_set_access_flags() (I *think*
that's the only thing the return value gets used for - flushing the
TLB on the local cpu for the cpu's that want it).

> Want to just remove the TLB flush entirely and see
> if anything breaks in 3.8-rc1?
>
> From reading the code again, it looks like things
> should indeed work ok.

I would be open to it, but just in case it causes bisectable problems
I'd really want to see it in two patches ("make it always do the local
flush" followed by "remove even the local flush"), and then it would
pinpoint any need.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
