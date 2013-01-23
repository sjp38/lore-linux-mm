Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 33B706B0009
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 08:17:12 -0500 (EST)
Date: Wed, 23 Jan 2013 13:17:13 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/6] mm: Fold page->_last_nid into page->flags where
 possible
Message-ID: <20130123131713.GG13304@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
 <1358874762-19717-6-git-send-email-mgorman@suse.de>
 <20130122144659.d512e05c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130122144659.d512e05c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 22, 2013 at 02:46:59PM -0800, Andrew Morton wrote:
> On Tue, 22 Jan 2013 17:12:41 +0000
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > 
> > page->_last_nid fits into page->flags on 64-bit. The unlikely 32-bit NUMA
> > configuration with NUMA Balancing will still need an extra page field.
> > As Peter notes "Completely dropping 32bit support for CONFIG_NUMA_BALANCING
> > would simplify things, but it would also remove the warning if we grow
> > enough 64bit only page-flags to push the last-cpu out."
> 
> How much space remains in the 64-bit page->flags?
> 

Good question.

There are 19 free bits in my configuration but it's related to
CONFIG_NODES_SHIFT which is 9 for me (512 nodes) and very heavily affected
by options such as CONFIG_SPARSEMEM_VMEMMAP. Memory hot-remove does not work
with CONFIG_SPARSEMEM_VMEMMAP and enterprise distribution configs may be
taking the performance hit to enable memory hot-remove. If I disable this
option to enable memory hot-remove then there are 0 free bits in page->flags.

Your milage will vary *considerably*.

In answering this question I remembered that mminit_loglevel is able to
answer these sort of questions but only if it's updated properly. I'll
post a follow-up patch.

> Was this the best possible use of the remaining space?
> 

Another good question and I do not have a good answer. There is a definite
cost to having a larger struct page on large memory systems. The benefit
to saving flags on 64-bit page->flags for potential future use is more
intangiable.

> It's good that we can undo this later by flipping
> LAST_NID_NOT_IN_PAGE_FLAGS.
> 

Yes and it generates a dirty warning if it's forced to use
LAST_NID_NOT_IN_PAGE_FLAGS.

> > [mgorman@suse.de: Minor modifications]
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Several of these patches are missing signoffs (Peter and Hugh).
> 

In the case of Peter's patches, they changed enough that I couldn't preserve
the signed-off-by. This happened for the NUMA balancing patches too. I
preserved the "From" and I'm hoping he'll respond to add his Signed-off-by
to these patches if he's ok with them.

In Hugh's case he did not add his signed-off-by because he was not sure
whether there was a gremlin hidden in there. If there is, I was not able
to find it. It's up to him whether he wants to put his signed-off-by on
it but I preserved the "From:".

> >
> > ...
> >
> > +static inline int page_last_nid(struct page *page)
> > +{
> > +	return (page->flags >> LAST_NID_PGSHIFT) & LAST_NID_MASK;
> > +}
> > +
> > +static inline int page_xchg_last_nid(struct page *page, int nid)
> > +{
> > +	unsigned long old_flags, flags;
> > +	int last_nid;
> > +
> > +	do {
> > +		old_flags = flags = page->flags;
> > +		last_nid = page_last_nid(page);
> > +
> > +		flags &= ~(LAST_NID_MASK << LAST_NID_PGSHIFT);
> > +		flags |= (nid & LAST_NID_MASK) << LAST_NID_PGSHIFT;
> > +	} while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags));
> > +
> > +	return last_nid;
> > +}
> > +
> > +static inline void reset_page_last_nid(struct page *page)
> > +{
> > +	page_xchg_last_nid(page, (1 << LAST_NID_SHIFT) - 1);
> > +}
> 
> page_xchg_last_nid() and reset_page_last_nid() are getting nuttily
> large.  Please investigate uninlining them?
> 

Will do.

> reset_page_last_nid() is poorly named.  page_reset_last_nid() would be
> better, and consistent.
> 

Will fix.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
