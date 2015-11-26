Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id AF7336B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 12:31:03 -0500 (EST)
Received: by wmuu63 with SMTP id u63so29434042wmu.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 09:31:03 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id a80si4890504wmd.0.2015.11.26.09.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 09:31:02 -0800 (PST)
Received: by wmec201 with SMTP id c201so30657833wme.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 09:31:02 -0800 (PST)
Date: Thu, 26 Nov 2015 18:31:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: introduce oom reaper
Message-ID: <20151126173100.GA22922@dhcp22.suse.cz>
References: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
 <20151125200806.GA13388@cmpxchg.org>
 <20151126110849.GC7953@dhcp22.suse.cz>
 <201511270024.DFJ57385.OFtJQSMOFFLOHV@I-love.SAKURA.ne.jp>
 <20151126163456.GM7953@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151126163456.GM7953@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, rientjes@google.com, riel@redhat.com, hughd@google.com, oleg@redhat.com, andrea@kernel.org, linux-kernel@vger.kernel.org

On Thu 26-11-15 17:34:56, Michal Hocko wrote:
> On Fri 27-11-15 00:24:43, Tetsuo Handa wrote:
> > Michal Hocko wrote:
[...]
> > > +	tlb_gather_mmu(&tlb, mm, 0, -1);
> > > +	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
> > > +		if (is_vm_hugetlb_page(vma))
> > > +			continue;
> > > +
> > > +		/*
> > > +		 * Only anonymous pages have a good chance to be dropped
> > > +		 * without additional steps which we cannot afford as we
> > > +		 * are OOM already.
> > > +		 */
> > > +		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
> > > +			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
> > > +					 &details);
> > 
> > How do you plan to make sure that reclaimed pages are used by
> > fatal_signal_pending() tasks?
> > http://lkml.kernel.org/r/201509242050.EHE95837.FVFOOtMQHLJOFS@I-love.SAKURA.ne.jp
> > http://lkml.kernel.org/r/201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp
> 
> Well the wake_oom_reaper is responsible to hand over mm of the OOM
> victim and as such it should be a killed process.  I guess you mean that
> the mm might be shared with another process which is hidden from the OOM
> killer, right? Well I think this is not something to care about at this
> layer. We shouldn't select a tasks which can lead to this situation in
> the first place. Such an oom victim is basically selected incorrectly. I
> think we can handle that by a flag in mm_struct.
> 
> I guess we have never cared too much about this case because it sounds
> like a misconfiguration. If you want to shoot your own head the do it.
> It is true that this patch will make such a case more prominent because
> we can cause a side effect now. I can cook up a patch to help to sort
> this out.
> 
> Thanks for pointing this out.

OK, so I was thinking about that some more and came to the conclusion
that we cannot use per mm struct flag. This would be basically
equivalent to moving oom_score_adj to mm_struct which has shown to be a
problem in the past (especially for vfork(); set_oom_score; execve()
loads). So I've ended up with the following. It would mean we will not
use the reaper in some cases but those should be marginal and some of
them even dubious at best.
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 043c0fe146a5..bceeebe96a1b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -646,6 +646,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	unsigned int victim_points = 0;
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
+	bool can_oom_reap = true;
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -736,15 +737,22 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		if (same_thread_group(p, victim))
 			continue;
-		if (unlikely(p->flags & PF_KTHREAD))
-			continue;
-		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
+		if (unlikely(p->flags & PF_KTHREAD) ||
+		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+			/*
+			 * We cannot usee oom_reaper for the mm shared by this process
+			 * because it wouldn't get killed and so the memory might be
+			 * still used.
+			 */
+			can_oom_reap = false;
 			continue;
+		}
 
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
 	}
 	rcu_read_unlock();
-	wake_oom_reaper(mm);
+	if (can_oom_reap)
+		wake_oom_reaper(mm);
 	mmdrop(mm);
 	put_task_struct(victim);
 }
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
