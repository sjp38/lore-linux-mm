Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D3A78E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 05:40:33 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id h85so3181168oib.9
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 02:40:33 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t4si620858otj.108.2019.01.17.02.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 02:40:31 -0800 (PST)
Subject: Re: [PATCH] mm, oom: Tolerate processes sharing mm with different
 view of oom_score_adj.
References: <1547636121-9229-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190116110937.GI24149@dhcp22.suse.cz>
 <88e10029-f3d9-5bb5-be46-a3547c54de28@I-love.SAKURA.ne.jp>
 <20190116121915.GJ24149@dhcp22.suse.cz>
 <6118fa8a-7344-b4b2-36ce-d77d495fba69@i-love.sakura.ne.jp>
 <20190116134131.GP24149@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <97fce864-6f75-bca5-14bc-12c9f890e740@i-love.sakura.ne.jp>
Date: Thu, 17 Jan 2019 19:40:12 +0900
MIME-Version: 1.0
In-Reply-To: <20190116134131.GP24149@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Yong-Taek Lee <ytk.lee@samsung.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>

On 2019/01/16 22:41, Michal Hocko wrote:
>>>> I do care about the latency. Holding RCU for more than 2 minutes is insane.
>>>
>>> Creating 8k threads could be considered insane as well. But more
>>> seriously. I absolutely do not insist on holding a single RCU section
>>> for the whole operation. But that doesn't really mean that we want to
>>> revert these changes. for_each_process is by far not only called from
>>> this path.
>>
>> Unlike check_hung_uninterruptible_tasks() where failing to resume after
>> breaking RCU section is tolerable, failing to resume after breaking RCU
>> section for __set_oom_adj() is not tolerable; it leaves the possibility
>> of different oom_score_adj.
> 
> Then make sure that no threads are really missed. Really I fail to see
> what you are actually arguing about.

Impossible unless we hold the global rw_semaphore for read during
copy_process()/do_exit() while hold the global rw_semaphore for write
during __set_oom_adj(). We won't accept such giant lock in order to close
the __set_oom_adj() race.

>                                      for_each_process is expensive. No
> question about that.

I'm saying that printk() is far more expensive. Current __set_oom_adj() code
allows wasting CPU by printing pointless message

  [ 1270.265958][ T8549] updating oom_score_adj for 30876 (a.out) from 0 to 0 because it shares mm with 8549 (a.out). Report if this is unexpected.
  [ 1270.265959][ T8549] updating oom_score_adj for 30877 (a.out) from 0 to 0 because it shares mm with 8549 (a.out). Report if this is unexpected.
  [ 1270.265961][ T8549] updating oom_score_adj for 30878 (a.out) from 0 to 0 because it shares mm with 8549 (a.out). Report if this is unexpected.
  [ 1270.265964][ T8549] updating oom_score_adj for 30879 (a.out) from 0 to 0 because it shares mm with 8549 (a.out). Report if this is unexpected.
  [ 1270.389516][ T8549] updating oom_score_adj for 30880 (a.out) from 0 to 0 because it shares mm with 8549 (a.out). Report if this is unexpected.
  [ 1270.395223][ T8549] updating oom_score_adj for 30881 (a.out) from 0 to 0 because it shares mm with 8549 (a.out). Report if this is unexpected.
  [ 1270.400871][ T8549] updating oom_score_adj for 30882 (a.out) from 0 to 0 because it shares mm with 8549 (a.out). Report if this is unexpected.
  [ 1270.406757][ T8549] updating oom_score_adj for 30883 (a.out) from 0 to 0 because it shares mm with 8549 (a.out). Report if this is unexpected.
  [ 1270.412509][ T8549] updating oom_score_adj for 30884 (a.out) from 0 to 0 because it shares mm with 8549 (a.out). Report if this is unexpected.

for _longer than one month_ ('2 minutes for one __set_oom_adj() call' x '32000
thread groups concurrently do "echo 0 > /proc/self/oom_score_adj"' = 44 days
to complete). This is nothing but a DoS attack vector.

>                      If you can replace it for this specific and odd
> usecase then go ahead. But there is absolutely zero reason to have a
> broken oom_score_adj semantic just because somebody might have thousands
> of threads and want to update the score faster.
> 
>> Unless it is inevitable (e.g. SysRq-t), I think
>> that calling printk() on each thread from RCU section is a poor choice.
>>
>> What if thousands of threads concurrently called __set_oom_adj() when
>> each __set_oom_adj() call involves printk() on thousands of threads
>> which can take more than 2 minutes? How long will it take to complete?
> 
> I really do not mind removing printk if that is what really bothers
> users. The primary purpose of this printk was to catch users who
> wouldn't expect this change. There were exactly zero.
> 

This printk() is pointless. There is no need to flood like above. Once is enough.
What is bad, it says "Report if this is unexpected." rather than "Report if you saw
this message.". If the user thinks that 'Oh, what a nifty caretaker. I need to do
"echo 0 > /proc/self/oom_score_adj" for only once.', that user won't report it.

And I estimate that we will need to wait for several more years to make sure that
all users upgrade their kernels to Linux 4.8+ which has __set_oom_adj() code. So far
"exactly zero" does not mean "changing oom_score_adj semantics is allowable". (But
so far "exactly zero" might suggest that there is absolutely no "CLONE_VM without
CLONE_SIGNAHD" user at all and thus preserving __oom_score_adj() code makes no sense.)



Given that said, I think that querying "CLONE_VM without CLONE_SIGNAHD" users at
copy_process() for the reason of that combination can improve the code.

--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1732,6 +1732,15 @@ static __latent_entropy struct task_struct *copy_process(
 	}
 
 	/*
+	 * Shared VM without signal handlers leads to complicated OOM-killer
+	 * handling. Let's ask such users why they want such combination.
+	 */
+	if ((clone_flags & CLONE_VM) && !(clone_flags & CLONE_SIGHAND))
+		pr_warn_once("***** %s(%d) is trying to create a thread sharing memory without signal handlers. Please be sure to report to linux-mm@kvack.org the reason why you want to use this combination. Otherwise, this combination will be forbidden in future kernels in order to simplify OOM-killer handling. *****\n",
+			     current->comm, task_pid_nr(current));
+
+
+	/*
 	 * Force any signals received before this point to be delivered
 	 * before the fork happens.  Collect up signals sent to multiple
 	 * processes that happen during the fork and delay them so that

If we waited enough period and there is no user, we can forbid that combination
and eliminate OOM handling code for "CLONE_VM without CLONE_SIGNAHD" which is
forcing current __set_oom_adj() code.
