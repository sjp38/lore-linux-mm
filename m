Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C024A6B0003
	for <linux-mm@kvack.org>; Tue, 14 Aug 2018 07:34:02 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i26-v6so7296594edr.4
        for <linux-mm@kvack.org>; Tue, 14 Aug 2018 04:34:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w11-v6si6876333edq.75.2018.08.14.04.34.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Aug 2018 04:34:00 -0700 (PDT)
Date: Tue, 14 Aug 2018 13:33:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
Message-ID: <20180814113359.GF32645@dhcp22.suse.cz>
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180806134550.GO19540@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com>
 <20180810090735.GY1644@dhcp22.suse.cz>
 <be42a7c0-015e-2992-a40d-20af21e8c0fc@i-love.sakura.ne.jp>
 <20180810111604.GA1644@dhcp22.suse.cz>
 <d9595c92-6763-35cb-b989-0848cf626cb9@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9595c92-6763-35cb-b989-0848cf626cb9@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On Sat 11-08-18 12:12:52, Tetsuo Handa wrote:
> On 2018/08/10 20:16, Michal Hocko wrote:
> >> How do you decide whether oom_reaper() was not able to reclaim much?
> > 
> > Just a rule of thumb. If it freed at least few kBs then we should be good
> > to MMF_OOM_SKIP.
> 
> I don't think so. We are talking about situations where MMF_OOM_SKIP is set
> before memory enough to prevent the OOM killer from selecting next OOM victim
> was reclaimed.

There is nothing like enough memory to prevent a new victim selection.
Just think of streaming source of allocation without any end. There is
simply no way to tell that we have freed enough. We have to guess and
tune based on reasonable workloads.

[...]
> Apart from the former is "sequential processing" and "the OOM reaper pays the cost
> for reclaiming" while the latter is "parallel (or round-robin) processing" and "the
> allocating thread pays the cost for reclaiming", both are timeout based back off
> with number of retry attempt with a cap.

And it is exactly the who pays the price concern I've already tried to
explain that bothers me.

I really do not see how making the code more complex by ensuring that
allocators share a fair part of the direct oom repaing will make the
situation any easier. Really there are basically two issues we really
should be after. Improve the oom reaper to tear down wider range of
memory (namely mlock) and to improve the cooperation with the exit path
to handle free_pgtables more gracefully because it is true that some
processes might really consume a lot of memory in page tables without
mapping  a lot of anonymous memory. Neither of the two is addressed by
your proposal. So if you want to help then try to think about the two
issues.

> >> We are already using timeout based decision, with some attempt to reclaim
> >> memory if conditions are met.
> > 
> > Timeout based decision is when you, well, make a decision after a
> > certain time passes. And we do not do that.
> 
> But we are talking about what we can do after oom_reap_task_mm() can no longer
> make progress. Both the former and the latter will wait until a time controlled
> by the number of attempts and retry interval elapses.

Do not confuse a sleep with the number of attempts. The latter is a unit
of work done the former is a unit of time.
-- 
Michal Hocko
SUSE Labs
