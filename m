Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 28F036B0068
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 20:41:41 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 19D6B3EE0B5
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 09:41:39 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 011EA45DE59
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 09:41:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DC75245DE56
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 09:41:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CB46EE08001
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 09:41:38 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BBD41DB804C
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 09:41:38 +0900 (JST)
Message-ID: <4FE11B6C.6020706@jp.fujitsu.com>
Date: Wed, 20 Jun 2012 09:38:04 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch v3] mm, oom: do not schedule if current has been killed
References: <alpine.DEB.2.00.1206181807060.13281@chino.kir.corp.google.com> <4FDFDCA7.8060607@jp.fujitsu.com> <alpine.DEB.2.00.1206181918390.13293@chino.kir.corp.google.com> <alpine.DEB.2.00.1206181930550.13293@chino.kir.corp.google.com> <20120619135551.GA24542@redhat.com> <alpine.DEB.2.00.1206191323470.17985@chino.kir.corp.google.com> <alpine.DEB.2.00.1206191358030.21795@chino.kir.corp.google.com> <4FE0F1A9.7050607@gmail.com>
In-Reply-To: <4FE0F1A9.7050607@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

(2012/06/20 6:39), KOSAKI Motohiro wrote:
> (6/19/12 4:58 PM), David Rientjes wrote:
>> The oom killer currently schedules away from current in an
>> uninterruptible sleep if it does not have access to memory reserves.
>> It's possible that current was killed because it shares memory with the
>> oom killed thread or because it was killed by the user in the interim,
>> however.
>>
>> This patch only schedules away from current if it does not have a pending
>> kill, i.e. if it does not share memory with the oom killed thread.  It's
>> possible that it will immediately retry its memory allocation and fail,
>> but it will immediately be given access to memory reserves if it calls
>> the oom killer again.
>>
>> This prevents the delay of memory freeing when threads that share memory
>> with the oom killed thread get unnecessarily scheduled.
>>
>> Signed-off-by: David Rientjes<rientjes@google.com>
>> ---
>>   mm/oom_kill.c |   11 +++++------
>>   1 file changed, 5 insertions(+), 6 deletions(-)
>>
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -746,11 +746,11 @@ out:
>>   	read_unlock(&tasklist_lock);
>>
>>   	/*
>> -	 * Give "p" a good chance of killing itself before we
>> -	 * retry to allocate memory unless "p" is current
>> +	 * Give the killed threads a good chance of exiting before trying to
>> +	 * allocate memory again.
>>   	 */
>> -	if (killed&&  !test_thread_flag(TIF_MEMDIE))
>> -		schedule_timeout_uninterruptible(1);
>> +	if (killed)
>> +		schedule_timeout_killable(1);
>>   }
>
> This is not match I expected. but I have no seen a big problem.
>
> Acked-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I'll check memcg part to make it consistent to this when this goes to -mm.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
