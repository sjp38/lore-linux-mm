Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 49E748E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 09:32:54 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e12so9057668edd.16
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 06:32:54 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6si2139075edk.66.2019.01.14.06.32.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 06:32:52 -0800 (PST)
Date: Mon, 14 Jan 2019 15:32:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9] mm/page_alloc.c: memory_hotplug: free pages as higher
 order
Message-ID: <20190114143251.GI21345@dhcp22.suse.cz>
References: <1547098543-26452-1-git-send-email-arunks@codeaurora.org>
 <f65b1b22426855ff261b3af719e58eded576a168.camel@linux.intel.com>
 <fa3dc06536a8ba980c4434806204017a@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa3dc06536a8ba980c4434806204017a@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>, arunks.linux@gmail.com, akpm@linux-foundation.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On Mon 14-01-19 19:29:39, Arun KS wrote:
> On 2019-01-10 21:53, Alexander Duyck wrote:
[...]
> > Couldn't you just do something like the following:
> > 		if ((end - start) >= (1UL << (MAX_ORDER - 1))
> > 			order = MAX_ORDER - 1;
> > 		else
> > 			order = __fls(end - start);
> > 
> > I would think this would save you a few steps in terms of conversions
> > and such since you are already working in page frame numbers anyway so
> > a block of 8 pfns would represent an order 3 page wouldn't it?
> > 
> > Also it seems like an alternative to using "end" would be to just track
> > nr_pages. Then you wouldn't have to do the "end - start" math in a few
> > spots as long as you remembered to decrement nr_pages by the amount you
> > increment start by.
> 
> Thanks for that. How about this?
> 
> static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
> {
>         unsigned long end = start + nr_pages;
>         int order;
> 
>         while (nr_pages) {
>                 if (nr_pages >= (1UL << (MAX_ORDER - 1)))
>                         order = MAX_ORDER - 1;
>                 else
>                         order = __fls(nr_pages);
> 
>                 (*online_page_callback)(pfn_to_page(start), order);
>                 nr_pages -= (1UL << order);
>                 start += (1UL << order);
>         }
>         return end - start;
> }

I find this much less readable so if this is really a big win
performance wise then make it a separate patch with some nubbers please.

-- 
Michal Hocko
SUSE Labs
