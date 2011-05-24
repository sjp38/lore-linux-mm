Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 39B1C6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 21:14:29 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 194273EE0C0
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:14:26 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F369D45DF4B
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:14:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DB20545DEDE
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:14:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CA9DE1DB8038
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:14:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 60AAA1DB8037
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:14:25 +0900 (JST)
Message-ID: <4DDB0669.6040409@jp.fujitsu.com>
Date: Tue, 24 May 2011 10:14:17 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] oom: oom-killer don't use proportion of system-ram
 internally
References: <4DD61F80.1020505@jp.fujitsu.com>	<4DD6204D.5020109@jp.fujitsu.com> <BANLkTim2-uncnzoHwdG+4+uCv+Ht4YH3Qw@mail.gmail.com>
In-Reply-To: <BANLkTim2-uncnzoHwdG+4+uCv+Ht4YH3Qw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

Hi


>> @@ -476,14 +476,17 @@ static const struct file_operations proc_lstats_operations = {
>>
>>   static int proc_oom_score(struct task_struct *task, char *buffer)
>>   {
>> -       unsigned long points = 0;
>> +       unsigned long points;
>> +       unsigned long ratio = 0;
>> +       unsigned long totalpages = totalram_pages + total_swap_pages + 1;
>
> Does we need +1?
> oom_badness does have the check.

"ratio = points * 1000 / totalpages;" need to avoid zero divide.

>>         /*
>>          * Root processes get 3% bonus, just like the __vm_enough_memory()
>>          * implementation used by LSMs.
>> +        *
>> +        * XXX: Too large bonus, example, if the system have tera-bytes memory..
>>          */
>> -       if (has_capability_noaudit(p, CAP_SYS_ADMIN))
>> -               points -= 30;
>> +       if (has_capability_noaudit(p, CAP_SYS_ADMIN)) {
>> +               if (points>= totalpages / 32)
>> +                       points -= totalpages / 32;
>> +               else
>> +                       points = 0;
>
> Odd. Why do we initialize points with 0?
>
> I think the idea is good.

The points is unsigned. It's common technique to avoid underflow.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
