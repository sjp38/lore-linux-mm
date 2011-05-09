Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 542AA6B0022
	for <linux-mm@kvack.org>; Mon,  9 May 2011 15:39:29 -0400 (EDT)
Date: Mon, 9 May 2011 15:39:16 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH 3/8] mm: remove MPOL_MF_STATS
Message-ID: <20110509193916.GB2865@wicker.gateway.2wire.net>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca>
 <1303947349-3620-4-git-send-email-wilsons@start.ca>
 <20110509164609.1657.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110509164609.1657.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Stephen Wilson <wilsons@start.ca>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 09, 2011 at 04:44:24PM +0900, KOSAKI Motohiro wrote:
> > Mapping statistics in a NUMA environment is now computed using the
> > generic walk_page_range() logic.  Remove the old/equivalent
> > functionality.
> > 
> > Signed-off-by: Stephen Wilson <wilsons@start.ca>
> > ---
> >  mm/mempolicy.c |   10 ++++++----
> >  1 files changed, 6 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index dfe27e3..63c0d69 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -99,7 +99,6 @@
> >  /* Internal flags */
> >  #define MPOL_MF_DISCONTIG_OK (MPOL_MF_INTERNAL << 0)	/* Skip checks for continuous vmas */
> >  #define MPOL_MF_INVERT (MPOL_MF_INTERNAL << 1)		/* Invert check for nodemask */
> > -#define MPOL_MF_STATS (MPOL_MF_INTERNAL << 2)		/* Gather statistics */
> >  
> >  static struct kmem_cache *policy_cache;
> >  static struct kmem_cache *sn_cache;
> > @@ -492,9 +491,7 @@ static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> >  		if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
> >  			continue;
> >  
> > -		if (flags & MPOL_MF_STATS)
> > -			gather_stats(page, private, pte_dirty(*pte));
> > -		else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> > +		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> >  			migrate_page_add(page, private, flags);
> >  		else
> >  			break;
> 
> This hunk looks good to me.
> 
> 
> > @@ -2572,6 +2569,7 @@ static int gather_pte_stats(pte_t *pte, unsigned long addr,
> >  		unsigned long pte_size, struct mm_walk *walk)
> >  {
> >  	struct page *page;
> > +	int nid;
> >  
> >  	if (pte_none(*pte))
> >  		return 0;
> > @@ -2580,6 +2578,10 @@ static int gather_pte_stats(pte_t *pte, unsigned long addr,
> >  	if (!page)
> >  		return 0;
> >  
> > +	nid = page_to_nid(page);
> > +	if (!node_isset(nid, node_states[N_HIGH_MEMORY]))
> > +		return 0;
> > +
> >  	gather_stats(page, walk->private, pte_dirty(*pte));
> >  	return 0;
> 
> However this hunk should be moved into patch [2/8]. because 1) keeping
> bisectability 2) The description says "Remove the old/equivalent
> functionality." but it added new functionality.

Absolutely.  Will move into the proper location and resend the whole
series.

Thanks again,

-- 
steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
