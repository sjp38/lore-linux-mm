Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 24FF66B004D
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 22:05:05 -0400 (EDT)
Message-ID: <4F8CCFD2.70300@kernel.org>
Date: Tue, 17 Apr 2012 11:05:06 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: swap on eMMC and other flash
References: <201203301744.16762.arnd@arndb.de> <201204111557.14153.arnd@arndb.de> <CAKL-ytsXbe4=u94PjqvhZo=ZLiChQ0FmZC84GNrFHa0N1mDjFw@mail.gmail.com> <201204161859.32436.arnd@arndb.de>
In-Reply-To: <201204161859.32436.arnd@arndb.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Stephan Uphoff <ups@google.com>, linaro-kernel@lists.linaro.org, android-kernel@googlegroups.com, linux-mm@kvack.org, "Luca Porzio (lporzio)" <lporzio@micron.com>, Alex Lemberg <alex.lemberg@sandisk.com>, linux-kernel@vger.kernel.org, Saugata Das <saugata.das@linaro.org>, Venkatraman S <venkat@linaro.org>, Yejin Moon <yejin.moon@samsung.com>, Hyojin Jeong <syr.jeong@samsung.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>

Hi Arnd,

On 04/17/2012 03:59 AM, Arnd Bergmann wrote:
> On Monday 16 April 2012, Stephan Uphoff wrote:
>> opportunity to plant a few ideas.
>>
>> In contrast to rotational disks read/write operation overhead and
>> costs are not symmetric.
>> While random reads are much faster on flash - the number of write
>> operations is limited by wearout and garbage collection overhead.
>> To further improve swapping on eMMC or similar flash media I believe
>> that the following issues need to be addressed:
>>
>> 1) Limit average write bandwidth to eMMC to a configurable level to
>> guarantee a minimum device lifetime
>> 2) Aim for a low write amplification factor to maximize useable write bandwidth
>> 3) Strongly favor read over write operations
>>
>> Lowering write amplification (2) has been discussed in this email
>> thread - and the only observation I would like to add is that
>> over-provisioning the internal swap space compared to the exported
>> swap space significantly can guarantee a lower write amplification
>> factor with the indirection and GC techniques discussed.
>
> Yes, good point.
>
>> I believe the swap functionality is currently optimized for storage
>> media where read and write costs are nearly identical.
>> As this is not the case on flash I propose splitting the anonymous
>> inactive queue (at least conceptually) - keeping clean anonymous pages
>> with swap slots on a separate queue as the cost of swapping them
>> out/in is only an inexpensive read operation. A variable similar to
>> swapiness (or a more dynamic algorithmn) could determine the
>> preference for swapping out clean pages or dirty pages. ( A similar
>> argument could be made for splitting up the file inactive queue )
>
> I'm not sure I understand yet how this would be different from swappiness.
>
>> The problem of limiting the average write bandwidth reminds me of
>> enforcing cpu utilization limits on interactive workloads.
>> Just as with cpu workloads - using the resources to the limit produces
>> poor interactivity.
>> When interactivity suffers too much I believe the only sane response
>> for an interactive device is to limit usage of the swap device and
>> transition into a low memory situation - and if needed - either
>> allowing userspace to reduce memory usage or invoking the OOM killer.
>> As a result low memory situations could not only be encountered on new
>> memory allocations but also on workload changes that increase the
>> number of dirty pages.
>
> While swap is just a special case for anonymous memory in writeback
> rather than file backed pages, I think what you want here is a tuning
> knob that decides whether we should discard a clean page or write back
> a dirty page under memory pressure. I have to say that I don't know
> whether we already have such a knob or whether we already treat them
> differently, but it is certainly a valid observation that on hard
> drives, discarding a clean page that is likely going to be needed
> again has about the same overhead as writing back a dirty page
> (i.e. one seek operation), while on flash the former would be much
> cheaper than the latter.

It seems to make sense with considering asymmetric of flash and there is 
a CFLRU(Clean First LRU)[1] paper about it. You might already know it. 
Anyway if you don't aware of it, I hope it helps you.

[1] 
http://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&ved=0CCkQFjAA&url=http%3A%2F%2Fstaff.ustc.edu.cn%2F~jpq%2Fpaper%2Fflash%2F2006-CASES-CFLRU-%2520A%2520Replacement%2520Algorithm%2520for%2520Flash%2520Memory.pdf&ei=G8-MT5jGIqnj0gGMzJyCCg&usg=AFQjCNHybc5rUvuAlMylOUNwsHoFmWegzw&sig2=Uu5LDD3suso0QHsfD7yZ9Q


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
