Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3CCA02802FE
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 07:26:03 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id q189so5344649wmd.6
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 04:26:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l19si3403475wrl.11.2017.08.04.04.26.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 04:26:01 -0700 (PDT)
Date: Fri, 4 Aug 2017 13:26:00 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, oom: task_will_free_mem(current) should ignore
 MMF_OOM_SKIP for once.
Message-ID: <20170804112600.GL26029@dhcp22.suse.cz>
References: <1501718104-8099-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170803071051.GB12521@dhcp22.suse.cz>
 <201708031653.JGD57352.OQFtVLSFOMOHJF@I-love.SAKURA.ne.jp>
 <20170803081459.GD12521@dhcp22.suse.cz>
 <201708042010.HDD60496.LFtOQMFJOSFHOV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708042010.HDD60496.LFtOQMFJOSFHOV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com

On Fri 04-08-17 20:10:09, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 03-08-17 16:53:40, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > > We don't need to give up task_will_free_mem(current) without trying
> > > > > allocation from memory reserves. We will need to select next OOM victim
> > > > > only when allocation from memory reserves did not help.
> > > > > 
> > > > > Thus, this patch allows task_will_free_mem(current) to ignore MMF_OOM_SKIP
> > > > > for once so that task_will_free_mem(current) will not start selecting next
> > > > > OOM victim without trying allocation from memory reserves.
> > > > 
> > > > As I've already said this is an ugly hack and once we have
> > > > http://lkml.kernel.org/r/20170727090357.3205-2-mhocko@kernel.org merged
> > > > then it even shouldn't be needed because _all_ threads of the oom victim
> > > > will have an instant access to memory reserves.
> > > > 
> > > > So I do not think we want to merge this.
> > > > 
> > > 
> > > No, we still want to merge this, for 4.8+ kernels which won't get your patch
> > > backported will need this. Even after your patch is merged, there is a race
> > > window where allocating threads are between after gfp_pfmemalloc_allowed() and
> > > before mutex_trylock(&oom_lock) in __alloc_pages_may_oom() which means that
> > > some threads could call out_of_memory() and hit this task_will_free_mem(current)
> > > test. Ignoring MMF_OOM_SKIP for once is still useful.
> > 
> > I disagree. I am _highly_ skeptical this is a stable material. The
> > mentioned test case is artificial and the source of the problem is
> > somewhere else. Moreover the culprit is somewhere else. It is in the oom
> > reaper setting MMF_OOM_SKIP too early and it should be addressed there.
> > Do not add workarounds where they are not appropriate.
> > 
> So, what alternative can you provide us for now?

As I've already said http://lkml.kernel.org/r/20170727090357.3205-2-mhocko@kernel.org
seems to be a better alternative. I am waiting for further review
feedback before reposting it again.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
