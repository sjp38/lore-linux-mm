Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id CB4506B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 17:03:55 -0400 (EDT)
Received: by igcqs7 with SMTP id qs7so89052344igc.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 14:03:55 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id 15si6323936ioo.98.2015.07.09.14.03.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 14:03:55 -0700 (PDT)
Received: by iecvh10 with SMTP id vh10so184988315iec.3
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 14:03:55 -0700 (PDT)
Date: Thu, 9 Jul 2015 14:03:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] oom: Do not panic when OOM killer is sysrq
 triggered
In-Reply-To: <20150709082304.GA13872@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1507091352150.17177@chino.kir.corp.google.com>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com> <1436360661-31928-2-git-send-email-mhocko@suse.com> <alpine.DEB.2.10.1507081635030.16585@chino.kir.corp.google.com> <20150709082304.GA13872@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 9 Jul 2015, Michal Hocko wrote:

> > the titles were wrong for patches 2 and 3, but it doesn't mean we need to 
> > add hacks around the code before organizing this into struct oom_control 
> 
> It is much easier to backport _fixes_ into older kernels (and yes I do
> care about that) if they do not depend on other cleanups. So I do not
> understand your point here. Besides that the cleanup really didn't make
> much change to the actuall fix because one way or another you still have
> to add a simple condition to rule out a heuristic/configuration which
> doesn't apply to sysrq+f path.
> 
> So I am really lost in your argumentation here.
> 

This isn't a bugfix: sysrq+f has, at least for eight years, been able to 
panic the kernel.  We're not fixing a bug, we're changing behavior.  It's 
quite appropriate to reorganize code before a behavior change to make it 
cleaner.

> > or completely pointless comments and printks that will fill the kernel 
> > log.
> 
> Could you explain what is so pointless about a comment which clarifies
> the fact which is not obviously visible from the current function?
> 

It states the obvious, a kthread is not going to be oom killed for 
oom_kill_allocating_task: it's not only current->mm, but also 
oom_unkillable_task(), which quite explicitly checks for PF_KTHREAD.  I 
don't think any reader of this code will assume a kthread is going to be 
oom killed.

> Also could you explain why the admin shouldn't get an information if
> sysrq+f didn't kill anything because no eligible task has been found?

The kernel log is the only notification mechanism that we have of the 
kernel killing a process, we want to avoid spamming it unnecessarily.  The 
kernel log is not the appropriate place for your debugging information 
that would only specify that yes, out_of_memory() was called, but there 
was nothing actionable, especially when that trigger can be constantly 
invoked by userspace once panicking is no longer possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
