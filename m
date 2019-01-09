Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 305298E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 03:28:52 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id f69so4748222pff.5
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 00:28:52 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id p23si375564plo.7.2019.01.09.00.28.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 00:28:51 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 09 Jan 2019 13:58:50 +0530
From: Arun KS <arunks@codeaurora.org>
Subject: Re: [PATCH v7] mm/page_alloc.c: memory_hotplug: free pages as higher
 order
In-Reply-To: <20190109073718.GM31793@dhcp22.suse.cz>
References: <1546578076-31716-1-git-send-email-arunks@codeaurora.org>
 <fb6465c99b3ada2c6af587a7eb00016d96d56f77.camel@linux.intel.com>
 <20190108181352.GI31793@dhcp22.suse.cz>
 <bfb543b6e343c21c3e263a110f234e08@codeaurora.org>
 <20190109073718.GM31793@dhcp22.suse.cz>
Message-ID: <a053bd9b93e71baae042cdfc3432f945@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>, arunks.linux@gmail.com, akpm@linux-foundation.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On 2019-01-09 13:07, Michal Hocko wrote:
> On Wed 09-01-19 11:28:52, Arun KS wrote:
>> On 2019-01-08 23:43, Michal Hocko wrote:
>> > On Tue 08-01-19 09:56:09, Alexander Duyck wrote:
>> > > On Fri, 2019-01-04 at 10:31 +0530, Arun KS wrote:
>> > [...]
>> > > >  static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
>> > > >  			void *arg)
>> > > >  {
>> > > > -	unsigned long i;
>> > > >  	unsigned long onlined_pages = *(unsigned long *)arg;
>> > > > -	struct page *page;
>> > > >
>> > > >  	if (PageReserved(pfn_to_page(start_pfn)))
>> > > > -		for (i = 0; i < nr_pages; i++) {
>> > > > -			page = pfn_to_page(start_pfn + i);
>> > > > -			(*online_page_callback)(page);
>> > > > -			onlined_pages++;
>> > > > -		}
>> > > > +		onlined_pages = online_pages_blocks(start_pfn, nr_pages);
>> > >
>> > > Shouldn't this be a "+=" instead of an "="? It seems like you are
>> > > going
>> > > to lose your count otherwise.
>> >
>> > You are right of course. I should have noticed during the review.
>> > Thanks!
>> 
>> I think we don't need to. The caller function is setting onlined_pages 
>> = 0
>> before calling online_pages_range().
>> And there are no other reference to online_pages_range other than from
>> online_pages().
> 
> Are you missing that we accumulate onlined_pages via
> 	*(unsigned long *)arg = onlined_pages;
> in online_pages_range?

In my testing I didn't find any problem. To match the code being 
replaced and to avoid any corner cases, it is better to use +=
Will update the patch.

Regards,
Arun
