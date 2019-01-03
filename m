Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C14DC43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 09:27:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CD4F2073D
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 09:27:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CD4F2073D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A535E8E0063; Thu,  3 Jan 2019 04:26:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A020C8E0002; Thu,  3 Jan 2019 04:26:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CA658E0063; Thu,  3 Jan 2019 04:26:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 480738E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 04:26:59 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id b17so34347988pfc.11
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 01:26:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=vXKbmOIfFs0hZeCYkn2j3EVI3Y5AHLs5tpCpmU+8MOI=;
        b=FKc4PtF8UIhf6MMtQ+juEifRr8HFGb0GhaqT4MF3+jjO7SG+1YeV4KynHhFK/wEjxJ
         FeCXMcvI/2+0whcEQunPIZ9KOebmCsT7sE3/ZBjFy+SYqrjI/wdDHU3NXKHdAhgB8T3G
         ovZvMESpEPGiO6pQbAMUonTMaDaPaBawA99O2TsxVrxFAibk6LqCa1OubcxpHgB9H0o5
         rgLEJHlKOLxv+DAe9obnEn8loHT0d2EE2iH5TNLA87gUrn1FZ6/BWv93iBWmnKVlu9z9
         HcUNLLT/SOWNygtiB5/bfJYqb/t6RKdq33vMv4x+k4V6T/GAl+jw/qndjR7F3OUiUxjs
         aTDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AJcUuke+7VU4JdqCr8pPn2NqdPamm+dtpi0Lq8jiFOTwaAvnjXQ17FYa
	8m7kkyngq64PNgHReduUUGR50KvkkUfaZP0QPsEN+KwjhA6Cl0rgPHLeQRFdQ/fHiHXSH/+7TGT
	vSojAzTV82JqcsKrUAyY8H7OWArL/NUNoVKxlVYFIzBFrFp8Rr/fZL0GScfzPlrv6Vw==
X-Received: by 2002:a63:5320:: with SMTP id h32mr44394090pgb.414.1546507618907;
        Thu, 03 Jan 2019 01:26:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN71GmV/fV9KeFDUDScTxUUVcgPMRxTeucHt6GOJNKfo8o/sU+ZYms0+MCz//mFyymM4tcju
X-Received: by 2002:a63:5320:: with SMTP id h32mr44394049pgb.414.1546507617744;
        Thu, 03 Jan 2019 01:26:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546507617; cv=none;
        d=google.com; s=arc-20160816;
        b=0A5eZesfde/L5itORjiSxUMx8+kZ1zFxXx1Hn+rBqBGYeAywZjJ/mPRLXWRsDsdcPZ
         J1wBsLCkN128S4igqh8Q/hqxrIVvsDquKh8d0c5M5wJTL6TgQvgwmtO1t0vPCYwjl/++
         56NxT3yKPnFqREXGxywq9Yb5Ng7XLAWW3AAB9MjMRTGXDZgGtS3S3frwSGKLsSRcRUvY
         g/sDvvx+oXhejjCo9ArLy5fvnzFYkH26iJ7DnLBHUzkvuf43jWNUUDnTz0f/1YeFZBAq
         5LjCp3mZTJXOZ5wtHShxYwq8CKR+05tHzmQQZhb97DFLj9L8O9ff6qlpx18Sl3We/PBZ
         zz1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=vXKbmOIfFs0hZeCYkn2j3EVI3Y5AHLs5tpCpmU+8MOI=;
        b=wdPX8FfxsN2a77LLnniLQTZvAD6emBReXJEhUwRDs/e8dUJ+M1R4R9K9xIhZLicdh4
         tKjbhaDF+fmOr/dNW+esYmo6Zy0IhpGFEMkzUTEdTTvzulxCfMco2dZNKWUlBp5apXNu
         nTdblJvWehIaGNBOcWbrTjOrbgJRiGzN+u4ckeVg5zHCg4fvcqKfc3EhO6TZ0LJThRLv
         Rv0Aktsb/L2N82FLGB2rVjV7XgBX5psDCc1idQrNGfG13YGB7pt/K2CaniV8IEm4JAz9
         pGdlTeEjga+WEvgF7WjnHOIthe/RPE9cIZutDlQ76VnHbmWP3pGBKyn1uU4GVWPPS/RX
         NUZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x64si50893378pfx.87.2019.01.03.01.26.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 01:26:57 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8B68FACC8;
	Thu,  3 Jan 2019 09:26:55 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 523F21E1588; Thu,  3 Jan 2019 10:26:54 +0100 (CET)
Date: Thu, 3 Jan 2019 10:26:54 +0100
From: Jan Kara <jack@suse.cz>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>,
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
Message-ID: <20190103092654.GA31370@quack2.suse.cz>
References: <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
 <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
 <20181219020723.GD4347@redhat.com>
 <20181219110856.GA18345@quack2.suse.cz>
 <20190103015533.GA15619@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190103015533.GA15619@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103092654.9dhEi1Qjf7csqpMZ-pPmIGXaXMPBWXNEGAcbWjU1tl8@z>

On Wed 02-01-19 20:55:33, Jerome Glisse wrote:
> On Wed, Dec 19, 2018 at 12:08:56PM +0100, Jan Kara wrote:
> > On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
> > > On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
> > > > OK, so let's take another look at Jerome's _mapcount idea all by itself (using
> > > > *only* the tracking pinned pages aspect), given that it is the lightest weight
> > > > solution for that.  
> > > > 
> > > > So as I understand it, this would use page->_mapcount to store both the real
> > > > mapcount, and the dma pinned count (simply added together), but only do so for
> > > > file-backed (non-anonymous) pages:
> > > > 
> > > > 
> > > > __get_user_pages()
> > > > {
> > > > 	...
> > > > 	get_page(page);
> > > > 
> > > > 	if (!PageAnon)
> > > > 		atomic_inc(page->_mapcount);
> > > > 	...
> > > > }
> > > > 
> > > > put_user_page(struct page *page)
> > > > {
> > > > 	...
> > > > 	if (!PageAnon)
> > > > 		atomic_dec(&page->_mapcount);
> > > > 
> > > > 	put_page(page);
> > > > 	...
> > > > }
> > > > 
> > > > ...and then in the various consumers of the DMA pinned count, we use page_mapped(page)
> > > > to see if any mapcount remains, and if so, we treat it as DMA pinned. Is that what you 
> > > > had in mind?
> > > 
> > > Mostly, with the extra two observations:
> > >     [1] We only need to know the pin count when a write back kicks in
> > >     [2] We need to protect GUP code with wait_for_write_back() in case
> > >         GUP is racing with a write back that might not the see the
> > >         elevated mapcount in time.
> > > 
> > > So for [2]
> > > 
> > > __get_user_pages()
> > > {
> > >     get_page(page);
> > > 
> > >     if (!PageAnon) {
> > >         atomic_inc(page->_mapcount);
> > > +       if (PageWriteback(page)) {
> > > +           // Assume we are racing and curent write back will not see
> > > +           // the elevated mapcount so wait for current write back and
> > > +           // force page fault
> > > +           wait_on_page_writeback(page);
> > > +           // force slow path that will fault again
> > > +       }
> > >     }
> > > }
> > 
> > This is not needed AFAICT. __get_user_pages() gets page reference (and it
> > should also increment page->_mapcount) under PTE lock. So at that point we
> > are sure we have writeable PTE nobody can change. So page_mkclean() has to
> > block on PTE lock to make PTE read-only and only after going through all
> > PTEs like this, it can check page->_mapcount. So the PTE lock provides
> > enough synchronization.
> > 
> > > For [1] only needing pin count during write back turns page_mkclean into
> > > the perfect spot to check for that so:
> > > 
> > > int page_mkclean(struct page *page)
> > > {
> > >     int cleaned = 0;
> > > +   int real_mapcount = 0;
> > >     struct address_space *mapping;
> > >     struct rmap_walk_control rwc = {
> > >         .arg = (void *)&cleaned,
> > >         .rmap_one = page_mkclean_one,
> > >         .invalid_vma = invalid_mkclean_vma,
> > > +       .mapcount = &real_mapcount,
> > >     };
> > > 
> > >     BUG_ON(!PageLocked(page));
> > > 
> > >     if (!page_mapped(page))
> > >         return 0;
> > > 
> > >     mapping = page_mapping(page);
> > >     if (!mapping)
> > >         return 0;
> > > 
> > >     // rmap_walk need to change to count mapping and return value
> > >     // in .mapcount easy one
> > >     rmap_walk(page, &rwc);
> > > 
> > >     // Big fat comment to explain what is going on
> > > +   if ((page_mapcount(page) - real_mapcount) > 0) {
> > > +       SetPageDMAPined(page);
> > > +   } else {
> > > +       ClearPageDMAPined(page);
> > > +   }
> > 
> > This is the detail I'm not sure about: Why cannot rmap_walk_file() race
> > with e.g. zap_pte_range() which decrements page->_mapcount and thus the
> > check we do in page_mkclean() is wrong?
> > 
> 
> Ok so i found a solution for that. First GUP must wait for racing
> write back. If GUP see a valid write-able PTE and the page has
> write back flag set then it must back of as if the PTE was not
> valid to force fault. It is just a race with page_mkclean and we
> want ordering between the two. Note this is not strictly needed
> so we can relax that but i believe this ordering is better to do
> in GUP rather then having each single user of GUP test for this
> to avoid the race.
> 
> GUP increase mapcount only after checking that it is not racing
> with writeback it also set a page flag (SetPageDMAPined(page)).
> 
> When clearing a write-able pte we set a special entry inside the
> page table (might need a new special swap type for this) and change
> page_mkclean_one() to clear to 0 those special entry.
> 
> 
> Now page_mkclean:
> 
> int page_mkclean(struct page *page)
> {
>     int cleaned = 0;
> +   int real_mapcount = 0;
>     struct address_space *mapping;
>     struct rmap_walk_control rwc = {
>         .arg = (void *)&cleaned,
>         .rmap_one = page_mkclean_one,
>         .invalid_vma = invalid_mkclean_vma,
> +       .mapcount = &real_mapcount,
>     };
> +   int mapcount1, mapcount2;
> 
>     BUG_ON(!PageLocked(page));
> 
>     if (!page_mapped(page))
>         return 0;
> 
>     mapping = page_mapping(page);
>     if (!mapping)
>         return 0;
> 
> +   mapcount1 = page_mapcount(page);
>     // rmap_walk need to change to count mapping and return value
>     // in .mapcount easy one
>     rmap_walk(page, &rwc);

So what prevents GUP_fast() to grab reference here and the test below would
think the page is not pinned? Or do you assume that every page_mkclean()
call will be protected by PageWriteback (currently it is not) so that
GUP_fast() blocks / bails out?

But I think that detecting pinned pages with small false positive rate is
OK. The extra page bouncing will cost some performance but if it is rare,
then we are OK. So I think we can go for the simple version of detecting
pinned pages as you mentioned in some earlier email. We just have to be
sure there are no false negatives.

								Honza

> +   if (PageDMAPined(page)) {
> +       int rc2;
> +
> +       if (mapcount1 == real_count) {
> +           /* Page is no longer pin, no zap pte race */
> +           ClearPageDMAPined(page);
> +           goto out;
> +       }
> +       /* No new mapping of the page so mp1 < rc is illegal. */
> +       VM_BUG_ON(mapcount1 < real_count);
> +       /* Page might be pin. */
> +       mapcount2 = page_mapcount(page);
> +       if (mapcount2 > real_count) {
> +           /* Page is pin for sure. */
> +           goto out;
> +       }
> +       /* We had a race with zap pte we need to rewalk again. */
> +       rc2 = real_mapcount;
> +       real_mapcount = 0;
> +       rwc.rmap_one = page_pin_one;
> +       rmap_walk(page, &rwc);
> +       if (mapcount2 <= (real_count + rc2)) {
> +           /* Page is no longer pin */
> +           ClearPageDMAPined(page);
> +       }
> +       /* At this point the page pin flag reflect pin status of the page */
> +   }
> +
> +out:
>     ...
> }
> 
> The page_pin_one() function count the number of special PTE entry so
> which match the count of pte that have been zapped since the first
> reverse map walk.
> 
> So worst case a page that was pin by a GUP would need 2 reverse map
> walk during page_mkclean(). Moreover this is only needed if we race
> with something that clear pte. I believe this is an acceptable worst
> case. I will work on some RFC patchset next week (once i am down with
> email catch up).
> 
> 
> I do not think i made mistake here, i have been torturing my mind
> trying to think of any race scenario and i believe it holds to any
> racing zap and page_mkclean()
> 
> Cheers,
> Jérôme
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

