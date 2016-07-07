Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 24C096B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 07:48:57 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id g8so47415036itb.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 04:48:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v127si2589045itg.48.2016.07.07.04.48.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 04:48:56 -0700 (PDT)
Subject: Re: [RFC PATCH 1/6] oom: keep mm of the killed task available
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
	<1467365190-24640-2-git-send-email-mhocko@kernel.org>
	<201607031145.HIF90125.LMHQVFJOtOSOFF@I-love.SAKURA.ne.jp>
	<20160707082431.GB5379@dhcp22.suse.cz>
In-Reply-To: <20160707082431.GB5379@dhcp22.suse.cz>
Message-Id: <201607072048.JBE13074.FSOJVHLOFFMOtQ@I-love.SAKURA.ne.jp>
Date: Thu, 7 Jul 2016 20:48:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com

Michal Hocko wrote:
> On Sun 03-07-16 11:45:34, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 7d0a275df822..4ea4a649822d 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -286,16 +286,17 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> > >  	 * Don't allow any other task to have access to the reserves unless
> > >  	 * the task has MMF_OOM_REAPED because chances that it would release
> > >  	 * any memory is quite low.
> > > +	 * MMF_OOM_NOT_REAPABLE means that the oom_reaper backed off last time
> > > +	 * so let it try again.
> > >  	 */
> > >  	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
> > > -		struct task_struct *p = find_lock_task_mm(task);
> > > +		struct mm_struct *mm = task->signal->oom_mm;
> > >  		enum oom_scan_t ret = OOM_SCAN_ABORT;
> > >  
> > > -		if (p) {
> > > -			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
> > > -				ret = OOM_SCAN_CONTINUE;
> > > -			task_unlock(p);
> > > -		}
> > > +		if (test_bit(MMF_OOM_REAPED, &mm->flags))
> > > +			ret = OOM_SCAN_CONTINUE;
> > > +		else if (test_bit(MMF_OOM_NOT_REAPABLE, &mm->flags))
> > > +			ret = OOM_SCAN_SELECT;
> > 
> > I don't think this is useful.
> 
> Well, to be honest me neither but changing the retry logic is not in
> scope of this patch. It just preserved the existing logic. I guess we
> can get rid of it but that deserves a separate patch. The retry was
> implemented to cover unlikely stalls when the lock is held but as this
> hasn't ever been observed in the real life I would agree to remove it to
> simplify the code (even though it is literally few lines of code). I was
> probably overcautious when adding the flag.
> 

You mean reverting http://lkml.kernel.org/r/1466426628-15074-10-git-send-email-mhocko@kernel.org ?

If we hit a situation where MMF_OOM_NOT_REAPABLE is set, it means that that mm
was used by multiple threads and one of them is blocked. On the other hand,
since currently task_struct->oom_reaper_list is used, we can hit
(say, T1 and T2 and T3 are sharing the same mm)

  (1) The T1's mm is queued to oom_reaper_list for the first time by T1.
  (2) The OOM reaper finds that mm for the first time.
  (3) The OOM reaper fails to hold mm->mmap_sem for read because T3 is blocked with that mm->mmap_sem held for write.
  (4) The T2's mm (which is same with T1's mm) is queued to oom_reaper_list for the second time by T2.
  (5) The OOM reaper still fails to hold mm->mmap_sem for read because T3 is blocked with that mm->mmap_sem held for write.
  (6) The OOM reaper sets MMF_OOM_NOT_REAPABLE.
  (7) That mm is dequeued from oom_reaper_list for the first time by the OOM reaper.
  (8) The OOM reaper finds that mm for the second time.
  (9) The OOM reaper still fails to hold mm->mmap_sem for read because T3 is blocked with that mm->mmap_sem held for write.
  (10) The OOM reaper sets MMF_OOM_REAPED.
  (11) That mm is dequeued from oom_reaper_list for the second time by the OOM reaper.

sequences. To me, MMF_OOM_NOT_REAPABLE alone is unlikely helpful.

If oom_mm_list list which chains mm_struct is used, at least we won't
concurrently queue same mm which is currently under OOM reaper's operation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
