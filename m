Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DEEC16B0A40
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 10:58:30 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id n32-v6so11860244edc.17
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 07:58:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g20-v6sor5106403ejt.1.2018.11.16.07.58.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Nov 2018 07:58:29 -0800 (PST)
Date: Fri, 16 Nov 2018 15:58:28 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: use managed_zone() for more exact check in zone
 iteration
Message-ID: <20181116155828.strdglxqgqe4jqkr@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181114235040.36180-1-richard.weiyang@gmail.com>
 <20181115133735.bb0313ec9293c415d08be550@linux-foundation.org>
 <20181116095720.GE14706@dhcp22.suse.cz>
 <1542366304.3020.15.camel@suse.de>
 <20181116112603.GI14706@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116112603.GI14706@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: osalvador <osalvador@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 16, 2018 at 12:26:03PM +0100, Michal Hocko wrote:
>On Fri 16-11-18 12:05:04, osalvador wrote:
>> On Fri, 2018-11-16 at 10:57 +0100, Michal Hocko wrote:
>[...]
>> > E.g. memory hotplug decreases both managed and present counters. I
>> > am actually not sure that is 100% correct (put on my TODO list to
>> > check). There is no consistency in that regards.
>> 
>> We can only offline non-reserved pages (so, managed pages).
>
>Yes
>
>> Since present pages holds reserved_pages + managed_pages, decreasing
>> both should be fine unless I am mistaken.
>
>Well, present_pages is defined as "physical pages existing within the zone"
>and those pages are still existing but they are offline. But as I've
>said I have to think about it some more

I may not catch up with your discussions, while I'd like to share what I
learnt.

online_pages()
    online_pages_range()
    zone->present_pages += onlined_pages;

__offline_pages()
    adjust_managed_page_count()
    zone->present_pages -= offlined_pages;

The two counters: present_pages & managed_pages would be adjusted during
online/offline.

While I am not sure when *reserved_pages* would be adjusted. Will we add
this hot-added memory into memblock.reserved? and allocate memory by
memblock_alloc() after system bootup?

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
