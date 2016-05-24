Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 40BA56B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 18:43:46 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id c127so70640298ywb.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 15:43:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r81si4639677qha.65.2016.05.24.15.43.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 15:43:45 -0700 (PDT)
Date: Wed, 25 May 2016 00:43:41 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: zone_reclaimable() leads to livelock in __alloc_pages_slowpath()
Message-ID: <20160524224341.GA11961@redhat.com>
References: <20160520202817.GA22201@redhat.com>
 <20160523072904.GC2278@dhcp22.suse.cz>
 <20160523151419.GA8284@redhat.com>
 <20160524071619.GB8259@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160524071619.GB8259@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/24, Michal Hocko wrote:
>
> On Mon 23-05-16 17:14:19, Oleg Nesterov wrote:
> > On 05/23, Michal Hocko wrote:
> [...]
> > > Could you add some tracing and see what are the numbers
> > > above?
> >
> > with the patch below I can press Ctrl-C when it hangs, this breaks the
> > endless loop and the output looks like
> >
> > 	vmscan: ZONE=ffffffff8189f180 0 scanned=0 pages=6
> > 	vmscan: ZONE=ffffffff8189eb00 0 scanned=1 pages=0
> > 	...
> > 	vmscan: ZONE=ffffffff8189eb00 0 scanned=2 pages=1
> > 	vmscan: ZONE=ffffffff8189f180 0 scanned=4 pages=6
> > 	...
> > 	vmscan: ZONE=ffffffff8189f180 0 scanned=4 pages=6
> > 	vmscan: ZONE=ffffffff8189f180 0 scanned=4 pages=6
> >
> > the numbers are always small.
>
> Small but scanned is not 0 and constant which means it either gets reset
> repeatedly (something gets freed) or we have stopped scanning. Which
> pattern can you see? I assume that the swap space is full at the time
> (could you add get_nr_swap_pages() to the output).

no, I tested this without SWAP,

> Also zone->name would
> be better than the pointer.

Yes, forgot to mention, this is DMA32. To remind, only 512m of RAM so
this is natural.

> I am trying to reproduce but your test case always hits the oom killer:

Did you try to run it in a loop? Usually it takes a while before the system
hangs.

> Swap:       138236      57740      80496

perhaps this makes a difference? See above, I have no SWAP.


So. I spent almost the whole day trying to understand whats going on, and
of course I failed.

But. It _seems to me_ that the kernel "leaks" some pages in LRU_INACTIVE_FILE
list because inactive_file_is_low() returns the wrong value. And do not even
ask me why I think so, unlikely I will be able to explain ;) to remind, I never
tried to read vmscan.c before.

But. if I change lruvec_lru_size()

	-       return zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru);
	+       return zone_page_state_snapshot(lruvec_zone(lruvec), NR_LRU_BASE + lru);

the problem goes away too.

To remind, it also goes away if I change calculate_normal_threshold() to return
zero, and it was not clear why. Now we can probably conclude that that this is
because the change obviouslt affects lruvec_lru_size().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
