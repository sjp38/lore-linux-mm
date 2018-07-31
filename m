Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id B5CC96B026F
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:58:13 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id i16-v6so12387218wrr.9
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 07:58:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6-v6sor3793488wrm.53.2018.07.31.07.58.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 07:58:12 -0700 (PDT)
MIME-Version: 1.0
References: <20180730180100.25079-1-guro@fb.com> <20180730180100.25079-2-guro@fb.com>
 <20180731084509.GE4557@dhcp22.suse.cz>
In-Reply-To: <20180731084509.GE4557@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 31 Jul 2018 07:58:00 -0700
Message-ID: <CALvZod75t+uK=FDtpuBCMZCk7cb4vQMy7DpXQ53Aj7ZLiYsTQQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: introduce mem_cgroup_put() helper
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Tue, Jul 31, 2018 at 1:45 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 30-07-18 11:00:58, Roman Gushchin wrote:
> > Introduce the mem_cgroup_put() helper, which helps to eliminate guarding
> > memcg css release with "#ifdef CONFIG_MEMCG" in multiple places.
>
> Is there any reason for this to be a separate patch? I usually do not
> like to add helpers without their users because this makes review
> harder. This one is quite trivial to fit into Patch3 easilly.
>

The helper function introduced in this change is also used in the
remote charging patches, so, I asked Roman to separate this change out
and thus can be merged independently.

Shakeel

> > Link: http://lkml.kernel.org/r/20180623000600.5818-2-guro@fb.com
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Reviewed-by: Shakeel Butt <shakeelb@google.com>
> > Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Shakeel Butt <shakeelb@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> > ---
> >  include/linux/memcontrol.h | 9 +++++++++
> >  1 file changed, 9 insertions(+)
> >
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 6c6fb116e925..e53e00cdbe3f 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -375,6 +375,11 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
> >       return css ? container_of(css, struct mem_cgroup, css) : NULL;
> >  }
> >
> > +static inline void mem_cgroup_put(struct mem_cgroup *memcg)
> > +{
> > +     css_put(&memcg->css);
> > +}
> > +
> >  #define mem_cgroup_from_counter(counter, member)     \
> >       container_of(counter, struct mem_cgroup, member)
> >
> > @@ -837,6 +842,10 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
> >       return true;
> >  }
> >
> > +static inline void mem_cgroup_put(struct mem_cgroup *memcg)
> > +{
> > +}
> > +
> >  static inline struct mem_cgroup *
> >  mem_cgroup_iter(struct mem_cgroup *root,
> >               struct mem_cgroup *prev,
> > --
> > 2.14.4
> >
>
> --
> Michal Hocko
> SUSE Labs
