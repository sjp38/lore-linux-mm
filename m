Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 667656B0253
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 03:41:28 -0400 (EDT)
Received: by wiga1 with SMTP id a1so7939747wig.0
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 00:41:28 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id uj1si14007879wjc.177.2015.07.10.00.41.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 00:41:26 -0700 (PDT)
Received: by wifm2 with SMTP id m2so38604403wif.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 00:41:26 -0700 (PDT)
Date: Fri, 10 Jul 2015 09:41:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] oom: Do not panic when OOM killer is sysrq triggered
Message-ID: <20150710074124.GB7343@dhcp22.suse.cz>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com>
 <1436360661-31928-2-git-send-email-mhocko@suse.com>
 <alpine.DEB.2.10.1507081635030.16585@chino.kir.corp.google.com>
 <20150709082304.GA13872@dhcp22.suse.cz>
 <alpine.DEB.2.10.1507091352150.17177@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507091352150.17177@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 09-07-15 14:03:53, David Rientjes wrote:
> On Thu, 9 Jul 2015, Michal Hocko wrote:
> 
> > > the titles were wrong for patches 2 and 3, but it doesn't mean we need to 
> > > add hacks around the code before organizing this into struct oom_control 
> > 
> > It is much easier to backport _fixes_ into older kernels (and yes I do
> > care about that) if they do not depend on other cleanups. So I do not
> > understand your point here. Besides that the cleanup really didn't make
> > much change to the actuall fix because one way or another you still have
> > to add a simple condition to rule out a heuristic/configuration which
> > doesn't apply to sysrq+f path.
> > 
> > So I am really lost in your argumentation here.
> > 
> 
> This isn't a bugfix: sysrq+f has, at least for eight years, been able to 
> panic the kernel.

This is an unwanted behavior and that is why I call it a bug. The mere
fact that nobody has noticed because panic_on_oom is not used widely and
even less with sysrq+f has nothing to do with it.

> We're not fixing a bug, we're changing behavior.  It's 
> quite appropriate to reorganize code before a behavior change to make it 
> cleaner.
> 
> > > or completely pointless comments and printks that will fill the kernel 
> > > log.
> > 
> > Could you explain what is so pointless about a comment which clarifies
> > the fact which is not obviously visible from the current function?
> > 
> 
> It states the obvious, a kthread is not going to be oom killed for 
> oom_kill_allocating_task:

Sigh. The comment says that the force_kill path _runs_ from the kthread
context which is far from obvious in out_of_memory.

[...]

> > Also could you explain why the admin shouldn't get an information if
> > sysrq+f didn't kill anything because no eligible task has been found?
> 
> The kernel log is the only notification mechanism that we have of the 
> kernel killing a process, we want to avoid spamming it unnecessarily.  The 
> kernel log is not the appropriate place for your debugging information 
> that would only specify that yes, out_of_memory() was called, but there 
> was nothing actionable, especially when that trigger can be constantly 
> invoked by userspace once panicking is no longer possible.

So how would you find out that there is no oom killable task?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
