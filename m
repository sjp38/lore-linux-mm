Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id E5F806B006E
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 09:37:38 -0500 (EST)
Date: Mon, 14 Jan 2013 15:37:30 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <50EDE41C.7090107@iskon.hr>  <1357867501.6568.19.camel@kernel.cn.ibm.com> <50EFF6BC.4060200@iskon.hr> <1358038004.1466.4.camel@kernel.cn.ibm.com>
In-Reply-To: <1358038004.1466.4.camel@kernel.cn.ibm.com>
Message-ID: <50F4182A.80006@iskon.hr>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] mm: wait for congestion to clear on all zones
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 13.01.2013 01:46, Simon Jeons wrote:
> On Fri, 2013-01-11 at 12:25 +0100, Zlatko Calusic wrote:
>> On 11.01.2013 02:25, Simon Jeons wrote:
>>> On Wed, 2013-01-09 at 22:41 +0100, Zlatko Calusic wrote:
>>>> From: Zlatko Calusic <zlatko.calusic@iskon.hr>
>>>>
>>>> Currently we take a short nap (HZ/10) and wait for congestion to clear
>>>> before taking another pass with lower priority in balance_pgdat(). But
>>>> we do that only for the highest zone that we encounter is unbalanced
>>>> and congested.
>>>>
>>>> This patch changes that to wait on all congested zones in a single
>>>> pass in the hope that it will save us some scanning that way. Also we
>>>> take a nap as soon as congested zone is encountered and sc.priority <
>>>> DEF_PRIORITY - 2 (aka kswapd in trouble).
>>>
>>> But you still didn't explain what's the problem you meat and what
>>> scenario can get benefit from your change.
>>>
>>
>> I did in my reply to Andrew. Here's the relevant part:
>>
>>> I have an observation that without it, under some circumstances that
>>> are VERY HARD to repeat (many days need to pass and some stars to align
>>> to see the effect), the page cache gets hit hard, 2/3 of it evicted in
>>> a split second. And it's not even under high load! So, I'm still
>>> monitoring it, but so far the memory utilization really seems better
>>> with the patch applied (no more mysterious page cache shootdowns).
>>
>> The scenario that should get benefit is everyday. I observed problems during
>> light but constant reading from disk (< 10MB/s). And sending that data
>> over the network at the same time. Think backup that compresses data on the
>> fly before pushing it over the network (so it's not very fast).
>>
>> The trouble is that you can't just fix up a quick benchmark and measure the
>> impact, because many days need to pass for the bug to show up in all it's beauty.
>>
>> Is there anybody out there who'd like to comment on the patch logic? I.e. do
>> you think that waiting on every congested zone is the more correct solution
>> than waiting on only one (only the highest one, and ignoring the fact that
>> there may be other even more congested zones)?
> 
> What's the benefit of waiting on every congested zone than waiting on
> only one against your scenario?
> 

The good:

Actually, we are _already_ waiting on every congested zone. And have
been for more than a year. So, all this discussion is... moot.

Andrew, ignore this patch, I'll send you a much better one in a minute.
There shouldn't be nearly so many questions about that one. ;)

The bad:

Obviously then, this patch didn't fix my issue. It just took a little
bit longer for it to appear again.

The ugly:

Here's what I observe on one of my machines:

Node 0, zone      DMA
    nr_vmscan_write 0
    nr_vmscan_immediate_reclaim 0
Node 0, zone    DMA32
    nr_vmscan_write 23164
    nr_vmscan_immediate_reclaim 582038
Node 0, zone   Normal
    nr_vmscan_write 16584344  <-- ugh!
    nr_vmscan_immediate_reclaim 1118415

But that's just a sneak peek, I'll open a proper thread to discuss this
when I collect a little bit more data. BTW, that Normal zone with
extraordinary amount of writebacks under memory pressure is 4 times
smaller than DMA32 zone, that's why I consider it ugly. :P
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
