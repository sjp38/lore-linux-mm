Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id DEDAC6B0253
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 04:55:09 -0400 (EDT)
Received: by wgjx7 with SMTP id x7so217107316wgj.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 01:55:09 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id q14si8593307wju.110.2015.07.09.01.55.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 01:55:08 -0700 (PDT)
Received: by wiclp1 with SMTP id lp1so103131009wic.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 01:55:07 -0700 (PDT)
Date: Thu, 9 Jul 2015 10:55:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/4] oom: Do not invoke oom notifiers on sysrq+f
Message-ID: <20150709085505.GB13872@dhcp22.suse.cz>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com>
 <1436360661-31928-3-git-send-email-mhocko@suse.com>
 <alpine.DEB.2.10.1507081636180.16585@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507081636180.16585@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 08-07-15 16:37:49, David Rientjes wrote:
> On Wed, 8 Jul 2015, Michal Hocko wrote:
> 
> > From: Michal Hocko <mhocko@suse.cz>
> > 
> > A github user rfjakob has reported the following issue via IRC.
> > <rfjakob> Manually triggering the OOM killer does not work anymore in 4.0.5
> > <rfjakob> This is what it looks like: https://gist.github.com/rfjakob/346b7dc611fc3cdf4011
> > <rfjakob> Basically, what happens is that the GPU driver frees some memory, that satisfies the OOM killer
> > <rfjakob> But the memory is allocated immediately again, and in the, no processes are killed no matter how often you trigger the oom killer
> > <rfjakob> "in the end"
> > 
> > Quoting from the github:
> > "
> > [19291.202062] sysrq: SysRq : Manual OOM execution
> > [19291.208335] Purging GPU memory, 74399744 bytes freed, 8728576 bytes still pinned.
> > [19291.390767] sysrq: SysRq : Manual OOM execution
> > [19291.396792] Purging GPU memory, 74452992 bytes freed, 8728576 bytes still pinned.
> > [19291.560349] sysrq: SysRq : Manual OOM execution
> > [19291.566018] Purging GPU memory, 75489280 bytes freed, 8728576 bytes still pinned.
> > [19291.729944] sysrq: SysRq : Manual OOM execution
> > [19291.735686] Purging GPU memory, 74399744 bytes freed, 8728576 bytes still pinned.
> > [19291.918637] sysrq: SysRq : Manual OOM execution
> > [19291.924299] Purging GPU memory, 74403840 bytes freed, 8728576 bytes still pinned.
> > "
> > 
> > The issue is that sysrq+f (force_kill) gets confused by the regular OOM
> > heuristic which tries to prevent from OOM killer if some of the oom
> > notifier can relase a memory. The heuristic doesn't make much sense for
> > the sysrq+f path because this one is used by the administrator to kill
> > a memory hog.
> > 
> > Reported-by: Jakob Unterwurzacher <jakobunt@gmail.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Nack, the oom notify list has no place in the oom killer, it should be 
> called in the page allocator before calling out_of_memory().  

I cannot say I would like oom notifiers interface. Quite contrary, it is
just a crude hack. It is living outside of the shrinker interface which is
what the reclaim is using and it acts like the last attempt before OOM
(e.g. i915_gem_shrinker_init registers both "shrinkers"). So I am not
sure it belongs outside of the oom killer proper.

Besides that out_of_memory already contains shortcuts to prevent killing
a task. Why is this any different? I mean why shouldn't callers of
out_of_memory check whether the task is killed or existing before
calling out_of_memory?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
