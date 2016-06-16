Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 481B46B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:28:17 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so18321237lfa.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 23:28:17 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id b64si9631144wma.31.2016.06.15.23.28.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 23:28:16 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id m124so8817981wme.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 23:28:16 -0700 (PDT)
Date: Thu, 16 Jun 2016 08:28:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/10] mm, oom_reaper: do not attempt to reap a task more
 than twice
Message-ID: <20160616062814.GB30768@dhcp22.suse.cz>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <1465473137-22531-10-git-send-email-mhocko@kernel.org>
 <20160615144835.GB7944@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160615144835.GB7944@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 15-06-16 16:48:35, Oleg Nesterov wrote:
> On 06/09, Michal Hocko wrote:
> >
> > @@ -556,8 +556,27 @@ static void oom_reap_task(struct task_struct *tsk)
> >  		schedule_timeout_idle(HZ/10);
> >  
> >  	if (attempts > MAX_OOM_REAP_RETRIES) {
> > +		struct task_struct *p;
> > +
> >  		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
> >  				task_pid_nr(tsk), tsk->comm);
> > +
> > +		/*
> > +		 * If we've already tried to reap this task in the past and
> > +		 * failed it probably doesn't make much sense to try yet again
> > +		 * so hide the mm from the oom killer so that it can move on
> > +		 * to another task with a different mm struct.
> > +		 */
> > +		p = find_lock_task_mm(tsk);
> > +		if (p) {
> > +			if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &p->mm->flags)) {
> > +				pr_info("oom_reaper: giving up pid:%d (%s)\n",
> > +						task_pid_nr(tsk), tsk->comm);
> > +				set_bit(MMF_OOM_REAPED, &p->mm->flags);
> 
> But why do we need MMF_OOM_NOT_REAPABLE? We set MMF_OOM_REAPED, oom_reap_task()
> should not see this task again, at least too often.

We set MMF_OOM_REAPED only when actually reaping something in
__oom_reap_task. We might have failed the mmap_sem read lock. The
purpose of this patch is to not encounter such a task for ever and do
not back off too easily. I guess we could set the flag unconditionally
after the first failure and can do that eventually when running out of
MMF flags but thiw way it looks like an easy trade off to me.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
