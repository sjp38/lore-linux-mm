Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DB94F6B0010
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 13:48:06 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l23-v6so16478390qtp.1
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 10:48:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 39-v6sor8411520qtm.155.2018.08.01.10.48.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 10:48:03 -0700 (PDT)
Date: Wed, 1 Aug 2018 13:50:57 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] mm, oom: introduce memory.oom.group
Message-ID: <20180801175057.GD11386@cmpxchg.org>
References: <20180730180100.25079-1-guro@fb.com>
 <20180730180100.25079-4-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180730180100.25079-4-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Mon, Jul 30, 2018 at 11:01:00AM -0700, Roman Gushchin wrote:
> For some workloads an intervention from the OOM killer
> can be painful. Killing a random task can bring
> the workload into an inconsistent state.
> 
> Historically, there are two common solutions for this
> problem:
> 1) enabling panic_on_oom,
> 2) using a userspace daemon to monitor OOMs and kill
>    all outstanding processes.
> 
> Both approaches have their downsides:
> rebooting on each OOM is an obvious waste of capacity,
> and handling all in userspace is tricky and requires
> a userspace agent, which will monitor all cgroups
> for OOMs.
> 
> In most cases an in-kernel after-OOM cleaning-up
> mechanism can eliminate the necessity of enabling
> panic_on_oom. Also, it can simplify the cgroup
> management for userspace applications.
> 
> This commit introduces a new knob for cgroup v2 memory
> controller: memory.oom.group. The knob determines
> whether the cgroup should be treated as a single
> unit by the OOM killer. If set, the cgroup and its
> descendants are killed together or not at all.
> 
> To determine which cgroup has to be killed, we do
> traverse the cgroup hierarchy from the victim task's
> cgroup up to the OOMing cgroup (or root) and looking
> for the highest-level cgroup  with memory.oom.group set.
> 
> Tasks with the OOM protection (oom_score_adj set to -1000)
> are treated as an exception and are never killed.
> 
> This patch doesn't change the OOM victim selection algorithm.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Tejun Heo <tj@kernel.org>

The semantics make sense to me and the code is straight-forward. With
Michal's other feedback incorporated, please feel free to add:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
