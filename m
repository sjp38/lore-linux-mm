Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 65F4E6B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:31:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a69so87598138pfa.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 23:31:31 -0700 (PDT)
Received: from mail-pf0-f196.google.com (mail-pf0-f196.google.com. [209.85.192.196])
        by mx.google.com with ESMTPS id qo11si12662117pab.106.2016.06.15.23.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 23:31:30 -0700 (PDT)
Received: by mail-pf0-f196.google.com with SMTP id 66so3354919pfy.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 23:31:30 -0700 (PDT)
Date: Thu, 16 Jun 2016 08:31:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 10/10] mm, oom: hide mm which is shared with kthread or
 global init
Message-ID: <20160616063126.GC30768@dhcp22.suse.cz>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <1465473137-22531-11-git-send-email-mhocko@kernel.org>
 <20160615143701.GA7944@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160615143701.GA7944@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 15-06-16 16:37:01, Oleg Nesterov wrote:
> Michal,
> 
> I am going to ack the whole series, but send some nits/questions,
> 
> On 06/09, Michal Hocko wrote:
> >
> > @@ -283,10 +283,22 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> >  
> >  	/*
> >  	 * This task already has access to memory reserves and is being killed.
> > -	 * Don't allow any other task to have access to the reserves.
> > +	 * Don't allow any other task to have access to the reserves unless
> > +	 * the task has MMF_OOM_REAPED because chances that it would release
> > +	 * any memory is quite low.
> >  	 */
> > -	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
> > -		return OOM_SCAN_ABORT;
> > +	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
> > +		struct task_struct *p = find_lock_task_mm(task);
> > +		enum oom_scan_t ret = OOM_SCAN_ABORT;
> > +
> > +		if (p) {
> > +			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
> > +				ret = OOM_SCAN_CONTINUE;
> > +			task_unlock(p);
> 
> OK, but perhaps it would be beter to change oom_badness() to return zero if
> MMF_OOM_REAPED is set?

We already do that:
	if (adj == OOM_SCORE_ADJ_MIN ||
			test_bit(MMF_OOM_REAPED, &p->mm->flags) ||
			in_vfork(p)) {
		task_unlock(p);
		return 0;
	}

It is kind of subtle that we have to check it 2 times but we would have
to rework this code much more because oom_badness only can tell to
ignore the task but not to abort scanning altogether currently. If we
should change this I would suggest a separate patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
