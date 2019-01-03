Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A61A8C43444
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 14:58:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44590217F5
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 14:58:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44590217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B54A88E007D; Thu,  3 Jan 2019 09:58:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B04DA8E0002; Thu,  3 Jan 2019 09:58:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CD5E8E007D; Thu,  3 Jan 2019 09:58:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 70AA68E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 09:58:06 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id p24so42425642qtl.2
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 06:58:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=QSBHT/RkfJ7gLPPRt00rSNUmUT08FJTVbbPkL5GwB48=;
        b=Q5i4zxArrnDD7+DweddAym/LvnZIw+MtrN3K+cDSCSnCo9gIilGwEeR/vmJQMb40+W
         PreDyeH5EsUAQSJ6OGWrAUe+9+4KAJb8nly5w7H+qyrN0Y3RITOSOUiqqpq5l/x/9IMB
         kQnCoYmDdKW6vGupoIXCZixj8O62UvHYLz6HGPSWlhdvXuAUYHmXIrAyqJu20uiAWp2j
         Ktkz3vNV3GkrXIWeCRSVt+gYrKDrSgvSsSX4MC8jdgJoIuHLXC45yIM367TDerihHmaq
         ITqurr/HmH00plH06xo3tSYOeEKcyu4kPc55WGkrdZ+AlEFwnjNsfu6SIVVtIKjNwh8i
         jh0g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AA+aEWZzxFcAMhf/8pOLAAZcB5kUmz406+bv8saTH09Vnb8rpjVqRTYA
	2N4nzqM7JlYZ40zfpi7StYtLudUAMRwj5huMTlCHJgTpQDtENhM+m+9uk4+cVDLP9LH4KsI6xpq
	rp6eK6B/7PvIVi6oH2wYn+dvDV5qlZDvRspu6tuV78OSYoyxD2eAsnelhf0N8MXFKxA==
X-Received: by 2002:aed:2f25:: with SMTP id l34mr47230823qtd.356.1546527486201;
        Thu, 03 Jan 2019 06:58:06 -0800 (PST)
X-Google-Smtp-Source: AFSGD/VZW155H9z4mE8IaUvLfpQ5QznEZ9IgV+RKoIDmWOCdSgJQjUa9iEn2LNklACfTpC7eKri0
X-Received: by 2002:aed:2f25:: with SMTP id l34mr47230792qtd.356.1546527485519;
        Thu, 03 Jan 2019 06:58:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546527485; cv=none;
        d=google.com; s=arc-20160816;
        b=ghsxAzGf7KXZ/UU3mbJHB2dRvya+490Kx8lNR+I6lziJ2p2YatkxfctGsZ/J20zkgS
         OILi0Q0jJXIcmqMdiaHLyJBFoH39QE6uMipVFNDaRV3svt4LoQZn3bAjwk6pP85yNmlh
         OgHvqJY/rPqAm70Gf04tp2dfeDs8dpFsDjYthi+cAMPMb2n0PgaDVzAOg+xzDmIwFPvE
         Ohv1odjGPdIm9Q7BTlj5FKacR9+uzoT8gJJJX5oZWduICy0lNbPuGFla2d8IKb941M8G
         naDE+2MgBa02JLtvRlrYzBLGzjjh8dGFxx79T68fl96bVaakcsQXICHt8/UD8zrRhP4V
         cy3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=QSBHT/RkfJ7gLPPRt00rSNUmUT08FJTVbbPkL5GwB48=;
        b=Nhj4MN3nFl6QuEpyQDw3HhlM9nFc8MASFYpVOtLGzBrq/GidfARr/BJohpkL3NkL00
         MGwYnVUMHVRXCdWc9ZxXcVp7xVx68r0qXdKieRLqOmEolAXA3178nNqpPjBodnz0qXXY
         1tpsqoCBW4el6XBMl89Zr7J5DsAaGn/1QSbOKpNImeGnoPeW8RmOq4saHth7aYgo7ToP
         EhO5p7qRIzcYqztn4d9WPcgbd5dMWXtB5RJ5p2Fm0RPnF23R0lV0Yosgr9du9UFxj6RF
         HkeKR18UmY78K1220V7KHtA4ONS9vPkqBrfcNrY6j35SKDrkfmx4RvHFUn1CbpGelKcg
         zv9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n37si1870113qtc.72.2019.01.03.06.58.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 06:58:05 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4DA3080461;
	Thu,  3 Jan 2019 14:58:04 +0000 (UTC)
Received: from redhat.com (ovpn-123-124.rdu2.redhat.com [10.10.123.124])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 47B6C60C45;
	Thu,  3 Jan 2019 14:58:01 +0000 (UTC)
Date: Thu, 3 Jan 2019 09:57:58 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>,
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
Message-ID: <20190103145758.GD3395@redhat.com>
References: <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
 <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
 <20181219020723.GD4347@redhat.com>
 <20181219110856.GA18345@quack2.suse.cz>
 <20190103015533.GA15619@redhat.com>
 <8ea4ebe9-bb4f-67e2-c7cb-7404598b7c7e@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <8ea4ebe9-bb4f-67e2-c7cb-7404598b7c7e@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 03 Jan 2019 14:58:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103145758.JU-1rN0Sxeg9n0yelepKcSCX6wEgtWAUsKPb1Fknukk@z>

On Wed, Jan 02, 2019 at 07:27:17PM -0800, John Hubbard wrote:
> On 1/2/19 5:55 PM, Jerome Glisse wrote:
> > On Wed, Dec 19, 2018 at 12:08:56PM +0100, Jan Kara wrote:
> >> On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
> >>> On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
> >>>> OK, so let's take another look at Jerome's _mapcount idea all by itself (using
> >>>> *only* the tracking pinned pages aspect), given that it is the lightest weight
> >>>> solution for that.  
> >>>>
> >>>> So as I understand it, this would use page->_mapcount to store both the real
> >>>> mapcount, and the dma pinned count (simply added together), but only do so for
> >>>> file-backed (non-anonymous) pages:
> >>>>
> >>>>
> >>>> __get_user_pages()
> >>>> {
> >>>> 	...
> >>>> 	get_page(page);
> >>>>
> >>>> 	if (!PageAnon)
> >>>> 		atomic_inc(page->_mapcount);
> >>>> 	...
> >>>> }
> >>>>
> >>>> put_user_page(struct page *page)
> >>>> {
> >>>> 	...
> >>>> 	if (!PageAnon)
> >>>> 		atomic_dec(&page->_mapcount);
> >>>>
> >>>> 	put_page(page);
> >>>> 	...
> >>>> }
> >>>>
> >>>> ...and then in the various consumers of the DMA pinned count, we use page_mapped(page)
> >>>> to see if any mapcount remains, and if so, we treat it as DMA pinned. Is that what you 
> >>>> had in mind?
> >>>
> >>> Mostly, with the extra two observations:
> >>>     [1] We only need to know the pin count when a write back kicks in
> >>>     [2] We need to protect GUP code with wait_for_write_back() in case
> >>>         GUP is racing with a write back that might not the see the
> >>>         elevated mapcount in time.
> >>>
> >>> So for [2]
> >>>
> >>> __get_user_pages()
> >>> {
> >>>     get_page(page);
> >>>
> >>>     if (!PageAnon) {
> >>>         atomic_inc(page->_mapcount);
> >>> +       if (PageWriteback(page)) {
> >>> +           // Assume we are racing and curent write back will not see
> >>> +           // the elevated mapcount so wait for current write back and
> >>> +           // force page fault
> >>> +           wait_on_page_writeback(page);
> >>> +           // force slow path that will fault again
> >>> +       }
> >>>     }
> >>> }
> >>
> >> This is not needed AFAICT. __get_user_pages() gets page reference (and it
> >> should also increment page->_mapcount) under PTE lock. So at that point we
> >> are sure we have writeable PTE nobody can change. So page_mkclean() has to
> >> block on PTE lock to make PTE read-only and only after going through all
> >> PTEs like this, it can check page->_mapcount. So the PTE lock provides
> >> enough synchronization.
> >>
> >>> For [1] only needing pin count during write back turns page_mkclean into
> >>> the perfect spot to check for that so:
> >>>
> >>> int page_mkclean(struct page *page)
> >>> {
> >>>     int cleaned = 0;
> >>> +   int real_mapcount = 0;
> >>>     struct address_space *mapping;
> >>>     struct rmap_walk_control rwc = {
> >>>         .arg = (void *)&cleaned,
> >>>         .rmap_one = page_mkclean_one,
> >>>         .invalid_vma = invalid_mkclean_vma,
> >>> +       .mapcount = &real_mapcount,
> >>>     };
> >>>
> >>>     BUG_ON(!PageLocked(page));
> >>>
> >>>     if (!page_mapped(page))
> >>>         return 0;
> >>>
> >>>     mapping = page_mapping(page);
> >>>     if (!mapping)
> >>>         return 0;
> >>>
> >>>     // rmap_walk need to change to count mapping and return value
> >>>     // in .mapcount easy one
> >>>     rmap_walk(page, &rwc);
> >>>
> >>>     // Big fat comment to explain what is going on
> >>> +   if ((page_mapcount(page) - real_mapcount) > 0) {
> >>> +       SetPageDMAPined(page);
> >>> +   } else {
> >>> +       ClearPageDMAPined(page);
> >>> +   }
> >>
> >> This is the detail I'm not sure about: Why cannot rmap_walk_file() race
> >> with e.g. zap_pte_range() which decrements page->_mapcount and thus the
> >> check we do in page_mkclean() is wrong?
> >>
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
> > 
> >     // rmap_walk need to change to count mapping and return value
> >     // in .mapcount easy one
> >     rmap_walk(page, &rwc);
> > 
> > +   if (PageDMAPined(page)) {
> > +       int rc2;
> > +
> > +       if (mapcount1 == real_count) {
> > +           /* Page is no longer pin, no zap pte race */
> > +           ClearPageDMAPined(page);
> > +           goto out;
> > +       }
> > +       /* No new mapping of the page so mp1 < rc is illegal. */
> > +       VM_BUG_ON(mapcount1 < real_count);
> > +       /* Page might be pin. */
> > +       mapcount2 = page_mapcount(page);
> > +       if (mapcount2 > real_count) {
> > +           /* Page is pin for sure. */
> > +           goto out;
> > +       }
> > +       /* We had a race with zap pte we need to rewalk again. */
> > +       rc2 = real_mapcount;
> > +       real_mapcount = 0;
> > +       rwc.rmap_one = page_pin_one;
> > +       rmap_walk(page, &rwc);
> > +       if (mapcount2 <= (real_count + rc2)) {
> > +           /* Page is no longer pin */
> > +           ClearPageDMAPined(page);
> > +       }
> > +       /* At this point the page pin flag reflect pin status of the page */
> 
> Until...what? In other words, what is providing synchronization here?

It can still race with put_user_page() but this is fine ie it means
that a racing put_user_page() will not be taken into account and that
page will still be consider pin for this round, even thought the last
pin might just have been drop.

It is all about getting the "real" mapcount value at one point in
time while racing with something that zap ptes. So what you want is
being able to count the number of zap ptes that are racing with you.
If there is none than you know you have a stable real mapcount value,
if there is you can account them in real mapcount and compare it to
the mapcount value of the page. Worst case is you report a page as
pin while it has just been release but next write back will catch
that (unless page is GUPed again).

Cheers,
Jérôme

