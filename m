Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7061F6B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 10:52:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o126so302862081pfb.2
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 07:52:25 -0700 (PDT)
Received: from dggrg03-dlp.huawei.com ([45.249.212.189])
        by mx.google.com with ESMTPS id b185si11649419pfg.247.2017.03.13.07.52.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 07:52:24 -0700 (PDT)
Message-ID: <58C6B1F8.90702@huawei.com>
Date: Mon, 13 Mar 2017 22:51:36 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, page_alloc: fix the duplicate save/ressave irq
References: <1489392174-11794-1-git-send-email-zhongjiang@huawei.com> <20170313111947.rdydbpblymc6a73x@techsingularity.net> <58C6A5C5.9070301@huawei.com> <20170313142636.ghschfm2sff7j7oh@techsingularity.net>
In-Reply-To: <20170313142636.ghschfm2sff7j7oh@techsingularity.net>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Rik
 van Riel <riel@redhat.com>, hillf.zj@alibaba-inc.com, tglx@linutronix.de, brouer@redhat.com

On 2017/3/13 22:26, Mel Gorman wrote:
> On Mon, Mar 13, 2017 at 09:59:33PM +0800, zhong jiang wrote:
>> On 2017/3/13 19:19, Mel Gorman wrote:
>>> On Mon, Mar 13, 2017 at 04:02:54PM +0800, zhongjiang wrote:
>>>> From: zhong jiang <zhongjiang@huawei.com>
>>>>
>>>> when commit 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
>>>> introduced to the mainline, free_pcppages_bulk irq_save/resave to protect
>>>> the IRQ context. but drain_pages_zone fails to clear away the irq. because
>>>> preempt_disable have take effect. so it safely remove the code.
>>>>
>>>> Fixes: 374ad05ab64d ("mm, page_alloc: only use per-cpu allocator for irq-safe requests")
>>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>>> It's not really a fix but is this even measurable?
>>>
>>> The reason the IRQ saving was preserved was for callers that are removing
>>> the CPU where it's not 100% clear if the CPU is protected from IPIs at
>>> the time the pcpu drain takes place. It may be ok but the changelog
>>> should include an indication that it has been considered and is known to
>>> be fine versus CPU hotplug.
>>>
>> you mean the removing cpu maybe  handle the IRQ, it will result in the incorrect pcpu->count ?
>>
> Yes, if it hasn't had interrupts disabled yet at the time of the drain.
> I didn't check, it probably is called from a context that disables
> interrupts but the fact you're not sure makes me automatically wary of
> the patch particularly given how little difference it makes for the common
> case where direct reclaim failed triggering a drain.
  Ok, I will test the benefits or not when direct reclaim failed and trigger a drain.  
>> but I don't sure that dying cpu remain handle the IRQ.
>>
> You'd need to be certain to justify the patch.
>
 Truely , Still  undecided it i rational at least theretically.  

Thanks
zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
