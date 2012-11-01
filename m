Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 3197E6B0073
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 06:42:38 -0400 (EDT)
Date: Thu, 1 Nov 2012 10:42:32 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 04/31] x86/mm: Introduce pte_accessible()
Message-ID: <20121101104232.GP3888@suse.de>
References: <20121025121617.617683848@chello.nl>
 <20121025124832.770994193@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121025124832.770994193@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Thu, Oct 25, 2012 at 02:16:21PM +0200, Peter Zijlstra wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> We need pte_present to return true for _PAGE_PROTNONE pages, to indicate that
> the pte is associated with a page.
> 
> However, for TLB flushing purposes, we would like to know whether the pte
> points to an actually accessible page.  This allows us to skip remote TLB
> flushes for pages that are not actually accessible.
> 

It feels like we are putting the cart before the horse to be taking TLB
flushing optimisations into account this early in the series. That
aside, what was wrong with the following patches?

autonuma: define _PAGE_NUMA
	arch-dependant definition of a flag that happens to be PROT_NONE
	on x86 but could be anything at all really which would help portability

autonuma: pte_numa() and pmd_numa()
	makes pte_present do what you want
	adds pte_numa and pmd_numa which potentially could have been
	used instead of pte_accessible

autonuma: teach gup_fast about pmd_numa
	sortof self-explanatory

and building on those? The arch-dependant nature of _PAGE_NUMA might have
avoided Linus sending the childrens college fund to the swear jar and
avoided this complaint;

===
because you have no idea if other architectures do

 (a) the same trick as x86 does for PROT_NONE (I can already tell you
     from a quick grep that ia64, m32r, m68k and sh do it)
 (b) might not perhaps be caching non-present pte's anyway
====

The "autonuma: define _PAGE_NUMA" happens to use PROT_NONE but as an
implementation detail rather than by design and as a bonus point describes
what it is doing. The "autonuma" part in the title is misleading, it's
not autonuma-specific at all and could have been dropped or just renamed
"numa:"

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
