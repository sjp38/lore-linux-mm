Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 654AF2806CB
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 21:41:38 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 28so17010293iod.14
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 18:41:38 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 198si922532ioc.80.2017.04.13.18.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 18:41:37 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@linux.intel.com>
Subject: Re: [PATCH -mm -v3] mm, swap: Sort swap entries before free
References: <20170407064901.25398-1-ying.huang@intel.com>
	<20170407144346.b2e5d3c8364767eb2b4118ed@linux-foundation.org>
	<878tn3db3h.fsf@yhuang-dev.intel.com>
Date: Fri, 14 Apr 2017 09:41:33 +0800
In-Reply-To: <878tn3db3h.fsf@yhuang-dev.intel.com> (Ying Huang's message of
	"Fri, 14 Apr 2017 09:36:18 +0800")
Message-ID: <874lxrdauq.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

"Huang, Ying" <ying.huang@intel.com> writes:

> Andrew Morton <akpm@linux-foundation.org> writes:
>
>> On Fri,  7 Apr 2017 14:49:01 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
>>
>>> To reduce the lock contention of swap_info_struct->lock when freeing
>>> swap entry.  The freed swap entries will be collected in a per-CPU
>>> buffer firstly, and be really freed later in batch.  During the batch
>>> freeing, if the consecutive swap entries in the per-CPU buffer belongs
>>> to same swap device, the swap_info_struct->lock needs to be
>>> acquired/released only once, so that the lock contention could be
>>> reduced greatly.  But if there are multiple swap devices, it is
>>> possible that the lock may be unnecessarily released/acquired because
>>> the swap entries belong to the same swap device are non-consecutive in
>>> the per-CPU buffer.
>>> 
>>> To solve the issue, the per-CPU buffer is sorted according to the swap
>>> device before freeing the swap entries.  Test shows that the time
>>> spent by swapcache_free_entries() could be reduced after the patch.
>>> 
>>> Test the patch via measuring the run time of swap_cache_free_entries()
>>> during the exit phase of the applications use much swap space.  The
>>> results shows that the average run time of swap_cache_free_entries()
>>> reduced about 20% after applying the patch.
>>
>> "20%" is useful info, but it is much better to present the absolute
>> numbers, please.  If it's "20% of one nanosecond" then the patch isn't
>> very interesting.  If it's "20% of 35 seconds" then we know we have
>> more work to do.
>
> I added memory freeing timing capability to vm-scalability test suite.
> The result shows the memory freeing time reduced from 2.64s to 2.31s
> (about -12.5%).

The memory space to free is 96G (including swap).  The machine has 144
CPU, 32G RAM, and 96G swap.  The process number is 16.

Best Regards,
Huang, Ying

> Best Regards,
> Huang, Ying
>
>> If there is indeed still a significant problem here then perhaps it
>> would be better to move the percpu swp_entry_t buffer into the
>> per-device structure swap_info_struct, so it becomes "per cpu, per
>> device".  That way we should be able to reduce contention further.
>>
>> Or maybe we do something else - it all depends upon the significance of
>> this problem, which is why a full description of your measurements is
>> useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
