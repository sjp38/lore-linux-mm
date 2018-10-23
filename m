Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 31CEB6B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 08:48:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 31-v6so923738edr.19
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 05:48:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p14-v6si1069630edi.343.2018.10.23.05.48.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 05:48:49 -0700 (PDT)
Date: Tue, 23 Oct 2018 14:48:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
Message-ID: <20181023124847.GT18839@dhcp22.suse.cz>
References: <f9a8079f-55b0-301e-9b3d-a5250bd7d277@i-love.sakura.ne.jp>
 <20181022120308.GB18839@dhcp22.suse.cz>
 <201810230101.w9N118i3042448@www262.sakura.ne.jp>
 <20181023114246.GR18839@dhcp22.suse.cz>
 <20181023121055.GS18839@dhcp22.suse.cz>
 <a55e70bd-dc5f-9a11-72e6-7cd7b3b48ab7@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a55e70bd-dc5f-9a11-72e6-7cd7b3b48ab7@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 23-10-18 21:33:43, Tetsuo Handa wrote:
> On 2018/10/23 21:10, Michal Hocko wrote:
> > On Tue 23-10-18 13:42:46, Michal Hocko wrote:
> >> On Tue 23-10-18 10:01:08, Tetsuo Handa wrote:
> >>> Michal Hocko wrote:
> >>>> On Mon 22-10-18 20:45:17, Tetsuo Handa wrote:
> >>>>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >>>>>> index e79cb59552d9..a9dfed29967b 100644
> >>>>>> --- a/mm/memcontrol.c
> >>>>>> +++ b/mm/memcontrol.c
> >>>>>> @@ -1380,10 +1380,22 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >>>>>>  		.gfp_mask = gfp_mask,
> >>>>>>  		.order = order,
> >>>>>>  	};
> >>>>>> -	bool ret;
> >>>>>> +	bool ret = true;
> >>>>>>  
> >>>>>>  	mutex_lock(&oom_lock);
> >>>>>> +
> >>>>>> +	/*
> >>>>>> +	 * multi-threaded tasks might race with oom_reaper and gain
> >>>>>> +	 * MMF_OOM_SKIP before reaching out_of_memory which can lead
> >>>>>> +	 * to out_of_memory failure if the task is the last one in
> >>>>>> +	 * memcg which would be a false possitive failure reported
> >>>>>> +	 */
> >>>>>> +	if (tsk_is_oom_victim(current))
> >>>>>> +		goto unlock;
> >>>>>> +
> >>>>>
> >>>>> This is not wrong but is strange. We can use mutex_lock_killable(&oom_lock)
> >>>>> so that any killed threads no longer wait for oom_lock.
> >>>>
> >>>> tsk_is_oom_victim is stronger because it doesn't depend on
> >>>> fatal_signal_pending which might be cleared throughout the exit process.
> >>>>
> >>>
> >>> I still want to propose this. No need to be memcg OOM specific.
> >>
> >> Well, I maintain what I've said [1] about simplicity and specific fix
> >> for a specific issue. Especially in the tricky code like this where all
> >> the consequences are far more subtle than they seem to be.
> >>
> >> This is obviously a matter of taste but I don't see much point discussing
> >> this back and forth for ever. Unless there is a general agreement that
> >> the above is less appropriate then I am willing to consider a different
> >> change but I simply do not have energy to nit pick for ever.
> >>
> >> [1] http://lkml.kernel.org/r/20181022134315.GF18839@dhcp22.suse.cz
> > 
> > In other words. Having a memcg specific fix means, well, a memcg
> > maintenance burden. Like any other memcg specific oom decisions we
> > already have. So are you OK with that Johannes or you would like to see
> > a more generic fix which might turn out to be more complex?
> > 
> 
> I don't know what "that Johannes" refers to.

let me rephrase

Johannes, are you OK with that (memcg specific fix) or you would like to
see a more generic fix which might turn out to be more complex.
-- 
Michal Hocko
SUSE Labs
