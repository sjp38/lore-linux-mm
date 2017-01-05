Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id E3C126B0261
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 15:27:14 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id c20so537223itb.5
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 12:27:14 -0800 (PST)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id q16si68008itc.58.2017.01.05.12.27.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 12:27:14 -0800 (PST)
Received: by mail-io0-x242.google.com with SMTP id n85so37612473ioi.1
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 12:27:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170105123341.GQ21618@dhcp22.suse.cz>
References: <bug-190841-27@https.bugzilla.kernel.org/> <20170104173037.7e501fdfee9ec21f0a3a5d55@linux-foundation.org>
 <20170105123341.GQ21618@dhcp22.suse.cz>
From: Vladyslav Frolov <frolvlad@gmail.com>
Date: Thu, 5 Jan 2017 22:26:53 +0200
Message-ID: <CAJABK0MAX2jz+U-00x1xM7EEFEe3_h-nwnEdG9axJKrzuqTBjQ@mail.gmail.com>
Subject: Re: [Bug 190841] New: [REGRESSION] Intensive Memory CGroup removal
 leads to high load average 10+
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

> I would expect older kernels would just refuse the create new cgroups... Maybe that happens in your script and just gets unnoticed?

I have been running a production service doing this "intensive"
cgroups creation and cleaning for over a year now and it just works
with 3.xx - 4.5 kernels (currently, I run it on an LTS 4.4 kernel),
triggering up to 100 CGroup creations/cleanings events per second
non-stop for months, and I haven't noticed any refuses in new cgroup
creations whatsoever even on 1GB RAM boxes.


> Even without memcg involved. Are there any strong reasons you cannot reuse an existing cgroup?

I run concurrent executions (I run cgmemtime
[https://github.com/gsauthof/cgmemtime] to measure high-water memory
usage of a group of processes), so I cannot reuse a single cgroup, and
I, currently, cannot maintain a pool of cgroups (it will add extra
complexity in my code, and will require cgmemtime patching, while
older kernels just worked fine). Do you believe there is no bug there
and it is just slow by design? There are a few odd things here:

1. 4.7+ kernels perform 20 times *slower* while postponing should in
theory speed things up due to "async" nature
2. Other cgroup creation/cleaning work like a charm, it is only
`memory` cgroup making my system overloaded


> echo 1 > $CGROUP_BASE/memory.force_empty

This didn't help at alll.

On 5 January 2017 at 14:33, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 04-01-17 17:30:37, Andrew Morton wrote:
>>
>> (switched to email.  Please respond via emailed reply-to-all, not via the
>> bugzilla web interface).
>>
>> On Wed, 21 Dec 2016 19:56:16 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
>>
>> > https://bugzilla.kernel.org/show_bug.cgi?id=190841
>> >
>> >             Bug ID: 190841
>> >            Summary: [REGRESSION] Intensive Memory CGroup removal leads to
>> >                     high load average 10+
>> >            Product: Memory Management
>> >            Version: 2.5
>> >     Kernel Version: 4.7.0-rc1+
>> >           Hardware: All
>> >                 OS: Linux
>> >               Tree: Mainline
>> >             Status: NEW
>> >           Severity: normal
>> >           Priority: P1
>> >          Component: Other
>> >           Assignee: akpm@linux-foundation.org
>> >           Reporter: frolvlad@gmail.com
>> >         Regression: No
>> >
>> > My simplified workflow looks like this:
>> >
>> > 1. Create a Memory CGroup with memory limit
>> > 2. Exec a child process
>> > 3. Add the child process PID into the Memory CGroup
>> > 4. Wait for the child process to finish
>> > 5. Remove the Memory CGroup
>> >
>> > The child processes usually run less than 0.1 seconds, but I have lots of them.
>> > Normally, I could run over 10000 child processes per minute, but with newer
>> > kernels, I can only do 400-500 executions per minute, and my system becomes
>> > extremely sluggish (the only indicator of the weirdness I found is an unusually
>> > high load average, which sometimes goes over 250!).
>
> Well, yes, rmdir is not the cheapest operation... Since b2052564e66d
> ("mm: memcontrol: continue cache reclaim from offlined groups") we are
> postponing the real memcg removal to later, when there is a memory
> pressure. 73f576c04b94 ("mm: memcontrol: fix cgroup creation failure
> after many small jobs") fixed unbound id space consumption. I would be
> quite surprised if this caused a new regression. But the report says
> that this is 4.7+ thing. I would expect older kernels would just refuse
> the create new cgroups... Maybe that happens in your script and just
> gets unnoticed?
>
> We might come up with some more harderning in the offline path (e.g.
> count the number of dead memcgs and force their reclaim after some
> number gets accumulated). But all that just adds more code and risk of
> regression for something that is not used very often. Cgroups
> creation/destruction are too heavy operations to be done for very
> shortlived process. Even without memcg involved. Are there any strong
> reasons you cannot reuse an existing cgroup?
>
>> > Here is a simple reproduction script:
>> >
>> > #!/bin/sh
>> > CGROUP_BASE=/sys/fs/cgroup/memory/qq
>> >
>> > for $i in $(seq 1000); do
>> >     echo "Iteration #$i"
>> >     sh -c "
>> >         mkdir '$CGROUP_BASE'
>> >         sh -c 'echo \$$ > $CGROUP_BASE/tasks ; sleep 0.0'
>
> one possible workaround would be to do
>             echo 1 > $CGROUP_BASE/memory.force_empty
>
> before you remove the cgroup. That should drop the existing charges - at
> least for the page cache which might be what keeps those memcgs alive.
>
>> >         rmdir '$CGROUP_BASE' || true
>> >     "
>> > done
>> > # ===
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
