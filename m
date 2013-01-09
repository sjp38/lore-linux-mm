Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 1E2AB6B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 17:15:35 -0500 (EST)
Date: Wed, 09 Jan 2013 23:15:29 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <50EDE41C.7090107@iskon.hr> <20130109134816.db51a820.akpm@linux-foundation.org>
In-Reply-To: <20130109134816.db51a820.akpm@linux-foundation.org>
Message-ID: <50EDEC01.7090807@iskon.hr>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] mm: wait for congestion to clear on all zones
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 09.01.2013 22:48, Andrew Morton wrote:
> On Wed, 09 Jan 2013 22:41:48 +0100
> Zlatko Calusic <zlatko.calusic@iskon.hr> wrote:
>
>> Currently we take a short nap (HZ/10) and wait for congestion to clear
>> before taking another pass with lower priority in balance_pgdat(). But
>> we do that only for the highest zone that we encounter is unbalanced
>> and congested.
>>
>> This patch changes that to wait on all congested zones in a single
>> pass in the hope that it will save us some scanning that way. Also we
>> take a nap as soon as congested zone is encountered and sc.priority <
>> DEF_PRIORITY - 2 (aka kswapd in trouble).
>>
>> ...
>>
>> The patch is against the mm tree. Make sure that
>> mm-avoid-calling-pgdat_balanced-needlessly.patch is applied first (not
>> yet in the mmotm tree). Tested on half a dozen systems with different
>> workloads for the last few days, working really well!
>
> But what are the user-observable effcets of this change?  Less kernel
> CPU consumption, presumably?  Did you quantify it?
>

I have an observation that without it, under some circumstances that are 
VERY HARD to repeat (many days need to pass and some stars to align to 
see the effect), the page cache gets hit hard, 2/3 of it evicted in a 
split second. And it's not even under high load! So, I'm still 
monitoring it, but so far the memory utilization really seems better 
with the patch applied (no more mysterious page cache shootdowns).

Other than that, it just seems more correct to wait on all congested 
zones, not just the highest one. When I sent my first patch that 
replaced congestion_wait() I didn't have much time to do elaborate 
analysis (3.7.0 was released in a matter of hours). So, I just plugged 
the hole and continued working on the proper solution.

I do think that this is my last patch in this particular area 
(balance_pgdat() & friends). But, I'll continue investigating for the 
root cause of this interesting debalance that happens only on this 
particular system. Because I think balance_pgdat() behaviour was just 
revealing it, but the real problem is somewhere else.
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
