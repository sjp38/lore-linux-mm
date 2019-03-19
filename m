Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7903C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 13:47:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A21492085A
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 13:47:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A21492085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D63E6B0003; Tue, 19 Mar 2019 09:47:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 360046B0006; Tue, 19 Mar 2019 09:47:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 202576B0007; Tue, 19 Mar 2019 09:47:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB1AB6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 09:47:31 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 23so17597362qkl.16
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 06:47:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4IV/YydOERXOEcACWDCxxLIAsvFogFMpjtB31rI36IE=;
        b=SPfAdqhQ/Bgcn271K8GVKoKnUx/DMreos6SxFN4kj/bxUAtRtMgSAIQ3Z7Yjucg6xL
         DsSN83+OHIC5p0g8dVml6EYmg19bWEwFFfDFvkMIxJH1AoGya69U5yfSD/A39PXe3kEn
         gT/zzyrF7oZglWgeAPNWrQW2UzhpS7I0aESwFaU4eT2vGYwhSXnFDvconBycqDGHgVQG
         L8inAh03OBUxGIKcqtQ0RFNBvREHwx4kf2pfMJSe0iFkjvkjp77Rw+YRQm26ecO7FQqW
         Dl0CIjrwkjJFxbnVPoSiDzjz5fs9MfcCG/JPgqTUAzsTdHk7wumtWOVnni7L0AfEvu3T
         gEFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW2/FlpnQGBzgBrWE25xeSEgGpx8Pg2BVl4/dIGSM7e4wBwzO4U
	ij+GXym+uAPDhEkhYuFleDRQ6UeuPFAisR1ZNcQcLdTL9y46vry0CdQ4JX5mxqvdZWply5P6X4c
	qurxSTDqGxW4h4bO2MHB2sq4ZVg+516xZViFvF7nQYFb6ViEdHuDiSd/pXyk31Uk/ug==
X-Received: by 2002:a0c:80a8:: with SMTP id 37mr1900005qvb.138.1553003251656;
        Tue, 19 Mar 2019 06:47:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmDzapOAP/HHBP5zCEXTsIwNq1xaxtkWGgiqqi+NgGeqCXiPxTw0ZY5Na60zvSGralDD+o
X-Received: by 2002:a0c:80a8:: with SMTP id 37mr1899950qvb.138.1553003250672;
        Tue, 19 Mar 2019 06:47:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553003250; cv=none;
        d=google.com; s=arc-20160816;
        b=UUc3oYq8sCmWwPmVp/dkqdUZZe+PTh3N6pC7k+bG7pkzIi7aUgyILytSvtNWvErCWY
         utkXuEkXTMHaTVWbUcQz23Zv28QV9r6e6kbod/lg0J4HOjJVUVnR09DZuGA3vcGaM7BG
         z9g75iq/ozo4JXW8Dt4tgVdQYbCD629YRJ/foP1D3T2PYmm6382/tef3am4Y6mYRw4pU
         qB1BCDlz5hTSwc+uxrOt37ci6xbLkFzH//zUZfWkkVFZ+BDLWa1/DjfWU/0rmn8khHdT
         PFpnMIrDHqcyElXaZaNYEU3Wlni42jZt/Bj8Uok8CVRdAXLPaIMaMAQ3OmHcdljCiILr
         FAdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4IV/YydOERXOEcACWDCxxLIAsvFogFMpjtB31rI36IE=;
        b=AKWFTJagINtTtOP5XITsClp6jAjfCewmpqu39AvGtpVbpUQCBxZyiQYINWr8iNLD0J
         BrPwB2r9Ogjih1TO1fvNRNdJ11Ruok9mFUgtNiK8m3I2aHMe9WqQlUEFwnhmYvGSwVwr
         owBu1fPaGnUc3E3S790/UxzCRBGtqMFw6cVeBW2ME0J0a2Ymy1TsfVdLESItDePvgWc4
         Ei3vh2f2W2z6rvDc1gALY6C9JrLdEQLGr49QVHuHEi3rTymv8B9AioWsTTtHb2SNfPkK
         7ONZpoLB8wD/FNBmAsvQ6d8mgrc9LuVP8QRwYq1AOw9uffQIAvVeOBBEnmyUt8qBH5H6
         7O+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f16si2741193qkg.87.2019.03.19.06.47.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 06:47:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3AE0320277;
	Tue, 19 Mar 2019 13:47:29 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A26125D706;
	Tue, 19 Mar 2019 13:47:26 +0000 (UTC)
Date: Tue, 19 Mar 2019 09:47:24 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190319134724.GB3437@redhat.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 19 Mar 2019 13:47:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
> On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
> > From: John Hubbard <jhubbard@nvidia.com>

[...]

> > diff --git a/mm/gup.c b/mm/gup.c
> > index f84e22685aaa..37085b8163b1 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -28,6 +28,88 @@ struct follow_page_context {
> >  	unsigned int page_mask;
> >  };
> >  
> > +typedef int (*set_dirty_func_t)(struct page *page);
> > +
> > +static void __put_user_pages_dirty(struct page **pages,
> > +				   unsigned long npages,
> > +				   set_dirty_func_t sdf)
> > +{
> > +	unsigned long index;
> > +
> > +	for (index = 0; index < npages; index++) {
> > +		struct page *page = compound_head(pages[index]);
> > +
> > +		if (!PageDirty(page))
> > +			sdf(page);
> 
> How is this safe? What prevents the page to be cleared under you?
> 
> If it's safe to race clear_page_dirty*() it has to be stated explicitly
> with a reason why. It's not very clear to me as it is.

The PageDirty() optimization above is fine to race with clear the
page flag as it means it is racing after a page_mkclean() and the
GUP user is done with the page so page is about to be write back
ie if (!PageDirty(page)) see the page as dirty and skip the sdf()
call while a split second after TestClearPageDirty() happens then
it means the racing clear is about to write back the page so all
is fine (the page was dirty and it is being clear for write back).

If it does call the sdf() while racing with write back then we
just redirtied the page just like clear_page_dirty_for_io() would
do if page_mkclean() failed so nothing harmful will come of that
neither. Page stays dirty despite write back it just means that
the page might be write back twice in a row.

> > +
> > +		put_user_page(page);
> > +	}
> > +}
> > +
> > +/**
> > + * put_user_pages_dirty() - release and dirty an array of gup-pinned pages
> > + * @pages:  array of pages to be marked dirty and released.
> > + * @npages: number of pages in the @pages array.
> > + *
> > + * "gup-pinned page" refers to a page that has had one of the get_user_pages()
> > + * variants called on that page.
> > + *
> > + * For each page in the @pages array, make that page (or its head page, if a
> > + * compound page) dirty, if it was previously listed as clean. Then, release
> > + * the page using put_user_page().
> > + *
> > + * Please see the put_user_page() documentation for details.
> > + *
> > + * set_page_dirty(), which does not lock the page, is used here.
> > + * Therefore, it is the caller's responsibility to ensure that this is
> > + * safe. If not, then put_user_pages_dirty_lock() should be called instead.
> > + *
> > + */
> > +void put_user_pages_dirty(struct page **pages, unsigned long npages)
> > +{
> > +	__put_user_pages_dirty(pages, npages, set_page_dirty);
> 
> Have you checked if compiler is clever enough eliminate indirect function
> call here? Maybe it's better to go with an opencodded approach and get rid
> of callbacks?
> 

Good point, dunno if John did check that.

> 
> > +}
> > +EXPORT_SYMBOL(put_user_pages_dirty);
> > +
> > +/**
> > + * put_user_pages_dirty_lock() - release and dirty an array of gup-pinned pages
> > + * @pages:  array of pages to be marked dirty and released.
> > + * @npages: number of pages in the @pages array.
> > + *
> > + * For each page in the @pages array, make that page (or its head page, if a
> > + * compound page) dirty, if it was previously listed as clean. Then, release
> > + * the page using put_user_page().
> > + *
> > + * Please see the put_user_page() documentation for details.
> > + *
> > + * This is just like put_user_pages_dirty(), except that it invokes
> > + * set_page_dirty_lock(), instead of set_page_dirty().
> > + *
> > + */
> > +void put_user_pages_dirty_lock(struct page **pages, unsigned long npages)
> > +{
> > +	__put_user_pages_dirty(pages, npages, set_page_dirty_lock);
> > +}
> > +EXPORT_SYMBOL(put_user_pages_dirty_lock);
> > +
> > +/**
> > + * put_user_pages() - release an array of gup-pinned pages.
> > + * @pages:  array of pages to be marked dirty and released.
> > + * @npages: number of pages in the @pages array.
> > + *
> > + * For each page in the @pages array, release the page using put_user_page().
> > + *
> > + * Please see the put_user_page() documentation for details.
> > + */
> > +void put_user_pages(struct page **pages, unsigned long npages)
> > +{
> > +	unsigned long index;
> > +
> > +	for (index = 0; index < npages; index++)
> > +		put_user_page(pages[index]);
> 
> I believe there's an room for improvement for compound pages.
> 
> If there's multiple consequential pages in the array that belong to the
> same compound page we can get away with a single atomic operation to
> handle them all.

Yes maybe just add a comment with that for now and leave this kind of
optimization to latter ?

