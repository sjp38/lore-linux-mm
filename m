Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F37B828E1
	for <linux-mm@kvack.org>; Mon, 16 May 2016 03:10:46 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id f14so54834110lbb.2
        for <linux-mm@kvack.org>; Mon, 16 May 2016 00:10:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ri9si16947570wjb.209.2016.05.16.00.10.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 May 2016 00:10:45 -0700 (PDT)
Subject: Re: [RFC 08/13] mm, compaction: simplify contended compaction
 handling
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-9-git-send-email-vbabka@suse.cz>
 <20160513130950.GN20141@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <57397271.50504@suse.cz>
Date: Mon, 16 May 2016 09:10:41 +0200
MIME-Version: 1.0
In-Reply-To: <20160513130950.GN20141@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/13/2016 03:09 PM, Michal Hocko wrote:
>> >@@ -1564,14 +1564,11 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
>> >  	trace_mm_compaction_end(start_pfn, cc->migrate_pfn,
>> >  				cc->free_pfn, end_pfn, sync, ret);
>> >
>> >-	if (ret == COMPACT_CONTENDED)
>> >-		ret = COMPACT_PARTIAL;
>> >-
>> >  	return ret;
>> >  }
> This took me a while to grasp but then I realized this is correct
> because we shouldn't pretend progress when there was none in fact,
> especially when __alloc_pages_direct_compact basically replaced this
> "fake" COMPACT_PARTIAL by COMPACT_CONTENDED anyway.

Yes. Actually COMPACT_CONTENDED compact_result used to be just for the 
tracepoint, and __alloc_pages_direct_compact used another function 
parameter to signal contention. You changed it with the oom rework so 
COMPACT_CONTENDED result value was used, so this hunk just makes sure 
it's still reported correctly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
