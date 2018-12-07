Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 44B326B7EDE
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 01:14:32 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id c14so1971523pls.21
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 22:14:32 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si2160800plx.33.2018.12.06.22.14.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 22:14:31 -0800 (PST)
Message-ID: <1544163250.3008.7.camel@suse.de>
Subject: Re: [PATCH] mm, kmemleak: Little optimization while scanning
From: Oscar Salvador <osalvador@suse.de>
Date: Fri, 07 Dec 2018 07:14:10 +0100
In-Reply-To: <20181207041528.xs4xnw6vpsbu5csx@master>
References: <20181206131918.25099-1-osalvador@suse.de>
	 <20181207041528.xs4xnw6vpsbu5csx@master>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com


> > +
> 
> This one maybe not necessary.

Yeah, that is a remind of an include file I used for time measurement.
I hope Andrew can drop that if this is taken.

> > /*
> >  * Kmemleak configuration and common defines.
> >  */
> > @@ -1547,11 +1548,14 @@ static void kmemleak_scan(void)
> > 		unsigned long pfn;
> > 
> > 		for (pfn = start_pfn; pfn < end_pfn; pfn++) {
> > -			struct page *page;
> > +			struct page *page =
> > pfn_to_online_page(pfn);
> > +
> > +			if (!page)
> > +				continue;
> > 
> > -			if (!pfn_valid(pfn))
> > +			/* only scan pages belonging to this node
> > */
> > +			if (page_to_nid(page) != i)
> > 				continue;
> 
> Not farmiliar with this situation. Is this often?
Well, hard to tell how often that happens because that mostly depends
on the Hardware in case of baremetal.
Virtual systems can also have it though.

> 
> > -			page = pfn_to_page(pfn);
> > 			/* only scan if page is in use */
> > 			if (page_count(page) == 0)
> > 				continue;
> > -- 
> > 2.13.7
> 
> 
-- 
Oscar Salvador
SUSE L3
