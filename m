Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92F796B0006
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 16:23:38 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m4-v6so7703875pgq.19
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 13:23:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 27-v6si2315100pgn.24.2018.08.07.13.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 13:23:37 -0700 (PDT)
Date: Tue, 7 Aug 2018 22:23:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg, oom: be careful about races when warning about no
 reclaimable task
Message-ID: <20180807202332.GK10003@dhcp22.suse.cz>
References: <20180807072553.14941-1-mhocko@kernel.org>
 <20180807200247.GA4251@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180807200247.GA4251@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dmitry Vyukov <dvyukov@google.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 07-08-18 16:02:47, Johannes Weiner wrote:
> On Tue, Aug 07, 2018 at 09:25:53AM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > "memcg, oom: move out_of_memory back to the charge path" has added a
> > warning triggered when the oom killer cannot find any eligible task
> > and so there is no way to reclaim the oom memcg under its hard limit.
> > Further charges for such a memcg are forced and therefore the hard limit
> > isolation is weakened.
> > 
> > The current warning is however too eager to trigger  even when we are not
> > really hitting the above condition. Syzbot[1] and Greg Thelen have noticed
> > that we can hit this condition even when there is still oom victim
> > pending. E.g. the following race is possible:
> > 
> > memcg has two tasks taskA, taskB.
> > 
> > CPU1 (taskA)			CPU2			CPU3 (taskB)
> > try_charge
> >   mem_cgroup_out_of_memory				try_charge
> >       select_bad_process(taskB)
> >       oom_kill_process		oom_reap_task
> > 				# No real memory reaped
> >     				  			  mem_cgroup_out_of_memory
> > 				# set taskB -> MMF_OOM_SKIP
> >   # retry charge
> >   mem_cgroup_out_of_memory
> >     oom_lock						    oom_lock
> >     select_bad_process(self)
> >     oom_kill_process(self)
> >     oom_unlock
> > 							    # no eligible task
> > 
> > In fact syzbot test triggered this situation by placing multiple tasks
> > into a memcg with hard limit set to 0. So no task really had any memory
> > charged to the memcg
> > 
> > : Memory cgroup stats for /ile0: cache:0KB rss:0KB rss_huge:0KB shmem:0KB mapped_file:0KB dirty:0KB writeback:0KB swap:0KB inactive_anon:0KB active_anon:0KB inactive_file:0KB active_file:0KB unevictable:0KB
> > : Tasks state (memory values in pages):
> > : [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
> > : [   6569]     0  6562     9427        1    53248        0             0 syz-executor0
> > : [   6576]     0  6576     9426        0    61440        0             0 syz-executor6
> > : [   6578]     0  6578     9426      534    61440        0             0 syz-executor4
> > : [   6579]     0  6579     9426        0    57344        0             0 syz-executor5
> > : [   6582]     0  6582     9426        0    61440        0             0 syz-executor7
> > : [   6584]     0  6584     9426        0    57344        0             0 syz-executor1
> > 
> > so in principle there is indeed nothing reclaimable in this memcg and
> > this looks like a misconfiguration. On the other hand we can clearly
> > kill all those tasks so it is a bit early to warn and scare users. Do
> > that by checking that the current is the oom victim and bypass the
> > warning then. The victim is allowed to force charge and terminate to
> > release its temporal charge along the way.
> > 
> > [1] http://lkml.kernel.org/r/0000000000005e979605729c1564@google.com
> > Fixes: "memcg, oom: move out_of_memory back to the charge path"
> > Noticed-by: Greg Thelen <gthelen@google.com>
> > Reported-and-tested-by: syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/memcontrol.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 4603ad75c9a9..1b6eed1bc404 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1703,7 +1703,8 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
> >  		return OOM_ASYNC;
> >  	}
> >  
> > -	if (mem_cgroup_out_of_memory(memcg, mask, order))
> > +	if (mem_cgroup_out_of_memory(memcg, mask, order) ||
> > +			tsk_is_oom_victim(current))
> >  		return OOM_SUCCESS;
> >  
> >  	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
> 
> This is really ugly. :(
> 
> If that check is only there to suppress the warning when the limit is
> 0, this should really be a separate branch around the warning, with a
> fat comment that this is a ridiculous cornercase, and not look like it
> is an essential part of the memcg reclaim/oom process.

I do not mind having it in a separate branch. Btw. this is not just about
hard limit set to 0. Similar can happen anytime we are getting out of
oom victims. The likelihood goes up with the remote memcg charging
merged recently.

> Personally, I really don't get the point of this message. What is the
> user to do with this information? What are we to do with it if people
> report it? It conveys zero information on what the problem could be,
> because it asserts a really vague high-level thing. Shouldn't such
> debugging happen inside the OOM killer? What are the conceivable
> scenarios in which this triggers other than obvious misconfigs?
> 
> What would we lose by just deleting it?

We know that _something_ bad is going on because we have no way to
reclaim down to the hard limit. And that is the primary tool for the
workload isolation. I am all for a better information to tell us more. I
do not know what that would be right now, though.

My primary motivation for this warning was to catch potential issues
after we have moved oom handling back to the charge path. If we just
remove it then we have no information at all.

I wouldn't mind removing it if it generated more false possitives but
that hasn't happened so far.

-- 
Michal Hocko
SUSE Labs
