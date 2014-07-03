Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id B24FF6B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 03:34:47 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id ty20so7891613lab.3
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 00:34:46 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id i6si15416302lbd.45.2014.07.03.00.34.44
        for <linux-mm@kvack.org>;
        Thu, 03 Jul 2014 00:34:46 -0700 (PDT)
Message-ID: <53B50791.50208@lge.com>
Date: Thu, 03 Jul 2014 16:34:41 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFC] CMA page migration failure due to buffers on bh_lru
References: <53A8D092.4040801@lge.com>	<xa1td2dvmznq.fsf@mina86.com>	<53ACAB82.6020201@lge.com>	<53B06DD0.8030106@codeaurora.org>	<53B209BA.8010106@lge.com>	<53B216C5.8020503@codeaurora.org> <20140701224621.bb6a5157.akpm@linux-foundation.org>
In-Reply-To: <20140701224621.bb6a5157.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <lauraa@codeaurora.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, Hugh Dickins <hughd@google.com>


Hi, Laura,

I has replaced the evict_bh_lrus(bh) with invalidate_bh_lrus() and it is working fine.
How about submit new patch with invalidate_bh_lrus()?
I would appreciate it.



2014-07-02 i??i?? 2:46, Andrew Morton i?' e,?:
> On Mon, 30 Jun 2014 19:02:45 -0700 Laura Abbott <lauraa@codeaurora.org> wrote:
>
>> On 6/30/2014 6:07 PM, Gioh Kim wrote:
>>> Hi,Laura.
>>>
>>> I have a question.
>>>
>>> Does the __evict_bh_lru() not need bh_lru_lock()?
>>> The get_cpu_var() has already preenpt_disable() and can prevent other thread.
>>> But get_cpu_var cannot prevent IRQ context such like page-fault.
>>> I think if a page-fault occured and a file is read in IRQ context it can change cpu-lru.
>>>
>>> Is my concern correct?
>>>
>>>
>>
>> __evict_bh_lru is called via on_each_cpu_cond which I believe will disable irqs.
>> I based the code on the existing invalidate_bh_lru which did not take the bh_lru_lock
>> either. It's possible I missed something though.
>
> I fear that running on_each_cpu() within try_to_free_buffers() is going
> to be horridly expensive in some cases.
>
> Maybe CMA can use invalidate_bh_lrus() to shoot down everything before
> trying the allocation attempt.  That should increase the success rate
> greatly and doesn't burden page reclaim.  The bh LRU isn't terribly
> important from a performance point of view, so emptying it occasionally
> won't hurt.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
