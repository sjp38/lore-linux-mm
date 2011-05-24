Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 4B69E8D003B
	for <linux-mm@kvack.org>; Mon, 23 May 2011 22:10:23 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 22DB53EE0B5
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:10:20 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0965045DF33
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:10:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E23EB45DF30
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:10:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D4252E08003
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:10:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D2BCE78002
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:10:19 +0900 (JST)
Message-ID: <4DDB1388.2080102@jp.fujitsu.com>
Date: Tue, 24 May 2011 11:10:16 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/3] vmscan: implement swap token priority aging
References: <4DD480DD.2040307@jp.fujitsu.com>	<4DD481A7.3050108@jp.fujitsu.com> <20110520123004.e81c932e.akpm@linux-foundation.org>
In-Reply-To: <20110520123004.e81c932e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com

Hi,

(2011/05/21 4:30), Andrew Morton wrote:
> On Thu, 19 May 2011 11:34:15 +0900
> KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>  wrote:
>
>> While testing for memcg aware swap token, I observed a swap token
>> was often grabbed an intermittent running process (eg init, auditd)
>> and they never release a token.
>>
>> Why?
>>
>> Some processes (eg init, auditd, audispd) wake up when a process
>> exiting. And swap token can be get first page-in process when
>> a process exiting makes no swap token owner. Thus such above
>> intermittent running process often get a token.
>>
>> And currently, swap token priority is only decreased at page fault
>> path. Then, if the process sleep immediately after to grab swap
>> token, the swap token priority never be decreased. That's obviously
>> undesirable.
>>
>> This patch implement very poor (and lightweight) priority aging.
>> It only be affect to the above corner case and doesn't change swap
>> tendency workload performance (eg multi process qsbench load)
>>
>> ...
>>
>> --- a/mm/thrash.c
>> +++ b/mm/thrash.c
>> @@ -25,10 +25,13 @@
>>
>>   #include<trace/events/vmscan.h>
>>
>> +#define TOKEN_AGING_INTERVAL	(0xFF)
>
> Needs a comment describing its units and what it does, please.
> Sufficient for readers to understand why this value was chosen and what
> effect they could expect to see from changing it.

Will do.


>>   static DEFINE_SPINLOCK(swap_token_lock);
>>   struct mm_struct *swap_token_mm;
>>   struct mem_cgroup *swap_token_memcg;
>>   static unsigned int global_faults;
>> +static unsigned int last_aging;
>
> Is this a good name?  Would something like prev_global_faults be better?

Current code is "next-aging = last-aging + 256global-fault". so,
prev_global_faults is slightly misleading to me.


> `global_faults' and `last_aging' could be made static local in
> grab_swap_token().

OK. even though I don't like static in a function.


>
>>   void grab_swap_token(struct mm_struct *mm)
>>   {
>> @@ -47,6 +50,11 @@ void grab_swap_token(struct mm_struct *mm)
>>   	if (!swap_token_mm)
>>   		goto replace_token;
>>
>> +	if ((global_faults - last_aging)>  TOKEN_AGING_INTERVAL) {
>> +		swap_token_mm->token_priority /= 2;
>> +		last_aging = global_faults;
>> +	}
>
> It's really hard to reverse-engineer the design decisions from the
> implementation here, therefore...  ?
>
>>   	if (mm == swap_token_mm) {
>>   		mm->token_priority += 2;
>>   		goto update_priority;
>> @@ -64,7 +72,7 @@ void grab_swap_token(struct mm_struct *mm)
>>   		goto replace_token;
>>
>>   update_priority:
>> -	trace_update_swap_token_priority(mm, old_prio);
>> +	trace_update_swap_token_priority(mm, old_prio, swap_token_mm);
>>
>>   out:
>>   	mm->faultstamp = global_faults;
>> @@ -80,6 +88,7 @@ replace_token:
>>   	trace_replace_swap_token(swap_token_mm, mm);
>>   	swap_token_mm = mm;
>>   	swap_token_memcg = memcg;
>> +	last_aging = global_faults;
>>   	goto out;
>>   }
>
> In fact all of grab_swap_token() and the thrash-detection code in
> general are pretty tricky and unobvious stuff.  So we left it
> undocumented :(

Well, original swap token (designed by Rik) is pretty straight forward
implementation on the theory. Therefore we didn't need too verbose doc.
The paper give us good well documentation.

# Oh, now http://www.cs.wm.edu/~sjiang/token.pdf is dead link.
# we should fix it to http://www.cse.ohio-state.edu/hpcs/WWW/HTML/publications/papers/TR-05-1.pdf,
# maybe, or do anybody know better url?

But following commit rewrite almost all code. and we lost good documentation.
It's a bit sad.


commit 7602bdf2fd14a40dd9b104e516fdc05e1bd17952
Author: Ashwin Chaugule <ashwin.chaugule@celunite.com>
Date:   Wed Dec 6 20:31:57 2006 -0800

     [PATCH] new scheme to preempt swap token





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
