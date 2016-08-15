Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB2656B025F
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 12:15:17 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 101so126623196qtb.0
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 09:15:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g23si14177848qtb.82.2016.08.15.09.15.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 09:15:17 -0700 (PDT)
Date: Mon, 15 Aug 2016 12:15:13 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle
 PF_LESS_THROTTLE tasks
In-Reply-To: <20160814103409.GC9248@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1608151211280.13026@file01.intranet.prod.int.rdu2.redhat.com>
References: <20160725083247.GD9401@dhcp22.suse.cz> <87lh0n4ufs.fsf@notabene.neil.brown.name> <20160727182411.GE21859@dhcp22.suse.cz> <87eg6e4vhc.fsf@notabene.neil.brown.name> <20160728071711.GB31860@dhcp22.suse.cz> <alpine.LRH.2.02.1608030844470.15274@file01.intranet.prod.int.rdu2.redhat.com>
 <20160803143419.GC1490@dhcp22.suse.cz> <alpine.LRH.2.02.1608041446430.21662@file01.intranet.prod.int.rdu2.redhat.com> <20160812123242.GH3639@dhcp22.suse.cz> <alpine.LRH.2.02.1608131323550.3291@file01.intranet.prod.int.rdu2.redhat.com>
 <20160814103409.GC9248@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "dm-devel@redhat.com David Rientjes" <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>



On Sun, 14 Aug 2016, Michal Hocko wrote:

> On Sat 13-08-16 13:34:29, Mikulas Patocka wrote:
> > 
> > 
> > On Fri, 12 Aug 2016, Michal Hocko wrote:
> > 
> > > On Thu 04-08-16 14:49:41, Mikulas Patocka wrote:
> > > 
> > > > On Wed, 3 Aug 2016, Michal Hocko wrote:
> > > > 
> > > > > But the device congestion is not the only condition required for the
> > > > > throttling. The pgdat has also be marked congested which means that the
> > > > > LRU page scanner bumped into dirty/writeback/pg_reclaim pages at the
> > > > > tail of the LRU. That should only happen if we are rotating LRUs too
> > > > > quickly. AFAIU the reclaim shouldn't allow free ticket scanning in that
> > > > > situation.
> > > > 
> > > > The obvious problem here is that mempool allocations should sleep in 
> > > > mempool_alloc() on &pool->wait (until someone returns some entries into 
> > > > the mempool), they should not sleep inside the page allocator.
> > > 
> > > I agree that mempool_alloc should _primarily_ sleep on their own
> > > throttling mechanism. I am not questioning that. I am just saying that
> > > the page allocator has its own throttling which it relies on and that
> > > cannot be just ignored because that might have other undesirable side
> > > effects. So if the right approach is really to never throttle certain
> > > requests then we have to bail out from a congested nodes/zones as soon
> > > as the congestion is detected.
> > > 
> > > Now, I would like to see that something like that is _really_ necessary.
> > 
> > Currently, it is not a problem - device mapper reports the device as 
> > congested only if the underlying physical disks are congested.
> > 
> > But once we change it so that device mapper reports congested state on its 
> > own (when it has too many bios in progress), this starts being a problem.
> 
> OK, can we wait until it starts becoming a real problem and solve it
> appropriately then?

I don't like the idea to deliberately introduce some code that triggers 
this bug into device mapper, then wait until some user hits the bug and 
then fix the bug.

If the VM throttles mempool allocations when the swap device is congested 
- than I won't report the device as congested in the device mapper.

Mikulas

> I will repost the patch which removes thottle_vm_pageout in the meantime
> as it doesn't seem to be needed anymore.
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
