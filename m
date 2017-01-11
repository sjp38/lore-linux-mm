Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C50D6B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 18:00:41 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y143so6567707pfb.6
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 15:00:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x61si7139407plb.36.2017.01.11.15.00.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 15:00:31 -0800 (PST)
Date: Wed, 11 Jan 2017 15:00:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 2/9] mm/swap: Add cluster lock
Message-Id: <20170111150029.29e942aa00af69f9c3c4e9b1@linux-foundation.org>
In-Reply-To: <dbb860bbd825b1aaba18988015e8963f263c3f0d.1484082593.git.tim.c.chen@linux.intel.com>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
	<dbb860bbd825b1aaba18988015e8963f263c3f0d.1484082593.git.tim.c.chen@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Wed, 11 Jan 2017 09:55:12 -0800 Tim Chen <tim.c.chen@linux.intel.com> wrote:

> From: "Huang, Ying" <ying.huang@intel.com>
> 
> This patch is to reduce the lock contention of swap_info_struct->lock
> via using a more fine grained lock in swap_cluster_info for some swap
> operations.  swap_info_struct->lock is heavily contended if multiple
> processes reclaim pages simultaneously.  Because there is only one lock
> for each swap device.  While in common configuration, there is only one
> or several swap devices in the system.  The lock protects almost all
> swap related operations.
> 
> In fact, many swap operations only access one element of
> swap_info_struct->swap_map array.  And there is no dependency between
> different elements of swap_info_struct->swap_map.  So a fine grained
> lock can be used to allow parallel access to the different elements of
> swap_info_struct->swap_map.
> 
> In this patch, one bit of swap_cluster_info is used as the bin spinlock
> to protect the elements of swap_info_struct->swap_map in the swap
> cluster and the fields of swap_cluster_info.  This reduced locking
> contention for swap_info_struct->swap_map access greatly.
> 
> To use the bin spinlock, the size of swap_cluster_info needs to increase
> from 4 bytes to 8 bytes on the 64bit system.  This will use 4k more
> memory for every 1G swap space.
> 
> Because the size of swap_cluster_info is much smaller than the size of
> the cache line (8 vs 64 on x86_64 architecture), there may be false
> cache line sharing between swap_cluster_info bit spinlocks.  To avoid
> the false sharing in the first round of the swap cluster allocation, the
> order of the swap clusters in the free clusters list is changed.  So
> that, the swap_cluster_info sharing the same cache line will be placed
> as far as possible.  After the first round of allocation, the order of
> the clusters in free clusters list is expected to be random.  So the
> false sharing should be not noticeable.
> 
> ...
>
> @@ -175,11 +175,16 @@ enum {
>   * protected by swap_info_struct.lock.
>   */
>  struct swap_cluster_info {
> -	unsigned int data:24;
> -	unsigned int flags:8;
> +	unsigned long data;
>  };
>
> ...
>
> +static inline void __lock_cluster(struct swap_cluster_info *ci)
> +{
> +	bit_spin_lock(CLUSTER_FLAG_LOCK_BIT, &ci->data);
> +}

hm, bit_spin_lock() is a nasty thing.  It is slow and it doesn't have
all the lockdep support.

Would the world end if we added a spinlock to swap_cluster_info?  Check
my math: for each 1G of wapspace we have 256k pages, hence 1k of
swap_cluster_infos, hence 4k of memory.  ie, one page of memory for
each 256,000 pages of swap.  Is increasing that 1/256000 to 2/256000 a
big deal?



Also, I note that struct swap_cluster_info is only used in swapfile.c
and as a cleanup we could move its definition into that .c file. 
Perhaps other things could be moved as well..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
