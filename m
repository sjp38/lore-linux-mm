Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id B82186B0032
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 17:34:01 -0500 (EST)
Received: by mail-ie0-f182.google.com with SMTP id x19so14056333ier.13
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 14:34:01 -0800 (PST)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com. [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id y90si1555662ioi.88.2014.12.16.14.33.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Dec 2014 14:34:00 -0800 (PST)
Received: by mail-ie0-f170.google.com with SMTP id rd18so14046432iec.1
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 14:33:59 -0800 (PST)
Date: Tue, 16 Dec 2014 14:33:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg: Provide knob for force OOM into the memcg
In-Reply-To: <20141216133935.GK22914@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1412161430040.5142@chino.kir.corp.google.com>
References: <1418736335-30915-1-git-send-email-cpandya@codeaurora.org> <20141216133935.GK22914@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Chintan Pandya <cpandya@codeaurora.org>, hannes@cmpxchg.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 16 Dec 2014, Michal Hocko wrote:

> > We may want to use memcg to limit the total memory
> > footprint of all the processes within the one group.
> > This may lead to a situation where any arbitrary
> > process cannot get migrated to that one  memcg
> > because its limits will be breached. Or, process can
> > get migrated but even being most recently used
> > process, it can get killed by in-cgroup OOM. To
> > avoid such scenarios, provide a convenient knob
> > by which we can forcefully trigger OOM and make
> > a room for upcoming process.
> > 
> > To trigger force OOM,
> > $ echo 1 > /<memcg_path>/memory.force_oom
> 
> What would prevent another task deplete that memory shortly after you
> triggered OOM and end up in the same situation? E.g. while the moving
> task is migrating its charges to the new group...
> 
> Why cannot you simply disable OOM killer in that memcg and handle it
> from userspace properly?
> 

The patch is introducing a mechanism to induce a kernel oom kill for a 
memcg hierarchy to make room for it in the new memcg, not disable the oom 
killer so the migration fails due to the lower limits.

It doesn't have any basis since a SIGKILL coming from userspace should be 
considered the same as a kernel oom kill from the memcg perspective, i.e. 
the fatal_signal_pending() checks that allow charge bypass instead of a 
strict reliance on TIF_MEMDIE being set.

It seems to be proposed as a shortcut so that the kernel will determine 
the best process to kill.  That information is available to userspace so 
it should be able to just SIGKILL the desired process (either in the 
destination memcg or in the source memcg to allow deletion), so this 
functionality isn't needed in the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
