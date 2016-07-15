Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C244F6B0261
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 08:22:13 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f126so13911205wma.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 05:22:13 -0700 (PDT)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id i83si5050840wma.27.2016.07.15.05.22.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 05:22:12 -0700 (PDT)
Received: by mail-wm0-f41.google.com with SMTP id o80so27586553wme.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 05:22:12 -0700 (PDT)
Date: Fri, 15 Jul 2016 14:22:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: System freezes after OOM
Message-ID: <20160715122210.GG11811@dhcp22.suse.cz>
References: <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
 <20160713111006.GF28723@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607131021410.31769@file01.intranet.prod.int.rdu2.redhat.com>
 <20160714125129.GA12289@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607140952550.1102@file01.intranet.prod.int.rdu2.redhat.com>
 <20160714145937.GB12289@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607141315130.17819@file01.intranet.prod.int.rdu2.redhat.com>
 <20160715083510.GD11811@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607150802380.5034@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1607150802380.5034@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dm-devel@redhat.com

On Fri 15-07-16 08:11:22, Mikulas Patocka wrote:
> 
> 
> On Fri, 15 Jul 2016, Michal Hocko wrote:
> 
> > On Thu 14-07-16 13:35:35, Mikulas Patocka wrote:
> > > On Thu, 14 Jul 2016, Michal Hocko wrote:
> > > > On Thu 14-07-16 10:00:16, Mikulas Patocka wrote:
> > > > > But it needs other changes to honor the PF_LESS_THROTTLE flag:
> > > > > 
> > > > > static int current_may_throttle(void)
> > > > > {
> > > > >         return !(current->flags & PF_LESS_THROTTLE) ||
> > > > >                 current->backing_dev_info == NULL ||
> > > > >                 bdi_write_congested(current->backing_dev_info);
> > > > > }
> > > > > --- if you set PF_LESS_THROTTLE, current_may_throttle may still return 
> > > > > true if one of the other conditions is met.
> > > > 
> > > > That is true but doesn't that mean that the device is congested and
> > > > waiting a bit is the right thing to do?
> > > 
> > > You shouldn't really throttle mempool allocations at all. It's better to 
> > > fail the allocation quickly and allocate from a mempool reserve than to 
> > > wait 0.1 seconds in the reclaim path.
> > 
> > Well, but we do that already, no? The first allocation request is NOWAIT
> 
> The stacktraces showed that the kcryptd process was throttled when it 
> tried to do mempool allocation. Mempool adds the __GFP_NORETRY flag to the 
> allocation, but unfortunatelly, this flag doesn't prevent the allocator 
> from throttling.

Yes and in fact it shouldn't prevent any throttling. The flag merely
says that the allocation should give up rather than retry
reclaim/compaction again and again.

> I say that the process doing mempool allocation shouldn't ever be 
> throttled. Maybe add __GFP_NOTHROTTLE?

A specific gfp flag would be an option but we are slowly running out of
bit space there and I am not yet convinced PF_LESS_THROTTLE is
unsuitable.

> > and then we try to consume an object from the pool. We are re-adding
> > __GFP_DIRECT_RECLAIM in case both fail. The point of throttling is to
> > prevent from scanning through LRUs too quickly while we know that the
> > bdi is congested.
> 
> > > dm-crypt can do approximatelly 100MB/s. That means that it processes 25k 
> > > swap pages per second. If you wait in mempool_alloc, the allocation would 
> > > be satisfied in 0.00004s. If you wait in the allocator's throttle 
> > > function, you waste 0.1s.
> > > 
> > > 
> > > It is also questionable if those 0.1 second sleeps are reasonable at all. 
> > > SSDs with 100k IOPS are common - they can drain the request queue in much 
> > > less time than 0.1 second. I think those hardcoded 0.1 second sleeps 
> > > should be replaced with sleeps until the device stops being congested.
> > 
> > Well if we do not do throttle_vm_writeout then the only remaining
> > writeout throttling for PF_LESS_THROTTLE is wait_iff_congested for
> > the direct reclaim and that should wake up if the device stops being
> > congested AFAIU.
> 
> I mean - a proper thing is to use active wakeup for the throttling, rather 
> than retrying every 0.1 second. Polling for some condition is generally 
> bad idea.
> 
> If there are too many pages under writeback, you should sleep on a wait 
> queue. When the number of pages under writeback drops, wake up the wait 
> queue.

I might be missing something but exactly this is what happens in
wait_iff_congested no? If the bdi doesn't see the congestion it wakes up
the reclaim context even before the timeout. Or are we talking past each
other?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
