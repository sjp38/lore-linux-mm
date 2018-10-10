Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 101496B0007
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 07:35:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e5-v6so3014397eda.4
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 04:35:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d10-v6si15123432ejd.315.2018.10.10.04.35.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 04:35:03 -0700 (PDT)
Date: Wed, 10 Oct 2018 13:35:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: INFO: rcu detected stall in shmem_fault
Message-ID: <20181010113500.GH5873@dhcp22.suse.cz>
References: <000000000000dc48d40577d4a587@google.com>
 <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
 <20181010085945.GC5873@dhcp22.suse.cz>
 <e72f799e-0634-f958-1af0-291f8577f4e8@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e72f799e-0634-f958-1af0-291f8577f4e8@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, hannes@cmpxchg.org, akpm@linux-foundation.org, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, syzkaller-bugs@googlegroups.com, yang.s@alibaba-inc.com, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Petr Mladek <pmladek@suse.com>

On Wed 10-10-18 19:43:38, Tetsuo Handa wrote:
> On 2018/10/10 17:59, Michal Hocko wrote:
> > On Wed 10-10-18 09:12:45, Tetsuo Handa wrote:
> >> syzbot is hitting RCU stall due to memcg-OOM event.
> >> https://syzkaller.appspot.com/bug?id=4ae3fff7fcf4c33a47c1192d2d62d2e03efffa64
> > 
> > This is really interesting. If we do not have any eligible oom victim we
> > simply force the charge (allow to proceed and go over the hard limit)
> > and break the isolation. That means that the caller gets back to running
> > and realease all locks take on the way.
> 
> What happens if the caller continued trying to allocate more memory
> because the caller cannot be noticed by SIGKILL from the OOM killer?

It could eventually trigger the global OOM.

> >                                         I am wondering how come we are
> > seeing the RCU stall. Whole is holding the rcu lock? Certainly not the
> > charge patch and neither should the caller because you have to be in a
> > sleepable context to trigger the OOM killer. So there must be something
> > more going on.
> 
> Just flooding out of memory messages can trigger RCU stall problems.
> For example, a severe skbuff_head_cache or kmalloc-512 leak bug is causing

[...]

Quite some of them, indeed! I guess we want to rate limit the output.
What about the following?

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa5360616..4ee393c85e27 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -430,6 +430,9 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
 
 static void dump_header(struct oom_control *oc, struct task_struct *p)
 {
+	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
+					      DEFAULT_RATELIMIT_BURST);
+
 	pr_warn("%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n",
 		current->comm, oc->gfp_mask, &oc->gfp_mask,
 		nodemask_pr_args(oc->nodemask), oc->order,
@@ -437,6 +440,9 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 	if (!IS_ENABLED(CONFIG_COMPACTION) && oc->order)
 		pr_warn("COMPACTION is disabled!!!\n");
 
+	if (!__ratelimit(&oom_rs))
+		return;
+
 	cpuset_print_current_mems_allowed();
 	dump_stack();
 	if (is_memcg_oom(oc))
@@ -931,8 +937,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	struct task_struct *t;
 	struct mem_cgroup *oom_group;
 	unsigned int victim_points = 0;
-	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
-					      DEFAULT_RATELIMIT_BURST);
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -949,8 +953,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	}
 	task_unlock(p);
 
-	if (__ratelimit(&oom_rs))
-		dump_header(oc, p);
+	dump_header(oc, p);
 
 	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 
> >> What should we do if memcg-OOM found no killable task because the allocating task
> >> was oom_score_adj == -1000 ? Flooding printk() until RCU stall watchdog fires 
> >> (which seems to be caused by commit 3100dab2aa09dc6e ("mm: memcontrol: print proper
> >> OOM header when no eligible victim left") because syzbot was terminating the test
> >> upon WARN(1) removed by that commit) is not a good behavior.
> > 
> > We definitely want to inform about ineligible oom victim. We might
> > consider some rate limiting for the memcg state but that is a valuable
> > information to see under normal situation (when you do not have floods
> > of these situations).
> > 
> 
> But if the caller cannot be noticed by SIGKILL from the OOM killer,
> allowing the caller to trigger the OOM killer again and again (until
> global OOM killer triggers) is bad.

There is simply no other option. Well, except for failing the charge
which has been considered and refused because it could trigger
unexpected error paths and that breaking the isolation on rare cases
when of the misconfiguration is acceptable. We can reconsider that
but you should bring really good arguments on the table. I was very
successful doing that.

-- 
Michal Hocko
SUSE Labs
