Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 015296B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 08:32:47 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so7173525wml.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 05:32:46 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id q126si2235018wme.10.2016.08.12.05.32.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 05:32:45 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i5so2604131wmg.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 05:32:45 -0700 (PDT)
Date: Fri, 12 Aug 2016 14:32:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle
 PF_LESS_THROTTLE tasks
Message-ID: <20160812123242.GH3639@dhcp22.suse.cz>
References: <20160722091558.GF794@dhcp22.suse.cz>
 <878twt5i1j.fsf@notabene.neil.brown.name>
 <20160725083247.GD9401@dhcp22.suse.cz>
 <87lh0n4ufs.fsf@notabene.neil.brown.name>
 <20160727182411.GE21859@dhcp22.suse.cz>
 <87eg6e4vhc.fsf@notabene.neil.brown.name>
 <20160728071711.GB31860@dhcp22.suse.cz>
 <alpine.LRH.2.02.1608030844470.15274@file01.intranet.prod.int.rdu2.redhat.com>
 <20160803143419.GC1490@dhcp22.suse.cz>
 <alpine.LRH.2.02.1608041446430.21662@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1608041446430.21662@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "dm-devel@redhat.com David Rientjes" <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu 04-08-16 14:49:41, Mikulas Patocka wrote:
> 
> 
> On Wed, 3 Aug 2016, Michal Hocko wrote:
> 
> > On Wed 03-08-16 08:53:25, Mikulas Patocka wrote:
> > > 
> > > 
> > > On Thu, 28 Jul 2016, Michal Hocko wrote:
> > > 
> > > > > >> I think we'd end up with cleaner code if we removed the cute-hacks.  And
> > > > > >> we'd be able to use 6 more GFP flags!!  (though I do wonder if we really
> > > > > >> need all those 26).
> > > > > >
> > > > > > Well, maybe we are able to remove those hacks, I wouldn't definitely
> > > > > > be opposed.  But right now I am not even convinced that the mempool
> > > > > > specific gfp flags is the right way to go.
> > > > > 
> > > > > I'm not suggesting a mempool-specific gfp flag.  I'm suggesting a
> > > > > transient-allocation gfp flag, which would be quite useful for mempool.
> > > > > 
> > > > > Can you give more details on why using a gfp flag isn't your first choice
> > > > > for guiding what happens when the system is trying to get a free page
> > > > > :-?
> > > > 
> > > > If we get rid of throttle_vm_writeout then I guess it might turn out to
> > > > be unnecessary. There are other places which will still throttle but I
> > > > believe those should be kept regardless of who is doing the allocation
> > > > because they are helping the LRU scanning sane. I might be wrong here
> > > > and bailing out from the reclaim rather than waiting would turn out
> > > > better for some users but I would like to see whether the first approach
> > > > works reasonably well.
> > > 
> > > If we are swapping to a dm-crypt device, the dm-crypt device is congested 
> > > and the underlying block device is not congested, we should not throttle 
> > > mempool allocations made from the dm-crypt workqueue. Not even a little 
> > > bit.
> > 
> > But the device congestion is not the only condition required for the
> > throttling. The pgdat has also be marked congested which means that the
> > LRU page scanner bumped into dirty/writeback/pg_reclaim pages at the
> > tail of the LRU. That should only happen if we are rotating LRUs too
> > quickly. AFAIU the reclaim shouldn't allow free ticket scanning in that
> > situation.
> 
> The obvious problem here is that mempool allocations should sleep in 
> mempool_alloc() on &pool->wait (until someone returns some entries into 
> the mempool), they should not sleep inside the page allocator.

I agree that mempool_alloc should _primarily_ sleep on their own
throttling mechanism. I am not questioning that. I am just saying that
the page allocator has its own throttling which it relies on and that
cannot be just ignored because that might have other undesirable side
effects. So if the right approach is really to never throttle certain
requests then we have to bail out from a congested nodes/zones as soon
as the congestion is detected.

Now, I would like to see that something like that is _really_ necessary.
I believe that we should simply start with easier part and get rid of
throttle_vm_writeout because that seems like a left over from the past.
If that turns out unsatisfactory and we have clear picture when the
throttling is harmful/suboptimal then we can move on with a more complex
solution. Does this sound like a way forward?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
