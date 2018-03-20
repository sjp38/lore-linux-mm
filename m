Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC0A06B0022
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 09:34:49 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w23so890111pgv.17
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 06:34:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 11-v6si1679175plb.658.2018.03.20.06.34.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Mar 2018 06:34:48 -0700 (PDT)
Date: Tue, 20 Mar 2018 14:34:45 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 1/2] mm,oom_reaper: Show trace of unable to reap victim
 thread.
Message-ID: <20180320133445.GP23100@dhcp22.suse.cz>
References: <1521547076-3399-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180320122818.GL23100@dhcp22.suse.cz>
 <201803202152.HED82804.QFOHLMVFFtOOJS@I-love.SAKURA.ne.jp>
 <20180320131953.GM23100@dhcp22.suse.cz>
 <201803202230.HDH17140.OFtMQJVLOOFHSF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201803202230.HDH17140.OFtMQJVLOOFHSF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com

On Tue 20-03-18 22:30:16, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 20-03-18 21:52:33, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > A single stack trace in the changelog would be sufficient IMHO.
> > > > Appart from that. What do you expect users will do about this trace?
> > > > Sure they will see a path which holds mmap_sem, we will see a bug report
> > > > but we can hardly do anything about that. We simply cannot drop the lock
> > > > from that path in 99% of situations. So _why_ do we want to add more
> > > > information to the log?
> > > 
> > > This case is blocked at i_mmap_lock_write().
> > 
> > But why does i_mmap_lock_write matter for oom_reaping. We are not
> > touching hugetlb mappings. dup_mmap holds mmap_sem for write which is
> > the most probable source of the backoff.
> 
> If i_mmap_lock_write can bail out upon SIGKILL, the OOM victim will be able to
> release mmap_sem held for write, which helps the OOM reaper not to back off.

There are so many other blocking calls (including allocations) in
dup_mmap that I do not really think i_mmap_lock_write is the biggest
problem. That will be likely the case for other mmap_sem write lockers.

Really I am not sure dumping more information is beneficial here.
-- 
Michal Hocko
SUSE Labs
