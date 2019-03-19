Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAA54C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:15:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87AF72147C
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:15:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87AF72147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FDF16B0006; Tue, 19 Mar 2019 10:15:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 287B76B0007; Tue, 19 Mar 2019 10:15:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1527B6B0008; Tue, 19 Mar 2019 10:15:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D825C6B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:15:39 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e1so19623200qth.23
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 07:15:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=wzdN7tRU7DE0EBzzQ2RWw2BpkLeoMJcbGycnoWwYw28=;
        b=eM1Fb+1qtGhPF6NogRFYlJOQ/o2iMDb60bsm5Qxu16CqJNfYDeRZGWgRixkaLzGa3H
         i8DnEaYP367Z8AuCJr5Summe0IEFm+o/VoCjSg3bV1B46paC1cgoiiarns2l8cV3aBu/
         ItNOqnAxPSIEtoCoj2eHytYDtejwN9jQhOwzwMhm5pvu9DUCeiYO7OxTYHI+mFZ1Cs+n
         fkKNQPcq1zgKJuHciMj2hLtXQjpi2Hw+aElfwd2ebOi3yt/Xa5WE1NRem+g2ckgAyrZS
         xCsMBV4ejTi3e2JwAjrt6qIyt936PTzRScEi/P9cFAYc42IIcP5tbhALGOFDaNFgE6bc
         jclg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWU29gbH91WptdxwOgJ2ES8LGie6AR1MeKcrQr2DxNCk9zVcegG
	rr1zq75gfUnX1GAwpNPzFgo2i77qRSfyLWkD9fdMd82khdC9N6GEbBh9yjBEa8FmB8S11Z3I2XC
	TQOzgSLOK8Y3r3wEXgCP1YF3fV1rSDosPK9HduD93bSYR/MvzoK0d75Qg3uPxHloiNw==
X-Received: by 2002:ac8:7513:: with SMTP id u19mr2245156qtq.202.1553004939662;
        Tue, 19 Mar 2019 07:15:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXIW8dWQe+a5hza3lh1uThKA4Nd9EaV6AYumOzXThDxrcXmtu2vSCpGmSUhOR8UrMavNey
X-Received: by 2002:ac8:7513:: with SMTP id u19mr2245092qtq.202.1553004938903;
        Tue, 19 Mar 2019 07:15:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553004938; cv=none;
        d=google.com; s=arc-20160816;
        b=uLqQq+KEnNJnzY7auX/LgvZviib//q6K0HyD9rUdKlYTc5V4pHcK6ESRTXhGcF2lwc
         FjnhrmJqvqlK/+Nbobsw2NGXjamNe2U9L1GHh00yCRVbjUPtErqnL0cBGg+QPAzUggEk
         mtqcCWWIOukFrh+pNW+9VZLy0Y4jVrG5avxtk6FESpLbd2fV8Itm7bmt71puo656LynJ
         DIdqJyu1v/Yn8pDY9HJMHlWtgOGhMb9lPG/+pwPNxu915E79jAUM4qqRaZeQKiUJ+8ya
         ur79Q/RsrD7SdiWjKbiMjM2TTl7dI2O3fuiL3TCMoIow+XhTX2WTw30yxUlEnSCweCm9
         bKBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=wzdN7tRU7DE0EBzzQ2RWw2BpkLeoMJcbGycnoWwYw28=;
        b=mT7ziuaq+ygtQv4WnsoNE3xqOb0Wty+58X6d1DhBC6UAf3G134WYb7GVXX/1vScEZJ
         lohbGGRtzE7GJM+MyZxbQMq3eHq1WdA8GJ4VaT6rSPBFMANX9zoWrz0VOpealVi4ZzZC
         MhnlP3QTV5DhGoL4H6SASlv7hvU/+Nrp3JHSDlqoCAynExUlZSrSz0NfxPAI9T7idVM4
         g3ri/nREuz8Iq/5ifV5K79FsfYqdeNXpp+ZhAoRX0hbEFHBrpHTNsW4/mKll46r9MnPL
         tdGQA1HDnD0kD5nlIyhiv6ZKK3c5Ax3vbAZQCEWEJGuYBePPUP5f4AWwjpKMxY6pySGR
         fCIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y44si3788761qvf.189.2019.03.19.07.15.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 07:15:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 866CC40F44;
	Tue, 19 Mar 2019 14:15:37 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3A17218BBA;
	Tue, 19 Mar 2019 14:15:35 +0000 (UTC)
Date: Tue, 19 Mar 2019 10:15:33 -0400
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
Message-ID: <20190319141533.GB3879@redhat.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
 <20190319140623.tblqyb4dcjabjn3o@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190319140623.tblqyb4dcjabjn3o@kshutemo-mobl1>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 19 Mar 2019 14:15:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 05:06:23PM +0300, Kirill A. Shutemov wrote:
> On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
> > On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
> > > On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
> > > > From: John Hubbard <jhubbard@nvidia.com>
> > 
> > [...]
> > 
> > > > diff --git a/mm/gup.c b/mm/gup.c
> > > > index f84e22685aaa..37085b8163b1 100644
> > > > --- a/mm/gup.c
> > > > +++ b/mm/gup.c
> > > > @@ -28,6 +28,88 @@ struct follow_page_context {
> > > >  	unsigned int page_mask;
> > > >  };
> > > >  
> > > > +typedef int (*set_dirty_func_t)(struct page *page);
> > > > +
> > > > +static void __put_user_pages_dirty(struct page **pages,
> > > > +				   unsigned long npages,
> > > > +				   set_dirty_func_t sdf)
> > > > +{
> > > > +	unsigned long index;
> > > > +
> > > > +	for (index = 0; index < npages; index++) {
> > > > +		struct page *page = compound_head(pages[index]);
> > > > +
> > > > +		if (!PageDirty(page))
> > > > +			sdf(page);
> > > 
> > > How is this safe? What prevents the page to be cleared under you?
> > > 
> > > If it's safe to race clear_page_dirty*() it has to be stated explicitly
> > > with a reason why. It's not very clear to me as it is.
> > 
> > The PageDirty() optimization above is fine to race with clear the
> > page flag as it means it is racing after a page_mkclean() and the
> > GUP user is done with the page so page is about to be write back
> > ie if (!PageDirty(page)) see the page as dirty and skip the sdf()
> > call while a split second after TestClearPageDirty() happens then
> > it means the racing clear is about to write back the page so all
> > is fine (the page was dirty and it is being clear for write back).
> > 
> > If it does call the sdf() while racing with write back then we
> > just redirtied the page just like clear_page_dirty_for_io() would
> > do if page_mkclean() failed so nothing harmful will come of that
> > neither. Page stays dirty despite write back it just means that
> > the page might be write back twice in a row.
> 
> Fair enough. Should we get it into a comment here?

Yes definitly also i just sent an email with an alternative that is
slightly better from my POV as it simplify my life for other things :)

Cheers,
Jérôme

