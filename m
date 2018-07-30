Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id D53ED6B000D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 15:14:26 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id a12-v6so7369599ybe.21
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 12:14:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 137-v6sor2562595ybd.21.2018.07.30.12.14.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 12:14:25 -0700 (PDT)
Date: Mon, 30 Jul 2018 12:14:23 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
Message-ID: <20180730191423.GN1206094@devbig004.ftw2.facebook.com>
References: <ca3da8b8-1bb5-c302-b190-fa6cebab58ca@I-love.SAKURA.ne.jp>
 <20180726113958.GE28386@dhcp22.suse.cz>
 <55c9da7f-e448-964a-5b50-47f89a24235b@i-love.sakura.ne.jp>
 <20180730093257.GG24267@dhcp22.suse.cz>
 <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp>
 <20180730144647.GX24267@dhcp22.suse.cz>
 <20180730145425.GE1206094@devbig004.ftw2.facebook.com>
 <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp>
 <20180730154424.GG1206094@devbig004.ftw2.facebook.com>
 <20180730185110.GB24267@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180730185110.GB24267@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hello, Michal.

On Mon, Jul 30, 2018 at 08:51:10PM +0200, Michal Hocko wrote:
> > Yeah, workqueue can choke on things like that and kthread indefinitely
> > busy looping doesn't do anybody any good.
> 
> Yeah, I do agree. But this is much easier said than done ;) Sure
> we have that hack that does sleep rather than cond_resched in the
> page allocator. We can and will "fix" it to be unconditional in the
> should_reclaim_retry [1] but this whole thing is really subtle. It just
> take one misbehaving worker and something which is really important to
> run will get stuck.

Oh yeah, I'm not saying the current behavior is ideal or anything, but
since the behavior has been put in many years ago, it only became a
problem only a couple times and all cases were rather easy and obvious
fixes on the wq user side.  It shouldn't be difficult to add a timer
mechanism on top.  We might be able to simply extend the hang
detection mechanism to kick off all pending rescuers after detecting a
wq stall.  I'm wary about making it a part of normal operation
(ie. silent timeout).  per-cpu kworkers really shouldn't busy loop for
an extended period of time.

Thanks.

-- 
tejun
