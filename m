Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE7D6B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 02:00:56 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so54878953wms.7
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 23:00:56 -0800 (PST)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id z2si33776376wje.203.2016.11.07.23.00.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Nov 2016 23:00:55 -0800 (PST)
Subject: Re: [PATCH v6 2/6] mm/cma: introduce new zone, ZONE_CMA
References: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476414196-3514-3-git-send-email-iamjoonsoo.kim@lge.com>
 <58184B28.8090405@hisilicon.com> <20161107061500.GA21159@js1304-P5Q-DELUXE>
 <58202881.5030004@hisilicon.com> <20161107072702.GC21159@js1304-P5Q-DELUXE>
 <582030CB.80905@hisilicon.com> <5820313A.80207@hisilicon.com>
 <20161108035942.GA31767@js1304-P5Q-DELUXE>
From: Chen Feng <puck.chen@hisilicon.com>
Message-ID: <582177C7.7010706@hisilicon.com>
Date: Tue, 8 Nov 2016 14:59:19 +0800
MIME-Version: 1.0
In-Reply-To: <20161108035942.GA31767@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura
 Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek
 Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, saberlily.xia@hisilicon.com, Zhuangluan Su <suzhuangluan@hisilicon.com>, Dan Zhao <dan.zhao@hisilicon.com>



On 2016/11/8 11:59, Joonsoo Kim wrote:
> On Mon, Nov 07, 2016 at 03:46:02PM +0800, Chen Feng wrote:
>>
>>
>> On 2016/11/7 15:44, Chen Feng wrote:
>>> On 2016/11/7 15:27, Joonsoo Kim wrote:
>>>> On Mon, Nov 07, 2016 at 03:08:49PM +0800, Chen Feng wrote:
>>>>>
>>>>>
>>>>> On 2016/11/7 14:15, Joonsoo Kim wrote:
>>>>>> On Tue, Nov 01, 2016 at 03:58:32PM +0800, Chen Feng wrote:
>>>>>>> Hello, I hava a question on cma zone.
>>>>>>>
>>>>>>> When we have cma zone, cma zone will be the highest zone of system.
>>>>>>>
>>>>>>> In android system, the most memory allocator is ION. Media system will
>>>>>>> alloc unmovable memory from it.
>>>>>>>
>>>>>>> On low memory scene, will the CMA zone always do balance?
>>>>>>
>>>>>> Allocation request for low zone (normal zone) would not cause CMA zone
>>>>>> to be balanced since it isn't helpful.
>>>>>>
>>>>> Yes. But the cma zone will run out soon. And it always need to do balance.
>>>>>
>>>>> How about use migrate cma before movable and let cma type to fallback movable.
>>>>>
>>>>> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1263745.html
>>>>
>>>> ZONE_CMA approach will act like as your solution. Could you elaborate
>>>> more on the problem of zone approach?
>>>>
>>>
>>> The ZONE approach is that makes cma pages in a zone. It can cause a higher swapin/out
>>> than use migrate cma first.
> 
> Interesting result. I should look at it more deeply. Could you explain
> me why the ZONE approach causes a higher swapin/out?
> 
The result is that. I don't have a obvious reason. Maybe add a zone, need to do more balance
to keep the watermark of cma-zone. cma-zone is always used firstly. Since the test-case
alloced the same memory in total.

>>>
>>> The higher swapin/out may have a performance effect to application. The application may
>>> use too much time swapin memory.
>>>
>>> You can see my tested result attached for detail. And the baseline is result of [1].
>>>
>>>
>> My test case is run 60 applications and alloc 512MB ION memory.
>>
>> Repeat this action 50 times
> 
> Could you tell me more detail about your test?
> Kernel version? Total Memory? Total CMA Memory? Android system? What
> type of memory does ION uses? Other statistics? Etc...

Tested on 4.1, android 7, 512MB-cma in 4G memory.
ION use normal unmovable memory, I use it to simulate a camera open operator.
> 
> If it tested on the Android, I'm not sure that we need to consider
> it's result. Android has a lowmemory killer which is quitely different
> with normal reclaim behaviour.
Why?
> 
> Thanks.
> 
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
