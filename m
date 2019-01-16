Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id B76AD8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 06:30:49 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id q23so3039607otn.3
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 03:30:49 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t22si2855173oih.69.2019.01.16.03.30.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 03:30:48 -0800 (PST)
Subject: Re: [PATCH] mm, oom: Tolerate processes sharing mm with different
 view of oom_score_adj.
References: <1547636121-9229-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190116110937.GI24149@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <88e10029-f3d9-5bb5-be46-a3547c54de28@I-love.SAKURA.ne.jp>
Date: Wed, 16 Jan 2019 20:30:25 +0900
MIME-Version: 1.0
In-Reply-To: <20190116110937.GI24149@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Yong-Taek Lee <ytk.lee@samsung.com>

On 2019/01/16 20:09, Michal Hocko wrote:
> On Wed 16-01-19 19:55:21, Tetsuo Handa wrote:
>> This patch reverts both commit 44a70adec910d692 ("mm, oom_adj: make sure
>> processes sharing mm have same view of oom_score_adj") and commit
>> 97fd49c2355ffded ("mm, oom: kill all tasks sharing the mm") in order to
>> close a race and reduce the latency at __set_oom_adj(), and reduces the
>> warning at __oom_kill_process() in order to minimize the latency.
>>
>> Commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE after oom_reaper managed
>> to unmap the address space") introduced the worst case mentioned in
>> 44a70adec910d692. But since the OOM killer skips mm with MMF_OOM_SKIP set,
>> only administrators can trigger the worst case.
>>
>> Since 44a70adec910d692 did not take latency into account, we can hold RCU
>> for minutes and trigger RCU stall warnings by calling printk() on many
>> thousands of thread groups. Even without calling printk(), the latency is
>> mentioned by Yong-Taek Lee [1]. And I noticed that 44a70adec910d692 is
>> racy, and trying to fix the race will require a global lock which is too
>> costly for rare events.
>>
>> If the worst case in 44a70adec910d692 happens, it is an administrator's
>> request. Therefore, tolerate the worst case and speed up __set_oom_adj().
> 
> I really do not think we care about latency. I consider the overal API
> sanity much more important. Besides that the original report you are
> referring to was never exaplained/shown to represent real world usecase.
> oom_score_adj is not really a an interface to be tweaked in hot paths.

I do care about the latency. Holding RCU for more than 2 minutes is insane.

----------
#define _GNU_SOURCE
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sched.h>
#include <sys/mman.h>
#include <signal.h>

#define STACKSIZE 8192
static int child(void *unused)
{
        pause();
        return 0;
}
int main(int argc, char *argv[])
{
        int fd = open("/proc/self/oom_score_adj", O_WRONLY);
        int i;
        char *stack = mmap(NULL, STACKSIZE, PROT_WRITE | PROT_READ, MAP_ANONYMOUS | MAP_PRIVATE, EOF, 0);
        for (i = 0; i < 8192 * 4; i++)
                if (clone(child, stack + STACKSIZE, CLONE_VM, NULL) == -1)
                        break;
        write(fd, "0\n", 2);
        kill(0, SIGSEGV);
        return 0;
}
----------

> 
> I can be convinced otherwise but that really requires some _real_
> usecase with an explanation why there is no other way. Until then
> 
> Nacked-by: Michal Hocko <mhocko@suse.com>
