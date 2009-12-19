Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 646676B0044
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 10:28:23 -0500 (EST)
Date: Sat, 19 Dec 2009 16:27:48 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 10 of 28] add pmd mangling functions to x86
Message-ID: <20091219152748.GY29790@random.random>
References: <patchbomb.1261076403@v2.random>
 <a77787d44f25abf69338.1261076413@v2.random>
 <20091218185602.GD21194@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091218185602.GD21194@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 18, 2009 at 06:56:02PM +0000, Mel Gorman wrote:
> (As a side-note, I am going off-line until after the new years fairly soon.
> I'm not doing a proper review at the moment, just taking a first read to
> see what's here. Sorry I didn't get a chance to read V1)

Not reading v1 means less wasted time for you, as I did lot of
polishing as result of the previous reviews, so no problem ;).

> On Thu, Dec 17, 2009 at 07:00:13PM -0000, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Add needed pmd mangling functions with simmetry with their pte counterparts.
> 
> Silly question, this assumes the bits used in the PTE are not being used in
> the PMD for something else, right? Is that guaranteed to be safe? According
> to the AMD manual, it's fine but is it typically true on other architectures?

I welcome people to double check with intel/amd manuals, but it's not
like I added those functions blindly hoping they would work ;),
luckily there's no intel/amd difference here because this stuff even
works on 32bit dinosaurs since PSE was added.

> > diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> > --- a/arch/x86/mm/pgtable.c
> > +++ b/arch/x86/mm/pgtable.c
> > @@ -288,6 +288,23 @@ int ptep_set_access_flags(struct vm_area
> >  	return changed;
> >  }
> >  
> > +int pmdp_set_access_flags(struct vm_area_struct *vma,
> > +			  unsigned long address, pmd_t *pmdp,
> > +			  pmd_t entry, int dirty)
> > +{
> > +	int changed = !pmd_same(*pmdp, entry);
> > +
> > +	VM_BUG_ON(address & ~HPAGE_MASK);
> > +
> 
> On the use of HPAGE_MASK, did you intend to use the PMD mask? Granted,
> it works out as being the same thing in this context but if there is
> ever support for 1GB pages at the next page table level, it could get
> confusing.

That's a very good question but it's not about the above only. I've
always been undecided if to use HPAGE_MASK or the pmd mask. I've no
clue what is better. I think as long as I use HPAGE_MASK all over
huge_memory.c this also should be an HPAGE_MASK. If we were to support
more levels (something not feasible with 1G as the whole point of this
feature is to be transparent and transparently 1G pages will never
come, even 2M is hard) I would expect all those HPAGE_MASK to be
replaced by something else.

If people thinks I should drop HPAGE_MASK as a whole and replace it
with PMD based masks let me know.. doing it only above and leave
HPAGE_MASK elsewhere is no-way IMHO. Personally I find more intuitive
HPAGE_MASK but it clearly matches the pmd mask as it gets mapped by a
pmd entry ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
