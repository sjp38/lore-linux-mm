Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E68556B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 04:33:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id j18-v6so6496929wme.5
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 01:33:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 50-v6si6516031edz.449.2018.06.19.01.33.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jun 2018 01:33:17 -0700 (PDT)
Date: Tue, 19 Jun 2018 10:33:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: fix unnecessary killing of additional processes
Message-ID: <20180619083316.GB13685@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com>
 <20180615065541.GA24039@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806151559360.49038@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1806151559360.49038@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 15-06-18 16:15:39, David Rientjes wrote:
[...]
> I'd be happy to make the this timeout configurable, however, and default 
> it to perhaps one second as the blockable mmu notifier timeout in your own 
> code does.  I find it somewhat sad that we'd need a sysctl for this, but 
> if that will appease you and it will help to move this into -mm then we 
> can do that.

No. This has been nacked in the past and I do not see anything different
from back than.

> > Other than that I've already pointed to a more robust solution. If you
> > are reluctant to try it out I will do, but introducing a timeout is just
> > papering over the real problem. Maybe we will not reach the state that
> > _all_ the memory is reapable but we definitely should try to make as
> > much as possible to be reapable and I do not see any fundamental
> > problems in that direction.
> 
> You introduced the timeout already, I'm sure you realized yourself that 
> the oom reaper sets MMF_OOM_SKIP much too early.  Trying to grab 
> mm->mmap_sem 10 times in a row with HZ/10 sleeps in between is a timeout.  

Yes, it is. And it is a timeout based some some feedback. The lock is
held, let's retry later but do not retry for ever. We can do the same
with blockable mmu notifiers. We are currently giving up right away. I
was proposing to add can_sleep parameter to mmu_notifier_invalidate_range_start
and return it EAGAIN if it would block. This would allow to simply retry
on EAGAIN like we do for the mmap_sem.

[...]
 
> The reproducer on powerpc is very simple.  Do an mmap() and mlock() the 
> length.  Fork one 120MB process that does that and two 60MB processes that 
> do that in a 128MB memcg.

And again, to solve this we just need to teach oom_reaper to handle
mlocked memory. There shouldn't be any fundamental reason why this would
be impossible AFAICS. Timeout is not a solution!

[...]

> It's inappropriate to merge code that oom kills many processes 
> unnecessarily when one happens to be mlocked or have blockable mmu 
> notifiers or when mm->mmap_sem can't be grabbed fast enough but forward 
> progress is actually being made.  It's a regression, and it impacts real 
> users.  Insisting that we fix the problem you introduced by making all mmu 
> notifiers unblockable and mlocked memory can always be reaped and 
> mm->mmap_sem can always be grabbed within a second is irresponsible.

Well, a lack of real world bug reports doesn't really back your story
here. I have asked about non-artificial workloads suffering and your
responsive were quite nonspecific to say the least.

And I do insist to come with a reasonable solution rather than random
hacks. Jeez the oom killer was full of these.

As I've said, if you are not willing to work on a proper solution, I
will, but my nack holds for this patch until we see no other way around
existing and real world problems.
-- 
Michal Hocko
SUSE Labs
