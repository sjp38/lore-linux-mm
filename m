Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 50B9C6B0031
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 08:26:31 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q58so4504665wes.26
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 05:26:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v11si3345175wjw.166.2014.03.31.05.26.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 05:26:29 -0700 (PDT)
Date: Mon, 31 Mar 2014 13:26:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] x86: use pv-ops in {pte,pmd}_{set,clear}_flags()
Message-ID: <20140331122625.GR25087@suse.de>
References: <1395425902-29817-1-git-send-email-david.vrabel@citrix.com>
 <1395425902-29817-3-git-send-email-david.vrabel@citrix.com>
 <533016CB.4090807@citrix.com>
 <CAKbGBLiVqaHEOZx6y4MW4xDTUdKRhVLZXTTGiqYT7vuH2Wgeww@mail.gmail.com>
 <CA+55aFwEwUmLe+dsFghMcaXdG5LPZ_NcQeOU1zZvEf7rCPw5CQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFwEwUmLe+dsFghMcaXdG5LPZ_NcQeOU1zZvEf7rCPw5CQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>

On Tue, Mar 25, 2014 at 01:16:02PM -0700, Linus Torvalds wrote:
> On Mon, Mar 24, 2014 at 8:31 AM, Steven Noonan <steven@uplinklabs.net> wrote:
> > Vrabel's comments make me think that revisiting the elimination of the
> > _PAGE_NUMA bit implementation would be a good idea... should I CC you
> > on this discussion (not sure if you're subscribed to xen-devel, or if
> > LKML is a better place for that discussion)?
> 
> I detest the PAGE_NUMA games myself, but:
> 

First of all, sorry for the slow response even by my standards. I was at
LSF/MM and Collaboration all last week and it took up all my attention. Today
is my first day back properly online and trawling through the inbox mess.

> From: David Vrabel <david.vrabel@citrix.com>:
> >
> > I really do not understand how you're supposed to distinguish between a
> > PTE for a PROT_NONE page and one with _PAGE_NUMA -- they're identical.
> > i.e., pte_numa() will return true for a PROT_NONE protected page which
> > just seems wrong to me.
> 
> The way to distinguish PAGE_NUMA from PROTNONE is *supposed* to be by
> looking at the vma, and PROTNONE goes together with a vma with
> PROT_NONE. That's what the comments in pgtable_types.h say.
> 

This is the expectation. We did not want to even attempt tracking NUMA
hints on a per-VMA basis because the fault handler would go to hell with
the need to fixup vmas.

> However, as far as I can tell, that is pure and utter bullshit.  It's
> true that generally handle_mm_fault() shouldn't be called for
> PROT_NONE pages, since it will fail the protection checks. However, we
> have FOLL_FORCE that overrides those protection checks for things like
> ptrace etc. So people have tried to convince me that _PAGE_NUMA works,
> but I'm really not at all sure they are right.
> 

For FOLL_FORCE, we do not set FOLL_NUMA in this chunk here

        /*
         * If FOLL_FORCE and FOLL_NUMA are both set, handle_mm_fault
         * would be called on PROT_NONE ranges. We must never invoke
         * handle_mm_fault on PROT_NONE ranges or the NUMA hinting
         * page faults would unprotect the PROT_NONE ranges if
         * _PAGE_NUMA and _PAGE_PROTNONE are sharing the same pte/pmd
         * bitflag. So to avoid that, don't set FOLL_NUMA if
         * FOLL_FORCE is set.
         */
        if (!(gup_flags & FOLL_FORCE))
                gup_flags |= FOLL_NUMA;

Without FOLL_NUMA, we do not do "pmd_numa" checks because they cannot
distinguish between a prot_none and pmd_numa as they use identical bits
on x86. This is in follow_page_mask

        if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
                goto no_page_table;

Without the checks FOLL_FORCE would screw up when it encountered a page
protected for NUMA hinting faults. I recognise that it further muddies
the waters on what _PAGE_NUMA actually means.

A potential alternative would have been to have two pte bits -- _PAGE_NONE
and an unused PTE bit (if there is one) that we'd call_PAGE_NUMA where a
pmd_mknuma sets both. The _PAGE_NONE is what would cause a hinting fault
but we'd use the second bit to distinguish between PROT_NONE and a NUMA
hinting fault. I doubt the end result would be much cleaner though and
it would be a mess.

Another alternative is to simply not allow NUMA_BALANCING on Xen. It's not
even clear what it means as the Xen NUMA topology may or may not correspond
to underlying physical nodes. It's even less clear what happens if both
guest and host use automatic balancing.

> I fundamentally think that it was a horrible horrible disaster to make
> _PAGE_NUMA alias onto _PAGE_PROTNONE.
> 

We did not have much of a choice. We needed something that would trap a
fault and _PAGE_PROTNONE is not available on all architectures. ppc64
reused _PAGE_COHERENT for example.

> But I'm cc'ing the people who tried to convince me otherwise last time
> around, to see if they can articulate this mess better now.
> 
> The argument *seems* to be that if things are truly PROT_NONE, then
> the page will never be touched by page faulting code (and as
> mentioned, I think that argument is fundamentally broken), and if it's
> PROT_NUMA then the page faulting code will magically do the right
> thing.
> 

This is essentially the argument with the addendum that follow_page is
meant to avoid trying pmd_numa checks on FOLL_FORCE.

> FURTHERMORE, the argument was that we can't just call things PROT_NONE
> and just say that "those are the semantics", because on other
> architectures PROT_NONE might mean/do something else.

Or that the equivalent of _PAGE_PROTNONE did not exist and was
implemented by some other means.

> Which really
> makes no sense either, because if the argument was that PROT_NONE
> causes faults that can either be handled as faults (for PROT_NONE) or
> as NUMA issues (for NUMA), then dammit, that argument should be
> completely architecture-independent.
> 
> But I gave up arguing with people. I will state (again) that I think
> this is a f*cking mess, and saying that PROTNONE and NUMA are somehow
> the exact same thing on x86 but not in general is bogus crap. And
> saying that you can determine which it is from the vma is very
> debatable too.
> 

Ok, so how do you suggest that _PAGE_NUMA could have been implemented
that did *not* use _PAGE_PROTNONE on x86, trapped a fault and was not
expensive as hell to handle?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
