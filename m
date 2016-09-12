Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1657A6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 05:11:45 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n4so81024273lfb.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 02:11:45 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id 81si14371493wmp.140.2016.09.12.02.11.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 02:11:43 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id b187so124970022wme.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 02:11:43 -0700 (PDT)
Date: Mon, 12 Sep 2016 11:11:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 3/4] mm, oom: do not rely on TIF_MEMDIE for exit_oom_victim
Message-ID: <20160912091141.GD14524@dhcp22.suse.cz>
References: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
 <1472723464-22866-4-git-send-email-mhocko@kernel.org>
 <201609041050.BFG65134.OHVFQJOOSLMtFF@I-love.SAKURA.ne.jp>
 <20160909140851.GP4844@dhcp22.suse.cz>
 <201609101529.GCI12481.VOtOLHJQFOSMFF@I-love.SAKURA.ne.jp>
 <201609102155.AHJ57859.SOFHQFOtOFLJVM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201609102155.AHJ57859.SOFHQFOtOFLJVM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, oleg@redhat.com, viro@zeniv.linux.org.uk

On Sat 10-09-16 21:55:49, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > > > Do we want to thaw OOM victims from the beginning? If the freezer
> > > > depends on CONFIG_MMU=y , we don't need to thaw OOM victims.
> > > 
> > > We want to thaw them, at least at this stage, because the task might be
> > > sitting on a memory which is not reclaimable by the oom reaper (e.g.
> > > different buffers of file descriptors etc.).
> 
> I haven't heard an answer to the question whether the freezer depends on
> CONFIG_MMU=y. But I assume the answer is yes here.

I do not think it depends on CONFIG_MMU. At least CGROUP_FREEZER depends
on CONFIG_CGROUPS and that doesn't seem to have any direct dependency on
MMU.

> > 
> > If you worry about tasks which are sitting on a memory which is not
> > reclaimable by the oom reaper, why you don't worry about tasks which
> > share mm and do not share signal (i.e. clone(CLONE_VM && !CLONE_SIGHAND)
> > tasks) ? Thawing only tasks which share signal is a halfway job.
> > 
> 
> Here is a different approach which does not thaw tasks as of mark_oom_victim()
> but thaws tasks as of oom_killer_disable(). I think that we don't need to
> distinguish OOM victims and killed/exiting tasks when we disable the OOM
> killer, for trying to reclaim as much memory as possible is preferable for
> reducing the possibility of memory allocation failure after the OOM killer
> is disabled.

This makes the oom_killer_disable suspend specific which is imho not
necessary. While we do not have any other user outside of the suspend
path right now and I hope we will not need any in a foreseeable future
there is no real reason to do a hack like this if we can make the
implementation suspend independent.

> Compared to your approach
> 
> >  include/linux/sched.h |  2 +-
> >  kernel/exit.c         | 38 ++++++++++++++++++++++++++++----------
> >  kernel/freezer.c      |  3 ++-
> >  mm/oom_kill.c         | 29 +++++++++++++++++------------
> >  4 files changed, 48 insertions(+), 24 deletions(-)
> 
> , my approach does not touch exit logic.

I consider the exit path changes so miniscule that trading it with pm
specific code in the oom sounds like a worse solution. Well, all that
assuming that the actual change is correct, of course.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
