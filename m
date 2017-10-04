Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 952A26B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 15:37:06 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l10so289123wre.4
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 12:37:06 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q3si575999edj.165.2017.10.04.12.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Oct 2017 12:37:05 -0700 (PDT)
Date: Wed, 4 Oct 2017 15:37:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [v10 4/6] mm, oom: introduce memory.oom_group
Message-ID: <20171004193700.GD1501@cmpxchg.org>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-5-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171004154638.710-5-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 04, 2017 at 04:46:36PM +0100, Roman Gushchin wrote:
> The cgroup-aware OOM killer treats leaf memory cgroups as memory
> consumption entities and performs the victim selection by comparing
> them based on their memory footprint. Then it kills the biggest task
> inside the selected memory cgroup.
> 
> But there are workloads, which are not tolerant to a such behavior.
> Killing a random task may leave the workload in a broken state.
> 
> To solve this problem, memory.oom_group knob is introduced.
> It will define, whether a memory group should be treated as an
> indivisible memory consumer, compared by total memory consumption
> with other memory consumers (leaf memory cgroups and other memory
> cgroups with memory.oom_group set), and whether all belonging tasks
> should be killed if the cgroup is selected.
> 
> If set on memcg A, it means that in case of system-wide OOM or
> memcg-wide OOM scoped to A or any ancestor cgroup, all tasks,
> belonging to the sub-tree of A will be killed. If OOM event is
> scoped to a descendant cgroup (A/B, for example), only tasks in
> that cgroup can be affected. OOM killer will never touch any tasks
> outside of the scope of the OOM event.
> 
> Also, tasks with oom_score_adj set to -1000 will not be killed.
> 
> The default value is 0.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org

Those semantics make sense to me and the code looks good.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
