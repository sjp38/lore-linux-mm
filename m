Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B92D6B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 04:23:51 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p17-v6so7859710wre.7
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 01:23:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s11si2055379edj.407.2018.04.20.01.23.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Apr 2018 01:23:50 -0700 (PDT)
Date: Fri, 20 Apr 2018 10:23:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper unmap
Message-ID: <20180420082349.GW17484@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1804171545460.53786@chino.kir.corp.google.com>
 <201804180057.w3I0vieV034949@www262.sakura.ne.jp>
 <alpine.DEB.2.21.1804171928040.100886@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1804171951440.105401@chino.kir.corp.google.com>
 <20180418075051.GO17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804181159020.227784@chino.kir.corp.google.com>
 <20180419063556.GK17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804191214130.157851@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1804191214130.157851@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 19-04-18 12:34:53, David Rientjes wrote:
> On Thu, 19 Apr 2018, Michal Hocko wrote:
> 
> > > exit_mmap() does not block before set_bit(MMF_OOM_SKIP) once it is 
> > > entered.
> > 
> > Not true. munlock_vma_pages_all might take page_lock which can have
> > unpredictable dependences. This is the reason why we are ruling out
> > mlocked VMAs in the first place when reaping the address space.
> > 
> 
> I don't find any occurrences in millions of oom kills in real-world 
> scenarios where this matters.

Which doesn't really mean much. We want a guarantee here.

> The solution is certainly not to hold 
> down_write(&mm->mmap_sem) during munlock_vma_pages_all() instead.

Why not? This is what we do for normal paths. exit path just tries to be
clever because it knows that it doesn't have to lock because there is no
concurent user. At least it wasn't until the oom reaper came. So I
really fail to see why we shouldn't do the most obvious thing and use
the locking.

> If 
> exit_mmap() is not making forward progress then that's a separate issue; 

Please read what I wrote. There is a page lock and there is no way to
guarantee it will make a forward progress. Or do you consider that not
true?

> that would need to be fixed in one of two ways: (1) in oom_reap_task() to 
> try over a longer duration before setting MMF_OOM_SKIP itself, but that 
> would have to be a long duration to allow a large unmap and page table 
> free, or (2) in oom_evaluate_task() so that we defer for MMF_OOM_SKIP but 
> only if MMF_UNSTABLE has been set for a long period of time so we target 
> another process when the oom killer has given up.
> 
> Either of those two fixes are simple to implement, I'd just like to see a 
> bug report with stack traces to indicate that a victim getting stalled in 
> exit_mmap() is a problem to justify the patch.

And both are not really needed if we do the proper and straightforward
locking.

> I'm trying to fix the page table corruption that is trivial to trigger on 
> powerpc.  We simply cannot allow the oom reaper's unmap_page_range() to 
> race with munlock_vma_pages_range(), ever.

There is no discussion about that. Sure, you are right. We are just
arguing how to achieve that.

> Holding down_write on 
> mm->mmap_sem otherwise needlessly over a large amount of code is riskier 
> (hasn't been done or tested here), more error prone (any code change over 
> this large area of code or in functions it calls are unnecessarily 
> burdened by unnecessary locking), makes exit_mmap() less extensible for 
> the same reason,

I do not see any of the calls in that path could suffer from holding
mmap_sem. Do you?

> and causes the oom reaper to give up and go set 
> MMF_OOM_SKIP itself because it depends on taking down_read while the 
> thread is still exiting.

Which is the standard backoff mechanism.

> > On the
> > other hand your lock protocol introduces the MMF_OOM_SKIP problem I've
> > mentioned above and that really worries me. The primary objective of the
> > reaper is to guarantee a forward progress without relying on any
> > externalities. We might kill another OOM victim but that is safer than
> > lock up.
> > 
> 
> I understand the concern, but it's the difference between the victim 
> getting stuck in exit_mmap() and actually taking a long time to free its 
> memory in exit_mmap().  I don't have evidence of the former.

I do not really want to repeat myself. The primary purpose of the oom
reaper is to provide a _guarantee_ of the forward progress. I do not
care whether there is any evidences. All I know that lock_page has
plethora of different dependencies and we cannot clearly state this is
safe so we _must not_ depend on it when setting MMF_OOM_SKIP.

The way how the oom path was fragile and lockup prone based on
optimistic assumptions shouldn't be repeated.

That being said, I haven't heard any actual technical argument about why
locking the munmap path is a wrong thing to do while the MMF_OOM_SKIP
dependency on the page_lock really concerns me so

Nacked-by: Michal Hocko <mhocko@suse.com>

If you want to keep the current locking protocol then you really have to
make sure that the oom reaper will set MMF_OOM_SKIP when racing with
exit_mmap.
-- 
Michal Hocko
SUSE Labs
