Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id C37F88E0001
	for <linux-mm@kvack.org>; Sat,  8 Sep 2018 09:57:34 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l7-v6so16693792qte.2
        for <linux-mm@kvack.org>; Sat, 08 Sep 2018 06:57:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t205-v6sor4230492qke.38.2018.09.08.06.57.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 08 Sep 2018 06:57:31 -0700 (PDT)
Date: Sat, 8 Sep 2018 09:57:28 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: print proper OOM header when no eligible
 victim left
Message-ID: <20180908135728.GA17637@cmpxchg.org>
References: <20180821160406.22578-1-hannes@cmpxchg.org>
 <b94f9964-c785-20c1-34af-e9013770b89a@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b94f9964-c785-20c1-34af-e9013770b89a@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat, Sep 08, 2018 at 10:36:06PM +0900, Tetsuo Handa wrote:
> On 2018/08/22 1:04, Johannes Weiner wrote:
> > When the memcg OOM killer runs out of killable tasks, it currently
> > prints a WARN with no further OOM context. This has caused some user
> > confusion.
> > 
> > Warnings indicate a kernel problem. In a reported case, however, the
> > situation was triggered by a non-sensical memcg configuration (hard
> > limit set to 0). But without any VM context this wasn't obvious from
> > the report, and it took some back and forth on the mailing list to
> > identify what is actually a trivial issue.
> > 
> > Handle this OOM condition like we handle it in the global OOM killer:
> > dump the full OOM context and tell the user we ran out of tasks.
> > 
> > This way the user can identify misconfigurations easily by themselves
> > and rectify the problem - without having to go through the hassle of
> > running into an obscure but unsettling warning, finding the
> > appropriate kernel mailing list and waiting for a kernel developer to
> > remote-analyze that the memcg configuration caused this.
> > 
> > If users cannot make sense of why the OOM killer was triggered or why
> > it failed, they will still report it to the mailing list, we know that
> > from experience. So in case there is an actual kernel bug causing
> > this, kernel developers will very likely hear about it.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/memcontrol.c |  2 --
> >  mm/oom_kill.c   | 13 ++++++++++---
> >  2 files changed, 10 insertions(+), 5 deletions(-)
> > 
> 
> Now that above patch went to 4.19-rc3, please apply below one.
> 
> From eb2bff2ed308da04785bcf541dd3f748286bfa23 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 8 Sep 2018 22:26:28 +0900
> Subject: [PATCH] mm, oom: Don't emit noises for failed SysRq-f.
> 
> Due to commit d75da004c708c9fc ("oom: improve oom disable handling") and
> commit 3100dab2aa09dc6e ("mm: memcontrol: print proper OOM header when
> no eligible victim left"), all
> 
>   kworker/0:1 invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), nodemask=(null), order=-1, oom_score_adj=0
>   (...snipped...)
>   Out of memory and no killable processes...
>   OOM request ignored. No task eligible
> 
> lines are printed.

This doesn't explain the context, what you were trying to do here, and
what you expected to happen. Plus, you (...snipped...) the important
part to understand why it failed in the first place.

> Let's not emit "invoked oom-killer" lines when SysRq-f failed.

I disagree. If the user asked for an OOM kill, it makes perfect sense
to dump the memory context and the outcome of the operation - even if
the outcome is "I didn't find anything to kill". I'd argue that the
failure case *in particular* is where I want to know about and have
all the information that could help me understand why it failed.

So NAK on the inferred patch premise, but please include way more
rationale, reproduction scenario etc. in future patches. It's not at
all clear *why* you think it should work the way you propose here.
