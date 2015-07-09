Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id DCEF46B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 06:05:46 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so237238678wib.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 03:05:46 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id fz8si4343477wjb.67.2015.07.09.03.05.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 03:05:45 -0700 (PDT)
Received: by wifm2 with SMTP id m2so13700805wif.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 03:05:44 -0700 (PDT)
Date: Thu, 9 Jul 2015 12:05:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] oom: split out forced OOM killer
Message-ID: <20150709100541.GD13872@dhcp22.suse.cz>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com>
 <1436360661-31928-5-git-send-email-mhocko@suse.com>
 <alpine.DEB.2.10.1507081638290.16585@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507081638290.16585@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 08-07-15 16:41:23, David Rientjes wrote:
> On Wed, 8 Jul 2015, Michal Hocko wrote:
> 
> > From: Michal Hocko <mhocko@suse.cz>
> > 
> > The forced OOM killing is currently wired into out_of_memory() call
> > even though their objective is different which makes the code ugly
> > and harder to follow. Generic out_of_memory path has to deal with
> > configuration settings and heuristics which are completely irrelevant
> > to the forced OOM killer (e.g. sysctl_oom_kill_allocating_task or
> > OOM killer prevention for already dying tasks). All of them are
> > either relying on explicit force_kill check or indirectly by checking
> > current->mm which is always NULL for sysrq+f. This is not nice, hard
> > to follow and error prone.
> > 
> > Let's pull forced OOM killer code out into a separate function
> > (force_out_of_memory) which is really trivial now.
> > As a bonus we can clearly state that this is a forced OOM killer
> > in the OOM message which is helpful to distinguish it from the
> > regular OOM killer.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> It's really absurd that we have to go through this over and over and that 
> your patches are actually being merged into -mm just because you don't get 
> the point.
> 
> We have no need for a force_out_of_memory() function.  None whatsoever.  

The reasons are explained in the changelog and I do not see a single
argument against any of them.

> Keeping oc->force_kill around is just more pointless space on a very deep 
> stack and I'm tired of fixing stack overflows.

This just doesn't make any sense. oc->force_kill vs oc->order =
-1 replacement is completely independent on this patch and can be
implemented on top of it if you really insist.

> I'm certainly not going to 
> introduce others because you think it looks cleaner in the code when 
> memory compaction does the exact same thing by using cc->order == -1 to 
> mean explicit compaction.
> 
> This is turning into a complete waste of time.

You know what? I am tired of your complete immunity to any arguments and
the way how you are pushing more hacks into an already cluttered code.

out_of_memory is a giant mess wrt. to force killing and you can see
at least two different bugs being there just because of the code
obfuscation. If this is the state that you want to keep, I do not
care. I wanted to fix real issues and do a clean up on top. You seem to
do anything to block that. I just give up.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
