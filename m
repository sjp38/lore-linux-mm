Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 622A16B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 10:50:20 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id n186so137788693wmn.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 07:50:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o65si10988820wmg.41.2016.03.03.07.50.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 07:50:19 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160302021954.GA22355@js1304-P5Q-DELUXE>
 <20160302095056.GB26701@dhcp22.suse.cz>
 <CAAmzW4MoS8K1G+MqavXZAGSpOt92LqZcRzGdGgcop-kQS_tTXg@mail.gmail.com>
 <20160302140611.GI26686@dhcp22.suse.cz>
 <CAAmzW4NX2sooaghiqkFjFb3Yzazi6rGguQbDjiyWDnfBqP0a-A@mail.gmail.com>
 <20160303092634.GB26202@dhcp22.suse.cz>
 <CAAmzW4NQznWcCWrwKk836yB0bhOaHNygocznzuaj5sJeepHfYQ@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56D85D38.1060404@suse.cz>
Date: Thu, 3 Mar 2016 16:50:16 +0100
MIME-Version: 1.0
In-Reply-To: <CAAmzW4NQznWcCWrwKk836yB0bhOaHNygocznzuaj5sJeepHfYQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On 03/03/2016 03:10 PM, Joonsoo Kim wrote:
> 
>> [...]
>>>>> At least, reset no_progress_loops when did_some_progress. High
>>>>> order allocation up to PAGE_ALLOC_COSTLY_ORDER is as important
>>>>> as order 0. And, reclaim something would increase probability of
>>>>> compaction success.
>>>>
>>>> This is something I still do not understand. Why would reclaiming
>>>> random order-0 pages help compaction? Could you clarify this please?
>>>
>>> I just can tell simple version. Please check the link from me on another reply.
>>> Compaction could scan more range of memory if we have more freepage.
>>> This is due to algorithm limitation. Anyway, so, reclaiming random
>>> order-0 pages helps compaction.
>>
>> I will have a look at that code but this just doesn't make any sense.
>> The compaction should be reshuffling pages, this shouldn't be a function
>> of free memory.
> 
> Please refer the link I mentioned before. There is a reason why more free
> memory would help compaction success. Compaction doesn't work
> like as random reshuffling. It has an algorithm to reduce system overall
> fragmentation so there is limitation.

I proposed another way to get better results from direct compaction -
don't scan for free pages but get them directly from freelists:

https://lkml.org/lkml/2015/12/3/60

But your redesign would be useful too for kcompactd/khugepaged keeping
overall fragmentation low.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
