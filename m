Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3D546B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 09:32:52 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y58so654752wry.15
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 06:32:52 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id o91si995400edd.474.2017.10.13.06.32.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 06:32:51 -0700 (PDT)
Date: Fri, 13 Oct 2017 14:32:19 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v11 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171013133219.GA5363@castle.DHCP.thefacebook.com>
References: <20171005130454.5590-1-guro@fb.com>
 <20171005130454.5590-4-guro@fb.com>
 <alpine.DEB.2.10.1710091414260.59643@chino.kir.corp.google.com>
 <20171010122306.GA11653@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.10.1710101345370.28262@chino.kir.corp.google.com>
 <20171010220417.GA8667@castle>
 <alpine.DEB.2.10.1710111247390.98307@chino.kir.corp.google.com>
 <20171011214927.GA28741@castle>
 <alpine.DEB.2.10.1710121415420.76558@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1710121415420.76558@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 12, 2017 at 02:50:38PM -0700, David Rientjes wrote:
> On Wed, 11 Oct 2017, Roman Gushchin wrote:
> 
> Think about it in a different way: we currently compare per-process usage 
> and userspace has /proc/pid/oom_score_adj to adjust that usage depending 
> on priorities of that process and still oom kill if there's a memory leak.  
> Your heuristic compares per-cgroup usage, it's the cgroup-aware oom killer 
> after all.  We don't need a strict memory.oom_priority that outranks all 
> other sibling cgroups regardless of usage.  We need a memory.oom_score_adj 
> to adjust the per-cgroup usage.  The decisionmaking in your earlier 
> example would be under the control of C/memory.oom_score_adj and 
> D/memory.oom_score_adj.  Problem solved.
> 
> It also solves the problem of userspace being able to influence oom victim 
> selection so now they can protect important cgroups just like we can 
> protect important processes today.
> 
> And since this would be hierarchical usage, you can trivially infer root 
> mem cgroup usage by subtraction of top-level mem cgroup usage.
> 
> This is a powerful solution to the problem and gives userspace the control 
> they need so that it can work in all usecases, not a subset of usecases.

You're right that per-cgroup oom_score_adj may resolve the issue with
too strict semantics of oom_priorities. But I believe nobody likes
the existing per-process oom_score_adj interface, and there are reasons behind.
Especially in case of memcg-OOM, getting the idea how exactly oom_score_adj
will work is not trivial.
For example, earlier in this thread I've shown an example, when a decision
which of two processes should be killed depends on whether it's global or
memcg-wide oom, despite both belong to a single cgroup!

Of course, it's technically trivial to implement some analog of oom_score_adj
for cgroups (and early versions of this patchset did that).
But the right question is: is this an interface we want to support
for the next many years? I'm not sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
