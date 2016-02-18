Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2486B0258
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 03:09:12 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id a4so13074986wme.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 00:09:12 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id lm2si8387761wjc.202.2016.02.18.00.09.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 00:09:11 -0800 (PST)
Received: by mail-wm0-f50.google.com with SMTP id c200so13799826wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 00:09:10 -0800 (PST)
Date: Thu, 18 Feb 2016 09:09:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm,oom: exclude oom_task_origin processes if they are
 OOM-unkillable.
Message-ID: <20160218080909.GA18149@dhcp22.suse.cz>
References: <1455719460-7690-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1602171430500.15429@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1602171430500.15429@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, akpm@linux-foundation.org, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 17-02-16 14:31:54, David Rientjes wrote:
> On Wed, 17 Feb 2016, Tetsuo Handa wrote:
> 
> > oom_scan_process_thread() returns OOM_SCAN_SELECT when there is a
> > thread which returns oom_task_origin() == true. But it is possible
> > that such thread is marked as OOM-unkillable. In that case, the OOM
> > killer must not select such process.
> > 
> > Since it is meaningless to return OOM_SCAN_OK for OOM-unkillable
> > process because subsequent oom_badness() call will return 0, this
> > patch changes oom_scan_process_thread to return OOM_SCAN_CONTINUE
> > if that process is marked as OOM-unkillable (regardless of
> > oom_task_origin()).
> > 
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Suggested-by: Michal Hocko <mhocko@kernel.org>
> > ---
> >  mm/oom_kill.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 7653055..cf87153 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -282,7 +282,7 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
> >  		if (!is_sysrq_oom(oc))
> >  			return OOM_SCAN_ABORT;
> >  	}
> > -	if (!task->mm)
> > +	if (!task->mm || task->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> >  		return OOM_SCAN_CONTINUE;
> >  
> >  	/*
> 
> I'm getting multiple emails from you with the identical patch, something 
> is definitely wacky in your toolchain.
> 
> Anyway, this is NACK'd since task->signal->oom_score_adj is checked under 
> task_lock() for threads with memory attached, that's the purpose of 
> finding the correct thread in oom_badness() and taking task_lock().  We 
> aren't going to duplicate logic in several functions that all do the same 
> thing.

Is the task_lock really necessary, though? E.g. oom_task_origin()
doesn't seem to depend on it for task->signal safety. If you are
referring to races with changing oom_score_adj does such a race matter
at all?

To me this looks like a reasonable cleanup because we _know_ that
OOM_SCORE_ADJ_MIN means OOM_SCAN_CONTINUE and do not really have to go
down to oom_badness to find that out. Or what am I missing?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
