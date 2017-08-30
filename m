Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 608AC6B02B4
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 16:56:25 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 83so14216016pgb.1
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 13:56:25 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t10sor2650857pgo.104.2017.08.30.13.56.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Aug 2017 13:56:24 -0700 (PDT)
Date: Wed, 30 Aug 2017 13:56:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v6 2/4] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20170830112240.GA4751@castle.dhcp.TheFacebook.com>
Message-ID: <alpine.DEB.2.10.1708301349130.79465@chino.kir.corp.google.com>
References: <20170823165201.24086-1-guro@fb.com> <20170823165201.24086-3-guro@fb.com> <20170824114706.GG5943@dhcp22.suse.cz> <20170824122846.GA15916@castle.DHCP.thefacebook.com> <20170824125811.GK5943@dhcp22.suse.cz> <20170824135842.GA21167@castle.DHCP.thefacebook.com>
 <20170824141336.GP5943@dhcp22.suse.cz> <20170824145801.GA23457@castle.DHCP.thefacebook.com> <20170825081402.GG25498@dhcp22.suse.cz> <20170830112240.GA4751@castle.dhcp.TheFacebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 30 Aug 2017, Roman Gushchin wrote:

> I've spent some time to implement such a version.
> 
> It really became shorter and more existing code were reused,
> howewer I've met a couple of serious issues:
> 
> 1) Simple summing of per-task oom_score doesn't make sense.
>    First, we calculate oom_score per-task, while should sum per-process values,
>    or, better, per-mm struct. We can take only threa-group leader's score
>    into account, but it's also not 100% accurate.
>    And, again, we have a question what to do with per-task oom_score_adj,
>    if we don't task the task's oom_score into account.
> 
>    Using memcg stats still looks to me as a more accurate and consistent
>    way of estimating memcg memory footprint.
> 

The patchset is introducing a new methodology for selecting oom victims so 
you can define how cgroups are compared vs other cgroups with your own 
"badness" calculation.  I think your implementation based heavily on anon 
and unevictable lrus and unreclaimable slab is fine and you can describe 
that detail in the documentation (along with the caveat that it is only 
calculated for nodes in the allocation's mempolicy).  With 
memory.oom_priority, the user has full ability to change that selection.  
Process selection heuristics have changed over time themselves, it's not 
something that must be backwards compatibile and trying to sum the usage 
from each of the cgroup's mm_struct's and respect oom_score_adj is 
unnecessarily complex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
