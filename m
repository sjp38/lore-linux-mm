Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E56316B0006
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 06:03:04 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b65-v6so9762984plb.5
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 03:03:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d10-v6si13636226pgo.630.2018.07.02.03.03.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 03:03:03 -0700 (PDT)
Date: Mon, 2 Jul 2018 12:03:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg, oom: move out_of_memory back to the charge path
Message-ID: <20180702100301.GC19043@dhcp22.suse.cz>
References: <20180628151101.25307-1-mhocko@kernel.org>
 <xr93in62jy8k.fsf@gthelen.svl.corp.google.com>
 <20180629072132.GA13860@dhcp22.suse.cz>
 <xr93bmbtju6f.fsf@gthelen.svl.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93bmbtju6f.fsf@gthelen.svl.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 29-06-18 11:59:04, Greg Thelen wrote:
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Thu 28-06-18 16:19:07, Greg Thelen wrote:
> >> Michal Hocko <mhocko@kernel.org> wrote:
> > [...]
> >> > +	if (mem_cgroup_out_of_memory(memcg, mask, order))
> >> > +		return OOM_SUCCESS;
> >> > +
> >> > +	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
> >> > +		"This looks like a misconfiguration or a kernel bug.");
> >> 
> >> I'm not sure here if the warning should here or so strongly worded.  It
> >> seems like the current task could be oom reaped with MMF_OOM_SKIP and
> >> thus mem_cgroup_out_of_memory() will return false.  So there's nothing
> >> alarming in that case.
> >
> > If the task is reaped then its charges should be released as well and
> > that means that we should get below the limit. Sure there is some room
> > for races but this should be still unlikely. Maybe I am just
> > underestimating though.
> >
> > What would you suggest instead?
> 
> I suggest checking MMF_OOM_SKIP or deleting the warning.

So what do you do when you have MMF_OOM_SKIP task? Do not warn? Checking
for all the tasks would be quite expensive and remembering that from the
task selection not nice either. Why do you think it would help much?

I feel strongly that we have to warn when bypassing the charge limit
during the corner case because it can lead to unexpected behavior and
users should be aware of this fact. I am open to the wording or some
optimizations. I would prefer the latter on top with a clear description
how it helped in a particular case though. I would rather not over
optimize now without any story to back it.
-- 
Michal Hocko
SUSE Labs
