Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 690616B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 07:15:11 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g11-v6so539369edi.8
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 04:15:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i20-v6si197465edb.403.2018.07.16.04.15.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 04:15:09 -0700 (PDT)
Date: Mon, 16 Jul 2018 13:15:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm] mm, oom: remove oom_lock from exit_mmap
Message-ID: <20180716111508.GL17280@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1807121432370.170100@chino.kir.corp.google.com>
 <20180713142612.GD19960@dhcp22.suse.cz>
 <44d26c25-6e09-49de-5e90-3c16115eb337@i-love.sakura.ne.jp>
 <20180716061317.GA17280@dhcp22.suse.cz>
 <916d7e1d-66ea-00d9-c943-ef3d2e082584@i-love.sakura.ne.jp>
 <20180716074410.GB17280@dhcp22.suse.cz>
 <f648cbc0-fa8f-5cf5-5e2b-d9ee6d721cf2@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f648cbc0-fa8f-5cf5-5e2b-d9ee6d721cf2@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 16-07-18 19:38:21, Tetsuo Handa wrote:
> On 2018/07/16 16:44, Michal Hocko wrote:
> >> If setting MMF_OOM_SKIP is guarded by oom_lock, we can enforce
> >> last second allocation attempt like below.
> >>
> >>   CPU 0                                   CPU 1
> >>   
> >>   mutex_trylock(&oom_lock) in __alloc_pages_may_oom() succeeds.
> >>   get_page_from_freelist() fails.
> >>   Enters out_of_memory().
> >>
> >>                                           __oom_reap_task_mm() reclaims some memory.
> >>                                           mutex_lock(&oom_lock);
> >>
> >>   select_bad_process() does not select new victim because MMF_OOM_SKIP is not yet set.
> >>   Leaves out_of_memory().
> >>   mutex_unlock(&oom_lock) in __alloc_pages_may_oom() is called.
> >>
> >>                                           Sets MMF_OOM_SKIP.
> >>                                           mutex_unlock(&oom_lock);
> >>
> >>   get_page_from_freelist() likely succeeds before reaching __alloc_pages_may_oom() again.
> >>   Saved one OOM victim from being needlessly killed.
> >>
> >> That is, guarding setting MMF_OOM_SKIP works as if synchronize_rcu(); it waits for anybody
> >> who already acquired (or started waiting for) oom_lock to release oom_lock, in order to
> >> prevent select_bad_process() from needlessly selecting new OOM victim.
> > 
> > Hmm, is this a practical problem though? Do we really need to have a
> > broader locking context just to defeat this race?
> 
> Yes, for you think that select_bad_process() might take long time. It is possible
> that MMF_OOM_SKIP is set while the owner of oom_lock is preempted. It is not such
> a small window that select_bad_process() finds an mm which got MMF_OOM_SKIP
> immediately before examining that mm.

I only do care if the race is practical to hit. And that is why I would
like a simplification first (so drop the oom_lock in the oom_reaper
path) and then follow up with some decent justification on top.
-- 
Michal Hocko
SUSE Labs
