Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 809D6831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 14:04:18 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id l128so90644783iol.12
        for <linux-mm@kvack.org>; Mon, 22 May 2017 11:04:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o126si19387223ioe.228.2017.05.22.11.04.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 11:04:17 -0700 (PDT)
Date: Mon, 22 May 2017 14:04:15 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: dm ioctl: Restore __GFP_HIGH in copy_params()
Message-ID: <20170522180415.GA25340@redhat.com>
References: <20170518190406.GB2330@dhcp22.suse.cz>
 <alpine.DEB.2.10.1705181338090.132717@chino.kir.corp.google.com>
 <1508444.i5EqlA1upv@js-desktop.svl.corp.google.com>
 <20170519074647.GC13041@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705191934340.17646@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522093725.GF8509@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705220759001.27401@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522120937.GI8509@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705221026430.20076@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522150321.GM8509@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170522150321.GM8509@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Junaid Shahid <junaids@google.com>, David Rientjes <rientjes@google.com>, Alasdair Kergon <agk@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, andreslc@google.com, gthelen@google.com, vbabka@suse.cz, linux-kernel@vger.kernel.org

On Mon, May 22 2017 at 11:03am -0400,
Michal Hocko <mhocko@kernel.org> wrote:

> On Mon 22-05-17 10:52:44, Mikulas Patocka wrote:
> > 
> > 
> > On Mon, 22 May 2017, Michal Hocko wrote:
> [...] 
> > > I am not sure I understand. OOM killer is invoked for _all_ allocations
> > > <= PAGE_ALLOC_COSTLY_ORDER that do not have __GFP_NORETRY as long as the
> > > OOM killer is not disabled (oom_killer_disable) and that only happens
> > > from the PM suspend path which makes sure that no userspace is active at
> > > the time. AFAIU this is a userspace triggered path and so the later
> > > shouldn't apply to it and GFP_KERNEL should be therefore sufficient.
> > > Relying to a portion of memory reserves to prevent from deadlock seems
> > > fundamentaly broken  to me.
> > > 
> > 
> > The lvm2 was designed this way - it is broken, but there is not much that 
> > can be done about it - fixing this would mean major rewrite. The only 
> > thing we can do about it is to lower the deadlock probability with 
> > __GFP_HIGH (or PF_MEMALLOC that was used some times ago).

Yes, lvm2 was originally designed to to have access to memory reserves
to ensure forward progress.  But if the mm subsystem has improved to
allow for the required progress without lvm2 trying to stake a claim on
those reserves then we'll gladly avoid (ab)using them.

> But let me repeat. GFP_KERNEL allocation for order-0 page will not fail.

OK, but will it be serviced immediately?  Not failing isn't useful if it
never completes.

> If you need non-failing semantic then just make it clear by adding
> __GFP_NOFAIL rather than __GFP_HIGH. Memory reserves are a scarce
> resource and there are users which might really need it from atomic
> contexts.

While adding the __GFP_NOFAIL flag would serve to document expectations
I'm left unconvinced that the memory allocator will _not fail_ for an
order-0 page -- as Mikulas said most ioctls don't need more than 4K.
(Apologies if you've already covered _why_ we can have confidence in the
mm subsystem's ability to ensure forward progress for these allocations).

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
