Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3PK5tFG014628
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 16:05:55 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3PK5t59221722
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 16:05:55 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3PK5iW4016159
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 16:05:45 -0400
Date: Fri, 25 Apr 2008 13:05:32 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 13/18] hugetlb: support boot allocate different sizes
Message-ID: <20080425200532.GC14623@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.027712000@nick.local0.net> <20080425184041.GH9680@us.ibm.com> <481227FF.5000802@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <481227FF.5000802@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 25.04.2008 [20:50:39 +0200], Andi Kleen wrote:
> Nishanth Aravamudan wrote:
> 
> > When would this be the case (the list is already init'd)?
> 
> It can happen inside the series before all the final checks are in
> with multiple arguments. In theory it could be removed at the end,
> but then it doesn't hurt.

Ok, I guess that indicates to me an ordering issue, but perhaps it is
unavoidable.

> >>  	for (i = 0; i < h->max_huge_pages; ++i) {
> >>  		if (h->order >= MAX_ORDER) {
> >> @@ -594,7 +597,7 @@ static void __init hugetlb_init_hstate(s
> >>  		} else if (!alloc_fresh_huge_page(h))
> >>  			break;
> >>  	}
> >> -	h->max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
> >> +	h->max_huge_pages = i;
> > 
> > Why don't we need to set these other values anymore?
> 
> Because the low level functions handle them already (as a simple grep
> would have told you)

[12:36:40]nacc@arkanoid:~/linux/views/linux-2.6-work$ rgrep free_huge_pages *
arch/x86/ia32/ia32entry.S:	.quad quiet_ni_syscall 	/* free_huge_pages */
include/linux/hugetlb.h:	unsigned long free_huge_pages;
include/linux/hugetlb.h:	unsigned int free_huge_pages_node[MAX_NUMNODES];
mm/hugetlb.c: * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
mm/hugetlb.c:	h->free_huge_pages++;
mm/hugetlb.c:	h->free_huge_pages_node[nid]++;
mm/hugetlb.c:			h->free_huge_pages--;
mm/hugetlb.c:			h->free_huge_pages_node[nid]--;
mm/hugetlb.c:			h->free_huge_pages--;
mm/hugetlb.c:			h->free_huge_pages_node[nid]--;
mm/hugetlb.c:	needed = (h->resv_huge_pages + delta) - h->free_huge_pages;
mm/hugetlb.c:	 * because either resv_huge_pages or free_huge_pages may have changed.
mm/hugetlb.c:			(h->free_huge_pages + allocated);
mm/hugetlb.c:			h->free_huge_pages--;
mm/hugetlb.c:			h->free_huge_pages_node[nid]--;
mm/hugetlb.c:	if (h->free_huge_pages > h->resv_huge_pages)
mm/hugetlb.c:			h->free_huge_pages);
mm/hugetlb.c:			h->free_huge_pages--;
mm/hugetlb.c:			h->free_huge_pages_node[page_to_nid(page)]--;
mm/hugetlb.c:	min_count = h->resv_huge_pages + h->nr_huge_pages - h->free_huge_pages;
mm/hugetlb.c:	n += dump_field(buf + n, offsetof(struct hstate, free_huge_pages));
mm/hugetlb.c:						free_huge_pages_node[nid]));
mm/hugetlb.c:		if (delta > cpuset_mems_nr(h->free_huge_pages_node)) {

Hrm, I don't see a single assignment to free_huge_pages there.

grep'ing through the patches from Nick's series, I don't see any there
either (which would indicate I misapplied a patch).

Andi, I'm doing a review of the patches because it is needed (I haven't
seen a comprehensive set of responses yet) and because my work depends
on these patches doing the right thing. I would appreciate it if you
could give me slightly more useful responses -- for instance, the aside
comment in your reply was entirely unnecessary, as grep didn't shed any
insight *and* I am looking at the code in question as I work.  Instead
please try to help me understand the patches.

If I didn't hope differently, I'd believe you don't want me to review
the patches at all.

> > I think it's use should be restricted to the sysctl as much as
> > possible (and the sysctl's should be updated to only do work if
> > write is set).  Does that seem sane to you?
> 
> Fundamental rule of programming: Information should be only kept at a
> single place if possible.

Ok ... I'm tired of reading one-sentence responses that don't answer my
questions and come across as insulting. The current patches duplicate
max_huge_pages *already*. My point was reduction. So if your response
was meant to be

	"Yes, that does seem sane."

then that is all you needed to write. If it was

	"No, that does not seem sane."

that would have been equally fine. But what you wrote has neither a
"yes" nor a "no" in it.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
