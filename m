Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2D7BC43444
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 14:44:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A857E2070D
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 14:44:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A857E2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A9698E007B; Thu,  3 Jan 2019 09:44:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47E438E0002; Thu,  3 Jan 2019 09:44:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3954D8E007B; Thu,  3 Jan 2019 09:44:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 102408E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 09:44:18 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id d35so42320941qtd.20
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 06:44:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=50ZMCetk8W2Dglwex2UjeQk48cgouFH0EPRHABgNlgY=;
        b=KJdK4tQjpEd+JDOZxmbkqi4zJ2NkYzISiqanNaBeWgK4VX3Dpl9bfCVr5s1vApR0HI
         u8O0TZDU3/p95FaWsIRIL+OOL0WkVgOJLz1p3n/aAAzro/BQMQnFvq2Q3LPCzS8R8mTy
         YKd1vg0X6cE4fIXU8P8s9QMAJ9hYqBWLojPoZhD6o0FA/LOyyqX7RFg6WXTkjL2lGXfB
         cN55VjYQQJNtXw2ICB7MQcocuaUeVN5N3RVaZSPU6voV5u2w8NWyQE51dWutRmrdTsb5
         hhLuvmrIG7KcHkJPidieUsnZRJqOagIRVoKXm4VYNDy7z00nMollQSiAEsYJbpTXKftu
         7AXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukcaGCtxZvlsHGFvK0z4MBYK3FL2zYM30ha80/LETg8GJ0T7zKCd
	op6OsUIsMaZ8QKJlWcPjgZ0B5XHoLgBsT5skpfjiR0zPPK7BM1iRSwVUzrACQ1RPkOqnCkvWC7B
	Yy31VlHE8hiBi1DgcDRsyrp9q64jGAAY7ESUJckWJseBIGPnOGULnaSM3z+uUafFo/A==
X-Received: by 2002:a0c:e84f:: with SMTP id l15mr46155680qvo.124.1546526657815;
        Thu, 03 Jan 2019 06:44:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6IrzQOSYZ2BhUG5VSZK/R3GQAiMbAIfPaQTVp6D5mGebhr2iY+S4V15AsaKTnUOYRg100l
X-Received: by 2002:a0c:e84f:: with SMTP id l15mr46155634qvo.124.1546526656992;
        Thu, 03 Jan 2019 06:44:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546526656; cv=none;
        d=google.com; s=arc-20160816;
        b=xpXf6lbwsgtNRACmQCeCHmhP9prxohH2LeVxlASS/vB04HBbZBJhHxLz2ABo5YWEzI
         /I5+SPYTV3y9Q2jQ+fJEK86lTGixZK5kTiQ137pOmPK8xmKaw9WpN2VvXGgHt59D0vGJ
         xSWmZWu2sKAHSbLceXq4me3aW6dQv0j/YGg8aX8dFQkFhMPJTvIO0sicfL7fsHwqmGgT
         B61dlgYc3gOshLUmxZHhOYpiw5nnLA3Pt/KMiuAM0X1bt3TSKQpOt/LPKAA/mlLLFuXk
         wrqBybB4kEZtxoxxeWz5/SLyhkFk3h9WcEQZ4CVojxlfpScm/JEerE5FgazcJ7kOUvLZ
         gHjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=50ZMCetk8W2Dglwex2UjeQk48cgouFH0EPRHABgNlgY=;
        b=FcIvQjLAe4l7U9gkSsAikTVJ+R2hpV36/lRpVt8jDSw79VLZzk1YcNUlKd73QJGZRy
         s0jI4UEhkXwyh994+zqZuAT1c0ASzISnfoYcNryHJSoHo7Gcvbg5TFixtJ3stRkzJOVo
         YBN4gmxAsMUPrT4LP/KoPV39OdHLZH+MRCNUYwLZWktaG9Odt0RA60lyRqffD9zmzj6C
         HhAgjGPyrGH4SrxAIAYdku1XWAEW4pAQJf/A+UfUMZG64YU9p2uxyrhyy3mNNJu0ykXq
         h0LpQhhoezmkpxF+NGSi1bsdGNVmabDOx2g2YoTFUQzOTL3eVh4OoMulxyBEy4AyIvm9
         m1vA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b54si629236qvb.176.2019.01.03.06.44.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 06:44:16 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A997085363;
	Thu,  3 Jan 2019 14:44:15 +0000 (UTC)
Received: from redhat.com (ovpn-123-124.rdu2.redhat.com [10.10.123.124])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4B0285D75C;
	Thu,  3 Jan 2019 14:44:08 +0000 (UTC)
Date: Thu, 3 Jan 2019 09:44:06 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Jan Kara <jack@suse.cz>
Cc: John Hubbard <jhubbard@nvidia.com>,
	Matthew Wilcox <willy@infradead.org>,
	Dave Chinner <david@fromorbit.com>,
	Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <john.hubbard@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>, tom@talpey.com,
	Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	"Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com,
	rcampbell@nvidia.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20190103144405.GC3395@redhat.com>
References: <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
 <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
 <20181219020723.GD4347@redhat.com>
 <20181219110856.GA18345@quack2.suse.cz>
 <20190103015533.GA15619@redhat.com>
 <20190103092654.GA31370@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190103092654.GA31370@quack2.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 03 Jan 2019 14:44:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103144406.YYwxiJsLH6fUtme_6CupD8fymh0PQKgTqqVugi_HdhI@z>

On Thu, Jan 03, 2019 at 10:26:54AM +0100, Jan Kara wrote:
> On Wed 02-01-19 20:55:33, Jerome Glisse wrote:
> > On Wed, Dec 19, 2018 at 12:08:56PM +0100, Jan Kara wrote:
> > > On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
> > > > On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
> > > > > OK, so let's take another look at Jerome's _mapcount idea all by itself (using
> > > > > *only* the tracking pinned pages aspect), given that it is the lightest weight
> > > > > solution for that.  
> > > > > 
> > > > > So as I understand it, this would use page->_mapcount to store both the real
> > > > > mapcount, and the dma pinned count (simply added together), but only do so for
> > > > > file-backed (non-anonymous) pages:
> > > > > 
> > > > > 
> > > > > __get_user_pages()
> > > > > {
> > > > > 	...
> > > > > 	get_page(page);
> > > > > 
> > > > > 	if (!PageAnon)
> > > > > 		atomic_inc(page->_mapcount);
> > > > > 	...
> > > > > }
> > > > > 
> > > > > put_user_page(struct page *page)
> > > > > {
> > > > > 	...
> > > > > 	if (!PageAnon)
> > > > > 		atomic_dec(&page->_mapcount);
> > > > > 
> > > > > 	put_page(page);
> > > > > 	...
> > > > > }
> > > > > 
> > > > > ...and then in the various consumers of the DMA pinned count, we use page_mapped(page)
> > > > > to see if any mapcount remains, and if so, we treat it as DMA pinned. Is that what you 
> > > > > had in mind?
> > > > 
> > > > Mostly, with the extra two observations:
> > > >     [1] We only need to know the pin count when a write back kicks in
> > > >     [2] We need to protect GUP code with wait_for_write_back() in case
> > > >         GUP is racing with a write back that might not the see the
> > > >         elevated mapcount in time.
> > > > 
> > > > So for [2]
> > > > 
> > > > __get_user_pages()
> > > > {
> > > >     get_page(page);
> > > > 
> > > >     if (!PageAnon) {
> > > >         atomic_inc(page->_mapcount);
> > > > +       if (PageWriteback(page)) {
> > > > +           // Assume we are racing and curent write back will not see
> > > > +           // the elevated mapcount so wait for current write back and
> > > > +           // force page fault
> > > > +           wait_on_page_writeback(page);
> > > > +           // force slow path that will fault again
> > > > +       }
> > > >     }
> > > > }
> > > 
> > > This is not needed AFAICT. __get_user_pages() gets page reference (and it
> > > should also increment page->_mapcount) under PTE lock. So at that point we
> > > are sure we have writeable PTE nobody can change. So page_mkclean() has to
> > > block on PTE lock to make PTE read-only and only after going through all
> > > PTEs like this, it can check page->_mapcount. So the PTE lock provides
> > > enough synchronization.
> > > 
> > > > For [1] only needing pin count during write back turns page_mkclean into
> > > > the perfect spot to check for that so:
> > > > 
> > > > int page_mkclean(struct page *page)
> > > > {
> > > >     int cleaned = 0;
> > > > +   int real_mapcount = 0;
> > > >     struct address_space *mapping;
> > > >     struct rmap_walk_control rwc = {
> > > >         .arg = (void *)&cleaned,
> > > >         .rmap_one = page_mkclean_one,
> > > >         .invalid_vma = invalid_mkclean_vma,
> > > > +       .mapcount = &real_mapcount,
> > > >     };
> > > > 
> > > >     BUG_ON(!PageLocked(page));
> > > > 
> > > >     if (!page_mapped(page))
> > > >         return 0;
> > > > 
> > > >     mapping = page_mapping(page);
> > > >     if (!mapping)
> > > >         return 0;
> > > > 
> > > >     // rmap_walk need to change to count mapping and return value
> > > >     // in .mapcount easy one
> > > >     rmap_walk(page, &rwc);
> > > > 
> > > >     // Big fat comment to explain what is going on
> > > > +   if ((page_mapcount(page) - real_mapcount) > 0) {
> > > > +       SetPageDMAPined(page);
> > > > +   } else {
> > > > +       ClearPageDMAPined(page);
> > > > +   }
> > > 
> > > This is the detail I'm not sure about: Why cannot rmap_walk_file() race
> > > with e.g. zap_pte_range() which decrements page->_mapcount and thus the
> > > check we do in page_mkclean() is wrong?
> > > 
> > 
> > Ok so i found a solution for that. First GUP must wait for racing
> > write back. If GUP see a valid write-able PTE and the page has
> > write back flag set then it must back of as if the PTE was not
> > valid to force fault. It is just a race with page_mkclean and we
> > want ordering between the two. Note this is not strictly needed
> > so we can relax that but i believe this ordering is better to do
> > in GUP rather then having each single user of GUP test for this
> > to avoid the race.
> > 
> > GUP increase mapcount only after checking that it is not racing
> > with writeback it also set a page flag (SetPageDMAPined(page)).
> > 
> > When clearing a write-able pte we set a special entry inside the
> > page table (might need a new special swap type for this) and change
> > page_mkclean_one() to clear to 0 those special entry.
> > 
> > 
> > Now page_mkclean:
> > 
> > int page_mkclean(struct page *page)
> > {
> >     int cleaned = 0;
> > +   int real_mapcount = 0;
> >     struct address_space *mapping;
> >     struct rmap_walk_control rwc = {
> >         .arg = (void *)&cleaned,
> >         .rmap_one = page_mkclean_one,
> >         .invalid_vma = invalid_mkclean_vma,
> > +       .mapcount = &real_mapcount,
> >     };
> > +   int mapcount1, mapcount2;
> > 
> >     BUG_ON(!PageLocked(page));
> > 
> >     if (!page_mapped(page))
> >         return 0;
> > 
> >     mapping = page_mapping(page);
> >     if (!mapping)
> >         return 0;
> > 
> > +   mapcount1 = page_mapcount(page);
> >     // rmap_walk need to change to count mapping and return value
> >     // in .mapcount easy one
> >     rmap_walk(page, &rwc);
> 
> So what prevents GUP_fast() to grab reference here and the test below would
> think the page is not pinned? Or do you assume that every page_mkclean()
> call will be protected by PageWriteback (currently it is not) so that
> GUP_fast() blocks / bails out?

So GUP_fast() becomes:

GUP_fast_existing() { ... }
GUP_fast()
{
    GUP_fast_existing();

    for (i = 0; i < npages; ++i) {
        if (PageWriteback(pages[i])) {
            // need to force slow path for this page
        } else {
            SetPageDmaPinned(pages[i]);
            atomic_inc(pages[i]->mapcount);
        }
    }
}

This is a minor slow down for GUP fast and it takes care of a
write back race on behalf of caller. This means that page_mkclean
can not see a mapcount value that increase. This simplify thing
we can relax that. Note that what this is doing is making sure
that GUP_fast never get lucky :) ie never GUP a page that is in
the process of being write back but has not yet had its pte
updated to reflect that.


> But I think that detecting pinned pages with small false positive rate is
> OK. The extra page bouncing will cost some performance but if it is rare,
> then we are OK. So I think we can go for the simple version of detecting
> pinned pages as you mentioned in some earlier email. We just have to be
> sure there are no false negatives.

What worry me is that a page might stays with the DMA pinned flag forever
if it keeps getting unlucky ie some process keeps mapping it after last
write back and keeps zapping that mapping while racing with page_mkclean.
This should be unlikely but nothing would prevent it. I am fine with
living with this but page might become a zombie GUP :)

Maybe we can start with the simple version and add big fat comment and see
if anyone complains about a zombie GUP ...

Cheers,
Jérôme

