Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 563F16B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 17:03:46 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id p186so6912900ioe.9
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 14:03:46 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y200sor3176251iof.12.2017.10.26.14.03.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Oct 2017 14:03:44 -0700 (PDT)
Date: Thu, 26 Oct 2017 14:03:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RESEND v12 0/6] cgroup-aware OOM killer
In-Reply-To: <20171026142445.GA21147@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1710261359550.75887@chino.kir.corp.google.com>
References: <20171019185218.12663-1-guro@fb.com> <20171019194534.GA5502@cmpxchg.org> <alpine.DEB.2.10.1710221715010.70210@chino.kir.corp.google.com> <20171026142445.GA21147@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>

On Thu, 26 Oct 2017, Johannes Weiner wrote:

> > The nack is for three reasons:
> > 
> >  (1) unfair comparison of root mem cgroup usage to bias against that mem 
> >      cgroup from oom kill in system oom conditions,
> > 
> >  (2) the ability of users to completely evade the oom killer by attaching
> >      all processes to child cgroups either purposefully or unpurposefully,
> >      and
> > 
> >  (3) the inability of userspace to effectively control oom victim  
> >      selection.
> 
> My apologies if my summary was too reductionist.
> 
> That being said, the arguments you repeat here have come up in
> previous threads and been responded to. This doesn't change my
> conclusion that your NAK is bogus.
> 

They actually haven't been responded to, Roman was working through v11 and 
made a change on how the root mem cgroup usage was calculated that was 
better than previous iterations but still not an apples to apples 
comparison with other cgroups.  The problem is that it the calculation for 
leaf cgroups includes additional memory classes, so it biases against 
processes that are moved to non-root mem cgroups.  Simply creating mem 
cgroups and attaching processes should not independently cause them to 
become more preferred: it should be a fair comparison between the root mem 
cgroup and the set of leaf mem cgroups as implemented.  That is very 
trivial to do with hierarchical oom cgroup scoring.

Since the ability of userspace to control oom victim selection is not 
addressed whatsoever by this patchset, and the suggested method cannot be 
implemented on top of this patchset as you have argued because it requires 
a change to the heuristic itself, the patchset needs to become complete 
before being mergeable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
