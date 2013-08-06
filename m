Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 045A36B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 10:09:20 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id z10so216921qcx.18
        for <linux-mm@kvack.org>; Tue, 06 Aug 2013 07:09:20 -0700 (PDT)
Date: Tue, 6 Aug 2013 10:09:04 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/5] cgroup, memcg: move cgroup_event implementation to
 memcg
Message-ID: <20130806140904.GA9814@mtj.dyndns.org>
References: <1375632446-2581-1-git-send-email-tj@kernel.org>
 <1375632446-2581-4-git-send-email-tj@kernel.org>
 <CAKTCnz=DdG6QD0yPJ1poRZk0NYrYHdkmabvCXY-AR2qC1GSzYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKTCnz=DdG6QD0yPJ1poRZk0NYrYHdkmabvCXY-AR2qC1GSzYA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: lizefan@huawei.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello, Balbir.

On Tue, Aug 06, 2013 at 08:56:34AM +0530, Balbir Singh wrote:
> [off-topic] Has the unified hierarchy been agreed upon? I did not
> follow that thread

I consider it agreed upon enough.  There of course are objections but
I feel fairly comfortable with the amount of existing consensus and
considering the current state of cgroup in general, especially the API
leaks, I don't think we have many other choices.  The devil is always
in the details but unless we meet a major technical barrier, I'm
pretty sure it's happening.

> > events at fixed points, or if that's too restrictive, configureable
> > cadence or single set of configureable points should be enough.
> 
> Nit-pick: typo on the spelling of configurable

Will update.

> Tejun, I think the framework was designed to be flexible. Do you see
> cgroup subsystems never using this?

I can't be a hundred percent sure that we won't need events which are
configureable per-listener but it's highly unlikely given that we're
moving onto single agent model and the nature of event delivery -
spurious events are unlikely to be noticeable unless the frequency is
very high.  In general, as anything, aiming for extremes isn't a
healthy design practice.  Maximum flexibility sounds good in isolation
but nothing is free and it entails unneeded complexity both in
implementation and usage.  Note that even for memcg, both oom and
vmpressure don't benefit in any way from all the added complexity at
all.  The only other place that I can see event being useful at the
moment is freezer state change notification and that also would only
require unconditional file modified notification.

> > +static int cgroup_write_event_control(struct cgroup_subsys_state *css,
> > +                                     struct cftype *cft, const char *buffer)
> > +{
> > +       struct cgroup *cgrp = css->cgroup;
> > +       struct cgroup_event *event;
> > +       struct cgroup *cgrp_cfile;
> > +       unsigned int efd, cfd;
> > +       struct file *efile;
> > +       struct file *cfile;
> > +       char *endp;
> > +       int ret;
> > +
> 
> Can we assert that buffer is NOT NULL here?

The patch moves the code as-is as things become difficult to review
otherwise.  After the patchset, it belongs to memcg, please feel free
to modify as memcg people see fit.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
