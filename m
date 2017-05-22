Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 96F326B0292
	for <linux-mm@kvack.org>; Mon, 22 May 2017 19:36:00 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id z142so58958642qkz.8
        for <linux-mm@kvack.org>; Mon, 22 May 2017 16:36:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t4si19693285qta.25.2017.05.22.16.35.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 16:35:59 -0700 (PDT)
Date: Mon, 22 May 2017 19:35:57 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: dm ioctl: Restore __GFP_HIGH in copy_params()
Message-ID: <20170522233557.GA26990@redhat.com>
References: <1508444.i5EqlA1upv@js-desktop.svl.corp.google.com>
 <20170519074647.GC13041@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705191934340.17646@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522093725.GF8509@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705220759001.27401@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522120937.GI8509@dhcp22.suse.cz>
 <alpine.LRH.2.02.1705221026430.20076@file01.intranet.prod.int.rdu2.redhat.com>
 <20170522150321.GM8509@dhcp22.suse.cz>
 <20170522180415.GA25340@redhat.com>
 <alpine.DEB.2.10.1705221325200.30407@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1705221325200.30407@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Mikulas Patocka <mpatocka@redhat.com>, Junaid Shahid <junaids@google.com>, Alasdair Kergon <agk@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, andreslc@google.com, gthelen@google.com, vbabka@suse.cz, linux-kernel@vger.kernel.org

On Mon, May 22 2017 at  4:35pm -0400,
David Rientjes <rientjes@google.com> wrote:

> On Mon, 22 May 2017, Mike Snitzer wrote:
> 
> > > > The lvm2 was designed this way - it is broken, but there is not much that 
> > > > can be done about it - fixing this would mean major rewrite. The only 
> > > > thing we can do about it is to lower the deadlock probability with 
> > > > __GFP_HIGH (or PF_MEMALLOC that was used some times ago).
> > 
> > Yes, lvm2 was originally designed to to have access to memory reserves
> > to ensure forward progress.  But if the mm subsystem has improved to
> > allow for the required progress without lvm2 trying to stake a claim on
> > those reserves then we'll gladly avoid (ab)using them.
> > 
> 
> There is no such improvement to the page allocator when allocating at 
> runtime.  A persistent amount of memory in a mempool could be set aside as 
> a preallocation and unavailable from the rest of the system forever as an 
> alternative to dynamically allocating with memory reserves, but that has 
> obvious downsides.  This patch is the exact right thing to do.
> 
> > > But let me repeat. GFP_KERNEL allocation for order-0 page will not fail.
> > 
> > OK, but will it be serviced immediately?  Not failing isn't useful if it
> > never completes.
> > 
> 
> No, and you can use __GFP_HIGH, which this patch does, to have a 
> reasonable expectation of forward progress in the very near term.
> 
> > While adding the __GFP_NOFAIL flag would serve to document expectations
> > I'm left unconvinced that the memory allocator will _not fail_ for an
> > order-0 page -- as Mikulas said most ioctls don't need more than 4K.
> 
> __GFP_NOFAIL would make no sense in kvmalloc() calls, ever, it would never 
> fallback to vmalloc :)
> 
> I'm hoping this can get merged during the 4.12 window to fix the broken 
> commit d224e9381897.

I've added your Acked-by and staged it for 4.12, please see:
https://git.kernel.org/pub/scm/linux/kernel/git/device-mapper/linux-dm.git/commit/?h=for-4.12/dm&id=8c1e2162f27b319da913683143c0c6c09b083ebb

Not sure when I'll send it to Linus but certainly no later than for rc4
inclusion.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
