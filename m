Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5A16B0035
	for <linux-mm@kvack.org>; Sun, 22 Jun 2014 22:10:54 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so5219964pbc.20
        for <linux-mm@kvack.org>; Sun, 22 Jun 2014 19:10:54 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id mo2si19634893pbc.110.2014.06.22.19.10.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 22 Jun 2014 19:10:53 -0700 (PDT)
Message-ID: <53A78B7C.1050302@huawei.com>
Date: Mon, 23 Jun 2014 10:05:48 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] mm: add page cache limit and reclaim feature
References: <539EB7D6.8070401@huawei.com> <20140616111422.GA16915@dhcp22.suse.cz> <20140616125040.GA29993@optiplex.redhat.com> <539F9B6C.1080802@huawei.com> <53A3E948.5020701@huawei.com> <20140620153212.GD23115@dhcp22.suse.cz>
In-Reply-To: <20140620153212.GD23115@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>

On 2014/6/20 23:32, Michal Hocko wrote:

> On Fri 20-06-14 15:56:56, Xishi Qiu wrote:
>> On 2014/6/17 9:35, Xishi Qiu wrote:
>>
>>> On 2014/6/16 20:50, Rafael Aquini wrote:
>>>
>>>> On Mon, Jun 16, 2014 at 01:14:22PM +0200, Michal Hocko wrote:
>>>>> On Mon 16-06-14 17:24:38, Xishi Qiu wrote:
>>>>>> When system(e.g. smart phone) running for a long time, the cache often takes
>>>>>> a large memory, maybe the free memory is less than 50M, then OOM will happen
>>>>>> if APP allocate a large order pages suddenly and memory reclaim too slowly. 
>>>>>
>>>>> Have you ever seen this to happen? Page cache should be easy to reclaim and
>>>>> if there is too mach dirty memory then you should be able to tune the
>>>>> amount by dirty_bytes/ratio knob. If the page allocator falls back to
>>>>> OOM and there is a lot of page cache then I would call it a bug. I do
>>>>> not think that limiting the amount of the page cache globally makes
>>>>> sense. There are Unix systems which offer this feature but I think it is
>>>>> a bad interface which only papers over the reclaim inefficiency or lack
>>>>> of other isolations between loads.
>>>>>
>>>> +1
>>>>
>>>> It would be good if you could show some numbers that serve as evidence
>>>> of your theory on "excessive" pagecache acting as a trigger to your
>>>> observed OOMs. I'm assuming, by your 'e.g', you're running a swapless
>>>> system, so I would think your system OOMs are due to inability to
>>>> reclaim anon memory, instead of pagecache.
>>>>
>>
>> I asked some colleagues, when the cache takes a large memory, it will not
>> trigger OOM, but performance regression. 
>>
>> It is because that business process do IO high frequency, and this will 
>> increase page cache. When there is not enough memory, page cache will
>> be reclaimed first, then alloc a new page, and add it to page cache. This
>> often takes too much time, and causes performance regression.
> 
> I cannot say I would understand the problem you are describing. So the
> page cache eats the most of the memory and that increases allocation
> latency for new page cache? Is it because of the direct reclaim?

Yes, allocation latency causes performance regression.

A user process produces page cache frequently, so free memory is not
enough after running a long time. Slow path takes much more time because 
direct reclaim. And kswapd will reclaim memory too, but not much. Thus it
always triggers slow path. this will cause performance regression.

Thanks,
Xishi Qiu

> Why kswapd doesn't reclaim the clean pagecache? Or is the memory dirty?
> 

>> In view of this situation, if we reclaim page cache in circles may be
>> fix this problem. What do you think?
> 
> No, it seems more like either system misconfiguration or a reclaim bug.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
