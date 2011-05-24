Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E1A8B6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 22:03:42 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C2CF93EE0C0
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:03:39 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AA4A445DE6E
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:03:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BC3545DE4E
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:03:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 505ECE38007
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:03:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 17B121DB803C
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:03:39 +0900 (JST)
Message-ID: <4DDB11F4.2070903@jp.fujitsu.com>
Date: Tue, 24 May 2011 11:03:32 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] oom: don't kill random process
References: <4DD61F80.1020505@jp.fujitsu.com> <4DD6207E.1070300@jp.fujitsu.com> <alpine.DEB.2.00.1105231529340.17840@chino.kir.corp.google.com> <4DDB0B45.2080507@jp.fujitsu.com> <alpine.DEB.2.00.1105231838420.17729@chino.kir.corp.google.com> <4DDB1028.7000600@jp.fujitsu.com> <alpine.DEB.2.00.1105231856210.18353@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1105231856210.18353@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

(2011/05/24 10:58), David Rientjes wrote:
> On Tue, 24 May 2011, KOSAKI Motohiro wrote:
>
>>>>> This is unnecessary and just makes the oom killer egregiously long.  We
>>>>> are already diagnosing problems here at Google where the oom killer
>>>>> holds
>>>>> tasklist_lock on the readside for far too long, causing other cpus
>>>>> waiting
>>>>> for a write_lock_irq(&tasklist_lock) to encounter issues when irqs are
>>>>> disabled and it is spinning.  A second tasklist scan is simply a
>>>>> non-starter.
>>>>>
>>>>>     [ This is also one of the reasons why we needed to introduce
>>>>>       mm->oom_disable_count to prevent a second, expensive tasklist scan.
>>>>> ]
>>>>
>>>> You misunderstand the code. Both select_bad_process() and
>>>> oom_kill_process()
>>>> are under tasklist_lock(). IOW, no change lock holding time.
>>>>
>>>
>>> A second iteration through the tasklist in select_bad_process() will
>>> extend the time that tasklist_lock is held, which is what your patch does.
>>
>> It never happen usual case. Plz think when happen all process score = 1.
>>
>
> I don't care if it happens in the usual case or extremely rare case.  It
> significantly increases the amount of time that tasklist_lock is held
> which causes writelock starvation on other cpus and causes issues,
> especially if the cpu being starved is updating the timer because it has
> irqs disabled, i.e. write_lock_irq(&tasklist_lock) usually in the clone or
> exit path.  We can do better than that, and that's why I proposed my patch
> to CAI that increases the resolution of the scoring and makes the root
> process bonus proportional to the amount of used memory.

Do I need to say the same word? Please read the code at first.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
