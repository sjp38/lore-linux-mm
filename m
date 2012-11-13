Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 46B046B007D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 09:26:41 -0500 (EST)
Date: Tue, 13 Nov 2012 14:26:34 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/19] mm: numa: Create basic numa page hinting
 infrastructure
Message-ID: <20121113142634.GC8218@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-9-git-send-email-mgorman@suse.de>
 <20121113102120.GD21522@gmail.com>
 <20121113115032.GY8218@suse.de>
 <20121113134910.GB17782@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121113134910.GB17782@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 13, 2012 at 02:49:10PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > > But given that most architectures will be just fine reusing 
> > > the already existing generic PROT_NONE machinery, the far 
> > > better approach is to do what we've been doing in generic 
> > > kernel code for the last 10 years: offer a default generic 
> > > version, and then to offer per arch hooks on a strict 
> > > as-needed basis, if they want or need to do something weird 
> > > ...
> > 
> > If they are *not* fine with it, it's a large retrofit because 
> > the PROT_NONE machinery has been hard-coded throughout. [...]
> 
> That was a valid criticism for earlier versions of the NUMA 
> patches - but should much less be the case in the latest 
> iterations of the patches:
> 

Which are where? They are possible somewhere in -tip, maybe the
tip/numa/core but I am seeing this;

$ git diff e657e078d3dfa9f96976db7a2b5fd7d7c9f1f1a6..tip/numa/core | grep change_prot_none
+change_prot_none(struct vm_area_struct *vma, unsigned long start, unsigned long end)
+		change_prot_none(vma, offset, end);
+			change_prot_none(vma, start, endvma);

This is being called from task_numa_work() for example so it's case where
the maintainer has to memember that prot_none actually means prot_numa in
this case. Further, the generic implementation of pte_numa is hard-coding
prot_none

+static bool pte_numa(struct vm_area_struct *vma, pte_t pte)
+{
.......
+       if (pte_same(pte, pte_modify(pte, vma->vm_page_prot)))
+               return false;
+
+       return pte_same(pte, pte_modify(pte, vma_prot_none(vma)));
+}

I can take the structuring idea of moving pte_numa around but it still
should have the _PAGE_NUMA naming. So it still looks to me as the PROT_NONE
machine is hard-coded.

>  - it has generic pte_numa() / pmd_numa() instead of using
>    prot_none() directly
> 

I intend to move the pte_numa out myself.

>  - the key utility functions are named using the _numa pattern,
>    not *_prot_none*() anymore.
> 

Where did change_prot_none() come from then?

> Let us know if you can still see such instances - it's probably 
> simple oversight.
> 

I could be lookjing at the wrong tip branch. Please post the full series
to the list so it can be reviewed that way instead of trying to second
guess.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
