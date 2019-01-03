Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC4B0C43612
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 01:55:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73DDB2073F
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 01:55:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73DDB2073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11C3E8E0054; Wed,  2 Jan 2019 20:55:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CC578E0002; Wed,  2 Jan 2019 20:55:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFD148E0054; Wed,  2 Jan 2019 20:55:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C27238E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 20:55:42 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y83so38293301qka.7
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 17:55:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=cQJXKKW1cwl5y9scV6x9SwXrJt7HhkHji7cmHswF870=;
        b=Qo4mGNuDlMlxAgvJgBr15JctuWxp/cI/aCCdN0x2kW2U6a+ptF0HJqgr665ye3I7CK
         NO+pT/AITOvoona5n/4NM/AKDcrkrSdjirxItVUN9817qnTHkuEsX8+Clo9rsljmZjET
         Wb4JnJBYPR7F+Rc7ozTf/KLlO95EEgyhR4Ruy5m/FyxKGYcG+CKkq2KvZ+0g4Q2xE1ac
         7iLYSU8Ja0lLA9esLY5+6EtCogPIEvy79IKlpDpvCwUCtx0WLSo9ey1N0kCQ+lCD4YoW
         U/wl8GFb0dyTr36ZrFQ9486iDFOUUUMd3sBNlXTo7/Dp6Z52CiWXkriLXqzs/CwGesCF
         M1jQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdE2ehNM18tDdmPTBgbRa6Im/M+NppbhTowO2tUukz2LLJYoSoD
	mSkXJp4Qt9rkShGIKBuFGuDEYo3l+z1XBZKQNOW1WCy/CmhygsL7zjkmLPK+ravHoXMsYpyeaJ0
	JkZgPn+ouXG73N/V9FiZVWO/XVuV3KBOJXAU0Va0W1md8Gp49tf6LLOag5ogSN5qYtA==
X-Received: by 2002:a37:3388:: with SMTP id z130mr40513578qkz.51.1546480542502;
        Wed, 02 Jan 2019 17:55:42 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7zEj7OU0un1TlESrF0T+Hc3Xw55ugBjhtauvAp1NlDbpBjnxjxJcbsl6eHtpY7fJEtpG0a
X-Received: by 2002:a37:3388:: with SMTP id z130mr40513549qkz.51.1546480541465;
        Wed, 02 Jan 2019 17:55:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546480541; cv=none;
        d=google.com; s=arc-20160816;
        b=Jq2w18MsvfIpMTQ+b6lI2GUOUtkHxXZAiysDIqMyLhSnnm0XeY33mVWsbwZ67w24Qy
         5EnD3Aaj3e2ELS3eEAvvnrl/EMC54Pe4q/t4D4v/qaim9n6DiSmJ4fEPG48EwEYfDXGu
         N6xyB0K8jUoxms6llQNH44E8jPGp52OjQojt4k2P/M7RrXdHVvO10qmyyqe9yMeJemPg
         Z9sp6Z/alRVAwXNab6ZAWooHPJydrRO8fkCBoNQBpU9l/MYf8N0UbEKi7+f1licbJ6+Z
         KjmJ2rwpD/kDO7+nzk18BEixKrE12eDap/nXz58FBkPLipmzgcthcaZXWk7if4d6KtZK
         Srcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=cQJXKKW1cwl5y9scV6x9SwXrJt7HhkHji7cmHswF870=;
        b=ML+Lo6hJHwN9n0ZQncrvaPpW1HOIsm0Ot/SbfiRElt9Sc+/6USD+nHPbvjWlDdoo6l
         uFbWz8xmdK7S/yJ28U2brx9OkVDHywBsEIRc4+0TZH4vJooFOYHScOYl5z3VZiLfTqst
         ETGjYF/JDBucSzk1d0rP2F43oATCtYrNnLfafFu85I5C4Zs+3489C8HJNZVebkrZLoKw
         p4B7G3T1f6wUUQFepNciIGCbRDOJpEW9w5OKcoMWML1SCochy/OLq+DHzvfPSiuV+tnQ
         IKe+lAcGnzUbl3Odsn4GdmBWQETgzwM/VgU35UW0lleC8oQW/wHWVjJuVrAF6PMIv8hD
         vTZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c18si1122632qvb.181.2019.01.02.17.55.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 17:55:41 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EBAAE2DACC3;
	Thu,  3 Jan 2019 01:55:39 +0000 (UTC)
Received: from redhat.com (ovpn-123-62.rdu2.redhat.com [10.10.123.62])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 24A825D9C9;
	Thu,  3 Jan 2019 01:55:35 +0000 (UTC)
Date: Wed, 2 Jan 2019 20:55:33 -0500
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
Message-ID: <20190103015533.GA15619@redhat.com>
References: <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
 <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
 <20181219020723.GD4347@redhat.com>
 <20181219110856.GA18345@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181219110856.GA18345@quack2.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 03 Jan 2019 01:55:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103015533.2CnmyaaxAtnV4bPXg9YmNTlmuSYtiid4FpDVzutvRNw@z>

On Wed, Dec 19, 2018 at 12:08:56PM +0100, Jan Kara wrote:
> On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
> > On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
> > > OK, so let's take another look at Jerome's _mapcount idea all by itself (using
> > > *only* the tracking pinned pages aspect), given that it is the lightest weight
> > > solution for that.  
> > > 
> > > So as I understand it, this would use page->_mapcount to store both the real
> > > mapcount, and the dma pinned count (simply added together), but only do so for
> > > file-backed (non-anonymous) pages:
> > > 
> > > 
> > > __get_user_pages()
> > > {
> > > 	...
> > > 	get_page(page);
> > > 
> > > 	if (!PageAnon)
> > > 		atomic_inc(page->_mapcount);
> > > 	...
> > > }
> > > 
> > > put_user_page(struct page *page)
> > > {
> > > 	...
> > > 	if (!PageAnon)
> > > 		atomic_dec(&page->_mapcount);
> > > 
> > > 	put_page(page);
> > > 	...
> > > }
> > > 
> > > ...and then in the various consumers of the DMA pinned count, we use page_mapped(page)
> > > to see if any mapcount remains, and if so, we treat it as DMA pinned. Is that what you 
> > > had in mind?
> > 
> > Mostly, with the extra two observations:
> >     [1] We only need to know the pin count when a write back kicks in
> >     [2] We need to protect GUP code with wait_for_write_back() in case
> >         GUP is racing with a write back that might not the see the
> >         elevated mapcount in time.
> > 
> > So for [2]
> > 
> > __get_user_pages()
> > {
> >     get_page(page);
> > 
> >     if (!PageAnon) {
> >         atomic_inc(page->_mapcount);
> > +       if (PageWriteback(page)) {
> > +           // Assume we are racing and curent write back will not see
> > +           // the elevated mapcount so wait for current write back and
> > +           // force page fault
> > +           wait_on_page_writeback(page);
> > +           // force slow path that will fault again
> > +       }
> >     }
> > }
> 
> This is not needed AFAICT. __get_user_pages() gets page reference (and it
> should also increment page->_mapcount) under PTE lock. So at that point we
> are sure we have writeable PTE nobody can change. So page_mkclean() has to
> block on PTE lock to make PTE read-only and only after going through all
> PTEs like this, it can check page->_mapcount. So the PTE lock provides
> enough synchronization.
> 
> > For [1] only needing pin count during write back turns page_mkclean into
> > the perfect spot to check for that so:
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
> >     // rmap_walk need to change to count mapping and return value
> >     // in .mapcount easy one
> >     rmap_walk(page, &rwc);
> > 
> >     // Big fat comment to explain what is going on
> > +   if ((page_mapcount(page) - real_mapcount) > 0) {
> > +       SetPageDMAPined(page);
> > +   } else {
> > +       ClearPageDMAPined(page);
> > +   }
> 
> This is the detail I'm not sure about: Why cannot rmap_walk_file() race
> with e.g. zap_pte_range() which decrements page->_mapcount and thus the
> check we do in page_mkclean() is wrong?
> 

Ok so i found a solution for that. First GUP must wait for racing
write back. If GUP see a valid write-able PTE and the page has
write back flag set then it must back of as if the PTE was not
valid to force fault. It is just a race with page_mkclean and we
want ordering between the two. Note this is not strictly needed
so we can relax that but i believe this ordering is better to do
in GUP rather then having each single user of GUP test for this
to avoid the race.

GUP increase mapcount only after checking that it is not racing
with writeback it also set a page flag (SetPageDMAPined(page)).

When clearing a write-able pte we set a special entry inside the
page table (might need a new special swap type for this) and change
page_mkclean_one() to clear to 0 those special entry.


Now page_mkclean:

int page_mkclean(struct page *page)
{
    int cleaned = 0;
+   int real_mapcount = 0;
    struct address_space *mapping;
    struct rmap_walk_control rwc = {
        .arg = (void *)&cleaned,
        .rmap_one = page_mkclean_one,
        .invalid_vma = invalid_mkclean_vma,
+       .mapcount = &real_mapcount,
    };
+   int mapcount1, mapcount2;

    BUG_ON(!PageLocked(page));

    if (!page_mapped(page))
        return 0;

    mapping = page_mapping(page);
    if (!mapping)
        return 0;

+   mapcount1 = page_mapcount(page);

    // rmap_walk need to change to count mapping and return value
    // in .mapcount easy one
    rmap_walk(page, &rwc);

+   if (PageDMAPined(page)) {
+       int rc2;
+
+       if (mapcount1 == real_count) {
+           /* Page is no longer pin, no zap pte race */
+           ClearPageDMAPined(page);
+           goto out;
+       }
+       /* No new mapping of the page so mp1 < rc is illegal. */
+       VM_BUG_ON(mapcount1 < real_count);
+       /* Page might be pin. */
+       mapcount2 = page_mapcount(page);
+       if (mapcount2 > real_count) {
+           /* Page is pin for sure. */
+           goto out;
+       }
+       /* We had a race with zap pte we need to rewalk again. */
+       rc2 = real_mapcount;
+       real_mapcount = 0;
+       rwc.rmap_one = page_pin_one;
+       rmap_walk(page, &rwc);
+       if (mapcount2 <= (real_count + rc2)) {
+           /* Page is no longer pin */
+           ClearPageDMAPined(page);
+       }
+       /* At this point the page pin flag reflect pin status of the page */
+   }
+
+out:
    ...
}

The page_pin_one() function count the number of special PTE entry so
which match the count of pte that have been zapped since the first
reverse map walk.

So worst case a page that was pin by a GUP would need 2 reverse map
walk during page_mkclean(). Moreover this is only needed if we race
with something that clear pte. I believe this is an acceptable worst
case. I will work on some RFC patchset next week (once i am down with
email catch up).


I do not think i made mistake here, i have been torturing my mind
trying to think of any race scenario and i believe it holds to any
racing zap and page_mkclean()

Cheers,
Jérôme

