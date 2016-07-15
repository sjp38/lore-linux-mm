Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E49436B0268
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 09:37:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so16225125wmr.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:37:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gm2si789042wjb.51.2016.07.15.06.37.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jul 2016 06:37:56 -0700 (PDT)
Subject: Re: [PATCH v3 12/17] mm, compaction: more reliably increase direct
 compaction priority
References: <20160624095437.16385-1-vbabka@suse.cz>
 <20160624095437.16385-13-vbabka@suse.cz>
 <20160706053954.GE23627@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <78b8fc60-ddd8-ae74-4f1a-f4bcb9933016@suse.cz>
Date: Fri, 15 Jul 2016 15:37:52 +0200
MIME-Version: 1.0
In-Reply-To: <20160706053954.GE23627@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On 07/06/2016 07:39 AM, Joonsoo Kim wrote:
> On Fri, Jun 24, 2016 at 11:54:32AM +0200, Vlastimil Babka wrote:
>> During reclaim/compaction loop, compaction priority can be increased by the
>> should_compact_retry() function, but the current code is not optimal. Priority
>> is only increased when compaction_failed() is true, which means that compaction
>> has scanned the whole zone. This may not happen even after multiple attempts
>> with the lower priority due to parallel activity, so we might needlessly
>> struggle on the lower priority and possibly run out of compaction retry
>> attempts in the process.
>>
>> We can remove these corner cases by increasing compaction priority regardless
>> of compaction_failed(). Examining further the compaction result can be
>> postponed only after reaching the highest priority. This is a simple solution
>> and we don't need to worry about reaching the highest priority "too soon" here,
>> because hen should_compact_retry() is called it means that the system is
>> already struggling and the allocation is supposed to either try as hard as
>> possible, or it cannot fail at all. There's not much point staying at lower
>> priorities with heuristics that may result in only partial compaction.
>> Also we now count compaction retries only after reaching the highest priority.
> 
> I'm not sure that this patch is safe. Deferring and skip-bit in
> compaction is highly related to reclaim/compaction. Just ignoring them and (almost)
> unconditionally increasing compaction priority will result in less
> reclaim and less success rate on compaction.

I don't see why less reclaim? Reclaim is always attempted before
compaction and compaction priority doesn't affect it. And as long as
reclaim wants to retry, should_compact_retry() isn't even called, so the
priority stays. I wanted to change that in v1, but Michal suggested I
shouldn't.

> And, as a necessarily, it
> would trigger OOM more frequently.

OOM is only allowed for costly orders. If reclaim itself doesn't want to
retry for non-costly orders anymore, and we finally start calling
should_compact_retry(), then I guess the system is really struggling
already and eventual OOM wouldn't be premature?

> It would not be your fault. This patch is reasonable in current
> situation. It just makes current things more deterministic
> although I dislike that current things and this patch would amplify
> those problem.
> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
