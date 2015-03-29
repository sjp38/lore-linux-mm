Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id C4EFC6B0082
	for <linux-mm@kvack.org>; Sun, 29 Mar 2015 13:42:41 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so96084657wib.1
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 10:42:41 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id u2si13812615wju.72.2015.03.29.10.42.39
        for <linux-mm@kvack.org>;
        Sun, 29 Mar 2015 10:42:40 -0700 (PDT)
Date: Sun, 29 Mar 2015 20:42:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 12/24] thp: PMD splitting without splitting compound
 page
Message-ID: <20150329174223.GA976@node.dhcp.inet.fi>
References: <1425486792-93161-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1425486792-93161-13-git-send-email-kirill.shutemov@linux.intel.com>
 <87ego7n6ha.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ego7n6ha.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Mar 29, 2015 at 09:25:29PM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> 
> > Current split_huge_page() combines two operations: splitting PMDs into
> > tables of PTEs and splitting underlying compound page. This patch
> > changes split_huge_pmd() implementation to split the given PMD without
> > splitting other PMDs this page mapped with or underlying compound page.
> >
> > In order to do this we have to get rid of tail page refcounting, which
> > uses _mapcount of tail pages. Tail page refcounting is needed to be able
> > to split THP page at any point: we always know which of tail pages is
> > pinned (i.e. by get_user_pages()) and can distribute page count
> > correctly.
> >
> > We can avoid this by allowing split_huge_page() to fail if the compound
> > page is pinned. This patch removes all infrastructure for tail page
> > refcounting and make split_huge_page() to always return -EBUSY. All
> > split_huge_page() users already know how to handle its fail. Proper
> > implementation will be added later.
> >
> > Without tail page refcounting, implementation of split_huge_pmd() is
> > pretty straight-forward.
> >
> > Memory cgroup is not yet ready for new refcouting. Let's disable it on
> > Kconfig level.
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> .....
> .....
> 
> >  static inline int page_mapped(struct page *page)
> >  {
> > -	return atomic_read(&(page)->_mapcount) + compound_mapcount(page) >= 0;
> > +	int i;
> > +	if (likely(!PageCompound(page)))
> > +		return atomic_read(&page->_mapcount) >= 0;
> > +	if (compound_mapcount(page))
> > +		return 1;
> > +	for (i = 0; i < hpage_nr_pages(page); i++) {
> > +		if (atomic_read(&page[i]._mapcount) >= 0)
> > +			return 1;
> > +	}
> 
> do we need to loop with head page here ? ie,

We do need to loop if we have only tail pages mapped. Partial unmap case.

> 
> page = compound_page(page);

compound_head() ?

This function expects to see head page on input. I'll put VM_BUG_ON()
there to make sure we don't call it tail pages.

> > +	return 0;
> >  }

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
