Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 435786B005A
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 22:09:52 -0500 (EST)
Message-ID: <4F0BABE0.8080107@redhat.com>
Date: Mon, 09 Jan 2012 22:09:20 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] make swapin readahead skip over holes
References: <20120109181023.7c81d0be@annuminas.surriel.com> <4F0B7D1F.7040802@gmail.com>
In-Reply-To: <4F0B7D1F.7040802@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On 01/09/2012 06:49 PM, KOSAKI Motohiro wrote:
> (1/9/12 6:10 PM), Rik van Riel wrote:
>> Ever since abandoning the virtual scan of processes, for scalability
>> reasons, swap space has been a little more fragmented than before.
>> This can lead to the situation where a large memory user is killed,
>> swap space ends up full of "holes" and swapin readahead is totally
>> ineffective.
>>
>> On my home system, after killing a leaky firefox it took over an
>> hour to page just under 2GB of memory back in, slowing the virtual
>> machines down to a crawl.
>>
>> This patch makes swapin readahead simply skip over holes, instead
>> of stopping at them. This allows the system to swap things back in
>> at rates of several MB/second, instead of a few hundred kB/second.
>
> If I understand correctly, this patch have
>
> Pros
> - increase IO throughput

By about a factor 3-10 in my tests here.

> Cons
> - increase a risk to pick up unrelated swap entries by swap readahead

I do not believe there is a very large risk of this, because
since we introduced rmap, we have been placing unrelated
pages right next to each other in swap.

This is also why, since 2.6.28, the kernel places newly swapped
in pages on the INACTIVE_ANON list, where they should not
displace the working set.

Another factor is that swapping on modern systems is often a
temporary thing. During a load spike, things get swapped out
and run slowly. After the load spike is over, or some memory
hog process got killed, we want the system to recover to normal
performance as soon as possible.  This often involves swapping
everything back into memory.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
