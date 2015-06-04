Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 188DE900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 18:59:12 -0400 (EDT)
Received: by iebgx4 with SMTP id gx4so46425892ieb.0
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 15:59:12 -0700 (PDT)
Received: from mail-ie0-x234.google.com (mail-ie0-x234.google.com. [2607:f8b0:4001:c03::234])
        by mx.google.com with ESMTPS id ng16si293641igb.36.2015.06.04.15.59.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jun 2015 15:59:11 -0700 (PDT)
Received: by iebgx4 with SMTP id gx4so46425768ieb.0
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 15:59:11 -0700 (PDT)
Date: Thu, 4 Jun 2015 15:59:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: split out forced OOM killer
In-Reply-To: <1433235187-32673-1-git-send-email-mhocko@suse.cz>
Message-ID: <alpine.DEB.2.10.1506041557070.16555@chino.kir.corp.google.com>
References: <1433235187-32673-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 2 Jun 2015, Michal Hocko wrote:

> OOM killer might be triggered externally via sysrq+f. This is supposed
> to kill a task no matter what e.g. a task is selected even though there
> is an OOM victim on the way to exit. This is a big hammer for an admin
> to help to resolve a memory short condition when the system is not able
> to cope with it on its own in a reasonable time frame (e.g. when the
> system is trashing or the OOM killer cannot make sufficient progress).
> 
> The forced OOM killing is currently wired into out_of_memory()
> call which is kind of ugly because generic out_of_memory path
> has to deal with configuration settings and heuristics which
> are completely irrelevant to the forced OOM killer (e.g.
> sysctl_oom_kill_allocating_task or OOM killer prevention for already
> dying tasks). Some of those will not apply to sysrq because the handler
> runs from the worker context.
> check_panic_on_oom on the other hand will work and that is kind of
> unexpected because sysrq+f should be usable to kill a mem hog whether
> the global OOM policy is to panic or not.
> It also doesn't make much sense to panic the system when no task cannot
> be killed because admin has a separate sysrq for that purpose.
> 
> Let's pull forced OOM killer code out into a separate function
> (force_out_of_memory) which is really trivial now. Also extract the core
> of oom_kill_process into __oom_kill_process which doesn't do any
> OOM prevention heuristics.
> As a bonus we can clearly state that this is a forced OOM killer in the
> OOM message which is helpful to distinguish it from the regular OOM
> killer.
> 

I'm not sure what the benefit of this is, and it's adding more code.  
Having multiple pathways and requirements, such as constrained_alloc(), to 
oom kill a process isn't any clearer, in my opinion.  It also isn't 
intended to be optimized since the oom killer called from the page 
allocator and from sysrq aren't fastpaths.  To me, this seems like only a 
source code level change and doesn't make anything more clear but rather 
adds more code and obfuscates the entry path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
