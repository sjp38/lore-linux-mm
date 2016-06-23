Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 08C0C828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 10:41:58 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id a2so54732141lfe.0
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 07:41:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m64si6857791wmf.79.2016.06.23.07.41.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 07:41:56 -0700 (PDT)
Subject: Re: [PATCH v2 12/18] mm, compaction: more reliably increase direct
 compaction priority
References: <20160531130818.28724-1-vbabka@suse.cz>
 <20160531130818.28724-13-vbabka@suse.cz>
 <20160601135124.GS26601@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <977bc795-d2e7-ee7b-df2e-a30ce5cf15cc@suse.cz>
Date: Thu, 23 Jun 2016 16:41:53 +0200
MIME-Version: 1.0
In-Reply-To: <20160601135124.GS26601@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>

On 06/01/2016 03:51 PM, Michal Hocko wrote:
> On Tue 31-05-16 15:08:12, Vlastimil Babka wrote:
>> During reclaim/compaction loop, compaction priority can be increased by the
>> should_compact_retry() function, but the current code is not optimal. Priority
>> is only increased when compaction_failed() is true, which means that compaction
>> has scanned the whole zone. This may not happen even after multiple attempts
>> with the lower priority due to parallel activity, so we might needlessly
>> struggle on the lower priority.
>>
>> We can remove these corner cases by increasing compaction priority regardless
>> of compaction_failed(). Examining further the compaction result can be
>> postponed only after reaching the highest priority. This is a simple solution
>> and we don't need to worry about reaching the highest priority "too soon" here,
>> because hen should_compact_retry() is called it means that the system is
>> already struggling and the allocation is supposed to either try as hard as
>> possible, or it cannot fail at all. There's not much point staying at lower
>> priorities with heuristics that may result in only partial compaction.
>>
>> The only exception here is the COMPACT_SKIPPED result, which means that
>> compaction could not run at all due to being below order-0 watermarks. In that
>> case, don't increase compaction priority, and check if compaction could proceed
>> when everything reclaimable was reclaimed. Before this patch, this was tied to
>> compaction_withdrawn(), but the other results considered there are in fact only
>> possible due to low compaction priority so we can ignore them thanks to the
>> patch. Since there are no other callers of compaction_withdrawn(), remove it.
>
> I agree with the change in general. I think that keeping compaction_withdrawn
> even with a single check is better because it abstracts the fact from a
> specific constant.

OK.

> Now that I think about that some more I guess you also want to update
> compaction_retries inside should_compact_retry as well, or at least
> update it only when we have reached the lowest priority. What do you
> think?

Makes sense, especially that after your suggestion, 
should_compact_retry() is not reached as long as should_reclaim_retry() 
returnes true. So I will do that.

>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>
> Other than that this makes sense
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
