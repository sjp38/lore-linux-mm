Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 092716B0005
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 01:53:07 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t17-v6so4194500edr.21
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 22:53:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g24-v6si6930470edm.273.2018.07.31.22.53.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 22:53:05 -0700 (PDT)
Date: Wed, 1 Aug 2018 07:53:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: introduce mem_cgroup_put() helper
Message-ID: <20180801055302.GA16767@dhcp22.suse.cz>
References: <20180730180100.25079-1-guro@fb.com>
 <20180730180100.25079-2-guro@fb.com>
 <20180731084509.GE4557@dhcp22.suse.cz>
 <CALvZod75t+uK=FDtpuBCMZCk7cb4vQMy7DpXQ53Aj7ZLiYsTQQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod75t+uK=FDtpuBCMZCk7cb4vQMy7DpXQ53Aj7ZLiYsTQQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Roman Gushchin <guro@fb.com>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Tue 31-07-18 07:58:00, Shakeel Butt wrote:
> On Tue, Jul 31, 2018 at 1:45 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 30-07-18 11:00:58, Roman Gushchin wrote:
> > > Introduce the mem_cgroup_put() helper, which helps to eliminate guarding
> > > memcg css release with "#ifdef CONFIG_MEMCG" in multiple places.
> >
> > Is there any reason for this to be a separate patch? I usually do not
> > like to add helpers without their users because this makes review
> > harder. This one is quite trivial to fit into Patch3 easilly.
> >
> 
> The helper function introduced in this change is also used in the
> remote charging patches, so, I asked Roman to separate this change out
> and thus can be merged independently.

Ok, that was not clear from the description. Then this is ok

Acked-by: Michal Hocko <mhocko@suse.com>
 
> Shakeel
> 
> > > Link: http://lkml.kernel.org/r/20180623000600.5818-2-guro@fb.com
> > > Signed-off-by: Roman Gushchin <guro@fb.com>
> > > Reviewed-by: Shakeel Butt <shakeelb@google.com>
> > > Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Shakeel Butt <shakeelb@google.com>
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > Cc: Michal Hocko <mhocko@kernel.org>
> > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> > > ---
> > >  include/linux/memcontrol.h | 9 +++++++++
> > >  1 file changed, 9 insertions(+)
> > >
> > > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > > index 6c6fb116e925..e53e00cdbe3f 100644
> > > --- a/include/linux/memcontrol.h
> > > +++ b/include/linux/memcontrol.h
> > > @@ -375,6 +375,11 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
> > >       return css ? container_of(css, struct mem_cgroup, css) : NULL;
> > >  }
> > >
> > > +static inline void mem_cgroup_put(struct mem_cgroup *memcg)
> > > +{
> > > +     css_put(&memcg->css);
> > > +}
> > > +
> > >  #define mem_cgroup_from_counter(counter, member)     \
> > >       container_of(counter, struct mem_cgroup, member)
> > >
> > > @@ -837,6 +842,10 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
> > >       return true;
> > >  }
> > >
> > > +static inline void mem_cgroup_put(struct mem_cgroup *memcg)
> > > +{
> > > +}
> > > +
> > >  static inline struct mem_cgroup *
> > >  mem_cgroup_iter(struct mem_cgroup *root,
> > >               struct mem_cgroup *prev,
> > > --
> > > 2.14.4
> > >
> >
> > --
> > Michal Hocko
> > SUSE Labs

-- 
Michal Hocko
SUSE Labs
