Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8629F800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 03:20:45 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id f6so1914703wre.4
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 00:20:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 25si1671959wrw.123.2018.01.24.00.20.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Jan 2018 00:20:44 -0800 (PST)
Date: Wed, 24 Jan 2018 09:20:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
Message-ID: <20180124082041.GD1526@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801161814130.28198@chino.kir.corp.google.com>
 <20180117154155.GU3460072@devbig577.frc2.facebook.com>
 <alpine.DEB.2.10.1801171348190.86895@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801191251080.177541@chino.kir.corp.google.com>
 <20180120123251.GB1096857@devbig577.frc2.facebook.com>
 <alpine.DEB.2.10.1801221420120.16871@chino.kir.corp.google.com>
 <20180123155301.GS1526@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801231416330.254281@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1801231416330.254281@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 23-01-18 14:22:07, David Rientjes wrote:
> On Tue, 23 Jan 2018, Michal Hocko wrote:
> 
> > > It can't, because the current patchset locks the system into a single 
> > > selection criteria that is unnecessary and the mount option would become a 
> > > no-op after the policy per subtree becomes configurable by the user as 
> > > part of the hierarchy itself.
> > 
> > This is simply not true! OOM victim selection has changed in the
> > past and will be always a subject to changes in future. Current
> > implementation doesn't provide any externally controlable selection
> > policy and therefore the default can be assumed. Whatever that default
> > means now or in future. The only contract added here is the kill full
> > memcg if selected and that can be implemented on _any_ selection policy.
> > 
> 
> The current implementation of memory.oom_group is based on top of a 
> selection implementation that is broken in three ways I have listed for 
> months:

This doesn't lead to anywhere. You are not presenting any new arguments
and you are ignoring feedback you have received so far. We have tried
really hard. Considering different _independent_ people presented more or
less consistent view on these points I think you should deeply
reconsider how you take that feedback.

>  - allows users to intentionally/unintentionally evade the oom killer,
>    requires not locking the selection implementation for the entire
>    system, requires subtree control to prevent, makes a mount option
>    obsolete, and breaks existing users who would use the implementation
>    based on 4.16 if this were merged,
> 
>  - unfairly compares the root mem cgroup vs leaf mem cgroup such that
>    users must structure their hierarchy only for 4.16 in such a way
>    that _all_ processes are under hierarchical control and have no
>    power to create sub cgroups because of the point above and
>    completely breaks any user of oom_score_adj in a completely
>    undocumented and unspecified way, such that fixing that breakage
>    would also break any existing users who would use the implementation
>    based on 4.16 if this were merged, and
> 
>  - does not allow userspace to protect important cgroups, which can be
>    built on top.

For the last time. This all can be done on top of the proposed solution
without breaking the proposed user API. I am really _convinced_ that you
underestimate how complex it is to provide a sane selection policy API
and it will take _months_ to settle on something. Existing OOM APIs are
a sad story and I definitly do not want to repeat same mistakes from the
past.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
