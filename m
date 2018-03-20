Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 699BD6B0009
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 10:10:55 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t23-v6so1213247ply.0
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 07:10:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s3-v6si1682536plp.523.2018.03.20.07.10.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Mar 2018 07:10:53 -0700 (PDT)
Date: Tue, 20 Mar 2018 15:10:51 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/2] mm,oom_reaper: Show trace of unable to reap victim
 thread.
Message-ID: <20180320141051.GS23100@dhcp22.suse.cz>
References: <20180320122818.GL23100@dhcp22.suse.cz>
 <201803202152.HED82804.QFOHLMVFFtOOJS@I-love.SAKURA.ne.jp>
 <20180320131953.GM23100@dhcp22.suse.cz>
 <201803202230.HDH17140.OFtMQJVLOOFHSF@I-love.SAKURA.ne.jp>
 <20180320133445.GP23100@dhcp22.suse.cz>
 <201803202250.CHG18290.FJMOtOHLFVQFOS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201803202250.CHG18290.FJMOtOHLFVQFOS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com

On Tue 20-03-18 22:50:21, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 20-03-18 22:30:16, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Tue 20-03-18 21:52:33, Tetsuo Handa wrote:
> > > > > Michal Hocko wrote:
> > > > > > A single stack trace in the changelog would be sufficient IMHO.
> > > > > > Appart from that. What do you expect users will do about this trace?
> > > > > > Sure they will see a path which holds mmap_sem, we will see a bug report
> > > > > > but we can hardly do anything about that. We simply cannot drop the lock
> > > > > > from that path in 99% of situations. So _why_ do we want to add more
> > > > > > information to the log?
> > > > > 
> > > > > This case is blocked at i_mmap_lock_write().
> > > > 
> > > > But why does i_mmap_lock_write matter for oom_reaping. We are not
> > > > touching hugetlb mappings. dup_mmap holds mmap_sem for write which is
> > > > the most probable source of the backoff.
> > > 
> > > If i_mmap_lock_write can bail out upon SIGKILL, the OOM victim will be able to
> > > release mmap_sem held for write, which helps the OOM reaper not to back off.
> > 
> > There are so many other blocking calls (including allocations) in
> > dup_mmap 
> 
> Yes. But
> 
> >          that I do not really think i_mmap_lock_write is the biggest
> > problem. That will be likely the case for other mmap_sem write lockers.
> 
> i_mmap_lock_write() is one of the problems which we could afford fixing.
> 8 out of 11 "oom_reaper: unable to reap" messages are blocked at i_mmap_lock_write().
> 
[...]
> > Really I am not sure dumping more information is beneficial here.
> 
> Converting to use killable where we can afford is beneficial.

I am no questioning that. I am questioning the additional information
because we won't be able to do anything about mmap_sem holder most of
the time. Because they tend block on allocations...

-- 
Michal Hocko
SUSE Labs
