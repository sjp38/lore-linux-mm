Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 916CA6B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 16:54:46 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id u82so179187443ywc.0
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 13:54:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x65si6151799ybh.300.2016.09.16.13.54.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 13:54:45 -0700 (PDT)
Date: Fri, 16 Sep 2016 22:54:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm: vma_merge: fix race vm_page_prot race condition
 against rmap_walk
Message-ID: <20160916205441.GB4743@redhat.com>
References: <1473961304-19370-1-git-send-email-aarcange@redhat.com>
 <1473961304-19370-3-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.11.1609161038340.3672@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1609161038340.3672@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Vorlicek <janvorli@microsoft.com>, Aditya Mandaleeka <adityam@microsoft.com>

On Fri, Sep 16, 2016 at 11:42:34AM -0700, Hugh Dickins wrote:
> >  	if (next && !insert) {
> > -		struct vm_area_struct *exporter = NULL, *importer = NULL;
> > +		struct vm_area_struct *exporter = NULL;
> >  
> >  		if (end >= next->vm_end) {
> >  			/*
> > @@ -729,6 +730,17 @@ again:
> >  			vma_interval_tree_remove(next, root);
> >  	}
> >  
> > +	if (importer == vma) {
> > +		/*
> > +		 * vm_page_prot and vm_flags can be read by the
> > +		 * rmap_walk, for example in
> > +		 * remove_migration_ptes(). Before releasing the rmap
> > +		 * locks the current vma must match the next that we
> > +		 * merged with for those fields.
> > +		 */
> > +		importer->vm_page_prot = next->vm_page_prot;
> > +		importer->vm_flags = next->vm_flags;
> > +	}
> 
> To take a concrete example for my doubt, "importer == vma" includes
> case 5 (see the diagrams above vma_merge()), but this then copies
> protections and flags from N to P ("P" being "vma" here), doesn't it?
> 
> Which would not be right, unless I'm confused - which is also very
> much possible.

I start to think it may be cleaner to pass the "vma" to copy the
protections from, as parameter of vma_adjust. I'll try without first,
but it'll add up to the knowledge of the caller details. At least this
code isn't changing often.

> For the moment I'm throwing this back to you without thinking more
> carefully about it, and assuming that either you'll come back with
> a new patch, or will point out my confusion.  But if you'd prefer
> me to take it over, do say so - you have the advantage of youth,
> I have the advantage of having written this code a long time ago,
> I'm not sure which of us is ahead :)

Up to you, we've been playing with this for days (most time spent
actually on NUMA/THP code until I figured it was something completely
different than initially though) so I've no problem in updating this
quick and testing it.

> Is it perhaps just case 8 (see "Odd one out" comment) that's a problem?

Case 8 is the one triggering the bug yes. And that got fixed 100% by
the patch. Unfortunately I agree I'm shifting the issue to case 5 and
so an update of this patch is in order...

> But I'm also worried about whether we shall need to try harder in the
> "remove_next == 2" case (I think that's case 6 in the diagrams): where
> for a moment vma_adjust() drops the locks with overlapping vmas in the
> tree, which the "goto again" goes back to clean up.  I don't know if
> the interval tree gives any guarantee of which of those overlapping
> vmas would be found first in lookup, nor whether it could actually
> trigger a problem with page migration.  But I suspect that for safety
> we shall need to enforce the same protections on the next->next which
> will be removed a moment later.  Ah, no, it must *already* have the
> same protections, if it's about to be merged out of existence: so I
> think I was making up a problem where there is none, but please check.

I think you're right the temporary release of the locks would be a
problem, it's a corollary of case 5 issue above.

I attempted a quick update for further review (beware,
untested). Tomorrow I'll test it and let you know how it goes after
thinking more about it...
