Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CBFC96B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 07:08:55 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t14so119291wmc.5
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 04:08:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o21si7971171wrf.105.2018.01.30.04.08.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 04:08:54 -0800 (PST)
Date: Tue, 30 Jan 2018 13:08:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm v2 2/3] mm, memcg: replace cgroup aware oom killer
 mount option with tunable
Message-ID: <20180130120852.GA21609@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1801251553030.161808@chino.kir.corp.google.com>
 <20180125160016.30e019e546125bb13b5b6b4f@linux-foundation.org>
 <alpine.DEB.2.10.1801261415090.15318@chino.kir.corp.google.com>
 <20180126143950.719912507bd993d92188877f@linux-foundation.org>
 <alpine.DEB.2.10.1801261441340.20954@chino.kir.corp.google.com>
 <20180126161735.b999356fbe96c0acd33aaa66@linux-foundation.org>
 <20180129104657.GC21609@dhcp22.suse.cz>
 <20180129191139.GA1121507@devbig577.frc2.facebook.com>
 <20180130085445.GQ21609@dhcp22.suse.cz>
 <20180130115846.GA4720@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130115846.GA4720@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 30-01-18 11:58:51, Roman Gushchin wrote:
> On Tue, Jan 30, 2018 at 09:54:45AM +0100, Michal Hocko wrote:
> > On Mon 29-01-18 11:11:39, Tejun Heo wrote:
> 
> Hello, Michal!
> 
> > diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
> > index 2eaed1e2243d..67bdf19f8e5b 100644
> > --- a/Documentation/cgroup-v2.txt
> > +++ b/Documentation/cgroup-v2.txt
> > @@ -1291,8 +1291,14 @@ This affects both system- and cgroup-wide OOMs. For a cgroup-wide OOM
> >  the memory controller considers only cgroups belonging to the sub-tree
> >  of the OOM'ing cgroup.
> >  
> > -The root cgroup is treated as a leaf memory cgroup, so it's compared
> > -with other leaf memory cgroups and cgroups with oom_group option set.
>                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> IMO, this statement is important. Isn't it?
> 
> > +Leaf cgroups are compared based on their cumulative memory usage. The
> > +root cgroup is treated as a leaf memory cgroup as well, so it's
> > +compared with other leaf memory cgroups. Due to internal implementation
> > +restrictions the size of the root cgroup is a cumulative sum of
> > +oom_badness of all its tasks (in other words oom_score_adj of each task
> > +is obeyed). Relying on oom_score_adj (appart from OOM_SCORE_ADJ_MIN)
> > +can lead to overestimating of the root cgroup consumption and it is
> 
> Hm, and underestimating too. Also OOM_SCORE_ADJ_MIN isn't any different
> in this case. Say, all tasks except a small one have OOM_SCORE_ADJ set to
> -999, this means the root croup has extremely low chances to be elected.
> 
> > +therefore discouraged. This might change in the future, though.
> 
> Other than that looks very good to me.

This?

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index 2eaed1e2243d..34ad80ee90f2 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -1291,8 +1291,15 @@ This affects both system- and cgroup-wide OOMs. For a cgroup-wide OOM
 the memory controller considers only cgroups belonging to the sub-tree
 of the OOM'ing cgroup.
 
-The root cgroup is treated as a leaf memory cgroup, so it's compared
-with other leaf memory cgroups and cgroups with oom_group option set.
+Leaf cgroups and cgroups with oom_group option set are compared based
+on their cumulative memory usage. The root cgroup is treated as a
+leaf memory cgroup as well, so it's compared with other leaf memory
+cgroups. Due to internal implementation restrictions the size of
+the root cgroup is a cumulative sum of oom_badness of all its tasks
+(in other words oom_score_adj of each task is obeyed). Relying on
+oom_score_adj (appart from OOM_SCORE_ADJ_MIN) can lead to over or
+underestimating of the root cgroup consumption and it is therefore
+discouraged. This might change in the future, though.
 
 If there are no cgroups with the enabled memory controller,
 the OOM killer is using the "traditional" process-based approach.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
