Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 471496B025E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 11:17:41 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u203so1089199itc.0
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 08:17:41 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z38si3081525ota.162.2016.06.03.08.17.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Jun 2016 08:17:40 -0700 (PDT)
Subject: Re: [PATCH 0/10 -v3] Handle oom bypass more gracefully
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
	<201606032100.AIH12958.HMOOOFLJSFQtVF@I-love.SAKURA.ne.jp>
	<20160603122030.GG20676@dhcp22.suse.cz>
In-Reply-To: <20160603122030.GG20676@dhcp22.suse.cz>
Message-Id: <201606040017.HDI52680.LFFOVMJQOFSOHt@I-love.SAKURA.ne.jp>
Date: Sat, 4 Jun 2016 00:17:29 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 03-06-16 21:00:31, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > Patch 8 is new in this version and it addresses an issue pointed out
> > > by 0-day OOM report where an oom victim was reaped several times.
> > 
> > I believe we need below once-you-nacked patch as well.
> > 
> > It would be possible to clear victim->signal->oom_flag_origin when
> > that victim gets TIF_MEMDIE, but I think that moving oom_task_origin()
> > test to oom_badness() will allow oom_scan_process_thread() which calls
> > oom_unkillable_task() only for testing task->signal->oom_victims to be
> > removed by also moving task->signal->oom_victims test to oom_badness().
> > Thus, I prefer this way.
> 
> Can we please forget about oom_task_origin for _now_. At least until we
> resolve the current pile? I am really skeptical oom_task_origin is a
> real problem and even if you think it might be and pulling its handling
> outside of oom_scan_process_thread would be better for other reasons we
> can do that later. Or do you insist this all has to be done in one go?
> 
> To be honest, I feel less and less confident as the pile grows and
> chances of introducing new bugs just grows after each rebase which tries
> to address more subtle and unlikely issues.
> 
> Do no take me wrong but I would rather make sure that the current pile
> is reviewed and no unintentional side effects are introduced than open
> yet another can of worms.
> 
> Thanks!

We have to open yet another can of worms because you insist on using
"decision by feedback from the OOM reaper" than "decision by timeout". ;-)

To be honest, I don't think we need to apply this pile. What is missing for
handling subtle and unlikely issues is "eligibility check for not to select
the same victim forever" (i.e. always set MMF_OOM_REAPED or OOM_SCORE_ADJ_MIN,
and check them before exercising the shortcuts).

Current 4.7-rc1 code will be sufficient (and sometimes even better than
involving user visible changes / selecting next OOM victim without delay)
if we started with "decision by timer" (e.g.
http://lkml.kernel.org/r/201601072026.JCJ95845.LHQOFOOSMFtVFJ@I-love.SAKURA.ne.jp )
approach.

As long as you insist on "decision by feedback from the OOM reaper",
we have to guarantee that the OOM reaper is always invoked in order to
handle subtle and unlikely cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
