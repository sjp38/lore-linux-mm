Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB7546B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 12:55:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d5so12867159pfg.3
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 09:55:11 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p5si7057509pgk.204.2017.07.24.09.55.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 09:55:11 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm/swap: Remove lock_initialized flag from
 swap_slots_cache
References: <65a9d0f133f63e66bba37b53b2fd0464b7cae771.1500677066.git.tim.c.chen@linux.intel.com>
 <867d1fb070644e6d5f0ac7780f63e75259b82cc3.1500677066.git.tim.c.chen@linux.intel.com>
 <878tjeh96m.fsf@yhuang-dev.intel.com>
From: Tim Chen <tim.c.chen@linux.intel.com>
Message-ID: <e6445164-ab4b-86cc-731f-5f6509a7449d@linux.intel.com>
Date: Mon, 24 Jul 2017 09:54:50 -0700
MIME-Version: 1.0
In-Reply-To: <878tjeh96m.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

On 07/23/2017 07:15 PM, Huang, Ying wrote:
> Hi, Tim,
> 
> Tim Chen <tim.c.chen@linux.intel.com> writes:
> 
>> We will only reach the lock initialization code
>> in alloc_swap_slot_cache when the cpu's swap_slots_cache's slots
>> have not been allocated and swap_slots_cache has not been initialized
>> previously.  So the lock_initialized check is redundant and unnecessary.
>> Remove lock_initialized flag from swap_slots_cache to save memory.
> 
> Is there a race condition with CPU offline/online when preempt is enabled?
> 
> CPU A                                   CPU B
> -----                                   -----
>                                         get_swap_page()
>                                           get cache[B], cache[B]->slots != NULL
>                                           preempted and moved to CPU A
>                                         be offlined
>                                         be onlined
>                                           alloc_swap_slot_cache()
> mutex_lock(cache[B]->alloc_lock)
>                                             mutex_init(cache[B]->alloc_lock) !!!
> 
> The cache[B]->alloc_lock will be reinitialized when it is still held.

Looks like for this case the lock_initialized flag is still needed
to prevent such races and prevent re-initialization of taken locks.

Okay, let's scrap patch 2.

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
