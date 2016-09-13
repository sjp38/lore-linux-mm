Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8EEEE6B0069
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 03:21:15 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k12so113791194lfb.2
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 00:21:15 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id p19si19430286wmb.111.2016.09.13.00.21.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Sep 2016 00:21:13 -0700 (PDT)
Received: by mail-wm0-f51.google.com with SMTP id b187so171160848wme.1
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 00:21:12 -0700 (PDT)
Date: Tue, 13 Sep 2016 09:21:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 3/4] mm, oom: do not rely on TIF_MEMDIE for exit_oom_victim
Message-ID: <20160913072111.GD31898@dhcp22.suse.cz>
References: <201609041050.BFG65134.OHVFQJOOSLMtFF@I-love.SAKURA.ne.jp>
 <20160909140851.GP4844@dhcp22.suse.cz>
 <201609101529.GCI12481.VOtOLHJQFOSMFF@I-love.SAKURA.ne.jp>
 <201609102155.AHJ57859.SOFHQFOtOFLJVM@I-love.SAKURA.ne.jp>
 <20160912091141.GD14524@dhcp22.suse.cz>
 <201609131525.IGF78600.JFOOVQMOLSHFFt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201609131525.IGF78600.JFOOVQMOLSHFFt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, oleg@redhat.com, viro@zeniv.linux.org.uk

On Tue 13-09-16 15:25:51, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 10-09-16 21:55:49, Tetsuo Handa wrote:
> > > Tetsuo Handa wrote:
> > > > If you worry about tasks which are sitting on a memory which is not
> > > > reclaimable by the oom reaper, why you don't worry about tasks which
> > > > share mm and do not share signal (i.e. clone(CLONE_VM && !CLONE_SIGHAND)
> > > > tasks) ? Thawing only tasks which share signal is a halfway job.
> > > > 
> > > 
> > > Here is a different approach which does not thaw tasks as of mark_oom_victim()
> > > but thaws tasks as of oom_killer_disable(). I think that we don't need to
> > > distinguish OOM victims and killed/exiting tasks when we disable the OOM
> > > killer, for trying to reclaim as much memory as possible is preferable for
> > > reducing the possibility of memory allocation failure after the OOM killer
> > > is disabled.
> > 
> > This makes the oom_killer_disable suspend specific which is imho not
> > necessary. While we do not have any other user outside of the suspend
> > path right now and I hope we will not need any in a foreseeable future
> > there is no real reason to do a hack like this if we can make the
> > implementation suspend independent.
> 
> My intention is to somehow get rid of oom_killer_disable(). While I wrote
> this approach, I again came to wonder why we need to disable the OOM killer
> during suspend.
> 
> If the reason is that the OOM killer thaws already frozen OOM victims,
> we won't have reason to disable the OOM killer if the OOM killer does not
> thaw OOM victims. We can rely on the OOM killer/reaper immediately before
> start taking a memory snapshot for suspend.

Yes, if we don't have to wake already frozen tasks then the life would
be easier. But as I've already mentioned the async oom doesn't cover all
we need and the tasks can be frozen also from the userspace which means
that this is under user control.

> If the reason is that the OOM killer changes SIGKILL pending state of
> already frozen OOM victims during taking a memory snapshot, I think that
> sending SIGKILL via not only SysRq-f but also SysRq-i will be problematic.

Sysrq+i will not be a problem because that will not thaw any frozen
tasks.

> If the reason is that the OOM reaper changes content of mm_struct of
> OOM victims during taking a memory snapshot,

I do not think this is a problem. But I have to think about this some
more. My thinking is that even if saved the original content before
reaping it then all that matters is that the victim just goes away so it
cannot observe the corruption.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
