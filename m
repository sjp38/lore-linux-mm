Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE8D06B0038
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 17:43:49 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u195so86114726pgb.1
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 14:43:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c15si6267073plk.79.2017.04.07.14.43.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 14:43:48 -0700 (PDT)
Date: Fri, 7 Apr 2017 14:43:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm -v3] mm, swap: Sort swap entries before free
Message-Id: <20170407144346.b2e5d3c8364767eb2b4118ed@linux-foundation.org>
In-Reply-To: <20170407064901.25398-1-ying.huang@intel.com>
References: <20170407064901.25398-1-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Fri,  7 Apr 2017 14:49:01 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:

> To reduce the lock contention of swap_info_struct->lock when freeing
> swap entry.  The freed swap entries will be collected in a per-CPU
> buffer firstly, and be really freed later in batch.  During the batch
> freeing, if the consecutive swap entries in the per-CPU buffer belongs
> to same swap device, the swap_info_struct->lock needs to be
> acquired/released only once, so that the lock contention could be
> reduced greatly.  But if there are multiple swap devices, it is
> possible that the lock may be unnecessarily released/acquired because
> the swap entries belong to the same swap device are non-consecutive in
> the per-CPU buffer.
> 
> To solve the issue, the per-CPU buffer is sorted according to the swap
> device before freeing the swap entries.  Test shows that the time
> spent by swapcache_free_entries() could be reduced after the patch.
> 
> Test the patch via measuring the run time of swap_cache_free_entries()
> during the exit phase of the applications use much swap space.  The
> results shows that the average run time of swap_cache_free_entries()
> reduced about 20% after applying the patch.

"20%" is useful info, but it is much better to present the absolute
numbers, please.  If it's "20% of one nanosecond" then the patch isn't
very interesting.  If it's "20% of 35 seconds" then we know we have
more work to do.

If there is indeed still a significant problem here then perhaps it
would be better to move the percpu swp_entry_t buffer into the
per-device structure swap_info_struct, so it becomes "per cpu, per
device".  That way we should be able to reduce contention further.

Or maybe we do something else - it all depends upon the significance of
this problem, which is why a full description of your measurements is
useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
