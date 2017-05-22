Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA0BB831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 08:09:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 204so24876739wmy.1
        for <linux-mm@kvack.org>; Mon, 22 May 2017 05:09:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a66si13402519wrc.296.2017.05.22.05.09.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 22 May 2017 05:09:43 -0700 (PDT)
Date: Mon, 22 May 2017 14:09:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] dm ioctl: Restore __GFP_HIGH in copy_params()
Message-ID: <20170522120937.GI8509@dhcp22.suse.cz>
References: <20170518185040.108293-1-junaids@google.com>
 <20170518190406.GB2330@dhcp22.suse.cz>
 <alpine.DEB.2.10.1705181338090.132717@chino.kir.corp.google.com>
 <1508444.i5EqlA1upv@js-desktop.svl.corp.google.com>
 <20170519074647.GC13041@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705191934340.17646@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522093725.GF8509@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705220759001.27401@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1705220759001.27401@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Junaid Shahid <junaids@google.com>, David Rientjes <rientjes@google.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, andreslc@google.com, gthelen@google.com, vbabka@suse.cz, linux-kernel@vger.kernel.org

On Mon 22-05-17 08:00:11, Mikulas Patocka wrote:
> 
> 
> On Mon, 22 May 2017, Michal Hocko wrote:
> 
> > On Fri 19-05-17 19:43:23, Mikulas Patocka wrote:
> > > 
> > > 
> > > On Fri, 19 May 2017, Michal Hocko wrote:
> > > 
> > > > On Thu 18-05-17 19:50:46, Junaid Shahid wrote:
> > > > > (Adding back the correct linux-mm email address and also adding linux-kernel.)
> > > > > 
> > > > > On Thursday, May 18, 2017 01:41:33 PM David Rientjes wrote:
> > > > [...]
> > > > > > Let's ask Mikulas, who changed this from PF_MEMALLOC to __GFP_HIGH, 
> > > > > > assuming there was a reason to do it in the first place in two different 
> > > > > > ways.
> > > > 
> > > > Hmm, the old PF_MEMALLOC used to have the following comment
> > > >         /*
> > > >          * Trying to avoid low memory issues when a device is
> > > >          * suspended. 
> > > >          */
> > > > 
> > > > I am not really sure what that means but __GFP_HIGH certainly have a
> > > > different semantic than PF_MEMALLOC. The later grants the full access to
> > > > the memory reserves while the prior on partial access. If this is _really_
> > > > needed then it deserves a comment explaining why.
> > > > -- 
> > > > Michal Hocko
> > > > SUSE Labs
> > > 
> > > Sometimes, I/O to a device mapper device is blocked until the userspace 
> > > daemon dmeventd does some action (for example, when dm-mirror leg fails, 
> > > dmeventd needs to mark the leg as failed in the lvm metadata and then 
> > > reload the device).
> > > 
> > > The dmeventd daemon mlocks itself in memory so that it doesn't generate 
> > > any I/O. But it must be able to call ioctls. __GFP_HIGH is there so that 
> > > the ioctls issued by dmeventd have higher chance of succeeding if some I/O 
> > > is blocked, waiting for dmeventd action. It reduces the possibility of 
> > > low-memory-deadlock, though it doesn't eliminate it entirely.
> > 
> > So what happens if the memory reserves are depleted. Do we deadlock?
> 
> Yes, it will deadlock.

That would be more than unfortunate and begs for a different solution.
The thing is that __GFP_HIGH is not propagated to all allocations in the
vmalloc proper. E.g. page table allocations are hardcoded GFP_KERNEL.

> > Why is OOM killer insufficient to allow the further progress?
> 
> I don't know if the OOM killer will or won't be triggered in this 
> situation, it depends on the people who wrote the OOM killer.

I am not sure I understand. OOM killer is invoked for _all_ allocations
<= PAGE_ALLOC_COSTLY_ORDER that do not have __GFP_NORETRY as long as the
OOM killer is not disabled (oom_killer_disable) and that only happens
from the PM suspend path which makes sure that no userspace is active at
the time. AFAIU this is a userspace triggered path and so the later
shouldn't apply to it and GFP_KERNEL should be therefore sufficient.
Relying to a portion of memory reserves to prevent from deadlock seems
fundamentaly broken  to me.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
