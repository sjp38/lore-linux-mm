Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7556B0035
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 19:34:30 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so1153202yha.35
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 16:34:30 -0800 (PST)
Received: from mail-gg0-x233.google.com (mail-gg0-x233.google.com [2607:f8b0:4002:c02::233])
        by mx.google.com with ESMTPS id q66si6708379yhm.204.2014.01.09.16.34.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 16:34:29 -0800 (PST)
Received: by mail-gg0-f179.google.com with SMTP id e5so11598ggh.10
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 16:34:28 -0800 (PST)
Date: Thu, 9 Jan 2014 16:34:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20131209230527.GL21724@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1401091629540.24832@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com> <20131127163435.GA3556@cmpxchg.org> <20131202200221.GC5524@dhcp22.suse.cz> <20131202212500.GN22729@cmpxchg.org> <20131203120454.GA12758@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312031544530.5946@chino.kir.corp.google.com> <20131204111318.GE8410@dhcp22.suse.cz> <alpine.DEB.2.02.1312041606260.6329@chino.kir.corp.google.com> <20131209124840.GC3597@dhcp22.suse.cz> <alpine.DEB.2.02.1312091328550.11026@chino.kir.corp.google.com>
 <20131209230527.GL21724@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

Andrew requested I reply to this email, so it's old, but here it is.


On Mon, 9 Dec 2013, Johannes Weiner wrote:

> We check for fatal signals during the repeated charge attempts and
> reclaim.  Should we be checking for PF_EXITING too?
> 

Michal has proposed that patch and I question whether we should be doing 
that because if significant memory allocation can be done in the exit() 
path after PF_EXITING either now or in the future, then it does not allow 
memory to be set aside for system oom handlers given the suggested memcg 
configuration from Tejun that limits the amount of "user" memory to a 
top-level memcg limit that can be overcommitted below it and bypasses 
these charges to root that would disallow the userspace oom handlers from 
getting memory that they have been reserved.  In other words, if a 64GB 
machine has top-level memcgs "user" with limit of 62GB and "oom" with 
limit of 2GB for system oom handlers, that 2GB cannot be guaranteed with 
all of these bypasses (uncharged memory, such as unaccounted kernel 
memory, memory reserves).

> You even re-inforced this motivation by suggesting the separate memcg
> margin check right before the OOM kill, so don't blame us for
> misunderstanding the exact placement of this check as your main
> argument when you repeated it over and over.
> 

We've talked about a lot of stuff in these threads, yes.

> All I object to is that the OOM killer is riddled with last-second
> checks of whether the OOM situation is still existant.  We establish
> that the context is OOM and once we are certain we are executing,
> period.
> 

This patch moves a check from being "last second" to actually before the 
oom killer is called at all, you should be pleased.

> Not catching PF_EXITING in the long window between the first reclaim
> and going OOM is a separate issue and I can see that this should be
> fixed but it should be checked before we start invoking OOM.
> 

Doesn't seem like an issue with this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
