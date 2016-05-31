Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 57E896B025E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 08:03:56 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n2so42588232wma.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 05:03:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g16si832792wjz.97.2016.05.31.05.03.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 05:03:55 -0700 (PDT)
Subject: Re: [RFC 03/13] mm, page_alloc: don't retry initial attempt in
 slowpath
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-4-git-send-email-vbabka@suse.cz>
 <20160531062510.GB30967@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <330053c0-560b-81dc-7d4f-97f8014d986b@suse.cz>
Date: Tue, 31 May 2016 14:03:51 +0200
MIME-Version: 1.0
In-Reply-To: <20160531062510.GB30967@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/31/2016 08:25 AM, Joonsoo Kim wrote:
> On Tue, May 10, 2016 at 09:35:53AM +0200, Vlastimil Babka wrote:
>> After __alloc_pages_slowpath() sets up new alloc_flags and wakes up kswapd, it
>> first tries get_page_from_freelist() with the new alloc_flags, as it may
>> succeed e.g. due to using min watermark instead of low watermark. This attempt
>> does not have to be retried on each loop, since direct reclaim, direct
>> compaction and oom call get_page_from_freelist() themselves.
>
> Hmm... there is a corner case. If did_some_progress is 0 or compaction
> is deferred, get_page_from_freelist() isn't called. But, we can
> succeed to allocate memory since there is a kswapd that reclaims
> memory in background.

Hmm good point. I think the cleanest solution is to let 
__alloc_pages_direct_reclaim attempt regardless of did_some_progress.

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
