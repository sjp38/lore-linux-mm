Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 991DB6B0071
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 14:04:46 -0500 (EST)
Message-ID: <4B7454C7.9020600@redhat.com>
Date: Thu, 11 Feb 2010 14:04:39 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: tracking memory usage/leak in "inactive" field in /proc/meminfo?
References: <4B71927D.6030607@nortel.com>	 <20100210093140.12D9.A69D9226@jp.fujitsu.com>	 <4B72E74C.9040001@nortel.com> <28c262361002101645g3fd08cc7t6a72d27b1f94db62@mail.gmail.com> <4B74524D.8080804@nortel.com>
In-Reply-To: <4B74524D.8080804@nortel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 02/11/2010 01:54 PM, Chris Friesen wrote:
> On 02/10/2010 06:45 PM, Minchan Kim wrote:
>> On Thu, Feb 11, 2010 at 2:05 AM, Chris Friesen<cfriesen@nortel.com>  wrote:
>
>>> In those spreadsheets I notice that
>>> memfree+active+inactive+slab+pagetables is basically a constant.
>>> However, if I don't use active+inactive then I can't make the numbers
>>> add up.  And the difference between active+inactive and
>>> buffers+cached+anonpages+dirty+mapped+pagetables+vmallocused grows
>>> almost monotonically.
>>
>> Such comparison is not right. That's because code pages of program account
>> with cached and mapped but they account just one in lru list(active +
>> inactive).
>> Also, if you use mmap on any file, above is applied.
>
> That just makes the comparison even worse...it means that there is more
> memory in active/inactive that isn't accounted for in any other category
> in /proc/meminfo.

Which does not happen in the standard 2.6.27 kernel.

Are you leaking memory in your driver?

>
>> I can't find any clue with your attachment.
>> You said you used kernel with some modification and non-vanilla drivers.
>> So I suspect that. Maybe kernel memory leak?
>
> Possibly.  Or it could be a use case issue, I know there have been
> memory leaks fixed since 2.6.27. :)
>
>> Now kernel don't account kernel memory allocations except SLAB.
>
> I don't think that's entirely accurate.  I think cached, buffers,
> pagetables, vmallocUsed are all kernel allocations.  Granted, they're
> generally on behalf of userspace.
>
> I've discovered that the generic page allocator (alloc_page, etc.) is
> not tracked at all in /proc/meminfo.  I seem to see the memory increase
> in the page cache (that is, active/inactive), so that would seem to rule
> out most direct allocations.
>
>> I think this patch can help you find the kernel memory leak.
>> (It isn't merged with mainline by somewhy but it is useful to you :)
>>
>> http://marc.info/?l=linux-mm&m=123782029809850&w=2
>
> I have a modified version of that which I picked up as part of the
> kmemleak backport.  However, it doesn't help unless I can narrow down
> *which* pages I should care about.
>
> I tried using kmemleak directly, but it didn't find anything.  I've also
> tried checking for inactive pages which haven't been written to in 10
> minutes, and haven't had much luck there either.  But active/inactive
> keeps growing, and I don't know why.
>
> Chris


-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
