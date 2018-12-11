Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 908FD8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 07:22:31 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so6898078edd.2
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 04:22:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i12si1474469edq.264.2018.12.11.04.22.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 04:22:29 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 11 Dec 2018 13:22:27 +0100
From: osalvador@suse.de
Subject: Re: [PATCH] mm, memory_hotplug: Don't bail out in do_migrate_range
 prematurely
In-Reply-To: <20181211101818.GE1286@dhcp22.suse.cz>
References: <20181211085042.2696-1-osalvador@suse.de>
 <20181211101818.GE1286@dhcp22.suse.cz>
Message-ID: <6009dea8a638aaa5b88088a117297edf@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, david@redhat.com, pasha.tatashin@soleen.com, dan.j.williams@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018-12-11 11:18, Michal Hocko wrote:
>> Currently, if we fail to isolate a single page, we put all already
>> isolated pages back to their LRU and we bail out from the function.
>> This is quite suboptimal, as this will force us to start over again
>> because scan_movable_pages will give us the same range.
>> If there is no chance that we can isolate that page, we will loop here
>> forever.
> 
> This is true but reorganizing the code will not help the underlying
> issue. Because the permanently failing page will be still there for
> scan_movable_pages to encounter.

Well, it would only help in case the page is neither LRU nor
non-movable page, then we would fail to isolate it in do_migrate_range
and we will start over.
Letting do_migrate_range do some work, would mean that at some point
the permanently failing page will not be within a range but the first 
one
of a range, and so scan_movable_pages will skip it.


> 
>> Issue debugged in 4d0c7db96 ("hwpoison, memory_hotplug: allow 
>> hwpoisoned
>> pages to be offlined") has proved that.
> 
> I assume that 4d0c7db96 is a sha1 from the linux-next. Please note that
> this is not going to be the case when merged upstream. So I would use a
> link.

I will replace the sha1 with the link in the next version.

>> Although this patch has proved to be useful when dealing with
>> 4d0c7db96 because it allows us to move forward as long as the
>> page is not in LRU, we still need 4d0c7db96
>> ("hwpoison, memory_hotplug: allow hwpoisoned pages to be offlined")
>> to handle the LRU case and the unmapping of the page if needed.
>> So, this is just a follow-up cleanup.
> 
> I suspect the above paragraph is adding more confusion than necessary. 
> I
> would just drop it.

Fair enough, I will drop it.

> The main question here is. Do we want to migrate as much as possible or
> do we want to be conservative and bail out early. The later could be an
> advantage if the next attempt could fail the whole operation because 
> the
> impact of the failed operation would be somehow reduced. The former
> should be better for throughput because easily done stuff is done 
> first.
> 
> I would go with the throuput because our failure mode is to bail out
> much earlier - even before we try to migrate. Even though the detection
> is not perfect it works reasonably well for most usecases.

I agree here.
I think it is better to do as much work as possible at once.


> you really want to keep this branch. You just do not want to bail out.
> We want to know about pages which fail to isolate and you definitely do
> not want to keep the reference elevated behind. not_managed stuff can 
> go
> away.

Yeah, I just realized when I sent it.
I will fix it up in v2.

Thanks
