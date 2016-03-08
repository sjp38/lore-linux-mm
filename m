Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 57D9B6B0256
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 10:03:43 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id p65so153574826wmp.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 07:03:43 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x68si4962891wme.32.2016.03.08.07.03.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 07:03:42 -0800 (PST)
Subject: Re: [PATCH 3/3] mm, oom: protect !costly allocations some more
References: <20160307160838.GB5028@dhcp22.suse.cz>
 <1457444565-10524-1-git-send-email-mhocko@kernel.org>
 <1457444565-10524-4-git-send-email-mhocko@kernel.org>
 <56DEE2FD.4000105@suse.cz> <20160308144827.GK13542@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56DEE9C9.7060503@suse.cz>
Date: Tue, 8 Mar 2016 16:03:37 +0100
MIME-Version: 1.0
In-Reply-To: <20160308144827.GK13542@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 03/08/2016 03:48 PM, Michal Hocko wrote:
> On Tue 08-03-16 15:34:37, Vlastimil Babka wrote:
>>> --- a/include/linux/compaction.h
>>> +++ b/include/linux/compaction.h
>>> @@ -14,6 +14,11 @@ enum compact_result {
>>>  	/* compaction should continue to another pageblock */
>>>  	COMPACT_CONTINUE,
>>>  	/*
>>> +	 * whoever is calling compaction should retry because it was either
>>> +	 * not active or it tells us there is more work to be done.
>>> +	 */
>>> +	COMPACT_SHOULD_RETRY = COMPACT_CONTINUE,
>>
>> Hmm, I'm not sure about this. AFAIK compact_zone() doesn't ever return
>> COMPACT_CONTINUE, and thus try_to_compact_pages() also doesn't. This
>> overloading of CONTINUE only applies to compaction_suitable(). But the
>> value that should_compact_retry() is testing comes only from
>> try_to_compact_pages(). So this is not wrong, but perhaps a bit misleading?
> 
> Well the idea was that I wanted to cover all the _possible_ cases where
> compaction might want to tell us "please try again even when the last
> round wasn't really successful". COMPACT_CONTINUE might not be returned
> right now but we can come up with that in the future. It sounds like a
> sensible feedback to me. But maybe there would be a better name for such
> a feedback. I confess this is a bit oom-rework centric name...

Hmm, I see. But it doesn't really tell use to please try again. That
interpretation is indeed oom-specific. What it's actually telling us is
either a) reclaim and then try again (COMPACT_SKIPPED), b) try again
just to overcome the deferred state (COMPACT_DEFERRED). COMPACT_CONTINUE
says "go ahead", but only from compaction_suitable().
So the attempt a generic name doesn't really work here I'm afraid :/

> Also I find it better to hide details behind a more generic name.
> 
> I am open to suggestions here, of course.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
