Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6663D6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 22:08:07 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A44BC3EE0C3
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:08:04 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A42645DF32
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:08:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 064FE45DF39
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:08:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EE669E78003
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:08:03 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B57F1E08002
	for <linux-mm@kvack.org>; Tue, 24 May 2011 11:08:03 +0900 (JST)
Message-ID: <4DDB12FD.2000208@jp.fujitsu.com>
Date: Tue, 24 May 2011 11:07:57 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] oom: oom-killer don't use proportion of system-ram
 internally
References: <4DD61F80.1020505@jp.fujitsu.com> <4DD6204D.5020109@jp.fujitsu.com> <alpine.DEB.2.00.1105231522410.17840@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1105231522410.17840@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

(2011/05/24 7:28), David Rientjes wrote:
> On Fri, 20 May 2011, KOSAKI Motohiro wrote:
>
>> CAI Qian reported his kernel did hang-up if he ran fork intensive
>> workload and then invoke oom-killer.
>>
>> The problem is, current oom calculation uses 0-1000 normalized value
>> (The unit is a permillage of system-ram). Its low precision make
>> a lot of same oom score. IOW, in his case, all processes have smaller
>> oom score than 1 and internal calculation round it to 1.
>>
>> Thus oom-killer kill ineligible process. This regression is caused by
>> commit a63d83f427 (oom: badness heuristic rewrite).
>>
>> The solution is, the internal calculation just use number of pages
>> instead of permillage of system-ram. And convert it to permillage
>> value at displaying time.
>>
>> This patch doesn't change any ABI (included  /proc/<pid>/oom_score_adj)
>> even though current logic has a lot of my dislike thing.
>>
>
> Same response as when you initially proposed this patch:
> http://marc.info/?l=linux-kernel&m=130507086613317 -- you never replied to
> that.

I did replay. Why don't you read?
http://www.gossamer-threads.com/lists/linux/kernel/1378837#1378837

If you haven't understand the issue, you can apply following patch and
run it.


diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b01fa64..f35909b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -718,6 +718,9 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
  	 */
  	constraint = constrained_alloc(zonelist, gfp_mask, nodemask,
  						&totalpages);
+
+	totalpages *= 10;
+
  	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
  	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask);



> The changelog doesn't accurately represent CAI Qian's problem; the issue
> is that root processes are given too large of a bonus in comparison to
> other threads that are using at most 1.9% of available memory.  That can
> be fixed, as I suggested by giving 1% bonus per 10% of memory used so that
> the process would have to be using 10% before it even receives a bonus.
>
> I already suggested an alternative patch to CAI Qian to greatly increase
> the granularity of the oom score from a range of 0-1000 to 0-10000 to
> differentiate between tasks within 0.01% of available memory (16MB on CAI
> Qian's 16GB system).  I'll propose this officially in a separate email.
>
> This patch also includes undocumented changes such as changing the bonus
> given to root processes.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
