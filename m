Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5F96A6B0003
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 19:08:21 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o8-v6so22753679wra.12
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 16:08:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b2si9313155edd.216.2018.04.24.16.08.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 16:08:19 -0700 (PDT)
Date: Tue, 24 Apr 2018 17:08:15 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaperunmap
Message-ID: <20180424230815.GX17484@dhcp22.suse.cz>
References: <20180420124044.GA17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804212019400.84222@chino.kir.corp.google.com>
 <201804221248.CHE35432.FtOMOLSHOFJFVQ@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1804231706340.18716@chino.kir.corp.google.com>
 <20180424130432.GB17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804241256000.231037@chino.kir.corp.google.com>
 <20180424201352.GV17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804241317200.231037@chino.kir.corp.google.com>
 <20180424203148.GW17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804241359280.186801@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1804241359280.186801@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 24-04-18 14:07:52, David Rientjes wrote:
> On Tue, 24 Apr 2018, Michal Hocko wrote:
> 
> > > > > My patch has passed intensive testing on both x86 and powerpc, so I'll ask 
> > > > > that it's pushed for 4.17-rc3.  Many thanks to Tetsuo for the suggestion 
> > > > > on calling __oom_reap_task_mm() from exit_mmap().
> > > > 
> > > > Yeah, but your patch does have a problem with blockable mmu notifiers
> > > > IIUC.
> > > 
> > > What on earth are you talking about?  exit_mmap() does 
> > > mmu_notifier_release().  There are no blockable mmu notifiers.
> > 
> > MMF_OOM_SKIP - remember? The thing that guarantees a forward progress.
> > So we cannot really depend on setting MMF_OOM_SKIP if a
> > mmu_notifier_release blocks for an excessive/unbounded amount of time.
> > 
> 
> If the thread is blocked in exit_mmap() because of mmu_notifier_release() 
> then the oom reaper will eventually grab mm->mmap_sem (nothing holding it 
> in exit_mmap()), return true, and oom_reap_task() will set MMF_OOM_SKIP.  
> This is unchanged with the patch and is a completely separate issue.

I must be missing something or we are talking past each other. So let me
be explicit. What does prevent the following

oom_reaper				exit_mmap
					  mutex_lock(oom_lock)
  mutex_lock(oom_lock)			    __oom_reap_task_mm
  					      mmu_notifier_invalidate_range_start
					        # blockable mmu_notifier
						# which takes ages to
						# finish or depends on
						# an allocation (in)directly
-- 
Michal Hocko
SUSE Labs
