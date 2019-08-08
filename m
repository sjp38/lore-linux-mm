Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7ADBFC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:41:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FA9D21773
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:41:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FA9D21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAD616B0003; Thu,  8 Aug 2019 19:41:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5E946B0006; Thu,  8 Aug 2019 19:41:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D71E6B0007; Thu,  8 Aug 2019 19:41:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 64A2B6B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:41:41 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id q14so60168800pff.8
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 16:41:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lAiuoRSbc3G5zek5xGU/U2TqjiEOlPLTzlLmSq0oGBg=;
        b=sN+xr6evxwUUqaV4/HdXjNOVGISOuOEx/w7XTqFndXofhVSRWHgNk/USas1xnDnn4K
         oVMLoEdVh/UVqkIAyMsLgImO/DILMsVPQksqhazqZxlER+SM7WKYwjstwu1sD0aLG2Ai
         YY5fXHm2IoTl6fR4xGQ1fHPvXlQwLnsj+aANO+xi6fHfEwnnf/G1rWaiXeWd7UuRY5y7
         i9VCigC4TMzBgJ2dlYZO58fTmS3qziSuOX8OjQgfiXRiQUTGKTIiGLahOWWSYUdDB86n
         PjqTBuvTD+SKgbDErLs2U2nwb1vUAY0GWtNf4s5cUcuqKRc7T/d59lqv7mAAbRQrtogl
         stMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXb23cwkLlhIKeypYbC71FT9RFEQTcZJjxBJ52M7Z/0kM+xtxuS
	mEYrLAI9lrKhbMAmpNXtTVrTjh93nTDuPChwYGnysAPrJX40dL9eh8P2XlCP2HNTv9e5h5iiUsV
	eRyUQjtf889jck1sawEk5dmijdb9b4PwL4Labqe9w53wrOPgAMw1XumYwlHMkrvwkUQ==
X-Received: by 2002:a17:902:7c96:: with SMTP id y22mr16548722pll.39.1565307701073;
        Thu, 08 Aug 2019 16:41:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWkw8Gq7LAS5cWVjnwVwngRqdU/onBYVMn0xzJWpDcddvP5PDmTSgL6tr/zJ+V76CX29/t
X-Received: by 2002:a17:902:7c96:: with SMTP id y22mr16548678pll.39.1565307700215;
        Thu, 08 Aug 2019 16:41:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565307700; cv=none;
        d=google.com; s=arc-20160816;
        b=KAm0TXVMVyQeuurwC1pBYvxAJqL+aqHgQv6TPc3FOcepmOd0NLKrbCct6O56MQz0Kh
         ykPS12FT2kd6gnM/yy2x80cEKT+pqKMM2sfg1zabA67lSOgJD2xCEymR5vCtMPU/tR5X
         EDmvbKNO2NzUOiZFZofdkWpGs5k6Fr4s4/4b2oZHzmRUF1985Y4zR+mNLj5LfT5nlEcm
         3M8pqnZ8BVaVH2+BhIEe+ThEzK/CipDY+NSmO7GdvxR8XPzWKkDDFq9j190fGnIrcMdp
         G1XhBqXeuCLompHZ4YHcEfK/pFA93rFNjlLgWQlmmlaDcM21BXKV+UADt2zpp+142qnh
         eIqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lAiuoRSbc3G5zek5xGU/U2TqjiEOlPLTzlLmSq0oGBg=;
        b=hsO1ldd+I8SKkWXSEkbZn+1+iEqLNdn8LOI9+Q7KsaiolwqnZxNH7qDjAFq+b1L8Ct
         jkIV5bI4b8BHyrhL+upY+T9BJ+3/rF0pB67whatNeT/4fw8+JzYXu5cigea3FmZxlKFf
         eIOPCm9DlMo92YcBQGqSXTXkwMpOt8uR2qVyd+bMUzfJliQplmc6SQEs0xm7l0N6gUgD
         SSd/DKNhqJP8tSkQ5vW/NZFujiR+Jgo5ZB72CPMPaR+RUJyrPD9pexyKgLwfnj4Bq0Pc
         zuXjH4XnjAuEnZN9QghpOX0k1HyoS6HqmuD88XUMLqJAs5pAyHaUc6NnGNaANDfgmdbV
         9iUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id b20si29795653plz.327.2019.08.08.16.41.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 16:41:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Aug 2019 16:41:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,363,1559545200"; 
   d="scan'208";a="203754786"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga002.fm.intel.com with ESMTP; 08 Aug 2019 16:41:38 -0700
Date: Thu, 8 Aug 2019 16:41:38 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Dan Williams <dan.j.williams@intel.com>,
	Daniel Black <daniel@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: Re: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
Message-ID: <20190808234138.GA15908@iweiny-DESK2.sc.intel.com>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
 <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
 <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
 <20190808062155.GF11812@dhcp22.suse.cz>
 <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
 <306128f9-8cc6-761b-9b05-578edf6cce56@nvidia.com>
 <d1ecb0d4-ea6a-637d-7029-687b950b783f@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d1ecb0d4-ea6a-637d-7029-687b950b783f@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 03:59:15PM -0700, John Hubbard wrote:
> On 8/8/19 12:20 PM, John Hubbard wrote:
> > On 8/8/19 4:09 AM, Vlastimil Babka wrote:
> >> On 8/8/19 8:21 AM, Michal Hocko wrote:
> >>> On Wed 07-08-19 16:32:08, John Hubbard wrote:
> >>>> On 8/7/19 4:01 AM, Michal Hocko wrote:
> >>>>> On Mon 05-08-19 15:20:17, john.hubbard@gmail.com wrote:
> >>>>>> From: John Hubbard <jhubbard@nvidia.com>
> >>>> Actually, I think follow_page_mask() gets all the pages, right? And the
> >>>> get_page() in __munlock_pagevec_fill() is there to allow a pagevec_release() 
> >>>> later.
> >>>
> >>> Maybe I am misreading the code (looking at Linus tree) but munlock_vma_pages_range
> >>> calls follow_page for the start address and then if not THP tries to
> >>> fill up the pagevec with few more pages (up to end), do the shortcut
> >>> via manual pte walk as an optimization and use generic get_page there.
> >>
> > 
> > Yes, I see it finally, thanks. :)  
> > 
> >> That's true. However, I'm not sure munlocking is where the
> >> put_user_page() machinery is intended to be used anyway? These are
> >> short-term pins for struct page manipulation, not e.g. dirtying of page
> >> contents. Reading commit fc1d8e7cca2d I don't think this case falls
> >> within the reasoning there. Perhaps not all GUP users should be
> >> converted to the planned separate GUP tracking, and instead we should
> >> have a GUP/follow_page_mask() variant that keeps using get_page/put_page?
> >>  
> > 
> > Interesting. So far, the approach has been to get all the gup callers to
> > release via put_user_page(), but if we add in Jan's and Ira's vaddr_pin_pages()
> > wrapper, then maybe we could leave some sites unconverted.
> > 
> > However, in order to do so, we would have to change things so that we have
> > one set of APIs (gup) that do *not* increment a pin count, and another set
> > (vaddr_pin_pages) that do. 
> > 
> > Is that where we want to go...?
> > 
> 
> Oh, and meanwhile, I'm leaning toward a cheap fix: just use gup_fast() instead
> of get_page(), and also fix the releasing code. So this incremental patch, on
> top of the existing one, should do it:
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index b980e6270e8a..2ea272c6fee3 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -318,18 +318,14 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
>                 /*
>                  * We won't be munlocking this page in the next phase
>                  * but we still need to release the follow_page_mask()
> -                * pin. We cannot do it under lru_lock however. If it's
> -                * the last pin, __page_cache_release() would deadlock.
> +                * pin.
>                  */
> -               pagevec_add(&pvec_putback, pvec->pages[i]);
> +               put_user_page(pages[i]);
>                 pvec->pages[i] = NULL;
>         }
>         __mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
>         spin_unlock_irq(&zone->zone_pgdat->lru_lock);
>  
> -       /* Now we can release pins of pages that we are not munlocking */
> -       pagevec_release(&pvec_putback);
> -

I'm not an expert but this skips a call to lru_add_drain().  Is that ok?

>         /* Phase 2: page munlock */
>         for (i = 0; i < nr; i++) {
>                 struct page *page = pvec->pages[i];
> @@ -394,6 +390,8 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
>         start += PAGE_SIZE;
>         while (start < end) {
>                 struct page *page = NULL;
> +               int ret;
> +
>                 pte++;
>                 if (pte_present(*pte))
>                         page = vm_normal_page(vma, start, *pte);
> @@ -411,7 +409,13 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
>                 if (PageTransCompound(page))
>                         break;
>  
> -               get_page(page);
> +               /*
> +                * Use get_user_pages_fast(), instead of get_page() so that the
> +                * releasing code can unconditionally call put_user_page().
> +                */
> +               ret = get_user_pages_fast(start, 1, 0, &page);
> +               if (ret != 1)
> +                       break;

I like the idea of making this a get/put pair but I'm feeling uneasy about how
this is really supposed to work.

For sure the GUP/PUP was supposed to be separate from [get|put]_page.

Ira
>                 /*
>                  * Increase the address that will be returned *before* the
>                  * eventual break due to pvec becoming full by adding the page
> 
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA

