Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 415806B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 05:00:23 -0400 (EDT)
Received: by obbta14 with SMTP id ta14so2898718obb.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 02:00:22 -0700 (PDT)
Message-ID: <4F6C3B7F.1070705@gmail.com>
Date: Fri, 23 Mar 2012 16:59:43 +0800
From: bill4carson <bill4carson@gmail.com>
MIME-Version: 1.0
Subject: Re: Why memory.usage_in_bytes is always increasing after every mmap/dirty/unmap
 sequence
References: <4F6C2E9B.9010200@gmail.com> <4F6C31F7.2010804@jp.fujitsu.com>
In-Reply-To: <4F6C31F7.2010804@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>



On 2012a1'03ae??23ae?JPY 16:19, KAMEZAWA Hiroyuki wrote:
> (2012/03/23 17:04), bill4carson wrote:
>
>> Hi, all
>>
>> I'm playing with memory cgroup, I'm a bit confused why
>> memory.usage in bytes is steadily increasing at 4K page pace
>> after every mmap/dirty/unmap sequence.
>>
>> On linux-3.6.34.10/linux-3.3.0-rc5
>> A simple test case does following:
>>
>> a) mmap 128k memory in private anonymous way
>> b) dirty all 128k to demand physical page
>> c) print memory.usage_in_bytes<-- increased at 4K after every loop
>> d) unmap previous 128 memory
>> e) goto a) to repeat
>
> In Documentation/cgroup/memory.txt
> ==
> 5.5 usage_in_bytes
>
> For efficiency, as other kernel components, memory cgroup uses some optimization
> to avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
> method and doesn't show 'exact' value of memory(and swap) usage, it's an fuzz
> value for efficient access. (Of course, when necessary, it's synchronized.)
> If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
> value in memory.stat(see 5.2).
> ==
>
> In current implementation, memcg tries to charge resource in size of 32 pages.
> So, if you get 32 pages and free 32pages, usage_in_bytes may not change.
> This is affected by caches in other cpus and other flushing operations caused
> by some workload in other cgroups. memcg's usage_in_bytes is not precise in
> 128k degree.
>
Yes, I tried to mmap/dirty/unmap in 32 times, when the usage_in_bytes
reached 128k, it rolls back to 4k again. So it doesn't hurt any more.

I haven't found the code regarding to this behavior.


> - How memory.stat changes ?
> - What happens when you do test with 4M alloc/free ?
>
> Thanks,
> -Kame
>
>
>
>
>
>
>
>
>

-- 
Love each day!

--bill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
