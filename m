Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE04D6B03A1
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 08:13:36 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so317164059pfx.1
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 05:13:36 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id p26si26625211pfk.183.2016.12.21.05.13.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 05:13:35 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id i5so6712918pgh.2
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 05:13:35 -0800 (PST)
Date: Wed, 21 Dec 2016 13:13:32 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH V2 2/2] mm/memblock.c: check return value of
 memblock_reserve() in memblock_virt_alloc_internal()
Message-ID: <20161221131332.GB23096@vultr.guest>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1482072470-26151-1-git-send-email-richard.weiyang@gmail.com>
 <1482072470-26151-3-git-send-email-richard.weiyang@gmail.com>
 <20161219152156.GC5175@dhcp22.suse.cz>
 <20161220164823.GB13224@vultr.guest>
 <20161221075115.GE16502@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161221075115.GE16502@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, trivial@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 21, 2016 at 08:51:16AM +0100, Michal Hocko wrote:
>On Tue 20-12-16 16:48:23, Wei Yang wrote:
>> On Mon, Dec 19, 2016 at 04:21:57PM +0100, Michal Hocko wrote:
>> >On Sun 18-12-16 14:47:50, Wei Yang wrote:
>> >> memblock_reserve() may fail in case there is not enough regions.
>> >
>> >Have you seen this happenning in the real setups or this is a by-review
>> >driven change?
>> 
>> This is a by-review driven change.
>> 
>> >[...]
>> >>  again:
>> >>  	alloc = memblock_find_in_range_node(size, align, min_addr, max_addr,
>> >>  					    nid, flags);
>> >> -	if (alloc)
>> >> +	if (alloc && !memblock_reserve(alloc, size))
>> >>  		goto done;
>
>So how exactly does the reserve fail when memblock_find_in_range_node
>found a suitable range for the given size?
>

Even memblock_find_in_range_node() gets a suitable range, memblock_reserve()
still could fail. And the case just happens when memblock can't resize.
memblock_reserve() reserve a range by adding a range to memblock.reserved. In
case the memblock.reserved is full and can't resize, this fails.

Not sure whether I get it clarified.

>> >>  
>> >>  	if (nid != NUMA_NO_NODE) {
>> >>  		alloc = memblock_find_in_range_node(size, align, min_addr,
>> >>  						    max_addr, NUMA_NO_NODE,
>> >>  						    flags);
>> >> -		if (alloc)
>> >> +		if (alloc && !memblock_reserve(alloc, size))
>> >>  			goto done;
>> >>  	}
>> >
>> >This doesn't look right. You can end up leaking the first allocated
>> >range.
>> >
>> 
>> Hmm... why?
>> 
>> If first memblock_reserve() succeed, it will jump to done, so that no 2nd
>> allocation.
>> If the second executes, it means the first allocation failed.
>> memblock_find_in_range_node() doesn't modify the memblock, it just tell you
>> there is a proper memory region available.
>
>yes, my bad. I have missed this. Sorry about the confusion

So do you agree with my patch now?

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
