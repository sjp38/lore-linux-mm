Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35B0B6B026A
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 12:06:56 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id na2so5607752lbb.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 09:06:56 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id j16si2946374wmi.23.2016.06.08.09.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 09:06:55 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id m124so4118232wme.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 09:06:54 -0700 (PDT)
Date: Wed, 8 Jun 2016 18:06:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm/swap.c: flush lru_add pvecs on compound page
 arrival
Message-ID: <20160608160653.GB21838@dhcp22.suse.cz>
References: <1465396537-17277-1-git-send-email-lukasz.odzioba@intel.com>
 <57583A49.30809@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57583A49.30809@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Lukasz Odzioba <lukasz.odzioba@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, vdavydov@parallels.com, mingli199x@qq.com, minchan@kernel.org, lukasz.anaczkowski@intel.com

On Wed 08-06-16 08:31:21, Dave Hansen wrote:
> On 06/08/2016 07:35 AM, Lukasz Odzioba wrote:
> > diff --git a/mm/swap.c b/mm/swap.c
> > index 9591614..3fe4f18 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -391,9 +391,8 @@ static void __lru_cache_add(struct page *page)
> >  	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
> >  
> >  	get_page(page);
> > -	if (!pagevec_space(pvec))
> > +	if (!pagevec_add(pvec, page) || PageCompound(page))
> >  		__pagevec_lru_add(pvec);
> > -	pagevec_add(pvec, page);
> >  	put_cpu_var(lru_add_pvec);
> >  }
> 
> Lukasz,
> 
> Do we have any statistics that tell us how many pages are sitting the
> lru pvecs?  Although this helps the problem overall, don't we still have
> a problem with memory being held in such an opaque place?

Is it really worth bothering when we are talking about 56kB per CPU
(after this patch)?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
