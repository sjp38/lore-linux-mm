Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 084F96B0269
	for <linux-mm@kvack.org>; Mon, 28 May 2018 11:54:00 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b31-v6so7808572plb.5
        for <linux-mm@kvack.org>; Mon, 28 May 2018 08:54:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b70-v6si30780109pfe.265.2018.05.28.08.53.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 May 2018 08:53:58 -0700 (PDT)
Date: Mon, 28 May 2018 14:43:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with
 oom_lock held.
Message-ID: <20180528124313.GC27180@dhcp22.suse.cz>
References: <20180524115017.GE20441@dhcp22.suse.cz>
 <201805250117.w4P1HgdG039943@www262.sakura.ne.jp>
 <20180525083118.GI11881@dhcp22.suse.cz>
 <201805251957.EJJ09809.LFJHFFVOOSQOtM@I-love.SAKURA.ne.jp>
 <20180525114213.GJ11881@dhcp22.suse.cz>
 <201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201805252046.JFF30222.JHSFOFQFMtVOLO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Fri 25-05-18 20:46:21, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 25-05-18 19:57:32, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > What is wrong with the folliwing? should_reclaim_retry should be a
> > > > natural reschedule point. PF_WQ_WORKER is a special case which needs a
> > > > stronger rescheduling policy. Doing that unconditionally seems more
> > > > straightforward than depending on a zone being a good candidate for a
> > > > further reclaim.
> > > 
> > > Where is schedule_timeout_uninterruptible(1) for !PF_KTHREAD threads?
> > 
> > Re-read what I've said.
> 
> Please show me as a complete patch. Then, I will test your patch.

So how about we start as simple as the following? If we _really_ need to
touch should_reclaim_retry then it should be done in a separate patch
with some numbers/tracing data backing that story.
---
