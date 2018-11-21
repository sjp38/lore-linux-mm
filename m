Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 20C166B2360
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 21:52:34 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id w2so1835663edc.13
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 18:52:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s4sor7919279edx.12.2018.11.20.18.52.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 18:52:32 -0800 (PST)
Date: Wed, 21 Nov 2018 02:52:31 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, hotplug: protect nr_zones with pgdat_resize_lock()
Message-ID: <20181121025231.ggk7zgq53nmqsqds@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181120073141.GY22247@dhcp22.suse.cz>
 <3ba8d8c524d86af52e4c1fddc2d45734@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3ba8d8c524d86af52e4c1fddc2d45734@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@suse.de
Cc: Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue, Nov 20, 2018 at 08:58:11AM +0100, osalvador@suse.de wrote:
>> On the other hand I would like to see the global lock to go away because
>> it causes scalability issues and I would like to change it to a range
>> lock. This would make this race possible.
>> 
>> That being said this is more of a preparatory work than a fix. One could
>> argue that pgdat resize lock is abused here but I am not convinced a
>> dedicated lock is much better. We do take this lock already and spanning
>> its scope seems reasonable. An update to the documentation is due.
>
>Would not make more sense to move it within the pgdat lock
>in move_pfn_range_to_zone?
>The call from free_area_init_core is safe as we are single-thread there.
>

Agree. This would be better.

>And if we want to move towards a range locking, I even think it would be more
>consistent if we move it within the zone's span lock (which is already
>wrapped with a pgdat lock).
>

I lost a little here, just want to confirm with you.

Instead of call pgdat_resize_lock() around init_currently_empty_zone()
in move_pfn_range_to_zone(), we move init_currently_empty_zone() before
resize_zone_range()?

This sounds reasonable.

>
>

-- 
Wei Yang
Help you, Help me
