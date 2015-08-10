Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 285D66B0254
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 05:44:20 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so15033398wic.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 02:44:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mn10si36661177wjc.72.2015.08.10.02.44.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Aug 2015 02:44:18 -0700 (PDT)
Subject: Re: [RFC v3 1/2] mm, compaction: introduce kcompactd
References: <1438619141-22215-1-git-send-email-vbabka@suse.cz>
 <1086308416.1472237.1439134679684.JavaMail.yahoo@mail.yahoo.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55C8726E.4090103@suse.cz>
Date: Mon, 10 Aug 2015 11:44:14 +0200
MIME-Version: 1.0
In-Reply-To: <1086308416.1472237.1439134679684.JavaMail.yahoo@mail.yahoo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pintu Kumar <pintu.k@samsung.com>

On 08/09/2015 05:37 PM, PINTU KUMAR wrote:
>> Waking up of the kcompactd threads is also tied to kswapd activity and follows
>> these rules:
>> - we don't want to affect any fastpaths, so wake up kcompactd only from the
>>    slowpath, as it's done for kswapd
>> - if kswapd is doing reclaim, it's more important than compaction, so
>> don't
>>    invoke kcompactd until kswapd goes to sleep
>> - the target order used for kswapd is passed to kcompactd
>>
>> The kswapd compact/reclaim loop for high-order pages is left alone for now
>> and precedes kcompactd wakeup, but this might be revisited later.
>
> kcompactd, will be really nice thing to have, but I oppose calling it from kswapd.
> Because, just after kswapd, we already have direct_compact.

Just to be clear, here you mean that kswapd already does the 
compact/reclaim loop?

> So it may end up in doing compaction 2 times.

The compact/reclaim loop might already do multiple iterations. The point 
is, kswapd will terminate the loop as soon as single page of desired 
order becomes available. Kcompactd is meant to go beyond that.
And having kcompactd run in parallel with kswapd's reclaim looks like 
nonsense to me, so I don't see other way than have kswapd wake up 
kcompactd when it's finished.

> Or, is it like, with kcompactd, we dont need direct_compact?

That will have to be evaluated. It would be nice to not need the 
compact/reclaim loop, but I'm not sure it's always possible. We could 
move it to kcompactd, but it would still mean that no daemon does 
exclusively just reclaim or just compaction.

> In embedded world situation is really worse.
> As per my experience in embedded world, just compaction does not help always in longer run.
>
> As I know there are already some Android model in market, that already run background compaction (from user space).
> But still there are sluggishness issues due to bad memory state in the long run.

It should still be better with background compaction than without it. Of 
course, avoiding a permanent fragmentation completely is not possible to 
guarantee as it depends on the allocation patterns.

> In embedded world, the major problems are related to camera and browser use cases that requires almost order-8 allocations.
> Also, for low RAM configurations (less than 512M, 256M etc.), the rate of failure of compaction is much higher than the rate of success.

I was under impression that CMA was introduced to deal with such 
high-order requirements in the embedded world?

> How can we guarantee that kcompactd is suitable for all situations?

We can't :) we can only hope to improve the average case. Anything that 
needs high-order *guarantees* has to rely on CMA or another kind of 
reservation (yeah even CMA is a pageblock reservation in some sense).

> In an case, we need large amount of testing to cover all scenarios.
> It should be called at the right time.
> I dont have any data to present right now.
> May be I will try to capture some data, and present here.

That would be nice. I'm going to collect some as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
