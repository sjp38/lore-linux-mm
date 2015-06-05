Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id A90F2900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 07:13:06 -0400 (EDT)
Received: by wiam3 with SMTP id m3so15522420wia.1
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 04:13:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tm3si12737261wjc.126.2015.06.05.04.13.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Jun 2015 04:13:04 -0700 (PDT)
Date: Fri, 5 Jun 2015 13:13:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: always panic on OOM when panic_on_oom is configured
Message-ID: <20150605111302.GB26113@dhcp22.suse.cz>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 04-06-15 16:12:27, David Rientjes wrote:
> On Mon, 1 Jun 2015, Michal Hocko wrote:
> 
> > panic_on_oom allows administrator to set OOM policy to panic the system
> > when it is out of memory to reduce failover time e.g. when resolving
> > the OOM condition would take much more time than rebooting the system.
> > 
> > out_of_memory tries to be clever and prevent from premature panics
> > by checking the current task and prevent from panic when the task
> > has fatal signal pending and so it should die shortly and release some
> > memory. This is fair enough but Tetsuo Handa has noted that this might
> > lead to a silent deadlock when current cannot exit because of
> > dependencies invisible to the OOM killer.
> > 
> > panic_on_oom is disabled by default and if somebody enables it then any
> > risk of potential deadlock is certainly unwelcome. The risk is really
> > low because there are usually more sources of allocation requests and
> > one of them would eventually trigger the panic but it is better to
> > reduce the risk as much as possible.
> > 
> > Let's move check_panic_on_oom up before the current task is
> > checked so that the knob value is . Do the same for the memcg in
> > mem_cgroup_out_of_memory.
> > 
> > Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Nack, this is not the appropriate response to exit path livelocks.  By 
> doing this, you are going to start unnecessarily panicking machines that 
> have panic_on_oom set when it would not have triggered before.  If there 
> is no reclaimable memory and a process that has already been signaled to 
> die to is in the process of exiting has to allocate memory, it is 
> perfectly acceptable to give them access to memory reserves so they can 
> allocate and exit.  Under normal circumstances, that allows the process to 
> naturally exit.  With your patch, it will cause the machine to panic.

Isn't that what the administrator of the system wants? The system
is _clearly_ out of memory at this point. A coincidental exiting task
doesn't change a lot in that regard. Moreover it increases a risk of
unnecessarily unresponsive system which is what panic_on_oom tries to
prevent from. So from my POV this is a clear violation of the user
policy.

> It's this simple: panic_on_oom is not a solution to workaround oom killer 
> livelocks and shouldn't be suggested as the canonical way that such 
> possibilities should be addressed.

I wasn't suggesting that at all.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
