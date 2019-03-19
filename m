Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCE8DC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:14:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A410D2133D
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:14:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A410D2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 485366B0003; Tue, 19 Mar 2019 10:14:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 410316B0006; Tue, 19 Mar 2019 10:14:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D7416B0007; Tue, 19 Mar 2019 10:14:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id ECDF56B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:14:22 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id i3so19687394qtc.7
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 07:14:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/lDSC81tTcGdITMSNYnGT4dXbgHL2JbGloBPv6Ppys8=;
        b=hIa8EuXf5BmvEGcxCShp6VlD88PQR9Z7NkTlVaTJ4Xxtw750JaSSnz/TT3jeF9oKP9
         EinxaPCzqwzt3l6pNoDU9vE8sa1xjFU6s8yKWj4UJA1ZXJMarfotnBleGZwngF2KdY2Q
         PukzSeCnE5V0+b88paVhrSqNzwtSiiq/xsdtTefv4NrhrSEfrYCnKxJvXq3+OLSkb+WF
         wOmonamgxRysjegSAeLF3ISvqAXRZr0z9S8Wu8+EpOtC2BUSym9ImCwHCLcDg1ZgSdF1
         hG1qjKxych0cpxLXjnrKbU3CMkYOmozzEMn4l09NM0BJ+fxTrdAW1kevpIiKRClheFML
         Beqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVfHYdRmzrqZlNNNyPTEBmdO0ReXz6u1+U7Gydvhc70IWjPRHrm
	ipMghRItNdZJ54b5mx3uR8zLGP7gvzjLdfxuKWyPdZ3JOGh++yh9S7QrCtOkgAw26nZGx9iZb4s
	UV5VuKgc4ixkARNrgz+euTf/A17monHZf13KxxHilRbqR4oRbOJxE1QCEOWYwj3SHBQ==
X-Received: by 2002:a0c:c950:: with SMTP id v16mr2030893qvj.204.1553004862706;
        Tue, 19 Mar 2019 07:14:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcgQLAiIDMx5kwAeAmNvwaVKmQW6QL55bh9PPkN5ONnAY6/FX0hTygtdRuMNOj83trIi+j
X-Received: by 2002:a0c:c950:: with SMTP id v16mr2030795qvj.204.1553004861420;
        Tue, 19 Mar 2019 07:14:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553004861; cv=none;
        d=google.com; s=arc-20160816;
        b=ZO36YfzfQFHxqsUJZjJAU8iy0XajR41OuijSS4BrgF+9LqNskKfCNRTrHK5Brjw1nu
         fLOpl0qVldALsdYvWZrSLPINgizDoJ4OUGRgvAKc9PutpiJaU+RNVI9ve74L6KRhaHuM
         KUMeFuRYHoLI+oSbuKI64xWgF/7AgVj1Kj70gfI++W18LVgDn2suiF5eHvPk0U0nKT5S
         2hUDWKmxaWP0NMjBaOjBxUHAsn62KjyHyF+9DRiGSk+01TWw86336Zwe+fCOSGJPxUnH
         hh1l0ARWiL5eB7eSrs34J/42+SUBEAozapB3UFpRXmjeDypjmoXPwIa7l75zjVvp1vah
         cQZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=/lDSC81tTcGdITMSNYnGT4dXbgHL2JbGloBPv6Ppys8=;
        b=A7hfy5YAp9+jVshRvS6hO7HDsQoDbWN1P2cOfUsBchZPoE0iEFhEMO1e1bZkG8by9j
         Oe9qwVN6P1s0dis0uDrX0IEkuxKnuyRHKNAxLBFBEYZgOKVAxBDtfnO57gq40mjZ39ie
         GllhcqAwtdeyBNMTSsqGdpIVUolN01jZIyumYKzmE+aU6KerQGWrNkyA/LDGcc9hYDdX
         m9xKPck2mSLa84i1CzQANJFbq2Gia4VjSKNlxUEGF21nm8qNQyRdhmkG20w8FMQ0cU/Z
         u/yGQOTR3gN7fw6TIPj9UCYS293bZUh4kKnFhTXKRpz+wKuIlpEiKfmw0Nk+23Z4r31L
         AlSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o47si6469641qve.201.2019.03.19.07.14.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 07:14:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 52ADC3082B42;
	Tue, 19 Mar 2019 14:14:20 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 21C83611C2;
	Tue, 19 Mar 2019 14:14:18 +0000 (UTC)
Date: Tue, 19 Mar 2019 10:14:16 -0400
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
	John Hubbard <jhubbard@nvidia.com>,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190319141416.GA3879@redhat.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190319134724.GB3437@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 19 Mar 2019 14:14:20 +0000 (UTC)
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

Forgot to mention one thing, we had a discussion with Andrea and Jan
about set_page_dirty() and Andrea had the good idea of maybe doing
the set_page_dirty() at GUP time (when GUP with write) not when the
GUP user calls put_page(). We can do that by setting the dirty bit
in the pte for instance. They are few bonus of doing things that way:
    - amortize the cost of calling set_page_dirty() (ie one call for
      GUP and page_mkclean()
    - it is always safe to do so at GUP time (ie the pte has write
      permission and thus the page is in correct state)
    - safe from truncate race
    - no need to ever lock the page

Extra bonus from my point of view, it simplify thing for my generic
page protection patchset (KSM for file back page).

So maybe we should explore that ? It would also be a lot less code.

Cheers,
Jérôme

