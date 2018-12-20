Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB198E0003
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 04:12:30 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d41so1648765eda.12
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 01:12:30 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n3si8851775edo.15.2018.12.20.01.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 01:12:28 -0800 (PST)
Date: Thu, 20 Dec 2018 10:12:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181220091228.GB14234@dhcp22.suse.cz>
References: <20181217225113.17864-1-osalvador@suse.de>
 <20181219142528.yx6ravdyzcqp5wtd@master>
 <20181219233914.2fxe26pih26ifvmt@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219233914.2fxe26pih26ifvmt@d104.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 20-12-18 00:39:18, Oscar Salvador wrote:
> On Wed, Dec 19, 2018 at 02:25:28PM +0000, Wei Yang wrote:
> > >-			iter = round_up(iter + 1, 1<<compound_order(page)) - 1;
> > >+			skip_pages = (1 << compound_order(head)) - (page - head);
> > >+			iter = round_up(iter + 1, skip_pages) - 1;
> > 
> > The comment of round_up says round up to next specified power of 2.  And
> > second parameter must be a power of 2.
> > 
> > Look skip_pages not satisfy this.

Yes this is true but the resulting numbers should be correct even for
skips that are not power of 2 AFAIC. Or do you have any counter example?

> 
> At least alloc_gigantic_page() looks for 1GB range, aligned to that.
> But I see that in alloc_contig_range(), the boundaries can differ.
> 
> Anyway, unless I am missing something, I think that we could just
> get rid of the round_up() and do something like:
> 
> <--
> skip_pages = (1 << compound_order(head)) - (page - head);
> iter = skip_pages - 1;
> --
> 
> which looks more simple IMHO.

Agreed!

-- 
Michal Hocko
SUSE Labs
