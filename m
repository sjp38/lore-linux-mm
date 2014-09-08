Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E67C56B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 11:48:25 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id kx10so3362456pab.3
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 08:48:25 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id bs9si18541973pdb.145.2014.09.08.08.48.23
        for <linux-mm@kvack.org>;
        Mon, 08 Sep 2014 08:48:23 -0700 (PDT)
Message-ID: <540DCF99.2070900@intel.com>
Date: Mon, 08 Sep 2014 08:47:37 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
References: <54061505.8020500@sr71.net> <5406262F.4050705@intel.com> <54062F32.5070504@sr71.net> <20140904142721.GB14548@dhcp22.suse.cz> <5408CB2E.3080101@sr71.net> <20140905123517.GA21208@cmpxchg.org>
In-Reply-To: <20140905123517.GA21208@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On 09/05/2014 05:35 AM, Johannes Weiner wrote:
> On Thu, Sep 04, 2014 at 01:27:26PM -0700, Dave Hansen wrote:
>> On 09/04/2014 07:27 AM, Michal Hocko wrote:
>>> Ouch. free_pages_and_swap_cache completely kills the uncharge batching
>>> because it reduces it to PAGEVEC_SIZE batches.
>>>
>>> I think we really do not need PAGEVEC_SIZE batching anymore. We are
>>> already batching on tlb_gather layer. That one is limited so I think
>>> the below should be safe but I have to think about this some more. There
>>> is a risk of prolonged lru_lock wait times but the number of pages is
>>> limited to 10k and the heavy work is done outside of the lock. If this
>>> is really a problem then we can tear LRU part and the actual
>>> freeing/uncharging into a separate functions in this path.
>>>
>>> Could you test with this half baked patch, please? I didn't get to test
>>> it myself unfortunately.
>>
>> 3.16 settled out at about 11.5M faults/sec before the regression.  This
>> patch gets it back up to about 10.5M, which is good.  The top spinlock
>> contention in the kernel is still from the resource counter code via
>> mem_cgroup_commit_charge(), though.
> 
> Thanks for testing, that looks a lot better.
> 
> But commit doesn't touch resource counters - did you mean try_charge()
> or uncharge() by any chance?

I don't have the perf output that I was looking at when I said this, but
here's the path that I think I was referring to.  The inlining makes
this non-obvious, but this memcg_check_events() calls
mem_cgroup_update_tree() which is contending on mctz->lock.

So, you were right, it's not the resource counters code, it's a lock in
'struct mem_cgroup_tree_per_zone'.  But, the contention isn't _that_
high (2% of CPU) in this case.  But, that is 2% that we didn't see before.

>      1.87%     1.87%  [kernel]               [k] _raw_spin_lock_irqsave       
>                                |
>                                --- _raw_spin_lock_irqsave
>                                   |          
>                                   |--107.09%-- memcg_check_events
>                                   |          |          
>                                   |          |--79.98%-- mem_cgroup_commit_charge
>                                   |          |          |          
>                                   |          |          |--99.81%-- do_cow_fault
>                                   |          |          |          handle_mm_fault
>                                   |          |          |          __do_page_fault
>                                   |          |          |          do_page_fault
>                                   |          |          |          page_fault
>                                   |          |          |          testcase
>                                   |          |           --0.19%-- [...]


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
