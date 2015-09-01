Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4EE6B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 10:58:20 -0400 (EDT)
Received: by qkct7 with SMTP id t7so43532155qkc.1
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 07:58:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x143si21625528qha.126.2015.09.01.07.58.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 07:58:19 -0700 (PDT)
Date: Tue, 1 Sep 2015 10:58:11 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 02/15] mmu_notifier: keep track of active invalidation
 ranges v4
Message-ID: <20150901145811.GA3058@redhat.com>
References: <1439493328-1028-1-git-send-email-jglisse@redhat.com>
 <1439493328-1028-3-git-send-email-jglisse@redhat.com>
 <alpine.DEB.2.00.1508312003400.18393@mdh-linux64-2.nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.00.1508312003400.18393@mdh-linux64-2.nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>

On Mon, Aug 31, 2015 at 08:27:17PM -0700, Mark Hairgrove wrote:
> On Thu, 13 Aug 2015, Jerome Glisse wrote:

[...]

Will fix syntax.

[...]

> > +/* mmu_notifier_range_wait_valid() - wait for a range to have no conflict with
> > + * active invalidation.
> > + *
> > + * @mm: The mm struct.
> > + * @start: Start address of the range (inclusive).
> > + * @end: End address of the range (exclusive).
> > + *
> > + * This function wait for any active range invalidation that conflict with the
> > + * given range, to end.
> > + *
> > + * Note by the time this function return a new range invalidation that conflict
> > + * might have started. So you need to atomically block new range and query
> > + * again if range is still valid with mmu_notifier_range_is_valid(). So call
> > + * sequence should be :
> > + *
> > + * again:
> > + * mmu_notifier_range_wait_valid()
> > + * // block new invalidation using that lock inside your range_start callback
> > + * lock_block_new_invalidation()
> > + * if (!mmu_notifier_range_is_valid())
> > + *     goto again;
> > + * unlock()
> 
> I think this example sequence can deadlock so I wouldn't want to encourage 
> its use. New invalidation regions are added to the list before the 
> range_start callback is invoked.
> 
> Thread A                           Thread B
> -----------------                  -----------------
> mmu_notifier_range_wait_valid
> // returns
>                                    __mmu_notifier_invalidate_range_start
>                                      list_add_tail
> lock_block_new_invalidation
>                                      ->invalidate_range_start
>                                        // invalidation blocked in callback
> mmu_notifier_range_is_valid // fails
> goto again
> mmu_notifier_range_wait_valid // deadlock
> 
> mmu_notifier_range_wait_valid can't finish until thread B's callback 
> returns, but thread B's callback can't return because it's blocked.
> 
> I see that HMM in later patches takes the approach of not holding the lock 
> when mmu_notifier_range_is_valid returns false. Instead of stalling new 
> invalidations it returns -EAGAIN to the caller. While that resolves the 
> deadlock, it won't prevent the faulting thread from being starved in the 
> pathological case.

The comment here is not clear, what HMM does is what is intended. If
mmu_notifier_range_is_valid() return false then you drop lock and try
again. I am not sure we should care about the starve case as it can
not happen, it would mean that something keeps invalidating over and
over the same range of address space of a process. I do not see how
such thing would happen.

> 
> Is it out of the question to build a lock into the mmu notifier API 
> directly? It's a little worrisome to me that the complexity for this 
> locking is pushed into the callbacks rather than handled in the core. 
> Something like this:
> 
>     mmu_notifier_range_lock(start, end)
>     mmu_notifier_range_unlock(start, end)

If a range is about to be invalidated it is better to avoid faulting
in memory in the device as that same memory is about to be invalidated.
This is why i always have invalidation take precedence over device fault.


> If that's not feasible and we have to stick with the current approach, 
> then I suggest changing the "valid" name. "valid" doesn't have a clear 
> meaning at first glance because the reader doesn't know what would make a 
> range "valid." How about "active" instead? Then the names would look 
> something like this, assuming the polarity matches their current versions:
> 
>     mmu_notifier_range_inactive_locked
>     mmu_notifier_range_inactive
>     mmu_notifier_range_wait_active

Those names are better i will update the patch accordingly.

Thanks for the review,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
