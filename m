Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CD6686B0026
	for <linux-mm@kvack.org>; Tue, 17 May 2011 21:12:28 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 568FA3EE0C0
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:08:57 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3650C45DF83
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:08:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A7ED45DF86
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:08:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 031AE1DB803F
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:08:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BDE121DB8037
	for <linux-mm@kvack.org>; Wed, 18 May 2011 10:08:56 +0900 (JST)
Message-ID: <4DD31C20.8050608@jp.fujitsu.com>
Date: Wed, 18 May 2011 10:08:48 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] vmscan: implement swap token priority decay
References: <4DCD1824.1060801@jp.fujitsu.com>	<4DCD1913.2090200@jp.fujitsu.com> <20110516172258.c7dcd982.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110516172258.c7dcd982.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, minchan.kim@gmail.com, riel@redhat.com

>> diff --git a/mm/thrash.c b/mm/thrash.c
>> index 14c6c9f..0c4f0a8 100644
>> --- a/mm/thrash.c
>> +++ b/mm/thrash.c
>> @@ -47,6 +47,9 @@ void grab_swap_token(struct mm_struct *mm)
>>   	if (!swap_token_mm)
>>   		goto replace_token;
>>
>> +	if (!(global_faults&  0xff))
>> +		mm->token_priority /= 2;
>> +
>
> I personally don't like this kind of checking counter with mask.
> Hmm. How about this ?
>
> ==
> 	#define TOKEN_AGE_MASK	~(0xff)
> 	/*
> 	 * If current global_fault is in different age from previous global_fault,
> 	 * Aging priority and starts new era.
> 	 */
> 	if ((mm->faultstamp&  TOKEN_AGE_MASK) != (global_faults&  MM_TOKEN_MASK))
> 		mm->token_priority /= 2;
> ==

OK. will do.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
