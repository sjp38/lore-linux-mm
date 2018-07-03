Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC2A6B0007
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 19:29:04 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id i127-v6so3858225qkc.22
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 16:29:04 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v21-v6sor1212657qvf.16.2018.07.03.16.29.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 16:29:03 -0700 (PDT)
Date: Tue, 03 Jul 2018 16:29:00 -0700
In-Reply-To: <20180703071658.GC16767@dhcp22.suse.cz>
Message-Id: <xr93woubj3ur.fsf@gthelen.svl.corp.google.com>
Mime-Version: 1.0
References: <20180628151101.25307-1-mhocko@kernel.org> <xr93in62jy8k.fsf@gthelen.svl.corp.google.com>
 <20180629072132.GA13860@dhcp22.suse.cz> <xr93bmbtju6f.fsf@gthelen.svl.corp.google.com>
 <20180702100301.GC19043@dhcp22.suse.cz> <xr938t6skd9m.fsf@gthelen.svl.corp.google.com>
 <20180703071658.GC16767@dhcp22.suse.cz>
Subject: Re: [PATCH] memcg, oom: move out_of_memory back to the charge path
From: Greg Thelen <gthelen@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 03-07-18 00:08:05, Greg Thelen wrote:
>> Michal Hocko <mhocko@kernel.org> wrote:
>> 
>> > On Fri 29-06-18 11:59:04, Greg Thelen wrote:
>> >> Michal Hocko <mhocko@kernel.org> wrote:
>> >> 
>> >> > On Thu 28-06-18 16:19:07, Greg Thelen wrote:
>> >> >> Michal Hocko <mhocko@kernel.org> wrote:
>> >> > [...]
>> >> >> > +	if (mem_cgroup_out_of_memory(memcg, mask, order))
>> >> >> > +		return OOM_SUCCESS;
>> >> >> > +
>> >> >> > +	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
>> >> >> > +		"This looks like a misconfiguration or a kernel bug.");
>> >> >> 
>> >> >> I'm not sure here if the warning should here or so strongly worded.  It
>> >> >> seems like the current task could be oom reaped with MMF_OOM_SKIP and
>> >> >> thus mem_cgroup_out_of_memory() will return false.  So there's nothing
>> >> >> alarming in that case.
>> >> >
>> >> > If the task is reaped then its charges should be released as well and
>> >> > that means that we should get below the limit. Sure there is some room
>> >> > for races but this should be still unlikely. Maybe I am just
>> >> > underestimating though.
>> >> >
>> >> > What would you suggest instead?
>> >> 
>> >> I suggest checking MMF_OOM_SKIP or deleting the warning.
>> >
>> > So what do you do when you have MMF_OOM_SKIP task? Do not warn? Checking
>> > for all the tasks would be quite expensive and remembering that from the
>> > task selection not nice either. Why do you think it would help much?
>> 
>> I assume we could just check current's MMF_OOM_SKIP - no need to check
>> all tasks.
>
> I still do not follow. If you are after a single task memcg then we
> should be ok. try_charge has a runaway for oom victims
> 	if (unlikely(tsk_is_oom_victim(current) ||
> 		     fatal_signal_pending(current) ||
> 		     current->flags & PF_EXITING))
> 		goto force;
>
> regardless of MMF_OOM_SKIP. So if there is a single process in the
> memcg, we kill it and the oom reaper kicks in and sets MMF_OOM_SKIP then
> we should bail out there. Or do I miss your intention?

For a single task memcg it seems that racing process cgroup migration
could trigger the new warning (I have attempted to reproduce this):

Processes A,B in memcg M1,M2.  M1 is oom.

  Process A[M1]               Process B[M2]

  M1 is oom
  try_charge(M1)
                              Move A M1=>M2
  mem_cgroup_oom()
  mem_cgroup_out_of_memory()
    out_of_memory()
      select_bad_process()
        sees nothing in M1
      return 0
    return 0
  WARN()


Another variant might be possible, this time with global oom:

Processes A,B in memcg M1,M2.  M1 is oom.

  Process A[M1]               Process B[M2]

  try_charge()
                              trigger global oom
                              reaper sets A.MMF_OOM_SKIP
  mem_cgroup_oom()
  mem_cgroup_out_of_memory()
    out_of_memory()
      select_bad_process()
        sees nothing in M1
      return 0
    return 0
  WARN()


These seem unlikely, so I'm fine with taking a wait-and-see approach.
