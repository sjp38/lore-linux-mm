Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id C13888E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 15:21:09 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id d15so2316020ybk.12
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 12:21:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c3sor4623755ybi.206.2019.01.20.12.21.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 12:21:08 -0800 (PST)
MIME-Version: 1.0
References: <20190119005022.61321-1-shakeelb@google.com> <20190119015843.GB15935@castle.DHCP.thefacebook.com>
In-Reply-To: <20190119015843.GB15935@castle.DHCP.thefacebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Sun, 20 Jan 2019 12:20:57 -0800
Message-ID: <CALvZod6zRy69bHoXvEWED28OFZ8u4o8JBAL7nyjKMmUjBb5n4w@mail.gmail.com>
Subject: Re: [RFC PATCH] mm, oom: fix use-after-free in oom_kill_process
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Jan 18, 2019 at 5:58 PM Roman Gushchin <guro@fb.com> wrote:
>
> Hi Shakeel!
>
> >
> > On looking further it seems like the process selected to be oom-killed
> > has exited even before reaching read_lock(&tasklist_lock) in
> > oom_kill_process(). More specifically the tsk->usage is 1 which is due
> > to get_task_struct() in oom_evaluate_task() and the put_task_struct
> > within for_each_thread() frees the tsk and for_each_thread() tries to
> > access the tsk. The easiest fix is to do get/put across the
> > for_each_thread() on the selected task.
>
> Please, feel free to add
> Reviewed-by: Roman Gushchin <guro@fb.com>
> for this part.
>

Thanks.

> >
> > Now the next question is should we continue with the oom-kill as the
> > previously selected task has exited? However before adding more
> > complexity and heuristics, let's answer why we even look at the
> > children of oom-kill selected task? The select_bad_process() has already
> > selected the worst process in the system/memcg. Due to race, the
> > selected process might not be the worst at the kill time but does that
> > matter matter? The userspace can play with oom_score_adj to prefer
> > children to be killed before the parent. I looked at the history but it
> > seems like this is there before git history.
>
> I'd totally support you in an attempt to remove this logic,
> unless someone has a good example of its usefulness.
>
> I believe it's a very old hack to select children over parents
> in case they have the same oom badness (e.g. share most of the memory).
>
> Maybe we can prefer older processes in case of equal oom badness,
> and it will be enough.
>
> Thanks!

I am thinking of removing the whole logic of selecting children.

Shakeel
