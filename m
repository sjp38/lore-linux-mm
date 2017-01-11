Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C133B6B0253
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 18:07:32 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id b22so7284102pfd.0
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 15:07:32 -0800 (PST)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id c9si7131839pgf.116.2017.01.11.15.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 15:07:31 -0800 (PST)
Date: Wed, 11 Jan 2017 16:07:29 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v5 2/9] mm/swap: Add cluster lock
Message-ID: <20170111160729.23e06078@lwn.net>
In-Reply-To: <20170111150029.29e942aa00af69f9c3c4e9b1@linux-foundation.org>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
	<dbb860bbd825b1aaba18988015e8963f263c3f0d.1484082593.git.tim.c.chen@linux.intel.com>
	<20170111150029.29e942aa00af69f9c3c4e9b1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, "Huang, Ying" <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>

On Wed, 11 Jan 2017 15:00:29 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> hm, bit_spin_lock() is a nasty thing.  It is slow and it doesn't have
> all the lockdep support.
> 
> Would the world end if we added a spinlock to swap_cluster_info?

FWIW, I asked the same question in December, this is what I got:

jon

> From: "Huang\, Ying" <ying.huang@intel.com>
> To: Jonathan Corbet <corbet@lwn.net>
> Cc: Tim Chen <tim.c.chen@linux.intel.com>,  Andrew Morton <akpm@linux-foundation.org>,  "Huang\, Ying" <ying.huang@intel.com>,  <dave.hansen@intel.com>,  <ak@linux.intel.com>,  <aaron.lu@intel.com>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Hugh Dickins <hughd@google.com>,  Shaohua Li <shli@kernel.org>,  Minchan Kim <minchan@kernel.org>,  Rik van Riel <riel@redhat.com>,  Andrea Arcangeli <aarcange@redhat.com>,  "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,  Vladimir Davydov <vdavydov.dev@gmail.com>,  Johannes Weiner <hannes@cmpxchg.org>,  Michal Hocko <mhocko@kernel.org>,  "Hillf Danton" <hillf.zj@alibaba-inc.com>
> Subject: Re: [PATCH v2 2/8] mm/swap: Add cluster lock
> Date: Tue, 25 Oct 2016 10:05:39 +0800
> 
> Hi, Jonathan,
> 
> Thanks for review.
> 
> Jonathan Corbet <corbet@lwn.net> writes:
> 
> > On Thu, 20 Oct 2016 16:31:41 -0700
> > Tim Chen <tim.c.chen@linux.intel.com> wrote:
> >  
> >> From: "Huang, Ying" <ying.huang@intel.com>
> >> 
> >> This patch is to reduce the lock contention of swap_info_struct->lock
> >> via using a more fine grained lock in swap_cluster_info for some swap
> >> operations.  swap_info_struct->lock is heavily contended if multiple
> >> processes reclaim pages simultaneously.  Because there is only one lock
> >> for each swap device.  While in common configuration, there is only one
> >> or several swap devices in the system.  The lock protects almost all
> >> swap related operations.  
> >
> > So I'm looking at this a bit.  Overall it seems like a good thing to do
> > (from my limited understanding of this area) but I have a probably silly
> > question... 
> >  
> >>  struct swap_cluster_info {
> >> -	unsigned int data:24;
> >> -	unsigned int flags:8;
> >> +	unsigned long data;
> >>  };
> >> -#define CLUSTER_FLAG_FREE 1 /* This cluster is free */
> >> -#define CLUSTER_FLAG_NEXT_NULL 2 /* This cluster has no next cluster */
> >> +#define CLUSTER_COUNT_SHIFT		8
> >> +#define CLUSTER_FLAG_MASK		((1UL << CLUSTER_COUNT_SHIFT) - 1)
> >> +#define CLUSTER_COUNT_MASK		(~CLUSTER_FLAG_MASK)
> >> +#define CLUSTER_FLAG_FREE		1 /* This cluster is free */
> >> +#define CLUSTER_FLAG_NEXT_NULL		2 /* This cluster has no next cluster */
> >> +/* cluster lock, protect cluster_info contents and sis->swap_map */
> >> +#define CLUSTER_FLAG_LOCK_BIT		2
> >> +#define CLUSTER_FLAG_LOCK		(1 << CLUSTER_FLAG_LOCK_BIT)  
> >
> > Why the roll-your-own locking and data structures here?  To my naive
> > understanding, it seems like you could do something like:
> >
> >   struct swap_cluster_info {
> >   	spinlock_t lock;
> > 	atomic_t count;
> > 	unsigned int flags;
> >   };
> >
> > Then you could use proper spinlock operations which, among other things,
> > would make the realtime folks happier.  That might well help with the
> > cache-line sharing issues as well.  Some of the count manipulations could
> > perhaps be done without the lock entirely; similarly, atomic bitops might
> > save you the locking for some of the flag tweaks - though I'd have to look
> > more closely to be really sure of that.
> >
> > The cost, of course, is the growth of this structure, but you've already
> > noted that the overhead isn't all that high; seems like it could be worth
> > it.  
> 
> Yes.  The data structure you proposed is much easier to be used than the
> current one.  The main concern is the RAM usage.  The size of the data
> structure you proposed is about 80 bytes, while that of the current one
> is about 8 bytes.  There will be one struct swap_cluster_info for every
> 1MB swap space, so for 1TB swap space, the total size will be 80M
> compared with 8M of current implementation.
> 
> In the other hand, the return of the increased size is not overwhelming.
> The bit spinlock on cluster will not be heavy contended because it is a
> quite fine-grained lock.  So the benefit will be little to use lockless
> operations.  I guess the realtime issue isn't serious given the lock is
> not heavy contended and the operations protected by the lock is
> light-weight too.
> 
> Best Regards,
> Huang, Ying
> 
> > I assume that I'm missing something obvious here?
> >
> > Thanks,
> >
> > jon  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
