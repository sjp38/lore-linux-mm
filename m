Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 911B76B1D3B
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 02:16:59 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o16-v6so7405930pgv.21
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 23:16:59 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a61-v6si3942798plc.239.2018.08.20.23.16.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Aug 2018 23:16:58 -0700 (PDT)
Date: Tue, 21 Aug 2018 08:16:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
Message-ID: <20180821061655.GV29735@dhcp22.suse.cz>
References: <20180806205121.GM10003@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com>
 <20180810090735.GY1644@dhcp22.suse.cz>
 <be42a7c0-015e-2992-a40d-20af21e8c0fc@i-love.sakura.ne.jp>
 <20180810111604.GA1644@dhcp22.suse.cz>
 <d9595c92-6763-35cb-b989-0848cf626cb9@i-love.sakura.ne.jp>
 <20180814113359.GF32645@dhcp22.suse.cz>
 <49a73f8a-a472-a464-f5bf-ebd7994ce2d3@i-love.sakura.ne.jp>
 <20180820055417.GA29735@dhcp22.suse.cz>
 <d5be452a-951f-ddc9-e7df-102d292f22c2@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d5be452a-951f-ddc9-e7df-102d292f22c2@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue 21-08-18 07:03:10, Tetsuo Handa wrote:
> On 2018/08/20 14:54, Michal Hocko wrote:
> >>>> Apart from the former is "sequential processing" and "the OOM reaper pays the cost
> >>>> for reclaiming" while the latter is "parallel (or round-robin) processing" and "the
> >>>> allocating thread pays the cost for reclaiming", both are timeout based back off
> >>>> with number of retry attempt with a cap.
> >>>
> >>> And it is exactly the who pays the price concern I've already tried to
> >>> explain that bothers me.
> >>
> >> Are you aware that we can fall into situation where nobody can pay the price for
> >> reclaiming memory?
> > 
> > I fail to see how this is related to direct vs. kthread oom reaping
> > though. Unless the kthread is starved by other means then it can always
> > jump in and handle the situation.
> 
> I'm saying that concurrent allocators can starve the OOM reaper kernel thread.
> I don't care if the OOM reaper kernel thread is starved by something other than
> concurrent allocators, as long as that something is doing useful things.
> 
> Allocators wait for progress using (almost) busy loop is prone to lockup; they are
> not doing useful things. But direct OOM reaping allows allocators avoid lockup and
> do useful things.

As long as those allocators are making _some_ progress and they are not
preempted themselves. Those might be low priority as well. To make it
more fun those high priority might easily preempt those which try to
make the direct reaping. And if you really want to achieve at least some
fairness there you will quickly grown into a complex scheme. Really our
direct reclaim is already quite fragile when it comes to fairness and
now you want to extend it to be even more fragile. Really, I think you
are not really appreciating what kind of complex beast you are going to
create.

If we have priority inversion problems during oom then we can always
return back to high priority oom reaper. This would be so much simpler.
-- 
Michal Hocko
SUSE Labs
