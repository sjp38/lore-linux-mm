Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F41D6B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 04:32:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 187so79594wmn.2
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 01:32:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b123sor216763wme.50.2017.09.13.01.32.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Sep 2017 01:32:42 -0700 (PDT)
Date: Wed, 13 Sep 2017 10:32:34 +0200
From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: Re: [PATCH] mm, hugetlb, soft_offline: save compound page order
 before page migration
Message-ID: <20170913083233.GA7659@gmail.com>
References: <20170912204306.GA12053@gmail.com>
 <20170913001308.GA13642@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170913001308.GA13642@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "minchan@kernel.org" <minchan@kernel.org>, "hillf.zj@alibaba-inc.com" <hillf.zj@alibaba-inc.com>, "shli@fb.com" <shli@fb.com>, "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "rientjes@google.com" <rientjes@google.com>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Sep 13, 2017 at 12:13:09AM +0000, Naoya Horiguchi wrote:
> Hi Alexandru,
> 
> On Tue, Sep 12, 2017 at 10:43:06PM +0200, Alexandru Moise wrote:
> > This fixes a bug in madvise() where if you'd try to soft offline a
> > hugepage via madvise(), while walking the address range you'd end up,
> > using the wrong page offset due to attempting to get the compound
> > order of a former but presently not compound page, due to dissolving
> > the huge page (since c3114a8).
> > 
> > Signed-off-by: Alexandru Moise <00moses.alexander00@gmail.com>
> 
> There was a similar discussion in https://marc.info/?l=linux-kernel&m=150354919510631&w=2
> over thp. As I stated there, if we give multi-page range into the parameters
> [start, end), we expect that memory errors are injected to every single page
> within the range. 

At the moment we'll end up offlining the i'th subpage of the newly migrated page with
each itteration. That's why I end up without free pages in hugetlbfs.

With this patch we migrate the hugepage, offline 1 subpage and dissolve the rest,
which is closer to how mcelog should behave, mcelog will usually try to offline random
spots within a hugepage, not offline a whole hugepage at once, which doesn't make
sense as you usually just get 1-2 stuck bits on your DIMM. The whole point of soft
offlining is as a preventive measure against large number of correctable memory
errors on a particular page.

I agree that if we give a range we should expect all the subpages to be offlined
although I don't know what value that would add.

> 
> So I start to feel that we should revert the following patch which introduced
> the multi-page stepping.
> 
>    commit 20cb6cab52a21b46e3c0dc7bd23f004f810fb421
>    Author: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>    Date:   Mon Sep 30 13:45:21 2013 -0700
>    
>        mm/hwpoison: fix traversal of hugetlbfs pages to avoid printk flood
> 
> In order to suppress the printk flood, we can use ratelimit mechanism, or
> just s/pr_info/pr_debug/ might be ok.

I'd rather keep the printouts, it's not really that much of a hot path, if
they went on forever sure, but if you manually offline 512 pages you should expect
512 printouts. It's nice to see exactly which PFNs get offlined as well.

../Alex

> 
> Thanks,
> Naoya Horiguchi
> 
> > ---
> >  mm/madvise.c | 12 ++++++++++--
> >  1 file changed, 10 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 21261ff0466f..25bade36e9ca 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -625,18 +625,26 @@ static int madvise_inject_error(int behavior,
> >  {
> >  	struct page *page;
> >  	struct zone *zone;
> > +	unsigned int order;
> >  
> >  	if (!capable(CAP_SYS_ADMIN))
> >  		return -EPERM;
> >  
> > -	for (; start < end; start += PAGE_SIZE <<
> > -				compound_order(compound_head(page))) {
> > +
> > +	for (; start < end; start += PAGE_SIZE << order) {
> >  		int ret;
> >  
> >  		ret = get_user_pages_fast(start, 1, 0, &page);
> >  		if (ret != 1)
> >  			return ret;
> >  
> > +		/*
> > +		 * When soft offlining hugepages, after migrating the page
> > +		 * we dissolve it, therefore in the second loop "page" will
> > +		 * no longer be a compound page, and order will be 0.
> > +		 */
> > +		order = compound_order(compound_head(page));
> > +
> >  		if (PageHWPoison(page)) {
> >  			put_page(page);
> >  			continue;
> > -- 
> > 2.14.1
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
