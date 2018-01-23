Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE234800DD
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 17:22:11 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id p202so2159299iod.18
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 14:22:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v128sor10575623iof.265.2018.01.23.14.22.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jan 2018 14:22:10 -0800 (PST)
Date: Tue, 23 Jan 2018 14:22:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
In-Reply-To: <20180123155301.GS1526@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1801231416330.254281@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com> <alpine.DEB.2.10.1801161814130.28198@chino.kir.corp.google.com> <20180117154155.GU3460072@devbig577.frc2.facebook.com> <alpine.DEB.2.10.1801171348190.86895@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801191251080.177541@chino.kir.corp.google.com> <20180120123251.GB1096857@devbig577.frc2.facebook.com> <alpine.DEB.2.10.1801221420120.16871@chino.kir.corp.google.com> <20180123155301.GS1526@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 23 Jan 2018, Michal Hocko wrote:

> > It can't, because the current patchset locks the system into a single 
> > selection criteria that is unnecessary and the mount option would become a 
> > no-op after the policy per subtree becomes configurable by the user as 
> > part of the hierarchy itself.
> 
> This is simply not true! OOM victim selection has changed in the
> past and will be always a subject to changes in future. Current
> implementation doesn't provide any externally controlable selection
> policy and therefore the default can be assumed. Whatever that default
> means now or in future. The only contract added here is the kill full
> memcg if selected and that can be implemented on _any_ selection policy.
> 

The current implementation of memory.oom_group is based on top of a 
selection implementation that is broken in three ways I have listed for 
months:

 - allows users to intentionally/unintentionally evade the oom killer,
   requires not locking the selection implementation for the entire
   system, requires subtree control to prevent, makes a mount option
   obsolete, and breaks existing users who would use the implementation
   based on 4.16 if this were merged,

 - unfairly compares the root mem cgroup vs leaf mem cgroup such that
   users must structure their hierarchy only for 4.16 in such a way
   that _all_ processes are under hierarchical control and have no
   power to create sub cgroups because of the point above and
   completely breaks any user of oom_score_adj in a completely
   undocumented and unspecified way, such that fixing that breakage
   would also break any existing users who would use the implementation
   based on 4.16 if this were merged, and

 - does not allow userspace to protect important cgroups, which can be
   built on top.

I'm focused on fixing the breakage in the first two points since it 
affects the API and we don't want to switch that out from the user.  I 
have brought these points up repeatedly and everybody else has actively 
disengaged from development, so I'm proposing incremental changes that 
make the cgroup aware oom killer have a sustainable API and isn't useful 
only for a highly specialized usecase where everything is containerized, 
nobody can create subcgroups, and nobody uses oom_score_adj to break the 
root mem cgroup accounting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
