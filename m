Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 927446B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 10:43:11 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y58so2297840wry.15
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 07:43:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k4si6217716wrd.11.2017.10.03.07.43.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 07:43:10 -0700 (PDT)
Date: Tue, 3 Oct 2017 16:43:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v9 3/5] mm, oom: cgroup-aware OOM killer
Message-ID: <20171003144308.zc5xaxmgbmiz2jvg@dhcp22.suse.cz>
References: <20170927130936.8601-1-guro@fb.com>
 <20170927130936.8601-4-guro@fb.com>
 <20171003114848.gstdawonla2gmfio@dhcp22.suse.cz>
 <20171003123721.GA27919@castle.dhcp.TheFacebook.com>
 <20171003133623.hoskmd3fsh4t2phf@dhcp22.suse.cz>
 <20171003140841.GA29624@castle.DHCP.thefacebook.com>
 <20171003142246.xactdt7xddqdhvtu@dhcp22.suse.cz>
 <20171003143808.GA531@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003143808.GA531@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 03-10-17 15:38:08, Roman Gushchin wrote:
> On Tue, Oct 03, 2017 at 04:22:46PM +0200, Michal Hocko wrote:
> > On Tue 03-10-17 15:08:41, Roman Gushchin wrote:
> > > On Tue, Oct 03, 2017 at 03:36:23PM +0200, Michal Hocko wrote:
> > [...]
> > > > I guess we want to inherit the value on the memcg creation but I agree
> > > > that enforcing parent setting is weird. I will think about it some more
> > > > but I agree that it is saner to only enforce per memcg value.
> > > 
> > > I'm not against, but we should come up with a good explanation, why we're
> > > inheriting it; or not inherit.
> > 
> > Inheriting sounds like a less surprising behavior. Once you opt in for
> > oom_group you can expect that descendants are going to assume the same
> > unless they explicitly state otherwise.
> > 
> > [...]
> > > > > > > @@ -962,6 +968,48 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> > > > > > >  	__oom_kill_process(victim);
> > > > > > >  }
> > > > > > >  
> > > > > > > +static int oom_kill_memcg_member(struct task_struct *task, void *unused)
> > > > > > > +{
> > > > > > > +	if (!tsk_is_oom_victim(task)) {
> > > > > > 
> > > > > > How can this happen?
> > > > > 
> > > > > We do start with killing the largest process, and then iterate over all tasks
> > > > > in the cgroup. So, this check is required to avoid killing tasks which are
> > > > > already in the termination process.
> > > > 
> > > > Do you mean we have tsk_is_oom_victim && MMF_OOM_SKIP == T?
> > > 
> > > No, just tsk_is_oom_victim. We're are killing the biggest task, and then _all_
> > > tasks. This is a way to skip the biggest task, and do not kill it again.
> > 
> > OK, I have missed that part. Why are we doing that actually? Why don't
> > we simply do 
> > 	/* If oom_group flag is set, kill all belonging tasks */
> > 	if (mem_cgroup_oom_group(oc->chosen_memcg))
> > 		mem_cgroup_scan_tasks(oc->chosen_memcg, oom_kill_memcg_member,
> > 				      NULL);
> > 
> > we are going to kill all the tasks anyway.
> 
> Well, the idea behind was that killing the biggest process give us better
> chances to get out of global memory shortage and guarantee forward progress.
> I can drop it, if it considered to be excessive.

Yes, please do so. If we need it then we can do that in a separate patch
along with the explanation why it is needed.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
