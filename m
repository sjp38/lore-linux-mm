Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E670F6B03A1
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 17:57:35 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 46so1824822wru.0
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 14:57:35 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id i24si5556633wrb.191.2017.06.02.14.57.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 14:57:33 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id d127so36356394wmf.0
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 14:57:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
References: <20170601115936.GA9091@dhcp22.suse.cz> <201706012211.GHI18267.JFOVMSOLFFQHOt@I-love.SAKURA.ne.jp>
 <20170601132808.GD9091@dhcp22.suse.cz> <20170601151022.b17716472adbf0e6d51fb011@linux-foundation.org>
 <20170602071818.GA29840@dhcp22.suse.cz> <201706022013.DCI34351.SHOLFFtJQOMFOV@I-love.SAKURA.ne.jp>
From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 2 Jun 2017 14:57:12 -0700
Message-ID: <CAM_iQpWC9E=hee9xYY7Z4_oAA3wK5VOAve-Q1nMD_1SOXJmiyw@mail.gmail.com>
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dave.hansen@intel.com, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, vbabka@suse.cz

On Fri, Jun 2, 2017 at 4:13 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Since the server used in that report is Dell Inc. PowerEdge C6220/03C9JJ,
> I estimate that the total CPUs installed is 12 cores * 2 slots = 24 CPUs.
> (I can confirm that at least 21 CPUs are recognized from "CPU: 20" output.)


Here is the lscpu output in case it is useful for you to debug:

$ lscpu -ae
CPU NODE SOCKET CORE L1d:L1i:L2:L3 ONLINE
0   0    0      0    0:0:0:0       yes
1   0    0      1    1:1:1:0       yes
2   0    0      2    2:2:2:0       yes
3   0    0      3    3:3:3:0       yes
4   0    0      4    4:4:4:0       yes
5   0    0      5    5:5:5:0       yes
6   1    1      6    6:6:6:1       yes
7   1    1      7    7:7:7:1       yes
8   1    1      8    8:8:8:1       yes
9   1    1      9    9:9:9:1       yes
10  1    1      10   10:10:10:1    yes
11  1    1      11   11:11:11:1    yes
12  0    0      0    0:0:0:0       yes
13  0    0      1    1:1:1:0       yes
14  0    0      2    2:2:2:0       yes
15  0    0      3    3:3:3:0       yes
16  0    0      4    4:4:4:0       yes
17  0    0      5    5:5:5:0       yes
18  1    1      6    6:6:6:1       yes
19  1    1      7    7:7:7:1       yes
20  1    1      8    8:8:8:1       yes
21  1    1      9    9:9:9:1       yes
22  1    1      10   10:10:10:1    yes
23  1    1      11   11:11:11:1    yes


> Since Cong was trying to run memcg stress test with 150 memcg groups, I
> estimate that there were 150 threads running. This means that the system
> might have been put under memory pressure where total number of threads
> looping inside the page allocator dominates total number of available CPUs.
> Since Cong assigned 0.5GB memory limit on each memcg group on a server
> which has 64GB of memory, I estimate that the system might experience
> non-memcg OOM due to 150 * 0.5G > 64G.

Just FYI: it is not us who picks those numbers, they are in the LTP test
memcg_stress_test.sh.


>
> Then, this situation resembles my testcase where I put the system under
> memory pressure where total number of threads looping inside the page
> allocator (about one hundred or so) dominates total number of available
> CPUs (i.e. 4) on a system with only 2GB or 4GB RAM (and no swap partition).
> What I can observe is that all CPU times are spent for pointless busy loop
> inside __alloc_pages_slowpath() and makes the OOM killer unable to send
> SIGKILL, and the system stalls to the level where printk() flooding happens
> due to uncontrolled concurrent warn_alloc().
>
> And your response is always "Your system is already DOSed. I don't make
> changes for such system at all." and the situation remained unchanged
> until this moment (i.e. Cong's report). It is possible that
>
>   (a) Cong is unintentionally making the system under DOS like
>       my non-memcg testcase while Cong just wanted to test memcg
>
> but it is also possible that
>
>   (b) Cong is reporting an unnoticed bug in the MM subsystem
>

I suppose so when I report the warning, unless commit
63f53dea0c9866e93802d50a230c460a024 is a false alarm. ;)

If I understand that commit correctly, it warns that we spend too
much time on retrying and make no progress on the mm allocator
slow path, which clearly indicates some problem.

But I thought it is obvious we should OOM instead of hanging
somewhere in this situation? (My mm knowledge is very limited.)


> as well as
>
>   (c) Cong is reporting a bug which does not exist in the latest
>       linux-next kernel
>

As I already mentioned in my original report, I know there are at least
two similar warnings reported before:

https://lkml.org/lkml/2016/12/13/529
https://bugzilla.kernel.org/show_bug.cgi?id=192981

I don't see any fix, nor I see they are similar to mine.


> and you are suspecting only (c) without providing a mechanism for
> checking (a) and (b). kmallocwd helps users to check (a) and (b)
> whereas printk() flooding due to uncontrolled concurrent warn_alloc()
> prevents users from checking (a) and (b). This is really bad.
>
>>
>>> What we should do is to yield CPU time to operations which might do useful
>>> things (let threads not doing memory allocation; e.g. let printk kernel
>>> threads to flush pending buffer, let console drivers write the output to
>>> consoles, let watchdog kernel threads report what is happening).
>>
>> yes we call that preemptive kernel...
>>
>
> And the page allocator is not preemptive. It does not yield enough CPU
> time for other threads to do potentially useful things, allowing (a) to
> happen.
>
>>> When memory allocation request is stalling, serialization via waiting
>>> for a lock does help.
>>
>> Which will mean that those unlucky ones which stall will stall even more
>> because they will wait on a lock with potentially many others. While
>> this certainly is a throttling mechanism it is also a big hammer.
>
> According to my testing, the cause of stalls with flooding of printk() from
> warn_alloc() is exactly the lack of enough CPU time because the page
> allocator continues busy looping when memory allocation is stalling.
>

In the retry loop, warn_alloc() is only called after stall is detected, not
before, therefore waiting on the mutex does not contribute to at least
the first stall.

>
>
> Andrew Morton wrote:
>> I'm thinking we should serialize warn_alloc anyway, to prevent the
>> output from concurrent calls getting all jumbled together?
>
> Yes. According to my testing, serializing warn_alloc() can not yield
> enough CPU time because warn_alloc() is called only once per 10 seconds.
> Serializing
>
> -       if (!mutex_trylock(&oom_lock)) {
> +       if (mutex_lock_killable(&oom_lock)) {
>
> in __alloc_pages_may_oom() can yield enough CPU time to solve the stalls.
>

For this point, I am with you, it would be helpful to serialize them in
case we mix different warnings in dmesg. But you probably need to adjust
the timestamps in case waiting on the mutex contributes to the stall too?

[...]

> This result shows that the OOM killer was not able to send SIGKILL until
> I gave up waiting and pressed SysRq-i because __alloc_pages_slowpath() continued
> wasting CPU time after the OOM killer tried to start printing memory information.
> We can avoid this case if we wait for oom_lock at __alloc_pages_may_oom().
>

Note, in my case OOM killer was probably not even invoked although
the log I captured is a complete one...


Thanks for looking into it!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
