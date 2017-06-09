Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C28C76B02B4
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 12:30:29 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y39so9209598wry.10
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 09:30:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r28si1642390wra.315.2017.06.09.09.30.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Jun 2017 09:30:26 -0700 (PDT)
Date: Fri, 9 Jun 2017 18:30:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v2 0/7] cgroup-aware OOM killer
Message-ID: <20170609163022.GA9332@dhcp22.suse.cz>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496342115-3974-1-git-send-email-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org

On Thu 01-06-17 19:35:08, Roman Gushchin wrote:
> This patchset makes the OOM killer cgroup-aware.
> 
> Patches 1-3 are simple refactorings of the OOM killer code,
> required to reuse the code in the memory controller.
> Patches 4 & 5 are introducing new memcg settings:
> oom_kill_all_tasks and oom_score_adj.
> Patch 6 introduces the cgroup-aware OOM killer.
> Patch 7 is docs update.

I have only had a look at the cumulative diff (sorry I've been quite
busy throughout the week) and here are my high level comments. I can see
few rather serious issues which will need to be resolved before this
can move on.
- the first problem is a pre-existing one but it will get more urgent
  with the fact that more tasks will be killed with your approach. OOM
  victims are allowed to consume memory reserves without any bound. The
  current throttling is quite arguable and it relies on the fact that we
  try to limit the number of tasks to have this access to reserves.
  Theoretically, though, a heavily multithread application can deplete the
  reserves completely even now. With more processes being killed this
  will get much more likely. Johannes and me have already posted patches
  to address that. The last patch was
  http://lkml.kernel.org/r/1472723464-22866-2-git-send-email-mhocko@kernel.org
- I do not see any explicit lockout mechanism to prevent from too eager oom
  invocation while the previous oom killed memcg is still not torn down
  completely. We use tsk_is_oom_victim check in oom_evaluate_task for
  that purpose. You seem to rely on the fact that such a memcg would be
  still the largest one, right? I am not really sure this is sufficient.
- You seem to completely ignore per task oom_score_adj and override it
  by the memcg value. This makes some sense but it can lead to an
  unexpected behavior when somebody relies on the original behavior.
  E.g. a workload that would corrupt data when killed unexpectedly and
  so it is protected by OOM_SCORE_ADJ_MIN. Now this assumption will
  break when running inside a container. I do not have a good answer
  what is the desirable behavior and maybe there is no universal answer.
  Maybe you just do not to kill those tasks? But then you have to be
  careful when selecting a memcg victim. Hairy...
- While we are at it oom_score_adj has turned out to be quite unusable
  for a sensible oom prioritization from my experience. Practically
  it reduced to disable/enforce the task for selection. The scale is
  quite small as well. There certainly is a need for prioritization
  and maybe a completely different api would be better. Maybe a simple
  priority in (0, infinity) range will be better. Priority could be used
  either as the only criterion or as a tie breaker when consumption of
  more memcgs is too close (this could be implemented for each strategy
  in a different way if we go modules way)
- oom_kill_all_tasks should be hierarchical and consistent within a
  hierarchy. Or maybe it should be applicable to memcgs with tasks (leaf
  cgroups). Although selecting a memcg higher in the hierarchy kill all
  tasks in that hierarchy makes some sense as well IMHO. Say you
  delegate a hierarchy to an unprivileged user and still want to contain
  that user.

I have likely forgot some points but the above ones should be the most
important ones I guess.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
