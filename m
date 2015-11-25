Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id AF4756B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 10:27:56 -0500 (EST)
Received: by iouu10 with SMTP id u10so57714591iou.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 07:27:56 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p34si21939779ioi.58.2015.11.25.07.27.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 07:27:55 -0800 (PST)
Subject: Re: WARNING in handle_mm_fault
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <CACT4Y+ZCkv0BPOdo3aiheA5LXzXhcnuiw7kCoWL=b9FcC8-wqg@mail.gmail.com>
	<20151125084403.GA24703@dhcp22.suse.cz>
	<565592A1.50407@I-love.SAKURA.ne.jp>
	<CACT4Y+Zn+mK37-mvqDQTyt1Psp6HT2heT0e937SO24F7V1q7PA@mail.gmail.com>
In-Reply-To: <CACT4Y+Zn+mK37-mvqDQTyt1Psp6HT2heT0e937SO24F7V1q7PA@mail.gmail.com>
Message-Id: <201511260027.CCC26590.SOHFMQLVJOtFOF@I-love.SAKURA.ne.jp>
Date: Thu, 26 Nov 2015 00:27:17 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com
Cc: mhocko@kernel.org, hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, syzkaller@googlegroups.com, kcc@google.com, glider@google.com, sasha.levin@oracle.com, edumazet@google.com, gthelen@google.com, tj@kernel.org, peterz@infradead.org

Dmitry Vyukov wrote:
> If the race described in
> http://www.spinics.net/lists/cgroups/msg14078.html does actually
> happen, then there is nothing to check.
> https://gcc.gnu.org/ml/gcc/2012-02/msg00005.html talks about different
> memory locations, if there is store-widening involving different
> memory locations, then this is a compiler bug. But the race happens on
> a single memory location, in such case the code is buggy.
> 

All ->in_execve ->in_iowait ->sched_reset_on_fork ->sched_contributes_to_load
->sched_migrated ->memcg_may_oom ->memcg_kmem_skip_account ->brk_randomized
shares the same byte.

sched_fork(p) modifies p->sched_reset_on_fork but p is not yet visible.
__sched_setscheduler(p) modifies p->sched_reset_on_fork.
try_to_wake_up(p) modifies p->sched_contributes_to_load.
perf_event_task_migrate(p) modifies p->sched_migrated.

Trying to reproduce this problem with

 static __always_inline bool
 perf_sw_migrate_enabled(void)
 {
-	if (static_key_false(&perf_swevent_enabled[PERF_COUNT_SW_CPU_MIGRATIONS]))
-		return true;
 	return false;
 }

would help testing ->sched_migrated case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
