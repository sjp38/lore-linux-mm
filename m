Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 80FB66B0253
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 15:56:52 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h70so6555320ioi.5
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 12:56:52 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l63sor3049383iol.240.2017.10.26.12.56.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Oct 2017 12:56:51 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
In-Reply-To: <20171026143140.GB21147@cmpxchg.org>
References: <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com> <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz> <20171025131151.GA8210@cmpxchg.org> <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz> <20171025164402.GA11582@cmpxchg.org> <20171025172924.i7du5wnkeihx2fgl@dhcp22.suse.cz> <20171025181106.GA14967@cmpxchg.org> <20171025190057.mqmnprhce7kvsfz7@dhcp22.suse.cz> <20171025211359.GA17899@cmpxchg.org> <xr931slqdery.fsf@gthelen.svl.corp.google.com> <20171026143140.GB21147@cmpxchg.org>
Date: Thu, 26 Oct 2017 12:56:48 -0700
Message-ID: <xr93y3nxbs3j.fsf@gthelen.svl.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Michal Hocko wrote:
> Greg Thelen wrote:
> > So a force charge fallback might be a needed even with oom killer successful
> > invocations.  Or we'll need to teach out_of_memory() to return three values
> > (e.g. NO_VICTIM, NEW_VICTIM, PENDING_VICTIM) and try_charge() can loop on
> > NEW_VICTIM.
> 
> No we, really want to wait for the oom victim to do its job. The only thing we
> should be worried about is when out_of_memory doesn't invoke the reaper. There
> is only one case like that AFAIK - GFP_NOFS request. I have to think about
> this case some more. We currently fail in that case the request.

Nod, but I think only wait a short time (more below).  The
schedule_timeout_killable(1) in out_of_memory() seems ok to me.  I don't
think there's a problem overcharging a little bit to expedite oom
killing.

Johannes Weiner wrote:
> True. I was assuming we'd retry MEM_CGROUP_RECLAIM_RETRIES times at a maximum,
> even if the OOM killer indicates a kill has been issued. What you propose
> makes sense too.

Sounds good.

It looks like the oom reaper will wait 1 second
(MAX_OOM_REAP_RETRIES*HZ/10) before giving up and setting MMF_OOM_SKIP,
which enables the oom killer to select another victim.  Repeated
try_charge() => out_of_memory() calls will return true while there's a
pending victim.  After the first call, out_of_memory() doesn't appear to
sleep.  So I assume try_charge() would quickly burn through
MEM_CGROUP_RECLAIM_RETRIES (5) attempts before resorting to
overcharging.  IMO, this is fine because:
1) it's possible the victim wants locks held by try_charge caller.  So
   waiting for the oom reaper to timeout and out_of_memory to select
   additional victims would kill more than required.
2) waiting 1 sec to detect a livelock between try_charge() and pending
   oom victim seems unfortunate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
