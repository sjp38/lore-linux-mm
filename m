Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5203C6B0253
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 04:23:09 -0400 (EDT)
Received: by wgck11 with SMTP id k11so216737753wgc.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 01:23:09 -0700 (PDT)
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id el9si7782423wid.119.2015.07.09.01.23.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 01:23:07 -0700 (PDT)
Received: by wgjx7 with SMTP id x7so216380874wgj.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 01:23:07 -0700 (PDT)
Date: Thu, 9 Jul 2015 10:23:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] oom: Do not panic when OOM killer is sysrq triggered
Message-ID: <20150709082304.GA13872@dhcp22.suse.cz>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com>
 <1436360661-31928-2-git-send-email-mhocko@suse.com>
 <alpine.DEB.2.10.1507081635030.16585@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507081635030.16585@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 08-07-15 16:36:14, David Rientjes wrote:
> On Wed, 8 Jul 2015, Michal Hocko wrote:
> 
> > From: Michal Hocko <mhocko@suse.cz>
> > 
> > OOM killer might be triggered explicitly via sysrq+f. This is supposed
> > to kill a task no matter what e.g. a task is selected even though there
> > is an OOM victim on the way to exit. This is a big hammer for an admin
> > to help to resolve a memory short condition when the system is not able
> > to cope with it on its own in a reasonable time frame (e.g. when the
> > system is trashing or the OOM killer cannot make sufficient progress)
> > 
> > E.g. it doesn't make any sense to obey panic_on_oom setting because
> > a) administrator could have used other sysrqs to achieve the
> > panic/reboot and b) the policy would break an existing usecase to
> > kill a memory hog which would be recoverable unlike the panic which
> > might be configured for the real OOM condition.
> > 
> > It also doesn't make much sense to panic the system when there is no
> > OOM killable task because administrator might choose to do additional
> > steps before rebooting/panicking the system.
> > 
> > While we are there also add a comment explaining why
> > sysctl_oom_kill_allocating_task doesn't apply to sysrq triggered OOM
> > killer even though there is no explicit check and we subtly rely
> > on current->mm being NULL for the context from which it is triggered.
> > 
> > Also be more explicit about sysrq+f behavior in the documentation.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Nack, this is already handled by patch 2 in my series.  I understand that 

I guess you mean patch#3

> the titles were wrong for patches 2 and 3, but it doesn't mean we need to 
> add hacks around the code before organizing this into struct oom_control 

It is much easier to backport _fixes_ into older kernels (and yes I do
care about that) if they do not depend on other cleanups. So I do not
understand your point here. Besides that the cleanup really didn't make
much change to the actuall fix because one way or another you still have
to add a simple condition to rule out a heuristic/configuration which
doesn't apply to sysrq+f path.

So I am really lost in your argumentation here.

> or completely pointless comments and printks that will fill the kernel 
> log.

Could you explain what is so pointless about a comment which clarifies
the fact which is not obviously visible from the current function?

Also could you explain why the admin shouldn't get an information if
sysrq+f didn't kill anything because no eligible task has been found?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
