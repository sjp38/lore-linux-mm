Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC0A86B025E
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 06:40:51 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y134so91945158pfg.1
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 03:40:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 10si2797576pab.31.2016.07.20.03.40.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jul 2016 03:40:51 -0700 (PDT)
Subject: Re: oom-reaper choosing wrong processes.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160718231850.GA23178@codemonkey.org.uk>
	<20160719090857.GB9490@dhcp22.suse.cz>
	<c77149ec-960c-d10a-0410-d09fe47bb14f@I-love.SAKURA.ne.jp>
	<20160719153637.GB11863@codemonkey.org.uk>
In-Reply-To: <20160719153637.GB11863@codemonkey.org.uk>
Message-Id: <201607201940.JEJ30214.OOtFLJHMSQFOFV@I-love.SAKURA.ne.jp>
Date: Wed, 20 Jul 2016 19:40:37 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davej@codemonkey.org.uk
Cc: mhocko@kernel.org, linux-mm@kvack.org

Dave Jones wrote:
> On Tue, Jul 19, 2016 at 07:52:28PM +0900, Tetsuo Handa wrote:
>  > On 2016/07/19 8:18, Dave Jones wrote:
>  > > Whoa. Why did it pick systemd-journal ?
>  > 
>  > I guess that it is because all trinity processes' mm already had MMF_OOM_REAPED set.
>  > 
>  > The OOM reaper sets MMF_OOM_REAPED when OOM reap operation succeeded. But
>  > "[ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name" listing
>  > includes processes whose mm already has MMF_OOM_REAPED set. As a result, trinity-c15 and
>  > trinity-c4 are shown again in the listing. While I can't confirm that trinity-c10, trinity-c2,
>  > trinity-c0 and trinity-c11 are already OOM killed, I guess they are already OOM killed and
>  > their mm already had MMF_OOM_REAPED set.
> 
> That still doesn't explain why it picked the journal process, instead of waiting until
> the previous reaping operation had actually killed those Trinity tasks.

I thought your patch did

--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -169,6 +169,8 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 
 	if (oom_unkillable_task(p, memcg, nodemask))
 		return 0;
+	if (!strncmp(p->comm, "trinity-", 8))
+		return 0;
 
 	p = find_lock_task_mm(p);
 	if (!p)

to OOM-kill only Trinity tasks. But your patch did not touch OOM victim selection logic.
Then, it is completely normal and expected result that systemd-journald was selected
because systemd-journald got highest score among all OOM-killable !MMF_OOM_REAPED mm
users. Nothing is wrong.

By the way, your patch needs to call put_task_struct(p) before return.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
