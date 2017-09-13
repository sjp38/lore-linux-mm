Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 22FCA6B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 08:19:24 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 6so85585pgh.0
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 05:19:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q13si9125880pgn.679.2017.09.13.05.19.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 05:19:22 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
References: <20170904082148.23131-1-mhocko@kernel.org>
 <20170904082148.23131-2-mhocko@kernel.org>
 <eb5bf356-f498-b430-1ae8-4ff1ad15ad7f@suse.cz>
 <20170911081714.4zc33r7wlj2nnbho@dhcp22.suse.cz>
 <9fad7246-c634-18bb-78f9-b95376c009da@suse.cz>
 <20170913121001.k3a5tkvunmncc5uj@dhcp22.suse.cz>
 <20170913121433.yjzloaf6g447zeq2@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <25ffda93-0c0d-28b4-bd0b-7fc9df7d678a@suse.cz>
Date: Wed, 13 Sep 2017 14:19:19 +0200
MIME-Version: 1.0
In-Reply-To: <20170913121433.yjzloaf6g447zeq2@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 09/13/2017 02:14 PM, Michal Hocko wrote:
>>>> Do you think that the changelog should be more clear about this?
>>>
>>> It certainly wouldn't hurt :)
>>
>> So what do you think about the following wording:
> 
> Ups, wrong patch
> 
> 
> From 8639496a834b4a7c24972ec23b17e50f0d6a304c Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Mon, 14 Aug 2017 10:46:12 +0200
> Subject: [PATCH 1/2] mm, memory_hotplug: do not fail offlining too early
> 
> Memory offlining can fail just too eagerly under a heavy memory pressure.
> 
> [ 5410.336792] page:ffffea22a646bd00 count:255 mapcount:252 mapping:ffff88ff926c9f38 index:0x3
> [ 5410.336809] flags: 0x9855fe40010048(uptodate|active|mappedtodisk)
> [ 5410.336811] page dumped because: isolation failed
> [ 5410.336813] page->mem_cgroup:ffff8801cd662000
> [ 5420.655030] memory offlining [mem 0x18b580000000-0x18b5ffffffff] failed
> 
> Isolation has failed here because the page is not on LRU. Most probably
> because it was on the pcp LRU cache or it has been removed from the LRU
> already but it hasn't been freed yet. In both cases the page doesn't look
> non-migrable so retrying more makes sense.
> 
> __offline_pages seems rather cluttered when it comes to the retry
> logic. We have 5 retries at maximum and a timeout. We could argue
> whether the timeout makes sense but failing just because of a race when
> somebody isoltes a page from LRU or puts it on a pcp LRU lists is just
> wrong. It only takes it to race with a process which unmaps some pages
> and remove them from the LRU list and we can fail the whole offline
> because of something that is a temporary condition and actually not
> harmful for the offline.
> 
> Please note that unmovable pages should be already excluded during
> start_isolate_page_range. We could argue that has_unmovable_pages is
> racy and MIGRATE_MOVABLE check doesn't provide any hard guarantee either
> but kernel zones (aka < ZONE_MOVABLE) will very likely detect unmovable
> pages in most cases and movable zone shouldn't contain unmovable pages
> at all. Some of those pages might be pinned but not for ever because
> that would be a bug on its own. In any case the context is still
> interruptible and so the userspace can easily bail out when the
> operation takes too long. This is certainly better behavior than a
> hardcoded retry loop which is racy.
> 
> Fix this by removing the max retry count and only rely on the timeout
> resp. interruption by a signal from the userspace. Also retry rather
> than fail when check_pages_isolated sees some !free pages because those
> could be a result of the race as well.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Yeah, that's better, thanks.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
