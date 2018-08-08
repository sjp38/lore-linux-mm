Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA6886B0007
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 01:40:03 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id m19-v6so909797uap.3
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 22:40:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z8-v6sor1241388uag.22.2018.08.07.22.40.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 22:40:02 -0700 (PDT)
MIME-Version: 1.0
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <20180808111224.52a451d9@canb.auug.org.au>
In-Reply-To: <20180808111224.52a451d9@canb.auug.org.au>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 7 Aug 2018 22:39:50 -0700
Message-ID: <CALvZod4CAA50sPB1V9bZVOZ__rOT=Ys8tLv+m-S-kP3NLubSqQ@mail.gmail.com>
Subject: Re: [PATCH RFC 00/10] Introduce lockless shrink_slab()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, gregkh@linuxfoundation.org, rafael@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, josh@joshtriplett.org, Steven Rostedt <rostedt@goodmis.org>, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, Hugh Dickins <hughd@google.com>, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@suse.com>, Chris Wilson <chris@chris-wilson.co.uk>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Matthew Wilcox <willy@infradead.org>, Huang Ying <ying.huang@intel.com>, jbacik@fb.com, Ingo Molnar <mingo@kernel.org>, mhiramat@kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Tue, Aug 7, 2018 at 6:12 PM Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> Hi Kirill,
>
> On Tue, 07 Aug 2018 18:37:19 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> >
> > After bitmaps of not-empty memcg shrinkers were implemented
> > (see "[PATCH v9 00/17] Improve shrink_slab() scalability..."
> > series, which is already in mm tree), all the evil in perf
> > trace has moved from shrink_slab() to down_read_trylock().
> > As reported by Shakeel Butt:
> >
> >      > I created 255 memcgs, 255 ext4 mounts and made each memcg create a
> >      > file containing few KiBs on corresponding mount. Then in a separate
> >      > memcg of 200 MiB limit ran a fork-bomb.
> >      >
> >      > I ran the "perf record -ag -- sleep 60" and below are the results:
> >      > +  47.49%            fb.sh  [kernel.kallsyms]    [k] down_read_trylock
> >      > +  30.72%            fb.sh  [kernel.kallsyms]    [k] up_read
> >      > +   9.51%            fb.sh  [kernel.kallsyms]    [k] mem_cgroup_iter
> >      > +   1.69%            fb.sh  [kernel.kallsyms]    [k] shrink_node_memcg
> >      > +   1.35%            fb.sh  [kernel.kallsyms]    [k] mem_cgroup_protected
> >      > +   1.05%            fb.sh  [kernel.kallsyms]    [k] queued_spin_lock_slowpath
> >      > +   0.85%            fb.sh  [kernel.kallsyms]    [k] _raw_spin_lock
> >      > +   0.78%            fb.sh  [kernel.kallsyms]    [k] lruvec_lru_size
> >      > +   0.57%            fb.sh  [kernel.kallsyms]    [k] shrink_node
> >      > +   0.54%            fb.sh  [kernel.kallsyms]    [k] queue_work_on
> >      > +   0.46%            fb.sh  [kernel.kallsyms]    [k] shrink_slab_memcg
> >
> > The patchset continues to improve shrink_slab() scalability and makes
> > it lockless completely. Here are several steps for that:
>
> So do you have any numbers for after theses changes?
>

I will do the same experiment as before with these patches sometime
this or next week.

BTW Kirill, thanks for pushing this.

regards,
Shakeel
