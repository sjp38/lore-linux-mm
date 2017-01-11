Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CFD426B0253
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 18:15:28 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so7359651pfb.7
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 15:15:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t80si7136149pfk.213.2017.01.11.15.15.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 15:15:28 -0800 (PST)
Date: Wed, 11 Jan 2017 15:15:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 2/9] mm/swap: Add cluster lock
Message-Id: <20170111151526.e905b91d6f1ee9f21e6907be@linux-foundation.org>
In-Reply-To: <20170111160729.23e06078@lwn.net>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
	<dbb860bbd825b1aaba18988015e8963f263c3f0d.1484082593.git.tim.c.chen@linux.intel.com>
	<20170111150029.29e942aa00af69f9c3c4e9b1@linux-foundation.org>
	<20170111160729.23e06078@lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, "Huang, Ying" <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>

On Wed, 11 Jan 2017 16:07:29 -0700 Jonathan Corbet <corbet@lwn.net> wrote:

> On Wed, 11 Jan 2017 15:00:29 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > hm, bit_spin_lock() is a nasty thing.  It is slow and it doesn't have
> > all the lockdep support.
> > 
> > Would the world end if we added a spinlock to swap_cluster_info?
> 
> FWIW, I asked the same question in December, this is what I got:
> 
> ...
>
> > > Why the roll-your-own locking and data structures here?  To my naive
> > > understanding, it seems like you could do something like:
> > >
> > >   struct swap_cluster_info {
> > >   	spinlock_t lock;
> > > 	atomic_t count;
> > > 	unsigned int flags;
> > >   };
> > >
> > > Then you could use proper spinlock operations which, among other things,
> > > would make the realtime folks happier.  That might well help with the
> > > cache-line sharing issues as well.  Some of the count manipulations could
> > > perhaps be done without the lock entirely; similarly, atomic bitops might
> > > save you the locking for some of the flag tweaks - though I'd have to look
> > > more closely to be really sure of that.
> > >
> > > The cost, of course, is the growth of this structure, but you've already
> > > noted that the overhead isn't all that high; seems like it could be worth
> > > it.  
> > 
> > Yes.  The data structure you proposed is much easier to be used than the
> > current one.  The main concern is the RAM usage.  The size of the data
> > structure you proposed is about 80 bytes, while that of the current one
> > is about 8 bytes.  There will be one struct swap_cluster_info for every
> > 1MB swap space, so for 1TB swap space, the total size will be 80M
> > compared with 8M of current implementation.

Where did this 80 bytes come from?  That swap_cluster_info is 12 bytes
and could perhaps be squeezed into 8 bytes if we can get away with a
24-bit "count".


> > In the other hand, the return of the increased size is not overwhelming.
> > The bit spinlock on cluster will not be heavy contended because it is a
> > quite fine-grained lock.  So the benefit will be little to use lockless
> > operations.  I guess the realtime issue isn't serious given the lock is
> > not heavy contended and the operations protected by the lock is
> > light-weight too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
