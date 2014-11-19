Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3476B0038
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 08:02:26 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so1747355wid.12
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 05:02:25 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id n6si2483065wjx.83.2014.11.19.05.02.25
        for <linux-mm@kvack.org>;
        Wed, 19 Nov 2014 05:02:25 -0800 (PST)
Date: Wed, 19 Nov 2014 15:02:14 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 10/19] thp: PMD splitting without splitting compound page
Message-ID: <20141119130214.GB29884@node.dhcp.inet.fi>
References: <1415198994-15252-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1415198994-15252-11-git-send-email-kirill.shutemov@linux.intel.com>
 <20141119065823.GA16887@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141119065823.GA16887@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Nov 19, 2014 at 06:57:47AM +0000, Naoya Horiguchi wrote:
> On Wed, Nov 05, 2014 at 04:49:45PM +0200, Kirill A. Shutemov wrote:
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
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> ...
> 
> > diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
> > index 7e70ae968e5f..e4ba17694b6b 100644
> > --- a/arch/powerpc/mm/hugetlbpage.c
> > +++ b/arch/powerpc/mm/hugetlbpage.c
> > @@ -1022,7 +1022,6 @@ int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
> >  {
> >  	unsigned long mask;
> >  	unsigned long pte_end;
> > -	struct page *head, *page, *tail;
> >  	pte_t pte;
> >  	int refs;
> >  
> 
> This breaks build of powerpc, so you need keep *head and *page as
> you do for other architectures.

Yeah. I've already fixed this localy after 0-DAY kernel testing
complained.

Thanks.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
