Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6A08D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 14:02:41 -0500 (EST)
Received: by bwz17 with SMTP id 17so133788bwz.14
        for <linux-mm@kvack.org>; Tue, 08 Mar 2011 11:02:36 -0800 (PST)
Message-ID: <4D767D43.5020802@gmail.com>
Date: Tue, 08 Mar 2011 22:02:27 +0300
From: "avagin@gmail.com" <avagin@gmail.com>
Reply-To: avagin@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
References: <20110307135831.9e0d7eaa.akpm@linux-foundation.org> <20110308094438.1ba05ed2.kamezawa.hiroyu@jp.fujitsu.com> <20110308120615.7EB9.A69D9226@jp.fujitsu.com>
In-Reply-To: <20110308120615.7EB9.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/08/2011 06:06 AM, KOSAKI Motohiro wrote:
>>>> Hmm.. Although it solves the problem, I think it's not a good idea that
>>>> depends on false alram and give up the retry.
>>>
>>> Any alternative proposals?  We should get the livelock fixed if possible..
>>
>> I agree with Minchan and can't think this is a real fix....
>> Andrey, I'm now trying your fix and it seems your fix for oom-killer,
>> 'skip-zombie-process' works enough good for my environ.
>>
>> What is your enviroment ? number of cpus ? architecture ? size of memory ?
>
> me too. 'skip-zombie-process V1' work fine. and I didn't seen this patch
> improve oom situation.
>
> And, The test program is purely fork bomb. Our oom-killer is not silver
> bullet for fork bomb from very long time ago. That said, oom-killer send
> SIGKILL and start to kill the victim process. But, it doesn't prevent
> to be created new memory hogging tasks. Therefore we have no gurantee
> to win process exiting and creating race.

I think a live-lock is a bug, even if it's provoked by fork bomds.

And now I want say some words about zone->all_unreclaimable. I think 
this flag is "conservative". It is set when situation is bad and it's 
unset when situation get better. If we have a small number of 
reclaimable  pages, the situation is still bad. What do you mean, when 
say that kernel is alive? If we have one reclaimable page, is the kernel 
alive? Yes, it can work, it will generate many page faults and do 
something, but anyone say that it is more dead than alive.

Try to look at it from my point of view. The patch will be correct and 
the kernel will be more alive.

Excuse me, If I'm mistaken...


>
> *IF* we really need to care fork bomb issue, we need to write completely
> new VM feature.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
