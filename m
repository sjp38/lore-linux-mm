Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id F2EB96B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:03:55 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j28so11533243wrd.17
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 05:03:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k25si22471edk.507.2018.03.13.05.03.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 05:03:54 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2DC3nOr137279
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:03:52 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gpd5n3ejd-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:03:50 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <imbrenda@linux.vnet.ibm.com>;
	Tue, 13 Mar 2018 12:03:42 -0000
Date: Tue, 13 Mar 2018 13:03:36 +0100
From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: Re: [PATCH v1 1/1] mm/ksm: fix interaction with THP
In-Reply-To: <20180312142210.4e664519118369d5d129e6dc@linux-foundation.org>
References: <1520872937-15351-1-git-send-email-imbrenda@linux.vnet.ibm.com>
	<20180312142210.4e664519118369d5d129e6dc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20180313130336.3afb8789@p-imbrenda.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, aarcange@redhat.com, minchan@kernel.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, hughd@google.com, borntraeger@de.ibm.com, gerald.schaefer@de.ibm.com

On Mon, 12 Mar 2018 14:22:10 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 12 Mar 2018 17:42:17 +0100 Claudio Imbrenda
> <imbrenda@linux.vnet.ibm.com> wrote:
> 
> > This patch fixes a corner case for KSM. When two pages belong or
> > belonged to the same transparent hugepage, and they should be
> > merged, KSM fails to split the page, and therefore no merging
> > happens.
> > 
> > This bug can be reproduced by:
> > * making sure ksm is running (in case disabling ksmtuned)
> > * enabling transparent hugepages
> > * allocating a THP-aligned 1-THP-sized buffer
> >   e.g. on amd64: posix_memalign(&p, 1<<21, 1<<21)
> > * filling it with the same values
> >   e.g. memset(p, 42, 1<<21)
> > * performing madvise to make it mergeable
> >   e.g. madvise(p, 1<<21, MADV_MERGEABLE)
> > * waiting for KSM to perform a few scans
> > 
> > The expected outcome is that the all the pages get merged (1 shared
> > and the rest sharing); the actual outcome is that no pages get
> > merged (1 unshared and the rest volatile)
> > 
> > The reason of this behaviour is that we increase the reference count
> > once for both pages we want to merge, but if they belong to the same
> > hugepage (or compound page), the reference counter used in both
> > cases is the one of the head of the compound page.
> > This means that split_huge_page will find a value of the reference
> > counter too high and will fail.
> > 
> > This patch solves this problem by testing if the two pages to merge
> > belong to the same hugepage when attempting to merge them. If so,
> > the hugepage is split safely. This means that the hugepage is not
> > split if not necessary.
> > 
> > Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> > Signed-off-by: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>  
> 
> Signoff trail is confusing.  Usually people put the primary author's
> signoff first, which makes me wonder whether you or Gerald was the
> primary author?

we literally wrote it together; I'll change Gerald's Signoff tag with a
Co-authored one, since he doesn't really have the time to follow this
patch

> > diff --git a/mm/ksm.c b/mm/ksm.c
> > index 293721f..7a826fa 100644
> > --- a/mm/ksm.c
> > +++ b/mm/ksm.c
> > @@ -2001,7 +2001,7 @@ static void cmp_and_merge_page(struct page
> > *page, struct rmap_item *rmap_item) struct page *kpage;
> >  	unsigned int checksum;
> >  	int err;
> > -	bool max_page_sharing_bypass = false;
> > +	bool split, max_page_sharing_bypass = false;  
> 
> `split' could be made local to the `if' block where it is used, which
> improves readability and maintainability somewhat.

will fix

> >  	stable_node = page_stable_node(page);
> >  	if (stable_node) {
> > @@ -2084,6 +2084,8 @@ static void cmp_and_merge_page(struct page
> > *page, struct rmap_item *rmap_item) if (tree_rmap_item) {
> >  		kpage = try_to_merge_two_pages(rmap_item, page,
> >  						tree_rmap_item,
> > tree_page);
> > +		split = PageTransCompound(page) &&
> > PageTransCompound(tree_page)
> > +			&& compound_head(page) ==
> > compound_head(tree_page);  
> 
> I think a comment explainig what's going on would be useful here.

will add
 
> >  		put_page(tree_page);
> >  		if (kpage) {
> >  			/*
> > @@ -2110,6 +2112,11 @@ static void cmp_and_merge_page(struct page
> > *page, struct rmap_item *rmap_item) break_cow(tree_rmap_item);
> >  				break_cow(rmap_item);
> >  			}
> > +		} else if (split) {
> > +			if (!trylock_page(page))
> > +				return;
> > +			split_huge_page(page);
> > +			unlock_page(page);  
> 
> Why did we use trylock_page()?  Perhaps for the same reasons which
> were explained in try_to_merge_one_page(), perhaps for other reasons. 

yes, that was our idea.

> cmp_and_merge_page() already does lock_page() and down_read(), so I
> wonder if those reasons are legitimate.

since the new code splits the page but doesn't actually merge it, we
thought it was better not to add the cost of a full lock. The full
locks in the rest of the function are only taken when there is
good probability or certainty that the lock will bring benefits.

> Again, a comment here is needed - otherwise it will be hard for
> readers to understand your intent.

I'll add a comment to clarify why we use trylock.
 
> >  		}
> >  	}
> >  }  
