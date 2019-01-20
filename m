Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC588E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 15:23:18 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id x64so10230977ywc.6
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 12:23:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor1905332ywm.164.2019.01.20.12.23.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 12:23:17 -0800 (PST)
MIME-Version: 1.0
References: <20190119005022.61321-1-shakeelb@google.com> <02f74c47-4f35-3d59-f767-268844cb875e@i-love.sakura.ne.jp>
In-Reply-To: <02f74c47-4f35-3d59-f767-268844cb875e@i-love.sakura.ne.jp>
From: Shakeel Butt <shakeelb@google.com>
Date: Sun, 20 Jan 2019 12:23:06 -0800
Message-ID: <CALvZod4h7ouNE7p2ouTix9uK3XLUvP6UYNDPEkR-y5PZRJRDnw@mail.gmail.com>
Subject: Re: [RFC PATCH] mm, oom: fix use-after-free in oom_kill_process
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 18, 2019 at 7:35 PM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/01/19 9:50, Shakeel Butt wrote:
> > On looking further it seems like the process selected to be oom-killed
> > has exited even before reaching read_lock(&tasklist_lock) in
> > oom_kill_process(). More specifically the tsk->usage is 1 which is due
> > to get_task_struct() in oom_evaluate_task() and the put_task_struct
> > within for_each_thread() frees the tsk and for_each_thread() tries to
> > access the tsk. The easiest fix is to do get/put across the
> > for_each_thread() on the selected task.
>
> Good catch. p->usage can become 1 while printk()ing a lot at dump_header().
>
> > @@ -981,6 +981,13 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> >        * still freeing memory.
> >        */
> >       read_lock(&tasklist_lock);
> > +
> > +     /*
> > +      * The task 'p' might have already exited before reaching here. The
> > +      * put_task_struct() will free task_struct 'p' while the loop still try
> > +      * to access the field of 'p', so, get an extra reference.
> > +      */
> > +     get_task_struct(p);
> >       for_each_thread(p, t) {
> >               list_for_each_entry(child, &t->children, sibling) {
> >                       unsigned int child_points;
> > @@ -1000,6 +1007,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> >                       }
> >               }
> >       }
> > +     put_task_struct(p);
>
> Moving put_task_struct(p) to after read_unlock(&tasklist_lock) will reduce
> latency of a write_lock(&tasklist_lock) waiter.
>
> >       read_unlock(&tasklist_lock);
> >
> >       /*
> >
>
> By the way, p->usage is already 1 implies that p->mm == NULL due to already
> completed exit_mm(p). Then, process_shares_mm(child, p->mm) might fail to
> return true for some of children. Not critical but might lead to unnecessary
> oom_badness() calls for child selection. Maybe we want to use same logic
> __oom_kill_process() uses (i.e. bail out if find_task_lock_mm(p) failed)?

Thanks for the review. I am thinking of removing the whole children
selection heuristic for now.

Shakeel
