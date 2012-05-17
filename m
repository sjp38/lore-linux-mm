Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id C02086B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 06:29:09 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DE5983EE0BC
	for <linux-mm@kvack.org>; Thu, 17 May 2012 19:29:07 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C70AD45DE71
	for <linux-mm@kvack.org>; Thu, 17 May 2012 19:29:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A9F4945DE73
	for <linux-mm@kvack.org>; Thu, 17 May 2012 19:29:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 708D81DB8042
	for <linux-mm@kvack.org>; Thu, 17 May 2012 19:29:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 274301DB8040
	for <linux-mm@kvack.org>; Thu, 17 May 2012 19:29:07 +0900 (JST)
Message-ID: <4FB4D27D.7020009@jp.fujitsu.com>
Date: Thu, 17 May 2012 19:27:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
References: <1336767077-25351-1-git-send-email-glommer@parallels.com> <1336767077-25351-3-git-send-email-glommer@parallels.com> <20120516140637.17741df6.akpm@linux-foundation.org> <4FB46B4C.3000307@parallels.com> <20120516223715.5d1b4385.akpm@linux-foundation.org> <4FB4CA4D.50608@parallels.com> <4FB4D061.10406@jp.fujitsu.com> <4FB4D14D.4020303@parallels.com>
In-Reply-To: <4FB4D14D.4020303@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

(2012/05/17 19:22), Glauber Costa wrote:

> On 05/17/2012 02:18 PM, KAMEZAWA Hiroyuki wrote:
>> (2012/05/17 18:52), Glauber Costa wrote:
>>
>>> On 05/17/2012 09:37 AM, Andrew Morton wrote:
>>>>>>   If that happens, locking in static_key_slow_inc will prevent any damage.
>>>>>>   My previous version had explicit code to prevent that, but we were
>>>>>>   pointed out that this is already part of the static_key expectations, so
>>>>>>   that was dropped.
>>>> This makes no sense.  If two threads run that code concurrently,
>>>> key->enabled gets incremented twice.  Nobody anywhere has a record that
>>>> this happened so it cannot be undone.  key->enabled is now in an
>>>> unknown state.
>>>
>>> Kame, Tejun,
>>>
>>> Andrew is right. It seems we will need that mutex after all. Just this
>>> is not a race, and neither something that should belong in the
>>> static_branch interface.
>>>
>>
>>
>> Hmm....how about having
>>
>> res_counter_xchg_limit(res,&old_limit, new_limit);
>>
>> if (!cg_proto->updated&&  old_limit == RESOURCE_MAX)
>> 	....update labels...
>>
>> Then, no mutex overhead maybe and activated will be updated only once.
>> Ah, but please fix in a way you like. Above is an example.
> 
> I think a mutex is a lot cleaner than adding a new function to the 
> res_counter interface.
> 
> We could do a counter, and then later decrement the key until the 
> counter reaches zero, but between those two, I still think a mutex here 
> is preferable.
> 
> Only that, instead of coming up with a mutex of ours, we could export 
> and reuse set_limit_mutex from memcontrol.c
> 


ok, please.

thx,
-Kame

> 
>> Thanks,
>> -Kame
>> (*) I'm sorry I won't be able to read e-mails, tomorrow.
>>
> Ok Kame. I am not in a terrible hurry to fix this, it doesn't seem to be 
> hurting any real workload.
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
