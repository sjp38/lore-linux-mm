Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 698806B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 14:49:44 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id g124so86552482qkd.1
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 11:49:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a129si6498763qkb.78.2016.08.04.11.49.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 11:49:43 -0700 (PDT)
Date: Thu, 4 Aug 2016 14:49:41 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle
 PF_LESS_THROTTLE tasks
In-Reply-To: <20160803143419.GC1490@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1608041446430.21662@file01.intranet.prod.int.rdu2.redhat.com>
References: <1468831285-27242-2-git-send-email-mhocko@kernel.org> <87oa5q5abi.fsf@notabene.neil.brown.name> <20160722091558.GF794@dhcp22.suse.cz> <878twt5i1j.fsf@notabene.neil.brown.name> <20160725083247.GD9401@dhcp22.suse.cz> <87lh0n4ufs.fsf@notabene.neil.brown.name>
 <20160727182411.GE21859@dhcp22.suse.cz> <87eg6e4vhc.fsf@notabene.neil.brown.name> <20160728071711.GB31860@dhcp22.suse.cz> <alpine.LRH.2.02.1608030844470.15274@file01.intranet.prod.int.rdu2.redhat.com> <20160803143419.GC1490@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "dm-devel@redhat.com David Rientjes" <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>



On Wed, 3 Aug 2016, Michal Hocko wrote:

> On Wed 03-08-16 08:53:25, Mikulas Patocka wrote:
> > 
> > 
> > On Thu, 28 Jul 2016, Michal Hocko wrote:
> > 
> > > > >> I think we'd end up with cleaner code if we removed the cute-hacks.  And
> > > > >> we'd be able to use 6 more GFP flags!!  (though I do wonder if we really
> > > > >> need all those 26).
> > > > >
> > > > > Well, maybe we are able to remove those hacks, I wouldn't definitely
> > > > > be opposed.  But right now I am not even convinced that the mempool
> > > > > specific gfp flags is the right way to go.
> > > > 
> > > > I'm not suggesting a mempool-specific gfp flag.  I'm suggesting a
> > > > transient-allocation gfp flag, which would be quite useful for mempool.
> > > > 
> > > > Can you give more details on why using a gfp flag isn't your first choice
> > > > for guiding what happens when the system is trying to get a free page
> > > > :-?
> > > 
> > > If we get rid of throttle_vm_writeout then I guess it might turn out to
> > > be unnecessary. There are other places which will still throttle but I
> > > believe those should be kept regardless of who is doing the allocation
> > > because they are helping the LRU scanning sane. I might be wrong here
> > > and bailing out from the reclaim rather than waiting would turn out
> > > better for some users but I would like to see whether the first approach
> > > works reasonably well.
> > 
> > If we are swapping to a dm-crypt device, the dm-crypt device is congested 
> > and the underlying block device is not congested, we should not throttle 
> > mempool allocations made from the dm-crypt workqueue. Not even a little 
> > bit.
> 
> But the device congestion is not the only condition required for the
> throttling. The pgdat has also be marked congested which means that the
> LRU page scanner bumped into dirty/writeback/pg_reclaim pages at the
> tail of the LRU. That should only happen if we are rotating LRUs too
> quickly. AFAIU the reclaim shouldn't allow free ticket scanning in that
> situation.

The obvious problem here is that mempool allocations should sleep in 
mempool_alloc() on &pool->wait (until someone returns some entries into 
the mempool), they should not sleep inside the page allocator.

Mikulas

> > So, I think, mempool_alloc should set PF_NO_THROTTLE (or 
> > __GFP_NO_THROTTLE).
> 
> As I've said earlier that would probably require to bail out from the
> reclaim if we detect a potential pgdat congestion. What do you think
> Mel?
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
