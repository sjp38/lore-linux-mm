Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 593DB6B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 07:42:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i16-v6so827173ede.11
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 04:42:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v3-v6si803794edq.63.2018.10.23.04.42.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 04:42:47 -0700 (PDT)
Date: Tue, 23 Oct 2018 13:42:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
Message-ID: <20181023114246.GR18839@dhcp22.suse.cz>
References: <f9a8079f-55b0-301e-9b3d-a5250bd7d277@i-love.sakura.ne.jp>
 <20181022120308.GB18839@dhcp22.suse.cz>
 <201810230101.w9N118i3042448@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201810230101.w9N118i3042448@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 23-10-18 10:01:08, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 22-10-18 20:45:17, Tetsuo Handa wrote:
> > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > index e79cb59552d9..a9dfed29967b 100644
> > > > --- a/mm/memcontrol.c
> > > > +++ b/mm/memcontrol.c
> > > > @@ -1380,10 +1380,22 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> > > >  		.gfp_mask = gfp_mask,
> > > >  		.order = order,
> > > >  	};
> > > > -	bool ret;
> > > > +	bool ret = true;
> > > >  
> > > >  	mutex_lock(&oom_lock);
> > > > +
> > > > +	/*
> > > > +	 * multi-threaded tasks might race with oom_reaper and gain
> > > > +	 * MMF_OOM_SKIP before reaching out_of_memory which can lead
> > > > +	 * to out_of_memory failure if the task is the last one in
> > > > +	 * memcg which would be a false possitive failure reported
> > > > +	 */
> > > > +	if (tsk_is_oom_victim(current))
> > > > +		goto unlock;
> > > > +
> > > 
> > > This is not wrong but is strange. We can use mutex_lock_killable(&oom_lock)
> > > so that any killed threads no longer wait for oom_lock.
> > 
> > tsk_is_oom_victim is stronger because it doesn't depend on
> > fatal_signal_pending which might be cleared throughout the exit process.
> > 
> 
> I still want to propose this. No need to be memcg OOM specific.

Well, I maintain what I've said [1] about simplicity and specific fix
for a specific issue. Especially in the tricky code like this where all
the consequences are far more subtle than they seem to be.

This is obviously a matter of taste but I don't see much point discussing
this back and forth for ever. Unless there is a general agreement that
the above is less appropriate then I am willing to consider a different
change but I simply do not have energy to nit pick for ever.

[1] http://lkml.kernel.org/r/20181022134315.GF18839@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs
