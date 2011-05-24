Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C5C9C6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 21:45:03 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 76E2A3EE0AE
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:45:00 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B39945DE9A
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:45:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C25C45DE94
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:45:00 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 29A92E78005
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:45:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E67ECE78003
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:44:59 +0900 (JST)
Message-ID: <4DDB0D93.5070005@jp.fujitsu.com>
Date: Tue, 24 May 2011 10:44:51 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] oom: oom-killer don't use proportion of system-ram
 internally
References: <4DD61F80.1020505@jp.fujitsu.com>	<4DD6204D.5020109@jp.fujitsu.com> <BANLkTinpX59NnwsJVQZNTgt_6X3DVK9WLg@mail.gmail.com>
In-Reply-To: <BANLkTinpX59NnwsJVQZNTgt_6X3DVK9WLg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

>> @@ -176,33 +178,49 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>>          */
>>         points = get_mm_rss(p->mm) + p->mm->nr_ptes;
>>         points += get_mm_counter(p->mm, MM_SWAPENTS);
>> -
>> -       points *= 1000;
>> -       points /= totalpages;
>>         task_unlock(p);
>>
>>         /*
>>          * Root processes get 3% bonus, just like the __vm_enough_memory()
>>          * implementation used by LSMs.
>> +        *
>> +        * XXX: Too large bonus, example, if the system have tera-bytes memory..
>>          */
>
> Nitpick. I have no opposition about adding this comment.
> But strictly speaking, the comment isn't related to this patch.
> No biggie and it's up to you.  :)

ok, removed.

 From 3dda8863e5acdba7a714f0e7506fae931865c442 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 24 May 2011 10:43:49 +0900
Subject: [PATCH] remove unrelated comments

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
  mm/oom_kill.c |    2 --
  1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index ec075cc..b01fa64 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -184,8 +184,6 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
  	/*
  	 * Root processes get 3% bonus, just like the __vm_enough_memory()
  	 * implementation used by LSMs.
-	 *
-	 * XXX: Too large bonus, example, if the system have tera-bytes memory..
  	 */
  	if (protect_root && has_capability_noaudit(p, CAP_SYS_ADMIN)) {
  		if (points >= totalpages / 32)
-- 
1.7.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
