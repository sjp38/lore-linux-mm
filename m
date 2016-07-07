Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA3E6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 09:33:02 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so18627519wmr.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 06:33:02 -0700 (PDT)
Received: from mail-lf0-f66.google.com (mail-lf0-f66.google.com. [209.85.215.66])
        by mx.google.com with ESMTPS id s2si2588672lfs.401.2016.07.07.06.33.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 06:33:01 -0700 (PDT)
Received: by mail-lf0-f66.google.com with SMTP id w130so1458115lfd.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 06:33:01 -0700 (PDT)
Date: Thu, 7 Jul 2016 15:32:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/6] oom: keep mm of the killed task available
Message-ID: <20160707133259.GL5379@dhcp22.suse.cz>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
 <1467365190-24640-2-git-send-email-mhocko@kernel.org>
 <201607031145.HIF90125.LMHQVFJOtOSOFF@I-love.SAKURA.ne.jp>
 <20160707082431.GB5379@dhcp22.suse.cz>
 <201607072048.JBE13074.FSOJVHLOFFMOtQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607072048.JBE13074.FSOJVHLOFFMOtQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com

On Thu 07-07-16 20:48:46, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sun 03-07-16 11:45:34, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > index 7d0a275df822..4ea4a649822d 100644
> > > > --- a/mm/oom_kill.c
> > > > +++ b/mm/oom_kill.c
> > > > @@ -286,16 +286,17 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> > > >  	 * Don't allow any other task to have access to the reserves unless
> > > >  	 * the task has MMF_OOM_REAPED because chances that it would release
> > > >  	 * any memory is quite low.
> > > > +	 * MMF_OOM_NOT_REAPABLE means that the oom_reaper backed off last time
> > > > +	 * so let it try again.
> > > >  	 */
> > > >  	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
> > > > -		struct task_struct *p = find_lock_task_mm(task);
> > > > +		struct mm_struct *mm = task->signal->oom_mm;
> > > >  		enum oom_scan_t ret = OOM_SCAN_ABORT;
> > > >  
> > > > -		if (p) {
> > > > -			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
> > > > -				ret = OOM_SCAN_CONTINUE;
> > > > -			task_unlock(p);
> > > > -		}
> > > > +		if (test_bit(MMF_OOM_REAPED, &mm->flags))
> > > > +			ret = OOM_SCAN_CONTINUE;
> > > > +		else if (test_bit(MMF_OOM_NOT_REAPABLE, &mm->flags))
> > > > +			ret = OOM_SCAN_SELECT;
> > > 
> > > I don't think this is useful.
> > 
> > Well, to be honest me neither but changing the retry logic is not in
> > scope of this patch. It just preserved the existing logic. I guess we
> > can get rid of it but that deserves a separate patch. The retry was
> > implemented to cover unlikely stalls when the lock is held but as this
> > hasn't ever been observed in the real life I would agree to remove it to
> > simplify the code (even though it is literally few lines of code). I was
> > probably overcautious when adding the flag.
> > 
> 
> You mean reverting http://lkml.kernel.org/r/1466426628-15074-10-git-send-email-mhocko@kernel.org ?

Yes, asuming that MMF_OOM_REAPED is set in that case of course.

[Skipping the rest as this is not related to this patch.]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
