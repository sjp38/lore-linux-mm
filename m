Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 0717C6B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 14:11:54 -0400 (EDT)
Message-ID: <508AD2FF.5020306@redhat.com>
Date: Fri, 26 Oct 2012 14:14:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/31] x86/mm: Reduce tlb flushes from ptep_set_access_flags()
References: <20121025121617.617683848@chello.nl> <20121025124832.840241082@chello.nl> <CA+55aFxRh43832cEW39t0+d1Sdz46Up6Za9w641jpWukmi4zFw@mail.gmail.com> <5089F5B5.1050206@redhat.com> <CA+55aFwcj=nh1RUmEXUk6W3XwfbdQdQofkkCstbLGVo1EoKryA@mail.gmail.com> <508A0A0D.4090001@redhat.com> <CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com> <CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com> <CA+55aFwpZ5pO2G7gs3Pga5et1DQZ4qMoe1CLFkSrVQK_4K4rhA@mail.gmail.com> <508ACE6E.8060303@redhat.com> <CA+55aFyYvu20qHtJ2SuNK3Dd466Hs9m9U3_41E8HtQ6KiRVRKw@mail.gmail.com>
In-Reply-To: <CA+55aFyYvu20qHtJ2SuNK3Dd466Hs9m9U3_41E8HtQ6KiRVRKw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On 10/26/2012 02:02 PM, Linus Torvalds wrote:
> On Fri, Oct 26, 2012 at 10:54 AM, Rik van Riel <riel@redhat.com> wrote:
>>
>> Would tlb_fix_spurious_fault take care of that on those
>> architectures?
>
> .. assuming that they implement it as a real TLB flush, yes.
>
> But maybe the architecture never noticed that it happened to depend on
> the fact that we do a cross-CPU invalidate? So a missing
> tlb_fix_spurious_fault() implementation could cause a short loop of
> repeated page faults, until the IPI happens. And it would be so
> incredibly rare that nobody would ever have noticed.
>
> And if that could have happened, then with the cross-cpu invalidate
> removed, the "incredibly rare short-lived constant page fault retry"
> could turn into "incredibly rare lockup due to infinite page fault
> retry due to TLB entry that never turns dirty despite it being marked
> dirty by SW in the in-memory page tables".

I suspect the next context switch would flush out the TLB,
making it a slowdown, not a lockup.

Still a good reason to make such a change in its own commit,
so it can be bisected and tracked down.

The commit message could tell architecture maintainers what
to do if this particular commit got them into trouble:
implement a proper local TLB flush in tlb_fix_spurious_fault.

I'll send this in as a separate patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
