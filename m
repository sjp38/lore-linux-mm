Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C7A4E6B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 15:00:45 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id w63so5425329qkd.0
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 12:00:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q14sor8488636ywl.200.2017.10.02.12.00.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 12:00:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171002122434.llbaarb6yw3o3mx3@dhcp22.suse.cz>
References: <20170926112134.r5eunanjy7ogjg5n@dhcp22.suse.cz>
 <20170926121300.GB23139@castle.dhcp.TheFacebook.com> <20170926133040.uupv3ibkt3jtbotf@dhcp22.suse.cz>
 <20170926172610.GA26694@cmpxchg.org> <CAAAKZws88uF2dVrXwRV0V6AH5X68rWy7AfJxTxYjpuiyiNJFWA@mail.gmail.com>
 <20170927074319.o3k26kja43rfqmvb@dhcp22.suse.cz> <CAAAKZws2CFExeg6A9AzrGjiHnFHU1h2xdk6J5Jw2kqxy=V+_YQ@mail.gmail.com>
 <20170927162300.GA5623@castle.DHCP.thefacebook.com> <CAAAKZwtApj-FgRc2V77nEb3BUd97Rwhgf-b-k0zhf1u+Y4fqxA@mail.gmail.com>
 <CALvZod7iaOEeGmDJA0cZvJWpuzc-hMRn3PG2cfzcMniJtAjKqA@mail.gmail.com> <20171002122434.llbaarb6yw3o3mx3@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 2 Oct 2017 12:00:43 -0700
Message-ID: <CALvZod65LYZZYy6uE=DQaQRPXYAhAci=NMG_w=ZANPGATgRwfg@mail.gmail.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tim Hockin <thockin@hockin.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

> Yes and nobody is disputing that, really. I guess the main disconnect
> here is that different people want to have more detailed control over
> the victim selection while the patchset tries to handle the most
> simplistic scenario when a no userspace control over the selection is
> required. And I would claim that this will be a last majority of setups
> and we should address it first.

IMHO the disconnect/disagreement is which memcgs should be compared
with each other for oom victim selection. Let's forget about oom
priority and just take size into the account. Should the oom selection
algorithm, compare the leaves of the hierarchy or should it compare
siblings? For the single user system, comparing leaves makes sense
while in a multi user system, siblings should be compared for victim
selection.

Coming back to the same example:

       root
       /    \
     A      D
     / \
   B   C

Let's view it as a multi user system and some central job scheduler
has asked a node controller on this system to start two jobs 'A' &
'D'. 'A' then went on to create sub-containers. Now, on system oom,
IMO the most simple sensible thing to do from the semantic point of
view is to compare 'A' and 'D' and if 'A''s usage is higher then
killall 'A' if oom_group or recursively find victim memcg taking 'A'
as root.

I have noted before that for single user systems, comparing 'B', 'C' &
'D' is the most sensible thing to do.

Now, in the multi user system, I can kind of force the comparison of
'A' & 'D' by setting oom_group on 'A'. IMO that is abuse of
'oom_group' as it will get double meanings/semantics which are
comparison leader and killall. I would humbly suggest to have two
separate notions instead. Let's say oom_gang (if you prefer just
'oom_group' is fine too) and killall.

For the single user system example, 'B', 'C' and 'D' will have
'oom_gang' set and if the user wants killall semantics too, he can set
it separately.

For the multi user, 'A' and 'D' will have 'oom_gang' set. Now, lets
say 'A' was selected on system oom, if 'killall' was set on 'A' then
'A' will be selected as victim otherwise the oom selection algorithm
will recursively take 'A' as root and try to find victim memcg.

Another major semantic of 'oom_gang' is that the leaves will always be
treated as 'oom_gang'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
