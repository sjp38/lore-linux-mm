Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 62C35828E1
	for <linux-mm@kvack.org>; Mon, 16 May 2016 03:31:48 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id ne4so55096015lbc.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 00:31:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n133si18547127wmf.100.2016.05.16.00.31.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 00:31:46 -0700 (PDT)
Subject: Re: [RFC 12/13] mm, compaction: more reliably increase direct
 compaction priority
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-13-git-send-email-vbabka@suse.cz>
 <20160513141539.GR20141@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57397760.4060407@suse.cz>
Date: Mon, 16 May 2016 09:31:44 +0200
MIME-Version: 1.0
In-Reply-To: <20160513141539.GR20141@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/13/2016 04:15 PM, Michal Hocko wrote:
> On Tue 10-05-16 09:36:02, Vlastimil Babka wrote:
>>
>> - should_compact_retry() is only called when should_reclaim_retry() returns
>>    false. This means that compaction priority cannot get increased as long
>>    as reclaim makes sufficient progress. Theoretically, reclaim should stop
>>    retrying for high-order allocations as long as the high-order page doesn't
>>    exist but due to races, this may result in spurious retries when the
>>    high-order page momentarily does exist.
>
> This is intentional behavior and I would like to preserve it if it is
> possible. For higher order pages should_reclaim_retry retries as long
> as there are some eligible high order pages present which are just hidden
> by the watermark check. So this is mostly to get us over watermarks to
> start carrying about fragmentation. If we race there then nothing really
> terrible should happen and we should eventually converge to a terminal
> state.
>
> Does this make sense to you?

Yeah it should work, my only worry was that this may get subtly wrong 
(as experience shows us) and due to e.g. slightly different watermark 
checks and/or a corner-case zone such as ZONE_DMA, 
should_reclaim_retry() would keep returning true, even if reclaim 
couldn't/wouldn't help anything. Then compaction would be needlessly 
kept at ineffective priority.

Also my understanding of the initial compaction priorities is to lower 
the latency if fragmentation is just light and there's enough memory. 
Once we start struggling, I don't see much point in not switching to the 
full compaction priority quickly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
