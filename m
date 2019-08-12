Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0F2EC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 20:46:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 993CA20684
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 20:46:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 993CA20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 365926B0008; Mon, 12 Aug 2019 16:46:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 316776B000A; Mon, 12 Aug 2019 16:46:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 204D36B000C; Mon, 12 Aug 2019 16:46:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0011.hostedemail.com [216.40.44.11])
	by kanga.kvack.org (Postfix) with ESMTP id EC4C16B0008
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:46:36 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 9AB572C8F
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 20:46:36 +0000 (UTC)
X-FDA: 75814959192.28.toy17_73bc4ccf22417
X-HE-Tag: toy17_73bc4ccf22417
X-Filterd-Recvd-Size: 9451
Received: from mga14.intel.com (mga14.intel.com [192.55.52.115])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 20:46:35 +0000 (UTC)
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Aug 2019 13:46:33 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,378,1559545200"; 
   d="scan'208";a="177592713"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga007.fm.intel.com with ESMTP; 12 Aug 2019 13:46:33 -0700
Date: Mon, 12 Aug 2019 13:46:33 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, Michal Hocko <mhocko@suse.com>,
	Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 12/19] mm/gup: Prep put_user_pages() to take an
 vaddr_pin struct
Message-ID: <20190812204633.GB20634@iweiny-DESK2.sc.intel.com>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-13-ira.weiny@intel.com>
 <12b6a576-7a64-102c-f4d7-7a4ad34df710@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <12b6a576-7a64-102c-f4d7-7a4ad34df710@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 05:30:00PM -0700, John Hubbard wrote:
> On 8/9/19 3:58 PM, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> > 
> > Once callers start to use vaddr_pin the put_user_pages calls will need
> > to have access to this data coming in.  Prep put_user_pages() for this
> > data.
> > 
> > Signed-off-by: Ira Weiny <ira.weiny@intel.com>

[snip]

> > diff --git a/mm/gup.c b/mm/gup.c
> > index a7a9d2f5278c..10cfd30ff668 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -24,30 +24,41 @@
> >  
> >  #include "internal.h"
> >  
> > -/**
> > - * put_user_pages_dirty_lock() - release and optionally dirty gup-pinned pages
> > - * @pages:  array of pages to be maybe marked dirty, and definitely released.
> 
> A couple comments from our circular review chain: some fellow with the same
> last name as you, recommended wording it like this:
> 
>       @pages:  array of pages to be put

Sure, see below...

> 
> > - * @npages: number of pages in the @pages array.
> > - * @make_dirty: whether to mark the pages dirty
> > - *
> > - * "gup-pinned page" refers to a page that has had one of the get_user_pages()
> > - * variants called on that page.
> > - *
> > - * For each page in the @pages array, make that page (or its head page, if a
> > - * compound page) dirty, if @make_dirty is true, and if the page was previously
> > - * listed as clean. In any case, releases all pages using put_user_page(),
> > - * possibly via put_user_pages(), for the non-dirty case.
> > - *
> > - * Please see the put_user_page() documentation for details.
> > - *
> > - * set_page_dirty_lock() is used internally. If instead, set_page_dirty() is
> > - * required, then the caller should a) verify that this is really correct,
> > - * because _lock() is usually required, and b) hand code it:
> > - * set_page_dirty_lock(), put_user_page().
> > - *
> > - */
> > -void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
> > -			       bool make_dirty)
> > +static void __put_user_page(struct vaddr_pin *vaddr_pin, struct page *page)
> > +{
> > +	page = compound_head(page);
> > +
> > +	/*
> > +	 * For devmap managed pages we need to catch refcount transition from
> > +	 * GUP_PIN_COUNTING_BIAS to 1, when refcount reach one it means the
> > +	 * page is free and we need to inform the device driver through
> > +	 * callback. See include/linux/memremap.h and HMM for details.
> > +	 */
> > +	if (put_devmap_managed_page(page))
> > +		return;
> > +
> > +	if (put_page_testzero(page))
> > +		__put_page(page);
> > +}
> > +
> > +static void __put_user_pages(struct vaddr_pin *vaddr_pin, struct page **pages,
> > +			     unsigned long npages)
> > +{
> > +	unsigned long index;
> > +
> > +	/*
> > +	 * TODO: this can be optimized for huge pages: if a series of pages is
> > +	 * physically contiguous and part of the same compound page, then a
> > +	 * single operation to the head page should suffice.
> > +	 */
> 
> As discussed in the other review thread (""), let's just delete that comment,
> as long as you're moving things around.

Done.

> 
> 
> > +	for (index = 0; index < npages; index++)
> > +		__put_user_page(vaddr_pin, pages[index]);
> > +}
> > +
> > +static void __put_user_pages_dirty_lock(struct vaddr_pin *vaddr_pin,
> > +					struct page **pages,
> > +					unsigned long npages,
> > +					bool make_dirty)
> 
> Elsewhere in this series, we pass vaddr_pin at the end of the arg list.
> Here we pass it at the beginning, and it caused a minor jar when reading it.
> Obviously just bike shedding at this point, though. Either way. :)

Yea I guess that is odd...  I changed it.  Not a big deal.

> 
> >  {
> >  	unsigned long index;
> >  
> > @@ -58,7 +69,7 @@ void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
> >  	 */
> >  
> >  	if (!make_dirty) {
> > -		put_user_pages(pages, npages);
> > +		__put_user_pages(vaddr_pin, pages, npages);
> >  		return;
> >  	}
> >  
> > @@ -86,9 +97,58 @@ void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
> >  		 */
> >  		if (!PageDirty(page))
> >  			set_page_dirty_lock(page);
> > -		put_user_page(page);
> > +		__put_user_page(vaddr_pin, page);
> >  	}
> >  }
> > +
> > +/**
> > + * put_user_page() - release a gup-pinned page
> > + * @page:            pointer to page to be released
> > + *
> > + * Pages that were pinned via get_user_pages*() must be released via
> > + * either put_user_page(), or one of the put_user_pages*() routines
> > + * below. This is so that eventually, pages that are pinned via
> > + * get_user_pages*() can be separately tracked and uniquely handled. In
> > + * particular, interactions with RDMA and filesystems need special
> > + * handling.
> > + *
> > + * put_user_page() and put_page() are not interchangeable, despite this early
> > + * implementation that makes them look the same. put_user_page() calls must
> > + * be perfectly matched up with get_user_page() calls.
> > + */
> > +void put_user_page(struct page *page)
> > +{
> > +	__put_user_page(NULL, page);
> > +}
> > +EXPORT_SYMBOL(put_user_page);
> > +
> > +/**
> > + * put_user_pages_dirty_lock() - release and optionally dirty gup-pinned pages
> > + * @pages:  array of pages to be maybe marked dirty, and definitely released.
> 
> Same here:
> 
>       @pages:  array of pages to be put

Actually here is the only place.  Above was removing the text to be put here...

Done -- I'll made a lead in patch because this was just copied text.

> 
> > + * @npages: number of pages in the @pages array.
> > + * @make_dirty: whether to mark the pages dirty
> > + *
> > + * "gup-pinned page" refers to a page that has had one of the get_user_pages()
> > + * variants called on that page.
> > + *
> > + * For each page in the @pages array, make that page (or its head page, if a
> > + * compound page) dirty, if @make_dirty is true, and if the page was previously
> > + * listed as clean. In any case, releases all pages using put_user_page(),
> > + * possibly via put_user_pages(), for the non-dirty case.
> > + *
> > + * Please see the put_user_page() documentation for details.
> > + *
> > + * set_page_dirty_lock() is used internally. If instead, set_page_dirty() is
> > + * required, then the caller should a) verify that this is really correct,
> > + * because _lock() is usually required, and b) hand code it:
> > + * set_page_dirty_lock(), put_user_page().
> > + *
> > + */
> > +void put_user_pages_dirty_lock(struct page **pages, unsigned long npages,
> > +			       bool make_dirty)
> > +{
> > +	__put_user_pages_dirty_lock(NULL, pages, npages, make_dirty);
> > +}
> >  EXPORT_SYMBOL(put_user_pages_dirty_lock);
> >  
> >  /**
> > @@ -102,15 +162,7 @@ EXPORT_SYMBOL(put_user_pages_dirty_lock);
> >   */
> >  void put_user_pages(struct page **pages, unsigned long npages)
> >  {
> > -	unsigned long index;
> > -
> > -	/*
> > -	 * TODO: this can be optimized for huge pages: if a series of pages is
> > -	 * physically contiguous and part of the same compound page, then a
> > -	 * single operation to the head page should suffice.
> > -	 */
> > -	for (index = 0; index < npages; index++)
> > -		put_user_page(pages[index]);
> > +	__put_user_pages(NULL, pages, npages);
> >  }
> >  EXPORT_SYMBOL(put_user_pages);
> >  
> > 
> 
> This all looks pretty good, so regardless of the outcome of the minor
> points above,
>    
>     Reviewed-by: John Hubbard <jhubbard@nvidia.com>

Thanks,
Ira

> 
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA

