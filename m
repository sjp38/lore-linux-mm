Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id ED19E6B0023
	for <linux-mm@kvack.org>; Wed, 18 May 2011 01:07:10 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E0D793EE0B6
	for <linux-mm@kvack.org>; Wed, 18 May 2011 14:07:05 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C68B645DF87
	for <linux-mm@kvack.org>; Wed, 18 May 2011 14:07:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AE5C545DF85
	for <linux-mm@kvack.org>; Wed, 18 May 2011 14:07:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 97A021DB8040
	for <linux-mm@kvack.org>; Wed, 18 May 2011 14:07:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 34EE61DB803E
	for <linux-mm@kvack.org>; Wed, 18 May 2011 14:07:05 +0900 (JST)
Message-ID: <4DD353E9.6020503@jp.fujitsu.com>
Date: Wed, 18 May 2011 14:06:49 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] comm: Introduce comm_lock spinlock to protect task->comm
 access
References: <1305682865-27111-1-git-send-email-john.stultz@linaro.org>	 <1305682865-27111-2-git-send-email-john.stultz@linaro.org>	 <4DD3287A.2030808@jp.fujitsu.com> <1305691896.2915.136.camel@work-vm>
In-Reply-To: <1305691896.2915.136.camel@work-vm>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.stultz@linaro.org
Cc: linux-kernel@vger.kernel.org, joe@perches.com, mingo@elte.hu, mina86@mina86.com, apw@canonical.com, jirislaby@gmail.com, rientjes@google.com, dave@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org

>> If we provide __get_task_comm(), we can't remove memset() forever.
>
> True enough. I'll fix that comment up then.
>
>>
>>>    	task_lock(tsk);
>>> +	spin_lock_irqsave(&tsk->comm_lock, flags);
>>
>> This is strange order. task_lock() doesn't disable interrupt.
>
> Strange order? Can you explain why you think that is? Having comm_lock
> as an inner-most lock seems quite reasonable, given the limited nature
> of what it protects.

spinlock -> irq_disable is wrong order.

local_irq_save()
task_lock()
spin_lock(task->comm)

is better. I think.

I mean if the task get interrupt at following point,

     	task_lock(tsk);
         // HERE
	spin_lock_irqsave(&tsk->comm_lock, flags);

the task hold task-lock long time rather than expected.

>> And, can you please document why we need interrupt disabling?
>
> Since we might access current->comm from irq context. Where would you
> like this documented? Just there in the code?

I'm prefer code comment. but another way is also good.


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
