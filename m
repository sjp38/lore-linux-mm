Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id DBCD26B0263
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 22:05:44 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id xx10so6155303pac.2
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 19:05:44 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id c4si3340409paz.118.2016.10.24.19.05.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 19:05:44 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v2 2/8] mm/swap: Add cluster lock
References: <cover.1477004978.git.tim.c.chen@linux.intel.com>
	<f399f0381db2e6d6bba804d139f5f41725137337.1477004978.git.tim.c.chen@linux.intel.com>
	<20161024103133.7c1a8f83@lwn.net>
Date: Tue, 25 Oct 2016 10:05:39 +0800
In-Reply-To: <20161024103133.7c1a8f83@lwn.net> (Jonathan Corbet's message of
	"Mon, 24 Oct 2016 10:31:33 -0600")
Message-ID: <87k2cxkwss.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Huang, Ying" <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

Hi, Jonathan,

Thanks for review.

Jonathan Corbet <corbet@lwn.net> writes:

> On Thu, 20 Oct 2016 16:31:41 -0700
> Tim Chen <tim.c.chen@linux.intel.com> wrote:
>
>> From: "Huang, Ying" <ying.huang@intel.com>
>> 
>> This patch is to reduce the lock contention of swap_info_struct->lock
>> via using a more fine grained lock in swap_cluster_info for some swap
>> operations.  swap_info_struct->lock is heavily contended if multiple
>> processes reclaim pages simultaneously.  Because there is only one lock
>> for each swap device.  While in common configuration, there is only one
>> or several swap devices in the system.  The lock protects almost all
>> swap related operations.
>
> So I'm looking at this a bit.  Overall it seems like a good thing to do
> (from my limited understanding of this area) but I have a probably silly
> question... 
>
>>  struct swap_cluster_info {
>> -	unsigned int data:24;
>> -	unsigned int flags:8;
>> +	unsigned long data;
>>  };
>> -#define CLUSTER_FLAG_FREE 1 /* This cluster is free */
>> -#define CLUSTER_FLAG_NEXT_NULL 2 /* This cluster has no next cluster */
>> +#define CLUSTER_COUNT_SHIFT		8
>> +#define CLUSTER_FLAG_MASK		((1UL << CLUSTER_COUNT_SHIFT) - 1)
>> +#define CLUSTER_COUNT_MASK		(~CLUSTER_FLAG_MASK)
>> +#define CLUSTER_FLAG_FREE		1 /* This cluster is free */
>> +#define CLUSTER_FLAG_NEXT_NULL		2 /* This cluster has no next cluster */
>> +/* cluster lock, protect cluster_info contents and sis->swap_map */
>> +#define CLUSTER_FLAG_LOCK_BIT		2
>> +#define CLUSTER_FLAG_LOCK		(1 << CLUSTER_FLAG_LOCK_BIT)
>
> Why the roll-your-own locking and data structures here?  To my naive
> understanding, it seems like you could do something like:
>
>   struct swap_cluster_info {
>   	spinlock_t lock;
> 	atomic_t count;
> 	unsigned int flags;
>   };
>
> Then you could use proper spinlock operations which, among other things,
> would make the realtime folks happier.  That might well help with the
> cache-line sharing issues as well.  Some of the count manipulations could
> perhaps be done without the lock entirely; similarly, atomic bitops might
> save you the locking for some of the flag tweaks - though I'd have to look
> more closely to be really sure of that.
>
> The cost, of course, is the growth of this structure, but you've already
> noted that the overhead isn't all that high; seems like it could be worth
> it.

Yes.  The data structure you proposed is much easier to be used than the
current one.  The main concern is the RAM usage.  The size of the data
structure you proposed is about 80 bytes, while that of the current one
is about 8 bytes.  There will be one struct swap_cluster_info for every
1MB swap space, so for 1TB swap space, the total size will be 80M
compared with 8M of current implementation.

In the other hand, the return of the increased size is not overwhelming.
The bit spinlock on cluster will not be heavy contended because it is a
quite fine-grained lock.  So the benefit will be little to use lockless
operations.  I guess the realtime issue isn't serious given the lock is
not heavy contended and the operations protected by the lock is
light-weight too.

Best Regards,
Huang, Ying

> I assume that I'm missing something obvious here?
>
> Thanks,
>
> jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
