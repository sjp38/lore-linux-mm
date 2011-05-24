Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 59B1A6B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 04:41:58 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7FB6C3EE0C2
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:41:54 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 651F545DECA
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:41:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 45DC145DE9C
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:41:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C4A1FE78006
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:41:53 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8298F1DB803E
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:41:53 +0900 (JST)
Message-ID: <4DDB6F48.1010809@jp.fujitsu.com>
Date: Tue, 24 May 2011 17:41:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: Unending loop in __alloc_pages_slowpath following OOM-kill; rfc:
 patch.
References: <4DCDA347.9080207@cray.com>	<BANLkTikiXUzbsUkzaKZsZg+5ugruA2JdMA@mail.gmail.com>	<4DD2991B.5040707@cray.com>	<BANLkTimYEs315jjY9OZsL6--mRq3O_zbDA@mail.gmail.com>	<20110520164924.GB2386@barrios-desktop>	<4DDB3A1E.6090206@jp.fujitsu.com> <BANLkTinkcu5j1H8tHNT4aTmOL-GXfSwPQw@mail.gmail.com>
In-Reply-To: <BANLkTinkcu5j1H8tHNT4aTmOL-GXfSwPQw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: abarry@cray.com, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, riel@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, fengguang.wu@intel.com

>> I'm sorry I missed this thread long time.
> 
> No problem. It would be better than not review.

thx.


>> In this case, I think we should call drain_all_pages(). then following
>> patch is better.
> 
> Strictly speaking, this problem isn't related to drain_all_pages.
> This problem caused by lru empty but I admit it could work well if
> your patch applied.
> So yours could help, too.
> 
>> However I also think your patch is valuable. because while the task is
>> sleeping in wait_iff_congested(), an another task may free some pages.
>> thus, rebalance path should try to get free pages. iow, you makes sense.
> 
> Yes.
> Off-topic.
> I would like to move cond_resched below get_page_from_freelist in
> __alloc_pages_direct_reclaim. Otherwise, it is likely we can be stolen
> pages to other processes.
> One more benefit is that if it's apparently OOM path(ie,
> did_some_progress = 0), we can reduce OOM kill latency due to remove
> unnecessary cond_resched.

I agree. Can you please mind to send a patch?


>> So, I'd like to propose to merge both your and my patch.
> 
> Recently, there was discussion on drain_all_pages with Wu.
> He saw much overhead in 8-core system, AFAIR.
> I Cced Wu.
> 
> How about checking per-cpu before calling drain_all_pages() than
> unconditional calling?
> if (per_cpu_ptr(zone->pageset, smp_processor_id())
>     drain_all_pages();
> 
> Of course, It can miss other CPU free pages. But above routine assume
> local cpu direct reclaim is successful but it failed by per-cpu. So I
> think it works.

Can you please tell me previous discussion url or mail subject?
I mean, if it is costly and performance degression risk, we don't have to
take my idea.

Thanks.


> 
> Thanks for good suggestion and Reviewed-by, KOSAKI.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
