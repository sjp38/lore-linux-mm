Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id CC48D900166
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 21:48:36 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 213873EE0BD
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 10:48:32 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EE30D45DE54
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 10:48:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE3D445DE51
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 10:48:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BDDC41DB8041
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 10:48:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 85C151DB803E
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 10:48:31 +0900 (JST)
Message-ID: <4E37576C.1000908@jp.fujitsu.com>
Date: Tue, 02 Aug 2011 10:48:28 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 3/3]vmscan: cleanup kswapd_try_to_sleep
References: <1311840789.15392.409.camel@sli10-conroe>  <4E374637.20202@jp.fujitsu.com> <1312247004.15392.451.camel@sli10-conroe>
In-Reply-To: <1312247004.15392.451.camel@sli10-conroe>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shaohua.li@intel.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, minchan.kim@gmail.com

(2011/08/02 10:03), Shaohua Li wrote:
> On Tue, 2011-08-02 at 08:35 +0800, KOSAKI Motohiro wrote:
>> (2011/07/28 17:13), Shaohua Li wrote:
>>> cleanup kswapd_try_to_sleep() a little bit. Sometimes kswapd doesn't
>>> really sleep. In such case, don't call prepare_to_wait/finish_wait.
>>> It just wastes CPU.
>>>
>>> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
>>> ---
>>>  mm/vmscan.c |    7 +++----
>>>  1 file changed, 3 insertions(+), 4 deletions(-)
>>>
>>> Index: linux/mm/vmscan.c
>>> ===================================================================
>>> --- linux.orig/mm/vmscan.c	2011-07-28 15:52:35.000000000 +0800
>>> +++ linux/mm/vmscan.c	2011-07-28 15:55:56.000000000 +0800
>>> @@ -2709,13 +2709,11 @@ static void kswapd_try_to_sleep(pg_data_
>>>  	if (freezing(current) || kthread_should_stop())
>>>  		return;
>>>  
>>> -	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>>> -
>>>  	/* Try to sleep for a short interval */
>>>  	if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx)) {
>>> +		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>>>  		remaining = schedule_timeout(HZ/10);
>>>  		finish_wait(&pgdat->kswapd_wait, &wait);
>>> -		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>>>  	}
>>>  
>>>  	/*
>>> @@ -2734,7 +2732,9 @@ static void kswapd_try_to_sleep(pg_data_
>>>  		 * them before going back to sleep.
>>>  		 */
>>>  		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
>>> +		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>>>  		schedule();
>>> +		finish_wait(&pgdat->kswapd_wait, &wait);
>>>  		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
>>>  	} else {
>>>  		if (remaining)
>>> @@ -2742,7 +2742,6 @@ static void kswapd_try_to_sleep(pg_data_
>>>  		else
>>>  			count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
>>>  	}
>>> -	finish_wait(&pgdat->kswapd_wait, &wait);
>>>  }
>>>  
>>>  /*
>>
>> Prepare_to_wait/finish_wait basic usage is below. Briefly,
>> 1) prepare_to_wait() is needed to call every sleeping
> yes
> 
>> 2) finish_wait is only need to exit sleeping loop
>>
>> So, 1) moving prepare_to_wait looks pretty good to me. but I doubt the worth
>> of moving the finish_wait of function last.
> so you are talking about leave the last finish_wait at the end of the
> function, and delete other finish_wait, right? 

exactly. :)


> that is ok, but I'm
> afraid it's not readable. a pair of prepare_to_wait/schedule/finish_wait
> is more readable.

hm. I personally think keeping generic usage convention doesn't decrease
a readability. but I have no strong option. so, I'd like to hear other
developers opinion. if they agree with you, I'll not stick my opinion.

Thanks.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
