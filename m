Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 2BC956B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 02:33:02 -0400 (EDT)
Message-ID: <4FEAA925.9020202@kernel.org>
Date: Wed, 27 Jun 2012 15:33:09 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: needed lru_add_drain_all() change
References: <20120626143703.396d6d66.akpm@linux-foundation.org> <4FEA59EE.8060804@kernel.org> <20120626181504.23b8b73d.akpm@linux-foundation.org> <4FEA6B5B.5000205@kernel.org> <20120626221217.1682572a.akpm@linux-foundation.org> <4FEA9D13.6070409@kernel.org> <20120626225544.068df1b9.akpm@linux-foundation.org>
In-Reply-To: <20120626225544.068df1b9.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On 06/27/2012 02:55 PM, Andrew Morton wrote:

> On Wed, 27 Jun 2012 14:41:39 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
>> On 06/27/2012 02:12 PM, Andrew Morton wrote:
>>
>>> On Wed, 27 Jun 2012 11:09:31 +0900 Minchan Kim <minchan@kernel.org> wrote:
>>>
>>>> On 06/27/2012 10:15 AM, Andrew Morton wrote:
>>>>
>>>>>> Considering mlock and CPU pinning
>>>>>>> of realtime thread is very rare, it might be rather expensive solution.
>>>>>>> Unfortunately, I have no idea better than you suggested. :(
>>>>>>>
>>>>>>> And looking 8891d6da17, mlock's lru_add_drain_all isn't must.
>>>>>>> If it's really bother us, couldn't we remove it?
>>>>> "grep lru_add_drain_all mm/*.c".  They're all problematic.
>>>>
>>>>
>>>> Yeb but I'm not sure such system modeling is good.
>>>> Potentially, It could make problem once we use workqueue of other CPU.
>>>
>>> whut?
>>>
>>> My suggestion is that we switch lru_add_drain_all() to on_each_cpu()
>>> and delete schedule_on_each_cpu().  No workqueues.
>>
>>
>> Current problem is that RT thread doesn't yield his CPU so other tasks can't be scheduled in.
>> schedule_on_each_cpu uses system workqueue so if there are any user to try using
>> workqueue for the CPU(ex, schedule_work_on), he can make trouble, too.
>> So my question is I doubt such greedy RT thread modeling is good.
>>
> 
> There's no way of fixing this without significantly degrading the
> service which rt priority offers.  As we don't wish to degrade that
> service, schedule_work_on() and schedule_on_each_cpu() cannot be
> implemented reliably.  So we delete them.


Okay. I'm not against strongly if local_irq_save/restore isn't expensive
as a first step for removing them because I have no good idea.
I want to add some comment on schedule_work_on and friends.
"You shouldn't use it any more and we will try to remove this".

Anyway, let's wait further answer, especially, RT folks. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
