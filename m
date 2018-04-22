Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF1756B0005
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 09:19:04 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f19so8112532pfn.6
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 06:19:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i12-v6si6220677plk.589.2018.04.22.06.19.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Apr 2018 06:19:03 -0700 (PDT)
Date: Sun, 22 Apr 2018 07:18:57 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper unmap
Message-ID: <20180422131857.GI17484@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1804171545460.53786@chino.kir.corp.google.com>
 <201804180057.w3I0vieV034949@www262.sakura.ne.jp>
 <alpine.DEB.2.21.1804171928040.100886@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1804171951440.105401@chino.kir.corp.google.com>
 <20180418075051.GO17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804181159020.227784@chino.kir.corp.google.com>
 <20180419063556.GK17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804191214130.157851@chino.kir.corp.google.com>
 <20180420082349.GW17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804212023120.84222@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1804212023120.84222@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat 21-04-18 20:45:11, David Rientjes wrote:
> On Fri, 20 Apr 2018, Michal Hocko wrote:
> 
> > > The solution is certainly not to hold 
> > > down_write(&mm->mmap_sem) during munlock_vma_pages_all() instead.
> > 
> > Why not? This is what we do for normal paths. exit path just tries to be
> > clever because it knows that it doesn't have to lock because there is no
> > concurent user. At least it wasn't until the oom reaper came. So I
> > really fail to see why we shouldn't do the most obvious thing and use
> > the locking.
> > 
> 
> Because the oom reaper uses the ability to acquire mm->mmap_sem as a 
> heuristic to determine when to give up and allow another process to be 
> chosen.
> 
> If the heuristics of the oom reaper are to be improved, that's great, but 
> this patch fixes the oops on powerpc as 4.17 material and as a stable 
> backport.  It's also well tested.
> 
> > > If 
> > > exit_mmap() is not making forward progress then that's a separate issue; 
> > 
> > Please read what I wrote. There is a page lock and there is no way to
> > guarantee it will make a forward progress. Or do you consider that not
> > true?
> > 
> 
> I don't have any evidence of it, and since this is called before 
> exit_mmap() sets MMF_OOM_SKIP then the oom reaper would need to set the 
> bit itself and I would be able to find the artifact it leaves behind in 
> the kernel log.  I cannot find a single instance of a thread stuck in 
> munlock by way of exit_mmap() that causes the oom reaper to have to set 
> the bit itself, and I should be able to if this were a problem.

Look. The fact that you do not _see any evidence_ is completely
irrelevant. The OOM reaper is about _guarantee_. And the guarantee is
gone with the page_lock because that is used in contexts which do
allocate memory and it can depend on other locks. So _no way_ we can
make MMF_OOM_SKIP to depend on it. I will not repeat it anymore. I will
not allow to ruin the whole oom reaper endeavor by adding "this should
not happen" stuff that the oom killer was full of.

> > > Holding down_write on 
> > > mm->mmap_sem otherwise needlessly over a large amount of code is riskier 
> > > (hasn't been done or tested here), more error prone (any code change over 
> > > this large area of code or in functions it calls are unnecessarily 
> > > burdened by unnecessary locking), makes exit_mmap() less extensible for 
> > > the same reason,
> > 
> > I do not see any of the calls in that path could suffer from holding
> > mmap_sem. Do you?
> > 
> > > and causes the oom reaper to give up and go set 
> > > MMF_OOM_SKIP itself because it depends on taking down_read while the 
> > > thread is still exiting.
> > 
> > Which is the standard backoff mechanism.
> > 
> 
> The reason today's locking methodology is preferred is because of the 
> backoff mechanism.  Your patch kills many processes unnecessarily if the 
> oom killer selects a large process to kill, which it specifically tries to 
> do, because unmap_vmas() and free_pgtables() takes a very long time, 
> sometimes tens of seconds.

and I absolutely agree that the feedback mechanism should be improved.
The patch I propose _might_ to lead to killing another task. I do not
pretend otherwise. But it will keep the lockup free guarantee which is
oom repeer giving us. Btw. the past oom implementation would simply kill
more in that case as well because exiting tasks with task->mm == NULL
would be ignored completely. So this is not a big regression even if
that happens occasionally.

Maybe invoking the reaper as suggested by Tetsuo will help here. Maybe
we will come up with something more smart. But I would like to have a
stop gap solution for stable that is easy enough. And your patch is not
doing that because it adds a very subtle dependency on the page lock.
So please stop repeating your arguments all over and either come with
an argument which proves me wrong and the lock_page dependency is not
real or come with an alternative solution which doesn't make
MMF_OOM_SKIP depend on the page lock.

-- 
Michal Hocko
SUSE Labs
