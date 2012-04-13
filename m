Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id EA9826B00F0
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 21:07:31 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 47A583EE0C5
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:07:30 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C12445DE9E
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:07:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F020345DEAD
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:07:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E2A2D1DB803F
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:07:29 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A20B1DB8040
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:07:29 +0900 (JST)
Message-ID: <4F877BE5.7080208@jp.fujitsu.com>
Date: Fri, 13 Apr 2012 10:05:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] res_counter: add a function res_counter_move_parent().
References: <4F86B9BE.8000105@jp.fujitsu.com> <4F86BA66.2010503@jp.fujitsu.com> <4F86D733.50809@parallels.com> <CAFTL4hyKOkoTv=717MkYx4QB0j3B6xA0ZPp1jg6HkrtTkAu7nQ@mail.gmail.com> <4F8779DF.3080307@jp.fujitsu.com> <20120413010443.GD12484@somewhere.redhat.com>
In-Reply-To: <20120413010443.GD12484@somewhere.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

(2012/04/13 10:04), Frederic Weisbecker wrote:

> On Fri, Apr 13, 2012 at 09:57:03AM +0900, KAMEZAWA Hiroyuki wrote:
>> (2012/04/12 23:30), Frederic Weisbecker wrote:
>>
>>> 2012/4/12 Glauber Costa <glommer@parallels.com>:
>>>> On 04/12/2012 08:20 AM, KAMEZAWA Hiroyuki wrote:
>>>>>
>>>>> This function is used for moving accounting information to its
>>>>> parent in the hierarchy of res_counter.
>>>>>
>>>>> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>>>>
>>>> Frederic has a patch in his fork cgroup series, that allows you to
>>>> uncharge a counter until you reach a specific ancestor.
>>>> You pass the parent as a parameter, and then only you gets uncharged.
>>>
>>> I'm missing the referring patchset from Kamezawa. Ok I'm going to
>>> subscribe to the
>>> cgroup mailing list. Meanwhile perhaps would it be nice to keep Cc
>>> LKML for cgroup patches?
>>>
>>
>> Ah, sorry. I will do next time.
>>
>>> Some comments below:
>>>
>>>>
>>>> I think that is a much better interface than this you are proposing.
>>>> We should probably merge that patch and use it.
>>>>
>>>>> ---
>>>>>   include/linux/res_counter.h |    3 +++
>>>>>   kernel/res_counter.c        |   13 +++++++++++++
>>>>>   2 files changed, 16 insertions(+), 0 deletions(-)
>>>>>
>>>>> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
>>>>> index da81af0..8919d3c 100644
>>>>> --- a/include/linux/res_counter.h
>>>>> +++ b/include/linux/res_counter.h
>>>>> @@ -135,6 +135,9 @@ int __must_check res_counter_charge_nofail(struct res_counter *counter,
>>>>>   void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
>>>>>   void res_counter_uncharge(struct res_counter *counter, unsigned long val);
>>>>>
>>>>> +/* move resource to parent counter...i.e. just forget accounting in a child */
>>>>> +void res_counter_move_parent(struct res_counter *counter, unsigned long val);
>>>>> +
>>>>>   /**
>>>>>    * res_counter_margin - calculate chargeable space of a counter
>>>>>    * @cnt: the counter
>>>>> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
>>>>> index d508363..fafebf0 100644
>>>>> --- a/kernel/res_counter.c
>>>>> +++ b/kernel/res_counter.c
>>>>> @@ -113,6 +113,19 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
>>>>>       local_irq_restore(flags);
>>>>>   }
>>>>>
>>>>> +/*
>>>>> + * In hierarchical accounting, child's usage is accounted into ancestors.
>>>>> + * To move local usage to its parent, just forget current level usage.
>>>
>>> The way I understand this comment and the changelog matches the opposite
>>> of what the below function is doing.
>>>
>>> The function charges a child and ignore all its parents. The comments says it
>>> charges the parents but not the child.
>>>
>>
>>
>> Sure, I'll fix...and look into your code first.
>> "uncharge a counter until you reach a specific ancestor"...
>> Is it in linux-next ?
> 
> No, it's part of the task counter so it's still out of tree.
> You were Cc'ed but if you can't find it in your inbox I can
> resend it:
> 
> http://thread.gmane.org/gmane.linux.kernel.containers/22378
> 


Ah, ok. I found it. Thank you!.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
