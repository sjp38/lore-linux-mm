Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0A17C6B0032
	for <linux-mm@kvack.org>; Sat, 17 Jan 2015 02:16:13 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id wp18so1379291obc.3
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 23:16:12 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id x71si3737141oie.3.2015.01.16.23.16.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 23:16:11 -0800 (PST)
Message-ID: <1421478959.4903.1.camel@stgolabs.net>
Subject: Re: [PATCH V3] mm/thp: Allocate transparent hugepages on local node
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Fri, 16 Jan 2015 23:15:59 -0800
In-Reply-To: <20150116160204.544e2bcf9627f5a4043ebf8d@linux-foundation.org>
References: 
	<1421393196-20915-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20150116160204.544e2bcf9627f5a4043ebf8d@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A.
 Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2015-01-16 at 16:02 -0800, Andrew Morton wrote:
> On Fri, 16 Jan 2015 12:56:36 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> > This make sure that we try to allocate hugepages from local node if
> > allowed by mempolicy. If we can't, we fallback to small page allocation
> > based on mempolicy. This is based on the observation that allocating pages
> > on local node is more beneficial than allocating hugepages on remote node.
> 
> The changelog is a bit incomplete.  It doesn't describe the current
> behaviour, nor what is wrong with it.  What are the before-and-after
> effects of this change?
> 
> And what might be the user-visible effects?

I'd be interested in any performance data. I'll run this by a 4 node box
next week.

> 
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -2030,6 +2030,46 @@ retry_cpuset:
> >  	return page;
> >  }
> >  
> > +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
> > +				unsigned long addr, int order)
> 
> alloc_pages_vma() is nicely documented.  alloc_hugepage_vma() is not
> documented at all.  This makes it a bit had for readers to work out the
> difference!
> 
> Is it possible to scrunch them both into the same function?  Probably
> too messy?
> 
> > +{
> > +	struct page *page;
> > +	nodemask_t *nmask;
> > +	struct mempolicy *pol;
> > +	int node = numa_node_id();
> > +	unsigned int cpuset_mems_cookie;
> > +
> > +retry_cpuset:
> > +	pol = get_vma_policy(vma, addr);
> > +	cpuset_mems_cookie = read_mems_allowed_begin();
> > +
> > +	if (pol->mode != MPOL_INTERLEAVE) {
> > +		/*
> > +		 * For interleave policy, we don't worry about
> > +		 * current node. Otherwise if current node is
> > +		 * in nodemask, try to allocate hugepage from
> > +		 * current node. Don't fall back to other nodes
> > +		 * for THP.
> > +		 */
> 
> This code isn't "interleave policy".  It's everything *but* interleave
> policy.  Comment makes no sense!

May I add that, while a nit, this indentation is quite ugly:

> 
> > +		nmask = policy_nodemask(gfp, pol);
> > +		if (!nmask || node_isset(node, *nmask)) {
> > +			mpol_cond_put(pol);
> > +			page = alloc_pages_exact_node(node, gfp, order);
> > +			if (unlikely(!page &&
> > +				     read_mems_allowed_retry(cpuset_mems_cookie)))
> > +				goto retry_cpuset;
> > +			return page;
> > +		}
> > +	}

Improving it makes the code visually easier on the eye. So this should
be considered if another re-spin of the patch is to be done anyway. Just
jump to the mpol refcounting and be done when 'pol->mode ==
MPOL_INTERLEAVE'.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
