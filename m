Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id CFC126B0072
	for <linux-mm@kvack.org>; Sat, 27 Oct 2012 09:38:32 -0400 (EDT)
Message-ID: <508BE459.2080406@redhat.com>
Date: Sat, 27 Oct 2012 09:40:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86,mm: drop TLB flush from ptep_set_access_flags
References: <20121025121617.617683848@chello.nl> <20121025124832.840241082@chello.nl> <CA+55aFxRh43832cEW39t0+d1Sdz46Up6Za9w641jpWukmi4zFw@mail.gmail.com> <5089F5B5.1050206@redhat.com> <CA+55aFwcj=nh1RUmEXUk6W3XwfbdQdQofkkCstbLGVo1EoKryA@mail.gmail.com> <508A0A0D.4090001@redhat.com> <CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com> <CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com> <m2pq45qu0s.fsf@firstfloor.org> <508A8D31.9000106@redhat.com> <20121026132601.GC9886@gmail.com> <20121026144502.6e94643e@dull> <20121026221254.7d32c8bf@pyramind.ukuu.org.uk>
In-Reply-To: <20121026221254.7d32c8bf@pyramind.ukuu.org.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Ingo Molnar <mingo@kernel.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, florian@openwrt.org, Borislav Petkov <borislav.petkov@amd.com>

On 10/26/2012 05:12 PM, Alan Cox wrote:
> On Fri, 26 Oct 2012 14:45:02 -0400
> Rik van Riel <riel@redhat.com> wrote:
>
>> Intel has an architectural guarantee that the TLB entry causing
>> a page fault gets invalidated automatically. This means
>> we should be able to drop the local TLB invalidation.
>>
>> Because of the way other areas of the page fault code work,
>> chances are good that all x86 CPUs do this.  However, if
>> someone somewhere has an x86 CPU that does not invalidate
>> the TLB entry causing a page fault, this one-liner should
>> be easy to revert.
>
> This does not strike me as a good standard of validation for such a change
>
> At the very least we should have an ACK from AMD and from VIA, and
> preferably ping RDC and some of the other embedded folks. Given an AMD
> and VIA ACK I'd be fine. I doubt anyone knows any more what Cyrix CPUs
> did or cared about and I imagine H Peter or Linus can answer for
> Transmeta ;-)

Florian, would you happen to know who at RDC could be contacted
to verify whether a TLB entry causing a page fault gets
invalidated automatically, upon entering the page fault path?

Borislav, would you happen to know whether AMD (and VIA) CPUs
automatically invalidate TLB entries that cause page faults?
If you do not know, would you happen who to ask? :)

If these CPUs do not invalidate a TLB entry causing a page
fault (a write fault on a read-only PTE), then we may have to
change the kernel so flush_tlb_fix_spurious_fault does
something on the CPU models in question...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
