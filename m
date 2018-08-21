Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4190E6B1EF7
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 09:40:20 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id w19-v6so15836430ioa.10
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 06:40:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id n23-v6si1973157ita.106.2018.08.21.06.40.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 06:40:18 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
References: <20180806205121.GM10003@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com>
 <20180810090735.GY1644@dhcp22.suse.cz>
 <be42a7c0-015e-2992-a40d-20af21e8c0fc@i-love.sakura.ne.jp>
 <20180810111604.GA1644@dhcp22.suse.cz>
 <d9595c92-6763-35cb-b989-0848cf626cb9@i-love.sakura.ne.jp>
 <20180814113359.GF32645@dhcp22.suse.cz>
 <49a73f8a-a472-a464-f5bf-ebd7994ce2d3@i-love.sakura.ne.jp>
 <20180820055417.GA29735@dhcp22.suse.cz>
 <d5be452a-951f-ddc9-e7df-102d292f22c2@i-love.sakura.ne.jp>
 <20180821061655.GV29735@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <b9a12edb-fc6e-9fc1-47c7-34302111229f@i-love.sakura.ne.jp>
Date: Tue, 21 Aug 2018 22:39:58 +0900
MIME-Version: 1.0
In-Reply-To: <20180821061655.GV29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 2018/08/21 15:16, Michal Hocko wrote:
> On Tue 21-08-18 07:03:10, Tetsuo Handa wrote:
>> On 2018/08/20 14:54, Michal Hocko wrote:
>>>>>> Apart from the former is "sequential processing" and "the OOM reaper pays the cost
>>>>>> for reclaiming" while the latter is "parallel (or round-robin) processing" and "the
>>>>>> allocating thread pays the cost for reclaiming", both are timeout based back off
>>>>>> with number of retry attempt with a cap.
>>>>>
>>>>> And it is exactly the who pays the price concern I've already tried to
>>>>> explain that bothers me.
>>>>
>>>> Are you aware that we can fall into situation where nobody can pay the price for
>>>> reclaiming memory?
>>>
>>> I fail to see how this is related to direct vs. kthread oom reaping
>>> though. Unless the kthread is starved by other means then it can always
>>> jump in and handle the situation.
>>
>> I'm saying that concurrent allocators can starve the OOM reaper kernel thread.
>> I don't care if the OOM reaper kernel thread is starved by something other than
>> concurrent allocators, as long as that something is doing useful things.
>>
>> Allocators wait for progress using (almost) busy loop is prone to lockup; they are
>> not doing useful things. But direct OOM reaping allows allocators avoid lockup and
>> do useful things.
> 
> As long as those allocators are making _some_ progress and they are not
> preempted themselves.

Even on linux-next-20180820 where neither the OOM reaper nor exit_mmap() waits for
oom_lock, a cluster of concurrently allocating realtime threads can make the OOM
victim get MMF_OOM_SKIP in 1800 milliseconds

[  122.291910] Out of memory: Kill process 1097 (a.out) score 868 or sacrifice child
[  122.296431] Killed process 1117 (a.out) total-vm:5244kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  125.186061] oom_reaper: reaped process 1117 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  125.191487] crond invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0

[  131.405754] Out of memory: Kill process 1097 (a.out) score 868 or sacrifice child
[  131.409970] Killed process 1121 (a.out) total-vm:5244kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  132.185982] oom_reaper: reaped process 1121 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  132.234704] a.out invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0

[  141.396004] Out of memory: Kill process 1097 (a.out) score 868 or sacrifice child
[  141.400194] Killed process 1128 (a.out) total-vm:5244kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
[  143.184631] oom_reaper: reaped process 1128 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  143.193077] in:imjournal invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0

[  143.721617] Out of memory: Kill process 1097 (a.out) score 868 or sacrifice child
[  143.725965] Killed process 1858 (a.out) total-vm:5244kB, anon-rss:1040kB, file-rss:28kB, shmem-rss:0kB
[  145.218808] oom_reaper: reaped process 1858 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  145.223753] systemd-journal invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0

whereas applying

@@ -440,17 +440,11 @@
 +		ret = true;
 +#ifdef CONFIG_MMU
 +		/*
-+		 * Since the OOM reaper exists, we can safely wait until
-+		 * MMF_OOM_SKIP is set.
++		 * We can safely try to reclaim until MMF_OOM_SKIP is set.
 +		 */
 +		if (!test_bit(MMF_OOM_SKIP, &mm->flags)) {
-+			if (!oom_reap_target) {
-+				get_task_struct(p);
-+				oom_reap_target = p;
-+				trace_wake_reaper(p->pid);
-+				wake_up(&oom_reaper_wait);
-+			}
-+			continue;
++			if (oom_reap_task_mm(p, mm))
++				set_bit(MMF_OOM_SKIP, &mm->flags);
 +		}
 +#endif
 +		/* We can wait as long as OOM score is decreasing over time. */

on top of this series can make the OOM victim get MMF_OOM_SKIP in 10 milliseconds.

[   43.407032] Out of memory: Kill process 1071 (a.out) score 865 or sacrifice child
[   43.411134] Killed process 1816 (a.out) total-vm:5244kB, anon-rss:1040kB, file-rss:0kB, shmem-rss:0kB
[   43.416427] oom_reaper: reaped process 1816 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[   44.689731] a.out invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0

[  159.572877] Out of memory: Kill process 2157 (a.out) score 891 or sacrifice child
[  159.576924] Killed process 2158 (first-victim) total-vm:5244kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[  159.580933] oom_reaper: reaped process 2158 (first-victim), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  160.602346] systemd-journal invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0

[  160.774149] Out of memory: Kill process 2157 (a.out) score 891 or sacrifice child
[  160.778139] Killed process 2159 (a.out) total-vm:5244kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[  160.781779] oom_reaper: reaped process 2159 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  162.745425] a.out invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0

[  162.916173] Out of memory: Kill process 2157 (a.out) score 891 or sacrifice child
[  162.920239] Killed process 2160 (a.out) total-vm:5244kB, anon-rss:88kB, file-rss:0kB, shmem-rss:0kB
[  162.924396] oom_reaper: reaped process 2160 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  166.034599] Gave up waiting for process 2160 (a.out) total-vm:5244kB, anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  166.038446] INFO: lockdep is turned off.
[  166.041780] a.out invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0

This number shows how much CPU resources we will waste for memory reclaim activities
without any progress. (I'm OK with doing both async reclaim by the OOM reaper kernel
thread and sync reclaim by allocating threads.)

>                       Those might be low priority as well.

It will not cause problems as long as we don't reclaim memory with oom_lock held.

>                                                            To make it
> more fun those high priority might easily preempt those which try to
> make the direct reaping.

Ditto.

>                          And if you really want to achieve at least some
> fairness there you will quickly grown into a complex scheme. Really our
> direct reclaim is already quite fragile when it comes to fairness

You can propose removing direct reclaim.
Then, we will get reliable __GFP_KILLABLE as a bonus.

>                                                                   and
> now you want to extend it to be even more fragile.

Direct OOM reaping is different from direct reclaim that direct OOM reaping
is never blocked on memory allocation. Thus, it will not make more fragile.

>                                                    Really, I think you
> are not really appreciating what kind of complex beast you are going to
> create.

Saying "dragon" or "beast" does not defeat me. Rather, such words drive me
to more and more direct OOM reaping (because you don't like waiting for
oom_lock at __alloc_pages_may_oom() which is a simple way for making sure
that CPU resource is spent for memory reclaim activities).

> 
> If we have priority inversion problems during oom then we can always
> return back to high priority oom reaper. This would be so much simpler.

We could utilize higher scheduling priority for memory reclaim activities
by the OOM reaper kernel thread until MMF_OOM_SKIP is set. But what we need
to think about is how we can wait for memory reclaim activities after
MMF_OOM_SKIP is set. A thread doing exit_mmap() might be idle scheduling
priority. Even if allocating threads found that exit_mmap() already reached
to the point of "no more being blocked on memory allocation", allocating
threads might keep exit_mmap() unable to make progress (for many minutes,
effectively forever) due to idle scheduling priority.

You want to preserve "the fairness destroyer" just because you fear creating
"a new monster". But the point of "no more being blocked on memory allocation"
cannot exist without making sure that CPU resources are spent for memory reclaim
activities. Without seriously considering how we can make sure that allocating
threads give enough CPU resources to memory reclaim activities (both "which the
OOM reaper can do" and "which will be done after the OOM reaper gave up"), your
"hand over" plan will fail. Allocating threads pay the cost for memory reclaim
activities is much simpler way.
