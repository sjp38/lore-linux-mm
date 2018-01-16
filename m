Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 88FB528024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 16:36:24 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id f67so4926768itf.2
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:36:24 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 4sor1484122itk.82.2018.01.16.13.36.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 13:36:23 -0800 (PST)
Date: Tue, 16 Jan 2018 13:36:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
In-Reply-To: <20180115115433.GA22473@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1801161323550.242486@chino.kir.corp.google.com>
References: <20171130152824.1591-1-guro@fb.com> <20171130123930.cf3217c816fd270fa35a40cb@linux-foundation.org> <alpine.DEB.2.10.1801091556490.173445@chino.kir.corp.google.com> <20180110131143.GB26913@castle.DHCP.thefacebook.com>
 <20180110113345.54dd571967fd6e70bfba68c3@linux-foundation.org> <20180111090809.GW1732@dhcp22.suse.cz> <20180111131845.GA13726@castle.DHCP.thefacebook.com> <alpine.DEB.2.10.1801121331110.120129@chino.kir.corp.google.com>
 <20180115115433.GA22473@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 15 Jan 2018, Michal Hocko wrote:

> > No, this isn't how kernel features get introduced.  We don't design a new 
> > kernel feature with its own API for a highly specialized usecase and then 
> > claim we'll fix the problems later.  Users will work around the 
> > constraints of the new feature, if possible, and then we can end up 
> > breaking them later.  Or, we can pollute the mem cgroup v2 filesystem with 
> > even more tunables to cover up for mistakes in earlier designs.
> 
> This is a blatant misinterpretation of the proposed changes. I haven't
> heard _any_ single argument against the proposed user interface except
> for complaints for missing tunables. This is not how the kernel
> development works and should work. The usecase was clearly described and
> far from limited to a single workload or company.
>  

The complaint about the user interface is that it is not extensible, as my 
next line states.  This doesn't need to be opted into with a mount option 
locking the entire system into a single oom policy.  That, itself, is the 
result of a poor design.  What is needed is a way for users to define an 
oom policy that is generally useful, not something that is locked in for 
the whole system.  We don't need several different cgroup mount options 
only for mem cgroup oom policies.  We also don't need random 
memory.groupoom files being added to the mem cgroup v2 filesystem only for 
one or two particular policies and being no-ops otherwise.  It can easily 
be specified as part of the policy itself.  My suggestion adds two new 
files to the mem cgroup v2 filesystem and no mount option, and allows any 
policy to be added later that only uses these two files.  I see you've 
ignored all of that in this email, so perhaps reading it would be 
worthwhile so that you can provide constructive feedback.

> > The key point to all three of my objections: extensibility.
> 
> And it has been argued that further _features_ can be added on top. I am
> absolutely fed up discussing those things again and again without any
> progress. You simply keep _ignoring_ counter arguments and that is a
> major PITA to be honest with you. You are basically blocking a useful
> feature because it doesn't solve your particular workload. This is
> simply not acceptable in the kernel development.
> 

As the thread says, this has nothing to do with my own particular 
workload, it has to do with three obvious shortcomings in the design that 
the user has no control over.  We can't add features on top if the 
heuristic itself changes as a result of the proposal, it needs to be 
introduced in an extensible way so that additional changes can be made 
later, if necessary, while still working around the very obvious problems 
with this current implementation.  My suggestion is that we introduce a 
way to define the oom policy once so that we don't have to change it later 
and are left with needless mount options or mem cgroup v2 files that 
become no-ops with the suggested design.  I hope that you will read the 
proposal for that extensible interface and comment on it about any 
concerns that you have, because that feedback would generally be useful.

> > Both you and Michal have acknowledged blantently obvious shortcomings in 
> > the design.
> 
> What you call blatant shortcomings we do not see affecting any
> _existing_ workloads. If they turn out to be real issues then we can fix
> them without deprecating any user APIs added by this patchset.
> 

There are existing workloads that use mem cgroup subcontainers purely for 
tracking charging and vmscan stats, which results in this logic being 
evaded.  It's a real issue, and a perfectly acceptable usecase for mem 
cgroup.  It's a result of the entire oom policy either being opted into or 
opted out of for the entire system and impossible for the user to 
configure or avoid.  That can be done better by enabling the oom policy 
only for a subtree, as I've suggested, but you've ignored.  It would also 
render both the mount option and the additional file in the mem cgroup v2 
filesystem added by this patchset to be no-ops.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
