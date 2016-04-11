Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6D6796B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:53:39 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id l6so144542150wml.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 05:53:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id uu10si28684212wjc.123.2016.04.11.05.53.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Apr 2016 05:53:38 -0700 (PDT)
Subject: Re: [PATCH 06/11] mm, compaction: distinguish between full and
 partial COMPACT_COMPLETE
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-7-git-send-email-mhocko@kernel.org>
 <570B9432.9090600@suse.cz> <20160411124653.GG23157@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570B9E50.9040000@suse.cz>
Date: Mon, 11 Apr 2016 14:53:36 +0200
MIME-Version: 1.0
In-Reply-To: <20160411124653.GG23157@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 04/11/2016 02:46 PM, Michal Hocko wrote:
>> This assumes that migrate scanner at initial position implies also free
>> scanner at the initial position. That should be true, because migration
>> scanner is the first to run. But getting the zone->compact_cached_*_pfn is
>> racy. Worse, zone->compact_cached_migrate_pfn is array distinguishing sync
>> and async compaction, so it's possible that async compaction has advanced
>> both its own migrate scanner cached position, and the shared free scanner
>> cached position, and then sync compaction starts migrate scanner at
>> start_pfn, but free scanner has already advanced.
>
> OK, I see. The whole thing smelled racy but I thought it wouldn't be
> such a big deal. Even if we raced then only a marginal part of the zone
> wouldn't be scanned, right? Or is it possible that free_pfn would appear
> in the middle of the zone because of the race?

The racy part is negligible but I didn't realize the sync/async migrate 
scanner part until now. So yeah, free_pfn could have got to middle of 
zone when it was in the async mode. But that also means that the async 
mode recently used up all free pages in the second half of the zone. WRT 
free pages isolation, async mode is not trying less than sync, so it 
shouldn't be a considerable missed opportunity if we don't rescan the 
it, though.

>> So you might still see a false positive COMPACT_COMPLETE, just less
>> frequently and probably with much lower impact.
>> But if you need to be truly reliable, check also that cc->free_pfn ==
>> round_down(end_pfn - 1, pageblock_nr_pages)
>
> I do not think we need the precise check if the race window (in the
> skipped zone range) is always small.
>
> Thanks!
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
