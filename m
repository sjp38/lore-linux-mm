Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 046516B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 06:50:37 -0500 (EST)
Date: Tue, 13 Nov 2012 11:50:32 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 08/19] mm: numa: Create basic numa page hinting
 infrastructure
Message-ID: <20121113115032.GY8218@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-9-git-send-email-mgorman@suse.de>
 <20121113102120.GD21522@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121113102120.GD21522@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 13, 2012 at 11:21:20AM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > Note: This patch started as "mm/mpol: Create special PROT_NONE
> > 	infrastructure" and preserves the basic idea but steals *very*
> > 	heavily from "autonuma: numa hinting page faults entry points" for
> > 	the actual fault handlers without the migration parts.	The end
> > 	result is barely recognisable as either patch so all Signed-off
> > 	and Reviewed-bys are dropped. If Peter, Ingo and Andrea are ok with
> > 	this version, I will re-add the signed-offs-by to reflect the history.
> 
> Most of the changes you had to do here relates to the earlier 
> decision to turn it all the NUMA protection fault demultiplexing 
> and setup code into a per arch facility.
> 

Yes.

> On one hand I'm 100% fine with making the decision to *use* the 
> new NUMA code per arch and explicitly opt-in - we already have 
> such a Kconfig switch in our tree already. The decision whether 
> to use any of this for an architecture must be considered and 
> tested carefully.
> 

Agreed.

> But given that most architectures will be just fine reusing the 
> already existing generic PROT_NONE machinery, the far better 
> approach is to do what we've been doing in generic kernel code 
> for the last 10 years: offer a default generic version, and then 
> to offer per arch hooks on a strict as-needed basis, if they 
> want or need to do something weird ...
> 

If they are *not* fine with it, it's a large retrofit because the PROT_NONE
machinery has been hard-coded throughout. It also requires that anyone
looking at the fault paths must remember at almost all times that PROT_NONE
can also mean PROT_NUMA and it depends on context. While that's fine right
now, it'll be harder to maintain in the future.

> So why fork away this logic into per arch code so early and 
> without explicit justification? It creates duplication artifacts 
> all around and makes porting to a new 'sane' architecture 
> harder.
> 

I agree that the duplication artifacts was a mistake. I can fix that but
feel that the naming is fine and we shouldn't hard-code that
change_prot_none() can actually mean change_prot_numa() if called from
the right place.

> Also, if there *are* per architecture concerns then I'd very 
> much like to see that argued very explicitly, on a per arch 
> basis, as it occurs, not obscured through thick "just in case" 
> layers of abstraction ...
> 

Once there is a generic pte_numa handler for example, an arch-specific
overriding of it should raise a red flag for closer inspection.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
