Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3D2E831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 10:52:52 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id x53so51681101qtx.14
        for <linux-mm@kvack.org>; Mon, 22 May 2017 07:52:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 37si10959856qts.117.2017.05.22.07.52.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 07:52:52 -0700 (PDT)
Date: Mon, 22 May 2017 10:52:44 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] dm ioctl: Restore __GFP_HIGH in copy_params()
In-Reply-To: <20170522120937.GI8509@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1705221026430.20076@file01.intranet.prod.int.rdu2.redhat.com>
References: <20170518185040.108293-1-junaids@google.com> <20170518190406.GB2330@dhcp22.suse.cz> <alpine.DEB.2.10.1705181338090.132717@chino.kir.corp.google.com> <1508444.i5EqlA1upv@js-desktop.svl.corp.google.com> <20170519074647.GC13041@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705191934340.17646@file01.intranet.prod.int.rdu2.redhat.com> <20170522093725.GF8509@dhcp22.suse.cz> <alpine.LRH.2.02.1705220759001.27401@file01.intranet.prod.int.rdu2.redhat.com> <20170522120937.GI8509@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Junaid Shahid <junaids@google.com>, David Rientjes <rientjes@google.com>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, andreslc@google.com, gthelen@google.com, vbabka@suse.cz, linux-kernel@vger.kernel.org



On Mon, 22 May 2017, Michal Hocko wrote:

> On Mon 22-05-17 08:00:11, Mikulas Patocka wrote:
> > 
> > On Mon, 22 May 2017, Michal Hocko wrote:
> > 
> > > > Sometimes, I/O to a device mapper device is blocked until the userspace 
> > > > daemon dmeventd does some action (for example, when dm-mirror leg fails, 
> > > > dmeventd needs to mark the leg as failed in the lvm metadata and then 
> > > > reload the device).
> > > > 
> > > > The dmeventd daemon mlocks itself in memory so that it doesn't generate 
> > > > any I/O. But it must be able to call ioctls. __GFP_HIGH is there so that 
> > > > the ioctls issued by dmeventd have higher chance of succeeding if some I/O 
> > > > is blocked, waiting for dmeventd action. It reduces the possibility of 
> > > > low-memory-deadlock, though it doesn't eliminate it entirely.
> > > 
> > > So what happens if the memory reserves are depleted. Do we deadlock?
> > 
> > Yes, it will deadlock.
> 
> That would be more than unfortunate and begs for a different solution.
> The thing is that __GFP_HIGH is not propagated to all allocations in the
> vmalloc proper. E.g. page table allocations are hardcoded GFP_KERNEL.

For a typical device mapper use, the ioctl area is smaller than 4k, so the 
vmalloc won't happen.

> > > Why is OOM killer insufficient to allow the further progress?
> > 
> > I don't know if the OOM killer will or won't be triggered in this 
> > situation, it depends on the people who wrote the OOM killer.
> 
> I am not sure I understand. OOM killer is invoked for _all_ allocations
> <= PAGE_ALLOC_COSTLY_ORDER that do not have __GFP_NORETRY as long as the
> OOM killer is not disabled (oom_killer_disable) and that only happens
> from the PM suspend path which makes sure that no userspace is active at
> the time. AFAIU this is a userspace triggered path and so the later
> shouldn't apply to it and GFP_KERNEL should be therefore sufficient.
> Relying to a portion of memory reserves to prevent from deadlock seems
> fundamentaly broken  to me.
> 
> -- 
> Michal Hocko
> SUSE Labs

The lvm2 was designed this way - it is broken, but there is not much that 
can be done about it - fixing this would mean major rewrite. The only 
thing we can do about it is to lower the deadlock probability with 
__GFP_HIGH (or PF_MEMALLOC that was used some times ago).

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
