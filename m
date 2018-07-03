Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5A67A6B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 03:08:10 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id k8-v6so1128684qtj.18
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 00:08:10 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v1-v6sor239260qth.29.2018.07.03.00.08.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 00:08:08 -0700 (PDT)
Date: Tue, 03 Jul 2018 00:08:05 -0700
In-Reply-To: <20180702100301.GC19043@dhcp22.suse.cz>
Message-Id: <xr938t6skd9m.fsf@gthelen.svl.corp.google.com>
Mime-Version: 1.0
References: <20180628151101.25307-1-mhocko@kernel.org> <xr93in62jy8k.fsf@gthelen.svl.corp.google.com>
 <20180629072132.GA13860@dhcp22.suse.cz> <xr93bmbtju6f.fsf@gthelen.svl.corp.google.com>
 <20180702100301.GC19043@dhcp22.suse.cz>
Subject: Re: [PATCH] memcg, oom: move out_of_memory back to the charge path
From: Greg Thelen <gthelen@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 29-06-18 11:59:04, Greg Thelen wrote:
>> Michal Hocko <mhocko@kernel.org> wrote:
>> 
>> > On Thu 28-06-18 16:19:07, Greg Thelen wrote:
>> >> Michal Hocko <mhocko@kernel.org> wrote:
>> > [...]
>> >> > +	if (mem_cgroup_out_of_memory(memcg, mask, order))
>> >> > +		return OOM_SUCCESS;
>> >> > +
>> >> > +	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
>> >> > +		"This looks like a misconfiguration or a kernel bug.");
>> >> 
>> >> I'm not sure here if the warning should here or so strongly worded.  It
>> >> seems like the current task could be oom reaped with MMF_OOM_SKIP and
>> >> thus mem_cgroup_out_of_memory() will return false.  So there's nothing
>> >> alarming in that case.
>> >
>> > If the task is reaped then its charges should be released as well and
>> > that means that we should get below the limit. Sure there is some room
>> > for races but this should be still unlikely. Maybe I am just
>> > underestimating though.
>> >
>> > What would you suggest instead?
>> 
>> I suggest checking MMF_OOM_SKIP or deleting the warning.
>
> So what do you do when you have MMF_OOM_SKIP task? Do not warn? Checking
> for all the tasks would be quite expensive and remembering that from the
> task selection not nice either. Why do you think it would help much?

I assume we could just check current's MMF_OOM_SKIP - no need to check
all tasks.  My only (minor) objection is that the warning text suggests
misconfiguration or kernel bug, when there may be neither.

> I feel strongly that we have to warn when bypassing the charge limit
> during the corner case because it can lead to unexpected behavior and
> users should be aware of this fact. I am open to the wording or some
> optimizations. I would prefer the latter on top with a clear description
> how it helped in a particular case though. I would rather not over
> optimize now without any story to back it.

I'm fine with the warning.  I know enough to look at dmesg logs to take
an educates that the race occurred.  We can refine it later if/when the
reports start rolling in.  No change needed.
