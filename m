Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 031266B037D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 02:51:19 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id hb5so57893348wjc.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 23:51:18 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id n1si22766972wme.119.2016.12.20.23.51.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 23:51:17 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id m203so28800119wma.3
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 23:51:17 -0800 (PST)
Date: Wed, 21 Dec 2016 08:51:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 2/2] mm/memblock.c: check return value of
 memblock_reserve() in memblock_virt_alloc_internal()
Message-ID: <20161221075115.GE16502@dhcp22.suse.cz>
References: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
 <1482072470-26151-3-git-send-email-richard.weiyang@gmail.com>
 <20161219152156.GC5175@dhcp22.suse.cz>
 <20161220164823.GB13224@vultr.guest>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161220164823.GB13224@vultr.guest>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 20-12-16 16:48:23, Wei Yang wrote:
> On Mon, Dec 19, 2016 at 04:21:57PM +0100, Michal Hocko wrote:
> >On Sun 18-12-16 14:47:50, Wei Yang wrote:
> >> memblock_reserve() may fail in case there is not enough regions.
> >
> >Have you seen this happenning in the real setups or this is a by-review
> >driven change?
> 
> This is a by-review driven change.
> 
> >[...]
> >>  again:
> >>  	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
> >>  					    nid, flags);
> >> -	if (alloc)
> >> +	if (alloc && !memblock_reserve(alloc, size))
> >>  		goto done;

So how exactly does the reserve fail when memblock_find_in_range_node
found a suitable range for the given size?

> >>  
> >>  	if (nid != NUMA_NO_NODE) {
> >>  		alloc = memblock_find_in_range_node(size, align, min_addr,
> >>  						    max_addr, NUMA_NO_NODE,
> >>  						    flags);
> >> -		if (alloc)
> >> +		if (alloc && !memblock_reserve(alloc, size))
> >>  			goto done;
> >>  	}
> >
> >This doesn't look right. You can end up leaking the first allocated
> >range.
> >
> 
> Hmm... why?
> 
> If first memblock_reserve() succeed, it will jump to done, so that no 2nd
> allocation.
> If the second executes, it means the first allocation failed.
> memblock_find_in_range_node() doesn't modify the memblock, it just tell you
> there is a proper memory region available.

yes, my bad. I have missed this. Sorry about the confusion.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
