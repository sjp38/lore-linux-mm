Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id E73EF6B0254
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 12:57:41 -0400 (EDT)
Received: by qgez77 with SMTP id z77so43745068qge.1
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 09:57:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g36si8684099qkh.100.2015.09.18.09.57.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 09:57:41 -0700 (PDT)
Date: Fri, 18 Sep 2015 18:54:42 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
Message-ID: <20150918165441.GA20665@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150917192204.GA2728@redhat.com> <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org> <20150918162423.GA18136@redhat.com> <201509190139.GJH48908.QMSFJLFtOHOVFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201509190139.GJH48908.QMSFJLFtOHOVFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: cl@linux.com, kwalker@redhat.com, akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On 09/19, Tetsuo Handa wrote:
>
> Oleg Nesterov wrote:
> > To simplify the discussion lets ignore PF_FROZEN, this is another issue.
> >
> > I am not sure this change is enough, we need to ensure that
> > select_bad_process() won't pick the same task (or its sub-thread) again.
>
> SysRq-f is sometimes unusable because it continues choosing the same thread.
> oom_kill_process() should not choose a thread which already has TIF_MEMDIE.

So I was right, this is really not enough...

> I think we need to rewrite oom_kill_process().

Heh. I can only ack the intent and wish you good luck ;)

> > And perhaps something like
> >
> > 	wait_event_timeout(oom_victims_wait, !oom_victims,
> > 				configurable_timeout);
> >
> > before select_bad_process() makes sense?
>
> I think you should not sleep for long with oom_lock mutex held.
> http://marc.info/?l=linux-mm&m=143031212312459

Yes, yes, sure, I didn't mean we should wait under oom_lock.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
