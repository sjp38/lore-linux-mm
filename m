Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 024346B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 04:27:35 -0400 (EDT)
Date: Thu, 26 Aug 2010 17:24:38 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/8] hugetlb: add allocate function for hugepage migration
Message-ID: <20100826082438.GV21389@spritzera.linux.bs1.fc.nec.co.jp>
References: <1282694127-14609-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1282694127-14609-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100825012941.GD7283@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100825012941.GD7283@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 25, 2010 at 09:29:41AM +0800, Wu Fengguang wrote:
> > +static struct page *alloc_buddy_huge_page_node(struct hstate *h, int nid)
> > +{
> > +	struct page *page = __alloc_huge_page_node(h, nid);
> >  	if (page) {
> > -		if (arch_prepare_hugepage(page)) {
> > -			__free_pages(page, huge_page_order(h));
> > +		set_compound_page_dtor(page, free_huge_page);
> > +		spin_lock(&hugetlb_lock);
> > +		h->nr_huge_pages++;
> > +		h->nr_huge_pages_node[nid]++;
> > +		spin_unlock(&hugetlb_lock);
> > +		put_page_testzero(page);
> > +	}
> > +	return page;
> > +}
> 
> One would expect the alloc_buddy_huge_page_node() to only differ with
> alloc_buddy_huge_page() in the alloc_pages/alloc_pages_exact_node
> calls. However you implement alloc_buddy_huge_page_node() in a quite
> different way. Can the two functions be unified at all?

Yes. I did it by adding argument @nid to alloc_buddy_huge_page().
Code gets cleaner and work without problems.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
