Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BFF9F6B0253
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 02:51:21 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so108072881lfi.0
        for <linux-mm@kvack.org>; Sun, 17 Jul 2016 23:51:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o18si12897005lfe.11.2016.07.17.23.51.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Jul 2016 23:51:19 -0700 (PDT)
Subject: Re: [PATCH 08/31] mm, vmscan: simplify the logic deciding whether
 kswapd sleeps
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-9-git-send-email-mgorman@techsingularity.net>
 <20160707012038.GB27987@js1304-P5Q-DELUXE>
 <20160707101701.GR11498@techsingularity.net>
 <20160708024447.GB2370@js1304-P5Q-DELUXE>
 <20160708101147.GD11498@techsingularity.net>
 <20160714052332.GA29676@js1304-P5Q-DELUXE>
 <5b6b1490-1dbc-74fc-e129-947141a1bee3@suse.cz>
 <20160718050756.GD9460@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ddb22709-5536-b147-e0e4-cd9f6b11820a@suse.cz>
Date: Mon, 18 Jul 2016 08:51:16 +0200
MIME-Version: 1.0
In-Reply-To: <20160718050756.GD9460@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On 07/18/2016 07:07 AM, Joonsoo Kim wrote:
> On Thu, Jul 14, 2016 at 10:32:09AM +0200, Vlastimil Babka wrote:
>> On 07/14/2016 07:23 AM, Joonsoo Kim wrote:
>>
>> I don't think there's a problem in the scenario? Kswapd will keep
>> being woken up and reclaim from the node lru. It will hit and free
>> any low zone pages that are on the lru, even though it doesn't
>> "balance for low zone". Eventually it will either satisfy the
>> constrained allocation by reclaiming those low-zone pages during the
>> repeated wakeups, or the low-zone wakeups will stop coming together
>> with higher-zone wakeups and then it will reclaim the low-zone pages
>> in a single low-zone wakeup. If the zone-constrained request is not
>
> Yes, probability of this would be low.
>
>> allowed to fail, then it will just keep waking up kswapd and waiting
>> for the progress. If it's allowed to fail (i.e. not __GFP_NOFAIL),
>> but not allowed to direct reclaim, it goes "goto nopage" rather
>> quickly in __alloc_pages_slowpath(), without any waiting for
>> kswapd's progress, so there's not really much difference whether the
>> kswapd wakeup picked up a low classzone or not. Note the
>
> Hmm... Even if allocation could fail, we should do our best to prevent
> failure. Relying on luck isn't good idea to me.

But "Doing our best" has to have some sane limits. Allocation, that 
cannot direct reclaim, already relies on luck. And we are not really 
changing this. The allocation will "goto nopage" before kswapd can even 
wake up and start doing something, regardless of classzone_idx used.

> Thanks.
>
>> __GFP_NOFAIL but ~__GFP_DIRECT_RECLAIM is a WARN_ON_ONCE() scenario,
>> so definitely not common...
>>
>>> Thanks.
>>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
