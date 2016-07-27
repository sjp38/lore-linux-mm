Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C33716B0261
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 14:40:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so2561785wml.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 11:40:24 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id ch18si8430606wjb.75.2016.07.27.11.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 11:40:23 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id o80so7734875wme.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 11:40:23 -0700 (PDT)
Date: Wed, 27 Jul 2016 20:40:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle
 PF_LESS_THROTTLE tasks
Message-ID: <20160727184021.GF21859@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-2-git-send-email-mhocko@kernel.org>
 <87oa5q5abi.fsf@notabene.neil.brown.name>
 <20160722091558.GF794@dhcp22.suse.cz>
 <878twt5i1j.fsf@notabene.neil.brown.name>
 <alpine.LRH.2.02.1607251730280.11852@file01.intranet.prod.int.rdu2.redhat.com>
 <87invr4tjm.fsf@notabene.neil.brown.name>
 <alpine.LRH.2.02.1607270948040.1779@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1607270948040.1779@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: NeilBrown <neilb@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 27-07-16 10:28:40, Mikulas Patocka wrote:
> 
> 
> On Wed, 27 Jul 2016, NeilBrown wrote:
> 
> > On Tue, Jul 26 2016, Mikulas Patocka wrote:
> > 
> > > On Sat, 23 Jul 2016, NeilBrown wrote:
> > >
> > >> "dirtying ... from the reclaim context" ??? What does that mean?
> > >> According to
> > >>   Commit: 26eecbf3543b ("[PATCH] vm: pageout throttling")
> > >> From the history tree, the purpose of throttle_vm_writeout() is to
> > >> limit the amount of memory that is concurrently under I/O.
> > >> That seems strange to me because I thought it was the responsibility of
> > >> each backing device to impose a limit - a maximum queue size of some
> > >> sort.
> > >
> > > Device mapper doesn't impose any limit for in-flight bios.
> > 
> > I would suggest that it probably should. At least it should
> > "set_wb_congested()" when the number of in-flight bios reaches some
> > arbitrary threshold.
> 
> If we set the device mapper device as congested, it can again trigger that 
> mempool alloc throttling bug.
> 
> I.e. suppose that we swap to a dm-crypt device. The dm-crypt device 
> becomes clogged and sets its state as congested. The underlying block 
> device is not congested.
> 
> The mempool_alloc function in the dm-crypt workqueue sets the 
> PF_LESS_THROTTLE flag, and tries to allocate memory, but according to 
> Michal's patches, processes with PF_LESS_THROTTLE may still get throttled.
> 
> So if we set the dm-crypt device as congested, it can incorrectly throttle 
> the dm-crypt workqueue that does allocations of temporary pages and 
> encryption.
> 
> I think that approach with PF_LESS_THROTTLE in mempool_alloc is incorrect 
> and that mempool allocations should never be throttled.

I'm not really sure this is the right approach. If a particular mempool
user cannot ever be throttled by the page allocator then it should
perform GFP_NOWAIT. Even mempool allocations shouldn't allow reclaim to
scan pages too quickly even when LRU lists are full of dirty pages. But
as I've said that would restrict the success rates even under light page
cache load. Throttling on the wait_iff_congested should be quite rare.

Anyway do you see an excessive throttling with the patch posted
http://lkml.kernel.org/r/20160725192344.GD2166@dhcp22.suse.cz ? Or from
another side. Do you see an excessive number of dirty/writeback pages
wrt. the dirty threshold or any other undesirable side effects?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
