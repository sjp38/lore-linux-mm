Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9AF6B039E
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 07:50:34 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id w132so87456476ita.1
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 04:50:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b85si13858257ioj.175.2016.11.21.04.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 04:50:33 -0800 (PST)
Date: Mon, 21 Nov 2016 07:50:29 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 03/18] mm/ZONE_DEVICE/free_hot_cold_page: catch
 ZONE_DEVICE pages
Message-ID: <20161121125029.GG2392@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-4-git-send-email-jglisse@redhat.com>
 <5832ADD2.5000507@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5832ADD2.5000507@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, Nov 21, 2016 at 01:48:26PM +0530, Anshuman Khandual wrote:
> On 11/18/2016 11:48 PM, Jerome Glisse wrote:
> > Catch page from ZONE_DEVICE in free_hot_cold_page(). This should never
> > happen as ZONE_DEVICE page must always have an elevated refcount.
> > 
> > This is to catch refcounting issues in a sane way for ZONE_DEVICE pages.
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> > ---
> >  mm/page_alloc.c | 10 ++++++++++
> >  1 file changed, 10 insertions(+)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 0fbfead..09b2630 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2435,6 +2435,16 @@ void free_hot_cold_page(struct page *page, bool cold)
> >  	unsigned long pfn = page_to_pfn(page);
> >  	int migratetype;
> >  
> > +	/*
> > +	 * This should never happen ! Page from ZONE_DEVICE always must have an
> > +	 * active refcount. Complain about it and try to restore the refcount.
> > +	 */
> > +	if (is_zone_device_page(page)) {
> > +		VM_BUG_ON_PAGE(is_zone_device_page(page), page);
> > +		page_ref_inc(page);
> > +		return;
> > +	}
> 
> This fixes an issue in the existing ZONE_DEVICE code, should not this
> patch be sent separately not in this series ?
> 

Well this is more like a safetynet feature, i can send it separately from the
series. It is not an issue per say as a trap to catch bugs. I had refcounting
bugs while working on this patchset and having this safetynet was helpful to
quickly pin-point issues.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
