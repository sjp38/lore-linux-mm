Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D54CB6B004A
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 06:17:06 -0400 (EDT)
Date: Thu, 21 Jul 2011 11:17:01 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/2] hugepage: Allow parallelization of the hugepage
 fault path
Message-ID: <20110721101701.GC5212@csn.ul.ie>
References: <20110125143226.37532ea2@kryten>
 <20110125143414.1dbb150c@kryten>
 <20110126092428.GR18984@csn.ul.ie>
 <20110715160650.48d61245@kryten>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110715160650.48d61245@kryten>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: dwg@au1.ibm.com, akpm@linux-foundation.org, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 15, 2011 at 04:06:50PM +1000, Anton Blanchard wrote:
> 
> Hi Mel,
> 
> > I haven't tested this patch yet but typically how I would test it is
> > multiple parallel instances of make func from libhugetlbfs. In
> > particular I would be looking out for counter corruption. Has
> > something like this been done? I know hugetlb_lock protects the
> > counters but the locking in there has turned into a bit of a mess so
> > it's easy to miss something.
> 
> Thanks for the suggestion and sorry for taking so long. Make check has
> the same PASS/FAIL count before and after the patches.
> 
> I also ran 16 copies of make func on a large box with 896 HW threads.
> Some of the tests that use shared memory were a bit upset, but that
> seems to be because we use a static key. It seems the tests were also
> fighting over the number of huge pages they wanted the system set to.
> 
> It got up to a load average of 13207, and heap-overflow consumed all my
> memory, a pretty good effort considering I have over 1TB of it.
> 
> After things settled down things were OK, apart from the fact that we
> have 20 huge pages unaccounted for:
> 
> HugePages_Total:   10000
> HugePages_Free:     9980
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> 
> I verified there were no shared memory segments, and no files in the
> hugetlbfs filesystem (I double checked by unmounting it).
> 
> I can't see how this patch set would cause this. It seems like we can
> leak huge pages, perhaps in an error path. Anyway, I'll repost the
> patch set for comments.
> 

I didn't see any problem with the patch either. The locking should
be functionally equivalent for both private and shared mappings.

Out of curiousity, can you trigger the bug without the patches? It
could be a race on faulting the shared regions that is causing the
leakage.  Any chance this can be debugged minimally by finding out if
this is an accounting bug or if if a hugepage is leaked? Considering
the stress of the machine and its size, I'm guessing it's not trivially
reproducible anywhere else.

I think one possibility of where the bug is is when updating
the hugepage pool size with "make func". This is a scenario that does
not normally occur as hugepage pool resizing is an administrative task
that happens rarely. See this chunk for instance

        spin_lock(&hugetlb_lock);
        if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages) {
                spin_unlock(&hugetlb_lock);
                return NULL;
        } else {
                h->nr_huge_pages++;
                h->surplus_huge_pages++;
        }
        spin_unlock(&hugetlb_lock);

        page = alloc_pages(htlb_alloc_mask|__GFP_COMP|
                                        __GFP_REPEAT|__GFP_NOWARN,
                                        huge_page_order(h));

        if (page && arch_prepare_hugepage(page)) {
                __free_pages(page, huge_page_order(h));
                return NULL;
        }

That thing is not updating the counters if arch_prepare_hugepage fails.
That function is a no-op on powerpc normally. That wasn't changed for
any reason was it?

Another possibility is a regression of
[4f16fc10: mm: hugetlb: fix hugepage memory leak in mincore()] so maybe
try a similar reproduction case of mincore?

Maybe also try putting assert_spin_locked at every point nr_free_pages
or nr_huge_pages is updated and see if one of them triggers?


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
