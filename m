Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 233AA6B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 05:59:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 796893EE081
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 18:59:05 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 604E445DE53
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 18:59:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C2CB45DE4E
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 18:59:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BC1E1DB802C
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 18:59:05 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DB0BE1DB803A
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 18:59:04 +0900 (JST)
Message-ID: <4F6C490A.4030608@jp.fujitsu.com>
Date: Fri, 23 Mar 2012 18:57:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Why memory.usage_in_bytes is always increasing after every mmap/dirty/unmap
 sequence
References: <4F6C2E9B.9010200@gmail.com> <4F6C31F7.2010804@jp.fujitsu.com> <4F6C3B7F.1070705@gmail.com> <4F6C3C88.5090800@jp.fujitsu.com> <4F6C3F29.8090402@gmail.com>
In-Reply-To: <4F6C3F29.8090402@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bill4carson <bill4carson@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

(2012/03/23 18:15), bill4carson wrote:

> 
> 
> On 2012a1'03ae??23ae?JPY 17:04, KAMEZAWA Hiroyuki wrote:
>> (2012/03/23 17:59), bill4carson wrote:
>>
>>>
>>>
>>> On 2012a1'03ae??23ae?JPY 16:19, KAMEZAWA Hiroyuki wrote:
>>>> (2012/03/23 17:04), bill4carson wrote:
>>>>
>>>>> Hi, all
>>>>>
>>>>> I'm playing with memory cgroup, I'm a bit confused why
>>>>> memory.usage in bytes is steadily increasing at 4K page pace
>>>>> after every mmap/dirty/unmap sequence.
>>>>>
>>>>> On linux-3.6.34.10/linux-3.3.0-rc5
>>>>> A simple test case does following:
>>>>>
>>>>> a) mmap 128k memory in private anonymous way
>>>>> b) dirty all 128k to demand physical page
>>>>> c) print memory.usage_in_bytes<-- increased at 4K after every loop
>>>>> d) unmap previous 128 memory
>>>>> e) goto a) to repeat
>>>>
>>>> In Documentation/cgroup/memory.txt
>>>> ==
>>>> 5.5 usage_in_bytes
>>>>
>>>> For efficiency, as other kernel components, memory cgroup uses some optimization
>>>> to avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
>>>> method and doesn't show 'exact' value of memory(and swap) usage, it's an fuzz
>>>> value for efficient access. (Of course, when necessary, it's synchronized.)
>>>> If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
>>>> value in memory.stat(see 5.2).
>>>> ==
>>>>
>>>> In current implementation, memcg tries to charge resource in size of 32 pages.
>>>> So, if you get 32 pages and free 32pages, usage_in_bytes may not change.
>>>> This is affected by caches in other cpus and other flushing operations caused
>>>> by some workload in other cgroups. memcg's usage_in_bytes is not precise in
>>>> 128k degree.
>>>>
>>> Yes, I tried to mmap/dirty/unmap in 32 times, when the usage_in_bytes
>>> reached 128k, it rolls back to 4k again. So it doesn't hurt any more.
>>
>>
>> rolls back before unmap() ?
>>
> After unmap
> 

>>>
>>> I haven't found the code regarding to this behavior.
>>
>>
>> Could you post your test program ?
>>
> Yes, it's a bit of messy, you can mock at me:)


Thank you. I tried.

I checked /proc/<pid>/smaps and compares it before I press 'm' and after I press 'm'.
So, anonymous should be increased 128k.

Then...
==
[root@bluextal kamezawa]# diff -Nru before.txt after.txt | grep Anonymous
 Anonymous:             0 kB
-Anonymous:            12 kB
+Anonymous:           140 kB   <============= 128kbytes you allocated
-Anonymous:             8 kB
+Anonymous:            12 kB   <============= maybe some library's heap.

==

Then, 4k remains even if you free all allocated area by your program, I think.

Thanks,
-Kame









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
