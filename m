Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id D1A396B0005
	for <linux-mm@kvack.org>; Fri, 19 Feb 2016 10:07:19 -0500 (EST)
Received: by mail-io0-f176.google.com with SMTP id l127so111658661iof.3
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 07:07:19 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 64si21950501iob.99.2016.02.19.07.07.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Feb 2016 07:07:19 -0800 (PST)
Subject: Re: [PATCH v2] mm,oom: exclude oom_task_origin processes if they are OOM-unkillable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1602171430500.15429@chino.kir.corp.google.com>
	<20160218080909.GA18149@dhcp22.suse.cz>
	<201602181930.HIH09321.SFVFOQLHOFMJOt@I-love.SAKURA.ne.jp>
	<20160218120849.GC18149@dhcp22.suse.cz>
	<20160218121333.GD18149@dhcp22.suse.cz>
In-Reply-To: <20160218121333.GD18149@dhcp22.suse.cz>
Message-Id: <201602200007.EAF90182.OQFSOMOFtFJLHV@I-love.SAKURA.ne.jp>
Date: Sat, 20 Feb 2016 00:07:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 18-02-16 13:08:49, Michal Hocko wrote:
> > I guess we can safely remove the memcg
> > argument from oom_badness and oom_unkillable_task. At least from a quick
> > glance...
> 
> No we cannot actually. oom_kill_process could select a child which is in
> a different memcg in that case...

Then, don't we need to check whether processes sharing victim->mm in other
thread groups are in the same memcg when we walk the process list?

----------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f426ce8..d05db31 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -762,8 +762,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		if (same_thread_group(p, victim))
 			continue;
-		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
-		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+		if (oom_badness(p, memcg, oc, totalpages, false) == 0) {
 			/*
 			 * We cannot use oom_reaper for the mm shared by this
 			 * process because it wouldn't get killed and so the
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
