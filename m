Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E5D06900001
	for <linux-mm@kvack.org>; Fri, 13 May 2011 07:02:36 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 938873EE0C0
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:02:32 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C9E345DD74
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:02:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5671345DE61
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:02:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A87C1DB802C
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:02:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 06863E08001
	for <linux-mm@kvack.org>; Fri, 13 May 2011 20:02:32 +0900 (JST)
Message-ID: <4DCD1027.70408@jp.fujitsu.com>
Date: Fri, 13 May 2011 20:04:07 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: OOM Killer don't works at all if the system have >gigabytes memory
 (was Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable())
References: <1889981320.330808.1305081044822.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>	<alpine.DEB.2.00.1105111331480.9346@chino.kir.corp.google.com>	<BANLkTi=fNtPZQk5Mp7rbZJFpA1tzBh+VcA@mail.gmail.com>	<alpine.DEB.2.00.1105121229150.2407@chino.kir.corp.google.com> <BANLkTikJvT8BmfvMeyL8MAyww3Gdgm3kPA@mail.gmail.com>
In-Reply-To: <BANLkTikJvT8BmfvMeyL8MAyww3Gdgm3kPA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: David Rientjes <rientjes@google.com>, CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

(2011/05/13 13:16), Minchan Kim wrote:
> On Fri, May 13, 2011 at 4:38 AM, David Rientjes<rientjes@google.com>  wrote:
>> On Thu, 12 May 2011, Minchan Kim wrote:
>>
>>>> processes a 1% bonus for every 30% of memory they use as proposed
>>>> earlier.)
>>>
>>> I didn't follow earlier your suggestion.
>>> But it's not formal patch so I expect if you send formal patch to
>>> merge, you would write down the rationale.
>>>
>>
>> Yes, I'm sure we'll still have additional discussion when KOSAKI-san
>> replies to my review of his patchset, so this quick patch was written only
>> for CAI's testing at this point.
>>
>> In reference to the above, I think that giving root processes a 3% bonus
>> at all times may be a bit aggressive.  As mentioned before, I don't think
>> that all root processes using 4% of memory and the remainder of system
>> threads are using 1% should all be considered equal.  At the same time, I
>> do not believe that two threads using 50% of memory should be considered
>> equal if one is root and one is not.  So my idea was to discount 1% for
>> every 30% of memory that a root process uses rather than a strict 3%.
>>
>> That change can be debated and I think we'll probably settle on something
>> more aggressive like 1% for every 10% of memory used since oom scores are
>> only useful in comparison to other oom scores: in the above scenario where
>> there are two threads, one by root and one not by root, using 50% of
>> memory each, I think it would be legitimate to give the root task a 5%
>> bonus so that it would only be selected if no other threads used more than
>> 44% of memory (even though the root thread is truly using 50%).
>>
>> This is a heuristic within the oom killer badness scoring that can always
>> be debated back and forth, but I think a 1% bonus for root processes for
>> every 10% of memory used is plausible.
>>
>> Comments?
>
> Yes. Tend to agree.
> Apparently, absolute 3% bonus is a problem in CAI's case.
>
> Your approach which makes bonus with function of rss is consistent
> with current OOM heuristic.
> So In consistency POV, I like it as it could help deterministic OOM policy.
>
> About 30% or 10% things, I think it's hard to define a ideal magic
> value for handling for whole workloads.
> It would be very arguable. So we might need some standard method to
> measure it/or redhat/suse peoples. Anyway, I don't want to argue it
> until we get a number.

I have small comments. 1) typical system have some small size system daemon
2) David's points -= 100 * (points / 3000); line doesn't make any bonus if
points is less than 3000. Zero root bonus is really desired? It may lead to
kill system daemon at first issue. 3) if we change minimum bonus from 0% to
1%, we will face the exact same problem when all process have less than
1% memory. It's not rare if the system has a plenty memory.
So, my recalculation logic (patch [4/4]) is necessary anyway.

However, proportional 1% - 10% bonus seems considerable good idea.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
