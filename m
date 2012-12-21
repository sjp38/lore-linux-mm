Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 596656B005A
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 04:58:13 -0500 (EST)
Message-ID: <50D43270.8010506@synopsys.com>
Date: Fri, 21 Dec 2012 15:27:04 +0530
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
MIME-Version: 1.0
Subject: trailing flush_tlb_fix_spurious_fault in handle_pte_fault (was Re:
 [PATCH 1/3] x86/mm: only do a local TLB flush in ptep_set_access_flags())
References: <20121025121617.617683848@chello.nl> <20121025124832.840241082@chello.nl> <CA+55aFxRh43832cEW39t0+d1Sdz46Up6Za9w641jpWukmi4zFw@mail.gmail.com> <5089F5B5.1050206@redhat.com> <CA+55aFwcj=nh1RUmEXUk6W3XwfbdQdQofkkCstbLGVo1EoKryA@mail.gmail.com> <508A0A0D.4090001@redhat.com> <CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com> <CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com> <m2pq45qu0s.fsf@firstfloor.org> <508A8D31.9000106@redhat.com> <20121026132601.GC9886@gmail.com> <20121026144419.7e666023@dull> <CA+55aFwdcMzMQ2ns6-p97GXuNhxiDO-nFa0h1A-tjN363mJniQ@mail.gmail.com> <508AE1A3.6030607@redhat.com> <CA+55aFxOywu=6pqejQi5DFm0KQYj0i9yQexwxgzdM5z3kcDgrg@mail.gmail.com> <508E9F5B.5010402@redhat.com>
In-Reply-To: <508E9F5B.5010402@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea
 Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes
 Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew
 Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gilad Ben Yossef <giladb@ezchip.com>Andrea Arcangeli <aarcange@redhat.com>

On Monday 29 October 2012 08:53 PM, Rik van Riel wrote:
> On 10/26/2012 03:18 PM, Linus Torvalds wrote:
>> On Fri, Oct 26, 2012 at 12:16 PM, Rik van Riel <riel@redhat.com> wrote:
>>>
>>> I can change the text of the changelog, however it looks
>>> like do_wp_page does actually use ptep_set_access_flags
>>> to set the write bit in the pte...
>>>
>>> I guess both need to be reflected in the changelog text
>>> somehow?
>>
>> Yeah, and by now, after all this discussion, I suspect it should be
>> committed with a comment too. Commit messages are good and all, but
>> unless chasing a particular bug they introduced, we shouldn't expect
>> people to read them for background information.
> 
> Now that we have the TLB things taken care of, and
> comments to patches 10/31 and 26/31 have been addressed,
> is there anything else that needs to be done before
> these NUMA patches can be merged?
> 
> Anyone, this is a good time to speak up. We have some
> time to address whatever concern you may have.
> 

Hi,

I know I'm very late in speaking up - but still I'll hazard a try. This is not
exactly the same topic but closely related.

There is a a different call to flush_tlb_fix_spurious( ), towards the end of
handle_pte_fault( ) which commit 61c77326d "x86, mm: Avoid unnecessary TLB flush"
made no-op for X86. However is this really needed for any arch at all - even if we
don't know all the arch specific quirks.

Given the code flow below

handle_pte_fault( )
....
....
if ptep_set_access_flags()-> if PTE chg remote TLB shot (pgtable-generic.c ver)
   update_mmu_cache       -> if PTE chg local TLB possibly shot too
else
   flush_tlb_fix_spurious_fault -> PTE didn't change - still remote TLB shotdown

So for PTE unchanged case, we default to doing remote TLB IPIs (barring X86) -
unless arch makes this macro NULL.

Thing is, in case of SMP races - due to PTE being different - any fixups to
local/remote will be handled within ptep_set_access_flags( ) - arch-specific or
generic versions. What I fail to understand is need to do anything - specially a
remote shootdown, for PTE not changed case.

I could shut up and just make it NO-OP for ARC, but ....

Please note that for the record, the addition of this special case was done via
following change. It might help answer what I feel to comprehend.

2005-10-29 1a44e14 [PATCH] .text page fault SMP scalability optimization

I might be totally off track so please feel free to bash me - but atleast I would
end up knowing more !

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
