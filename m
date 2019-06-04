Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0763FC28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 20:31:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE7A4208CB
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 20:31:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE7A4208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53AD26B0271; Tue,  4 Jun 2019 16:31:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C4C36B0273; Tue,  4 Jun 2019 16:31:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33ED76B0274; Tue,  4 Jun 2019 16:31:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC53D6B0271
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 16:31:39 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z2so16951776pfb.12
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 13:31:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SuLWDoC/s8/821tRl+sVU8TRKA4t4pcUdnJu/eqSVxA=;
        b=smDG6uDOkHU5D7DbrYd+jZGzXssg3rZz4BSltyHeHecx7t4JkM59Qm3fGGNH2ygSHP
         sqY0C8ctbGgdLhAmBl6rcNrusu8flO4plcMib72Cjpk0UeRw4JVWkFNyTt6AcV/F23VI
         ZDzFTU7Op576on7Dr7M1ioJM/a9qeMkXBuakf446yUuCgIZFWjh9P9K3pwiXmldLYB8e
         7RmlNKtVD63pOKJx8y9l4YGURDnAKi0Br+TOkz/Y5FZCttO4zRyBWCEOU8lhuBqNLOlk
         uc0ckgR1oGp2KurTyS8tdxBwqgbynsz9PrwFsarJy/8SSiSxN9IqX99OlS40uuT0Toke
         lAjA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV6L5sbZ24//sDqNcOev9BL0RA6Jc8VFI4w1zwfVzPpGibg1gSC
	s9h55l+nmMf5jYexPkhROzi/4dkQ43I3IpcIl7bNEA2n0Bcwj8NVF9n0zVwZFVIDQj9s9Y1edpM
	vePKW3AqX6Kyv1mAoNQx0eXhHmg630Jg/3QpnsUf00sfwGGvrr2hcXDF2SB0T93aRbQ==
X-Received: by 2002:a17:902:ac82:: with SMTP id h2mr39216554plr.303.1559680299595;
        Tue, 04 Jun 2019 13:31:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZFZ/aDJbW1qtwvHeTvJ84VaFb9KnmfrLbXJZyTgf6lMJ0TDQ+CgLhWXtwDyQxbpK91v31
X-Received: by 2002:a17:902:ac82:: with SMTP id h2mr39216445plr.303.1559680298660;
        Tue, 04 Jun 2019 13:31:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559680298; cv=none;
        d=google.com; s=arc-20160816;
        b=0oRuHhU+wZWUycxCKuZl3JFllkKLcgHsKJpQAo/aIi3fCcdM+m2d3umQkiqJD/tiQK
         eC9u12zLxfNsUSrEALtSJFzeuMybNyIl7bQpxCH3VDr69s8+hQVHnxDQTQUpC+VcZnzd
         q6e8pFUw37LkT9Mnf9YVwwowlKa5AOxw/GqtQJwSAgApAZnjPVWIHpf0X2lhL7tKvaoR
         Z13inH2EpYpN0KACjKspLOW/d3HhBuMNdD+eONlpG3b0cjKGS5+fBBTo9gTWWzkomuPo
         UEKXDmayjJPsLm4QRTjk3NrahZk845x4N2wAKdljUVQi7EJfQ6XNei9QOB+FmgasU5hO
         OR5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SuLWDoC/s8/821tRl+sVU8TRKA4t4pcUdnJu/eqSVxA=;
        b=AnQNd1FCZkDa6cpQJTtOdGRG64Xq+KGMQiwMHfWTvjT5dVLY/f1zs915o01UrJ90B5
         NSOId12WbYHWv6+gzcByZaK5XAutpAV05xsTU6mhhiuO3mQiLWW9n2JtJ3C5XeDmlVvL
         kXatm0Y65uRPAHv4NROZSHT1sFZO237ph0h5lxpz//wz26mwxYS27a4UEI0B+7zpkvvU
         qlFvlIjyZpxtqiHuYi+WkKsgwOG4V4TEczAKDRBFWUuHTZolVC97Y1KOo73/4+IVsiQM
         YU0Sb6ME9Mms9Z0y0L8JFbE3scANpkxFcpmlDHkTZ2o/oPimEcyMDMlYC0u55SD5Kw2U
         KBDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id r14si15147151pjp.95.2019.06.04.13.31.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 13:31:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Jun 2019 13:31:38 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga004.jf.intel.com with ESMTP; 04 Jun 2019 13:31:37 -0700
Date: Tue, 4 Jun 2019 13:32:47 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v3] mm/swap: Fix release_pages() when releasing devmap
 pages
Message-ID: <20190604203247.GB3980@iweiny-DESK2.sc.intel.com>
References: <20190604164813.31514-1-ira.weiny@intel.com>
 <cfd74a0f-71b5-1ece-80af-7f415321d5c1@nvidia.com>
 <CAPcyv4hmN7M3Y1HzVGSi9JuYKUUmvBRgxmkdYdi_6+H+eZAyHA@mail.gmail.com>
 <4d97645c-0e55-37c0-1a16-8649706b9e78@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4d97645c-0e55-37c0-1a16-8649706b9e78@nvidia.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 01:17:42PM -0700, John Hubbard wrote:
> On 6/4/19 1:11 PM, Dan Williams wrote:
> > On Tue, Jun 4, 2019 at 12:48 PM John Hubbard <jhubbard@nvidia.com> wrote:
> >>
> >> On 6/4/19 9:48 AM, ira.weiny@intel.com wrote:
> >>> From: Ira Weiny <ira.weiny@intel.com>
> >>>
> ...
> >>> diff --git a/mm/swap.c b/mm/swap.c
> >>> index 7ede3eddc12a..6d153ce4cb8c 100644
> >>> --- a/mm/swap.c
> >>> +++ b/mm/swap.c
> >>> @@ -740,15 +740,20 @@ void release_pages(struct page **pages, int nr)
> >>>               if (is_huge_zero_page(page))
> >>>                       continue;
> >>>
> >>> -             /* Device public page can not be huge page */
> >>> -             if (is_device_public_page(page)) {
> >>> +             if (is_zone_device_page(page)) {
> >>>                       if (locked_pgdat) {
> >>>                               spin_unlock_irqrestore(&locked_pgdat->lru_lock,
> >>>                                                      flags);
> >>>                               locked_pgdat = NULL;
> >>>                       }
> >>> -                     put_devmap_managed_page(page);
> >>> -                     continue;
> >>> +                     /*
> >>> +                      * Not all zone-device-pages require special
> >>> +                      * processing.  Those pages return 'false' from
> >>> +                      * put_devmap_managed_page() expecting a call to
> >>> +                      * put_page_testzero()
> >>> +                      */
> >>
> >> Just a documentation tweak: how about:
> >>
> >>                         /*
> >>                          * ZONE_DEVICE pages that return 'false' from
> >>                          * put_devmap_managed_page() do not require special
> >>                          * processing, and instead, expect a call to
> >>                          * put_page_testzero().
> >>                          */
> > 
> > Looks better to me, but maybe just go ahead and list those
> > expectations explicitly. Something like:
> > 
> >                         /*
> >                          * put_devmap_managed_page() only handles
> >                          * ZONE_DEVICE (struct dev_pagemap managed)
> >                          * pages when the hosting dev_pagemap has the
> >                          * ->free() or ->fault() callback handlers
> >                          *  implemented as indicated by
> >                          *  dev_pagemap.type. Otherwise the expectation
> >                          *  is to fall back to a plain decrement /
> >                          *  put_page_testzero().
> >                          */
> 
> I like it--but not here, because it's too much internal detail in a
> call site that doesn't use that level of detail. The call site looks
> at the return value, only.
> 
> Let's instead put that blurb above (or in) the put_devmap_managed_page() 
> routine itself. And leave the blurb that I wrote where it is. And then I
> think everything will have an appropriate level of detail in the right places.

I agree.  This leaves it open that this handles any special processing which is
required.

FWIW the same call is made in put_page() and has no comment so perhaps we are
getting wrapped around the axle for no reason?

Frankly I questioned myself when I mentioned put_page_testzero() as well.  But
I'm ok with Johns suggestion.  My wording was a bit "rushed".  Sorry about
that.  I wanted to remove the word 'fail' from the comment because I think it
is what caught Michal's eye.

Ira

> 
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA
> 

