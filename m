Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id B94E66B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 09:26:07 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id c4so1270992eek.14
        for <linux-mm@kvack.org>; Fri, 26 Oct 2012 06:26:06 -0700 (PDT)
Date: Fri, 26 Oct 2012 15:26:01 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 05/31] x86/mm: Reduce tlb flushes from
 ptep_set_access_flags()
Message-ID: <20121026132601.GC9886@gmail.com>
References: <20121025121617.617683848@chello.nl>
 <20121025124832.840241082@chello.nl>
 <CA+55aFxRh43832cEW39t0+d1Sdz46Up6Za9w641jpWukmi4zFw@mail.gmail.com>
 <5089F5B5.1050206@redhat.com>
 <CA+55aFwcj=nh1RUmEXUk6W3XwfbdQdQofkkCstbLGVo1EoKryA@mail.gmail.com>
 <508A0A0D.4090001@redhat.com>
 <CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com>
 <CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com>
 <m2pq45qu0s.fsf@firstfloor.org>
 <508A8D31.9000106@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <508A8D31.9000106@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Rik van Riel <riel@redhat.com> wrote:

> On 10/26/2012 08:48 AM, Andi Kleen wrote:
> >Michel Lespinasse <walken@google.com> writes:
> >
> >>On Thu, Oct 25, 2012 at 9:23 PM, Linus Torvalds
> >><torvalds@linux-foundation.org> wrote:
> >>>On Thu, Oct 25, 2012 at 8:57 PM, Rik van Riel <riel@redhat.com> wrote:
> >>>>
> >>>>That may not even be needed.  Apparently Intel chips
> >>>>automatically flush an entry from the TLB when it
> >>>>causes a page fault.  I assume AMD chips do the same,
> >>>>because flush_tlb_fix_spurious_fault evaluates to
> >>>>nothing on x86.
> >>>
> >>>Yes. It's not architected as far as I know, though. But I agree, it's
> >>>possible - even likely - we could avoid TLB flushing entirely on x86.
> >>
> >>Actually, it is architected on x86. This was first described in the
> >>intel appnote 317080 "TLBs, Paging-Structure Caches, and Their
> >>Invalidation", last paragraph of section 5.1. Nowadays, the same
> >>contents are buried somewhere in Volume 3 of the architecture manual
> >>(in my copy: 4.10.4.1 Operations that Invalidate TLBs and
> >>Paging-Structure Caches)
> >
> > This unfortunately would only work for processes with no 
> > threads because it only works on the current logical CPU.
> 
> That is fine.
> 
> Potentially triggering a spurious page fault on
> another CPU is bound to be better than always
> doing a synchronous remote TLB flush, waiting
> for who knows how many CPUs to acknowledge the
> IPI...

The other killer is the fundamental IPI delay - which makes it 
'invisible' to regular profiling and makes it hard to analyze.

So yes, even the local flush is a win, a major one - and the 
flush-less one is likely a win too, because INVLPG has some 
TLB-cache-walking costs.

Rik, mind sending an updated patch that addresses Linus's 
concerns, or should I code it up if you are busy?

We can also certainly try the second patch, but I'd do it at the 
end of the series, to put some tree distance between the two 
patches, to not concentrate regression risks too tightly in the 
Git space, to help out with hard to bisect problems...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
