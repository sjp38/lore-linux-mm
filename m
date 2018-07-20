Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B847E6B026F
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 16:20:01 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id q18-v6so8224877pll.3
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 13:20:01 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d2-v6sor891379pll.134.2018.07.20.13.20.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 13:20:00 -0700 (PDT)
Date: Fri, 20 Jul 2018 13:19:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v3] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <9ab77cc7-2167-0659-a2ad-9cec3b9440e9@i-love.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1807201315580.231119@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com> <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp> <alpine.DEB.2.21.1807181317540.49359@chino.kir.corp.google.com> <a78fb992-ad59-0cdb-3c38-8284b2245f21@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807200133310.119737@chino.kir.corp.google.com> <9ab77cc7-2167-0659-a2ad-9cec3b9440e9@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 20 Jul 2018, Tetsuo Handa wrote:

> > Absent oom_lock serialization, this is exactly working as intended.  You 
> > could argue that once the thread has reached exit_mmap() and begins oom 
> > reaping that it should be allowed to finish before the oom reaper declares 
> > MMF_OOM_SKIP.  That could certainly be helpful, I simply haven't 
> > encountered a usecase where it were needed.  Or, we could restart the oom 
> > expiration when MMF_UNSTABLE is set and deem that progress is being made 
> > so it give it some extra time.  In practice, again, we haven't seen this 
> > needed.  But either of those are very easy to add in as well.  Which would 
> > you prefer?
> 
> I don't think we need to introduce user-visible knob interface (even if it is in
> debugfs), for I think that my approach can solve your problem. Please try OOM lockup
> (CVE-2016-10723) mitigation patch ( https://marc.info/?l=linux-mm&m=153112243424285&w=4 )

The issue I am fixing has nothing to do with contention on oom_lock, it 
has to do with the inability of the oom reaper to free memory for one or 
more of several reasons: mlock, blockable mmus, ptes, mm->mmap_sem 
contention, and then the setting of MMF_OOM_SKIP to choose another victim 
before the original victim even reaches exit_mmap().  Thus, removing 
oom_lock from exit_mmap() will not fix this issue.

I agree that oom_lock can be removed from exit_mmap() and it would be 
helpful to do so, and may address a series of problems that we have yet to 
encounter, but this would not fix the almost immediate setting of 
MMF_OOM_SKIP that occurs with minimal memory freeing due to the oom 
reaper.
