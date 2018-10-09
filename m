Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D73326B027B
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 10:09:30 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s15-v6so973307pgv.9
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 07:09:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n20-v6si7400848pgf.210.2018.10.09.07.09.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 07:09:29 -0700 (PDT)
Date: Tue, 9 Oct 2018 16:09:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom_adj: avoid meaningless loop to find processes
 sharing mm
Message-ID: <20181009140925.GS8528@dhcp22.suse.cz>
References: <f5bdf4a7-e491-1cda-590c-792526f49050@i-love.sakura.ne.jp>
 <20181009063541.GB8528@dhcp22.suse.cz>
 <20181009075015.GC8528@dhcp22.suse.cz>
 <df4b029c-16b4-755f-2672-d7ec116f78ba@i-love.sakura.ne.jp>
 <20181009111005.GK8528@dhcp22.suse.cz>
 <99008444-b6b1-efc9-8670-f3eac4d2305f@i-love.sakura.ne.jp>
 <20181009125841.GP8528@dhcp22.suse.cz>
 <41754dfe-3be7-f64e-45c9-2525d3b20d62@i-love.sakura.ne.jp>
 <20181009132622.GR8528@dhcp22.suse.cz>
 <0ab96b81-042e-b9d9-8d63-b423941d8072@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0ab96b81-042e-b9d9-8d63-b423941d8072@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: ytk.lee@samsung.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue 09-10-18 22:51:00, Tetsuo Handa wrote:
> On 2018/10/09 22:26, Michal Hocko wrote:
> > On Tue 09-10-18 22:14:24, Tetsuo Handa wrote:
> >> On 2018/10/09 21:58, Michal Hocko wrote:
> >>> On Tue 09-10-18 21:52:12, Tetsuo Handa wrote:
> >>>> On 2018/10/09 20:10, Michal Hocko wrote:
> >>>>> On Tue 09-10-18 19:00:44, Tetsuo Handa wrote:
> >>>>>>> 2) add OOM_SCORE_ADJ_MIN and do not kill tasks sharing mm and do not
> >>>>>>> reap the mm in the rare case of the race.
> >>>>>>
> >>>>>> That is no problem. The mistake we made in 4.6 was that we updated oom_score_adj
> >>>>>> to -1000 (and allowed unprivileged users to OOM-lockup the system).
> >>>>>
> >>>>> I do not follow.
> >>>>>
> >>>>
> >>>> http://tomoyo.osdn.jp/cgi-bin/lxr/source/mm/oom_kill.c?v=linux-4.6.7#L493
> >>>
> >>> Ahh, so you are not referring to the current upstream code. Do you see
> >>> any specific problem with the current one (well, except for the possible
> >>> race which I have tried to evaluate).
> >>>
> >>
> >> Yes. "task_will_free_mem(current) in out_of_memory() returns false due to MMF_OOM_SKIP
> >> being already set" is a problem for clone(CLONE_VM without CLONE_THREAD/CLONE_SIGHAND)
> >> with the current code.
> > 
> > a) I fail to see how that is related to your previous post and b) could
> > you be more specific. Is there any other scenario from the two described
> > in my earlier email?
> > 
> 
> I do not follow. Just reverting commit 44a70adec910d692 and commit 97fd49c2355ffded
> is sufficient for closing the copy_process() versus __set_oom_adj() race.

Please go back and see why this has been done in the first place.

> We went too far towards complete "struct mm_struct" based OOM handling. But stepping
> back to "struct signal_struct" based OOM handling solves Yong-Taek's for_each_process()
> latency problem and your copy_process() versus __set_oom_adj() race problem and my
> task_will_free_mem(current) race problem.

And again, I have put an evaluation of the race and try to see what is
the effect. Then you have started to fire hard to follow notes and it is
not clear whether the analysis/conclusions is wrong/incomplete.

So an we get back to that analysis and stick to the topic please?

-- 
Michal Hocko
SUSE Labs
