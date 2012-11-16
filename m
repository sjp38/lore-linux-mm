Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id F0B706B005A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 12:26:56 -0500 (EST)
Message-ID: <50A67751.1090306@redhat.com>
Date: Fri, 16 Nov 2012 12:26:41 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/43] mm: numa: Make pte_numa() and pmd_numa() a generic
 implementation
References: <1353064973-26082-1-git-send-email-mgorman@suse.de> <1353064973-26082-7-git-send-email-mgorman@suse.de> <50A648FF.2040707@redhat.com> <20121116144109.GA8218@suse.de> <CA+55aFzH_-6FuwTF1GVDzLK+7c0MGLsLdPFjzzwU78GVUEMbBw@mail.gmail.com> <20121116160852.GA4302@gmail.com> <20121116165606.GE8218@suse.de>
In-Reply-To: <20121116165606.GE8218@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/16/2012 11:56 AM, Mel Gorman wrote:

>> b33467764d8a mm/migrate: Introduce migrate_misplaced_page()
>
> bolts onto the side of migration and introduces MIGRATE_FAULT which
> should not have been necessary. Already complained about.
>
> The alternative uses the existing migrate_pages() function but has
> different requirements for taking a reference to the page.

Indeed, NACK to b33467764d8a

Mel's tree implements this in a much cleaner way.

>> ca2ea0747a5b mm/mpol: Add MPOL_MF_LAZY
>
> We more or less share this except I backed out the userspace visible bits
> in a separate patch because I didn't think it had been carefully reviewed
> how an application should use it and if it was a good idea. Covered in an
> earlier review.

Agreed, these bits should not be userspace visible, at least
not for now.

>> cd203e33c39d mm/mpol: Add MPOL_MF_NOOP
>
> I have a patch that backs this out on the grounds that I don't think we
> have adequately discussed if it was the correct userspace interface. I
> know Peter put a lot of time into it so it's probably correct but
> without man pages or spending time writing an example program that used
> it, I played safe.

Ditto.

>> 6fe64360a759 mm: Only flush the TLB when clearing an accessible pte
>
> I missed this. Stupid stupid stupid! It would reduce the TLB flushes from
> migration context.

However, Ingo's tree still incurs the double page fault for
migrated pages. Both trees could use a little improvement in
this area :)

>> e9df40bfeb25 x86/mm: Introduce pte_accessible()
>
> prot_none.

This one is x86 specific, and would work as well with Andrea's
_PAGE_NUMA as it would with _PAGE_PROTNONE.

>> is a good foundation already with no WIP policy bits in it.
>>
>> Mel, could you please work on this basis, or point out the bits
>> you don't agree with so I can fix it?
>>
>
> My main hangup is the prot_none choice and I know it's something we have
> butted heads on without progress. I feel it is a lot cleaner to have
> the _PAGE_NUMA bit (even if it's PROT_NONE underneath) and the helpers
> avoid function calls where possible.

I am pretty neutral on whether we use _PAGE_NUMA with _PAGE_PROTNONE
underneath, or the slightly higher overhead actual prot_none stuff.

I can live with whichever of these Linus ends up merging.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
