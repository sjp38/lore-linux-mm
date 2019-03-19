Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3847C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:06:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 742672075E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:06:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="PzB1zI90"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 742672075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C57CF6B0003; Tue, 19 Mar 2019 10:06:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B663D6B0006; Tue, 19 Mar 2019 10:06:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B18766B0007; Tue, 19 Mar 2019 10:06:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24EBF6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:06:31 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h15so22946094pfj.22
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 07:06:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bHQ3oqYGOw6mAzwKVyAQ07+Fulp0qnOCWUl38WK1ISQ=;
        b=sR1G+ncIffDgicSHKoUrkzqnAiKxglskYnBrevYztmWa1H5n4PEZjzQtXglCTp33jU
         48H9Kkgjro+6yAd+ZU48pJZsyommPBJOPX7lyVvvLN0gbLdThAS2nH6SnRcSPG57898+
         lTmJWKu92/eARQhEBMxGqsyqr0bLLtU4sh/DfqhROvaSYSdN7w/7x3nLBcw6i1h6bzOe
         +ozAIgxs3z35Epu1Lml5/zpBgs8hBaHKU8tEJ4GrYESViZAwVmuxtX4BMSeBLZO3J6vk
         p/MMZRUnauXt+BcC+Sr4Yz3FBtmy410S9Yk8AkzGUuM7k/3WFa/aeSv/Vx7O5F3+Mllb
         E7wg==
X-Gm-Message-State: APjAAAUqYpL60pMC4dlrpUlG1B82aOAJC+f8Jx4GNW3dDnx9VuH6g7Dl
	O2nfozu8NU2IIE8fVj60QX+FSi+evORhh4G/rGFwRaPCYMC1p0C9UaVDijfx64rDhxiELPKt3yD
	f15qwNsyN0vSUJEqAYhigHxPQDDI4nfIYMLt1Y8n9GGTTecS573Y24Qt1Zt5DvXIhGw==
X-Received: by 2002:aa7:8b0c:: with SMTP id f12mr2141646pfd.154.1553004390360;
        Tue, 19 Mar 2019 07:06:30 -0700 (PDT)
X-Received: by 2002:aa7:8b0c:: with SMTP id f12mr2141572pfd.154.1553004389388;
        Tue, 19 Mar 2019 07:06:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553004389; cv=none;
        d=google.com; s=arc-20160816;
        b=So9cUrOKJDbbD/7sCKCy3suHRzvjPcyL4o4slKWHp8oL85gphhiNUGcUntqAyGsqC9
         Br5wjBqR1MKzk6vp5NPIM0LmPuDWCcHiqpYwdEvXokAfxYIBFTJYNZgRTA/g8l6AbWmg
         Mbp/U5r9Nu2aGtP98sfj7kRhOFtQ0ZpeA43+nh0zb2J+GPgmetLialzRfUyhsmhvpLc9
         tDUOrAbyoBfLgew3x4NujLjnmY6VabA+ut4wlXTcVjJSI0PbCerdPPLB8lQ0EtSZV/HK
         zn2VZp+r4bkSEra0suASpnkplp/kVolT1YU9tx5ZCSF7dy3TMHJy23GqoifxVhfynax/
         IelQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bHQ3oqYGOw6mAzwKVyAQ07+Fulp0qnOCWUl38WK1ISQ=;
        b=QAlSIcV53z3XsJK6rjOz0tQ4jo46WFIM5U7AkneovAHAhbh60hqWSe6x33mZGNtnxP
         MWmjbFIvusx4bqzuWwFBWNQv+lcO5QkLuNUJYIEEddePFFeoqN6R2pRXjdIR4cNxt6np
         P3KELOBFr1GN8VXnkjzzrq3Px2DWbGZPtqUgs4rFSU90R+54NKWXi2uXaZYstcclRJtS
         gvUUDyqBVW6ylrSBtXwdPQln/vQZKc9kAHGwglV1ajTz7v8DQrpBzggvN2XEFs5ZAS9y
         9zWrMgGeCfH3vcSlq1K7CCLmnV+3Bie6pnfTASn/mWCknqwEXdi9BTjnFFOyGRXIXE1+
         OV6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=PzB1zI90;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f129sor3246165pfb.54.2019.03.19.07.06.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 07:06:29 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=PzB1zI90;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bHQ3oqYGOw6mAzwKVyAQ07+Fulp0qnOCWUl38WK1ISQ=;
        b=PzB1zI909lcNM/YzJY+3015iZEf+PdrS5ILcrKJDxpepK1ilmkl1iWSwgLK9C9jRuP
         lOEn9+woDg4FXKUQhKzz/YbTR2wcU50xlTG0nyqh871ae8/mVgJytd0beXkNQGM25ylV
         4GGYBZBaJR8lMwmEtIcAJJO9itvYqUjKu3NxBvPkUB5Q8GIBEjNFXzZT1WpC0wRkTDfl
         CxRBSP5n0HBYvdzdccyKtIPhgKLJO3xKcRA+RTAnqWh4X4jvFP+lveusANkgpepxgHQR
         nJ5g3BPEaN47OoRHxLAgMTIoYTj3tCqRpGmQkPlsmlxULX/JK45v3358CtvVxYqpfyJ4
         EWKg==
X-Google-Smtp-Source: APXvYqzh/5+h50GyWZg4rnMdZOduspnjHPSIFlsjDZ11nKe18mb/ykay6zBdJhPiKKsk14fO52eTkw==
X-Received: by 2002:aa7:8d17:: with SMTP id j23mr2201765pfe.62.1553004388699;
        Tue, 19 Mar 2019 07:06:28 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain ([134.134.139.83])
        by smtp.gmail.com with ESMTPSA id l5sm24631404pfi.97.2019.03.19.07.06.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 07:06:28 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id C7BBB3011DA; Tue, 19 Mar 2019 17:06:23 +0300 (+03)
Date: Tue, 19 Mar 2019 17:06:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Jerome Glisse <jglisse@redhat.com>
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
Message-ID: <20190319140623.tblqyb4dcjabjn3o@kshutemo-mobl1>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319134724.GB3437@redhat.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
> On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
> > On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
> > > From: John Hubbard <jhubbard@nvidia.com>
> 
> [...]
> 
> > > diff --git a/mm/gup.c b/mm/gup.c
> > > index f84e22685aaa..37085b8163b1 100644
> > > --- a/mm/gup.c
> > > +++ b/mm/gup.c
> > > @@ -28,6 +28,88 @@ struct follow_page_context {
> > >  	unsigned int page_mask;
> > >  };
> > >  
> > > +typedef int (*set_dirty_func_t)(struct page *page);
> > > +
> > > +static void __put_user_pages_dirty(struct page **pages,
> > > +				   unsigned long npages,
> > > +				   set_dirty_func_t sdf)
> > > +{
> > > +	unsigned long index;
> > > +
> > > +	for (index = 0; index < npages; index++) {
> > > +		struct page *page = compound_head(pages[index]);
> > > +
> > > +		if (!PageDirty(page))
> > > +			sdf(page);
> > 
> > How is this safe? What prevents the page to be cleared under you?
> > 
> > If it's safe to race clear_page_dirty*() it has to be stated explicitly
> > with a reason why. It's not very clear to me as it is.
> 
> The PageDirty() optimization above is fine to race with clear the
> page flag as it means it is racing after a page_mkclean() and the
> GUP user is done with the page so page is about to be write back
> ie if (!PageDirty(page)) see the page as dirty and skip the sdf()
> call while a split second after TestClearPageDirty() happens then
> it means the racing clear is about to write back the page so all
> is fine (the page was dirty and it is being clear for write back).
> 
> If it does call the sdf() while racing with write back then we
> just redirtied the page just like clear_page_dirty_for_io() would
> do if page_mkclean() failed so nothing harmful will come of that
> neither. Page stays dirty despite write back it just means that
> the page might be write back twice in a row.

Fair enough. Should we get it into a comment here?

> > > +void put_user_pages(struct page **pages, unsigned long npages)
> > > +{
> > > +	unsigned long index;
> > > +
> > > +	for (index = 0; index < npages; index++)
> > > +		put_user_page(pages[index]);
> > 
> > I believe there's an room for improvement for compound pages.
> > 
> > If there's multiple consequential pages in the array that belong to the
> > same compound page we can get away with a single atomic operation to
> > handle them all.
> 
> Yes maybe just add a comment with that for now and leave this kind of
> optimization to latter ?

Sounds good to me.

-- 
 Kirill A. Shutemov

