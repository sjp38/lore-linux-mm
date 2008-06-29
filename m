Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m5T4mEvd009566
	for <linux-mm@kvack.org>; Sun, 29 Jun 2008 14:48:14 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5T4mjGd257494
	for <linux-mm@kvack.org>; Sun, 29 Jun 2008 14:48:48 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5T4mjbg002871
	for <linux-mm@kvack.org>; Sun, 29 Jun 2008 14:48:45 +1000
Message-ID: <48671433.1060409@linux.vnet.ibm.com>
Date: Sun, 29 Jun 2008 10:18:51 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC 5/5] Memory controller soft limit reclaim on contention
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop> <20080627151906.31664.7247.sendpatchset@balbir-laptop> <6599ad830806270909w6a2c26d8mcf406856c06c5da@mail.gmail.com>
In-Reply-To: <6599ad830806270909w6a2c26d8mcf406856c06c5da@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Fri, Jun 27, 2008 at 8:19 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> +/*
>> + * Create a heap of memory controller structures. The heap is reverse
>> + * sorted by size. This heap is used for implementing soft limits. Our
>> + * current heap implementation does not allow dynamic heap updates, but
>> + * eventually, the costliest controller (over it's soft limit should
> 
> it's -> its
> 
>> +                       old_mem = heap_insert(&mem_cgroup_heap, mem,
>> +                                               HEAP_REP_LEAF);
>> +                       mem->on_heap = 1;
>> +                       if (old_mem)
>> +                               old_mem->on_heap = 0;
> 
> Maybe a comment here that mem might == old_mem?
> 
>> + * When the soft limit is exceeded, look through the heap and start
>> + * reclaiming from all groups over thier soft limit
> 
> thier -> their
> 
>> +               if (!res_counter_check_under_soft_limit(&mem->res)) {
>> +                       /*
>> +                        * The current task might already be over it's soft
>> +                        * limit and trying to aggressively grow. We check to
>> +                        * see if it the memory group associated with the
>> +                        * current task is on the heap when the current group
>> +                        * is over it's soft limit. If not, we add it
>> +                        */
>> +                       if (!mem->on_heap) {
>> +                               struct mem_cgroup *old_mem;
>> +
>> +                               old_mem = heap_insert(&mem_cgroup_heap, mem,
>> +                                                       HEAP_REP_LEAF);
>> +                               mem->on_heap = 1;
>> +                               if (old_mem)
>> +                                       old_mem->on_heap = 0;
>> +                       }
>> +               }
> 
> This and the other similar code for adding to the heap should be
> refactored into a separate function.
> 
>> +static int mem_cgroup_compare_soft_limits(void *p1, void *p2)
>> +{
>> +       struct mem_cgroup *mem1 = (struct mem_cgroup *)p1;
>> +       struct mem_cgroup *mem2 = (struct mem_cgroup *)p2;
>> +       unsigned long long delta1, delta2;
>> +
>> +       delta1 = res_counter_soft_limit_delta(&mem1->res);
>> +       delta2 = res_counter_soft_limit_delta(&mem2->res);
>> +
>> +       return delta1 > delta2;
>> +}
> 
> This isn't a valid comparator, since it isn't a constant function of
> its two input pointers - calling mem_cgroup_compare_soft_limits(m1,
> m2) can give different results at different times. So your heap
> invariant will become invalid over time.
> 
> I think if you want to do this, you're going to need to periodically
> take a snapshot of each cgroup's excess and use that snapshot in the
> comparator; whenever you update the snapshots, you'll need to restore
> the heap invariant.

I see your point. Keeping snapshots sounds OK, but updating the heap each time
is expensive, since it's hard to find a node in the heap. If we could, then we
could call heap_adjust frequently (whenever the delta changes) and keep the heap
correctly formed. I wonder if keeping two snapshots will help. One for use by
the ->gt callback (called old_snapshot) and then we switch over to the new
snapshot when we reinsert the element after it has been deleted from the heap.

Thinking further, snapshotting might work, provided we take snapshots at the
time of insertion only. When an element is deleted and re-inserted we update the
snapshot. That way the invariant is not broken.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
