Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 021E56B026C
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 05:44:05 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so12433728wme.1
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 02:44:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yt2si1079139wjb.283.2016.08.18.02.44.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Aug 2016 02:44:03 -0700 (PDT)
Subject: Re: [PATCH v6 06/11] mm, compaction: more reliably increase direct
 compaction priority
References: <20160810091226.6709-1-vbabka@suse.cz>
 <20160810091226.6709-7-vbabka@suse.cz>
 <20160818091036.GF30162@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <1f761527-ed12-ba16-0565-c64d14e200eb@suse.cz>
Date: Thu, 18 Aug 2016 11:44:00 +0200
MIME-Version: 1.0
In-Reply-To: <20160818091036.GF30162@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/18/2016 11:10 AM, Michal Hocko wrote:
> On Wed 10-08-16 11:12:21, Vlastimil Babka wrote:
>> During reclaim/compaction loop, compaction priority can be increased by the
>> should_compact_retry() function, but the current code is not optimal. Priority
>> is only increased when compaction_failed() is true, which means that compaction
>> has scanned the whole zone. This may not happen even after multiple attempts
>> with a lower priority due to parallel activity, so we might needlessly
>> struggle on the lower priorities and possibly run out of compaction retry
>> attempts in the process.
>>
>> After this patch we are guaranteed at least one attempt at the highest
>> compaction priority even if we exhaust all retries at the lower priorities.
>
> I expect we will tend to do some special handling at the highest
> priority so guaranteeing at least one run with that prio seems sensible to me. The only
> question is whether we really want to enforce the highest priority for
> costly orders as well. I think we want to reserve the highest (maybe add
> one more) prio for !costly orders as those invoke the OOM killer and the
> failure are quite disruptive.

Costly orders are already ruled out of reaching the highest priority 
unless they are __GFP_REPEAT, so I assumed that if they are allocations 
with __GFP_REPEAT, they really would like to succeed, so let them use 
the highest priority.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
