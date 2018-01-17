Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3CB526B0271
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 17:32:01 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id g81so19599634ioa.14
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 14:32:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q19sor3016829iod.149.2018.01.17.14.32.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 14:32:00 -0800 (PST)
Date: Wed, 17 Jan 2018 14:31:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 0/4] mm, memcg: introduce oom policies
In-Reply-To: <20180117114554.GA10523@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.10.1801171420330.86895@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com> <20180117114554.GA10523@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 17 Jan 2018, Roman Gushchin wrote:

> You're introducing a new oom_policy knob, which has two separate sets
> of possible values for the root and non-root cgroups. I don't think
> it aligns with the existing cgroup v2 design.
> 

The root mem cgroup can use "none" or "cgroup" to either disable or 
enable, respectively, the cgroup aware oom killer.  These are available to 
non root mem cgroups as well, with the addition of hierarchical usage 
comparison to prevent the ability to completely evade the oom killer by 
the user by creating sub cgroups.  Just as we have files that are made 
available on the root cgroup and not others, I think it's fine to allow 
only certain policies on the root mem cgroup.  As I wrote to Tejun, I'm 
fine with the policy being separated from the mechanism.  That can be 
resolved in that email thread, but the overall point of this patchset is 
to allow hierarchical comparison on some subtrees and not on others.  We 
can avoid the mount option in the same manner.

> For the root cgroup it works exactly as mount option, and both "none"
> and "cgroup" values have no meaning outside of the root cgroup. We can
> discuss if a knob on root cgroup is better than a mount option, or not
> (I don't think so), but it has nothing to do with oom policy as you
> define it for non-root cgroups.
> 

It certainly does have value outside of the root cgroup: for system oom 
conditions it is possible to choose the largest process, largest single 
cgroup, or largest subtree to kill from.  For memcg oom conditions it's 
possible for a consumer in a subtree to define whether it wants the 
largest memory hogging process to be oom killed or the largest of its 
child sub cgroups.  This would be needed for a job scheduler in its own 
subtree, for example, that creates its own subtrees to limit jobs 
scheduled by individual users who have the power over their subtree but 
not their limit.  This is a real-world example.  Michal also provided his 
own example concerning top-level /admins and /students.  They want to use 
"cgroup" themselves and then /students/roman would be forced to "tree".

Keep in mind that this patchset alone makes the interface extensible and 
addresses one of my big three concerns, but the comparison of the root mem 
cgroup compared to other individual cgroups and cgroups maintaining a 
subtree needs to be fixed separately so that we don't completely evade all 
of these oom policies by using /proc/pid/oom_score_adj in the root mem 
cgroup.  That's a separate issue that needs to be addressed.  My last 
concern, about userspace influence, can probably be addressed after this 
is merged by yet another tunable since it's vital that important cgroups 
can be protected.  It does make sense for an important cgroup to be able 
to use 50% of memory without being oom killed, and that's impossible if 
cgroup v2 has been mounted with your mount option.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
