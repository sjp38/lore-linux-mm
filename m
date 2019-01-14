Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 154AF8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 11:41:31 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 202so12916639pgb.6
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 08:41:31 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d90si719093pld.148.2019.01.14.08.41.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 08:41:29 -0800 (PST)
Message-ID: <d242b75461b38f4910ed619fabc0f9b52dce7f8b.camel@linux.intel.com>
Subject: Re: [PATCH v9] mm/page_alloc.c: memory_hotplug: free pages as
 higher order
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 14 Jan 2019 08:41:29 -0800
In-Reply-To: <20190114143251.GI21345@dhcp22.suse.cz>
References: <1547098543-26452-1-git-send-email-arunks@codeaurora.org>
	 <f65b1b22426855ff261b3af719e58eded576a168.camel@linux.intel.com>
	 <fa3dc06536a8ba980c4434806204017a@codeaurora.org>
	 <20190114143251.GI21345@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Arun KS <arunks@codeaurora.org>
Cc: arunks.linux@gmail.com, akpm@linux-foundation.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On Mon, 2019-01-14 at 15:32 +0100, Michal Hocko wrote:
> On Mon 14-01-19 19:29:39, Arun KS wrote:
> > On 2019-01-10 21:53, Alexander Duyck wrote:
> 
> [...]
> > > Couldn't you just do something like the following:
> > > 		if ((end - start) >= (1UL << (MAX_ORDER - 1))
> > > 			order = MAX_ORDER - 1;
> > > 		else
> > > 			order = __fls(end - start);
> > > 
> > > I would think this would save you a few steps in terms of conversions
> > > and such since you are already working in page frame numbers anyway so
> > > a block of 8 pfns would represent an order 3 page wouldn't it?
> > > 
> > > Also it seems like an alternative to using "end" would be to just track
> > > nr_pages. Then you wouldn't have to do the "end - start" math in a few
> > > spots as long as you remembered to decrement nr_pages by the amount you
> > > increment start by.
> > 
> > Thanks for that. How about this?
> > 
> > static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
> > {
> >         unsigned long end = start + nr_pages;
> >         int order;
> > 
> >         while (nr_pages) {
> >                 if (nr_pages >= (1UL << (MAX_ORDER - 1)))
> >                         order = MAX_ORDER - 1;
> >                 else
> >                         order = __fls(nr_pages);
> > 
> >                 (*online_page_callback)(pfn_to_page(start), order);
> >                 nr_pages -= (1UL << order);
> >                 start += (1UL << order);
> >         }
> >         return end - start;
> > }
> 
> I find this much less readable so if this is really a big win
> performance wise then make it a separate patch with some nubbers please.

I suppose we could look at simplifying this further. Maybe something
like:
	unsigned long end = start + nr_pages;
	int order = MAX_ORDER - 1;

	while (start < end) {
		if ((end - start) < (1UL << (MAX_ORDER - 1))
			order = __fls(end - start));
		(*online_page_callback)(pfn_to_page(start), order);
		start += 1UL << order;
	}

	return nr_pages;

I would argue it probably doesn't get much more readable than this. The
basic idea is we are chopping off MAX_ORDER - 1 sized chunks and
setting them online until we have to start working our way down in
powers of 2.

In terms of performance the loop itself isn't going to have that much
impact. The bigger issue as I saw it was that we were going through and
converting PFNs to a physical addresses just for the sake of contorting
things to make them work with get_order when we already have the PFN
numbers so all we really need to know is the most significant bit for
the total page count.
