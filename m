Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5U3gjgC030487
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 09:12:45 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5U3fZP8966894
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 09:11:35 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5U3gjtc006800
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 09:12:45 +0530
Message-ID: <48685640.5080408@linux.vnet.ibm.com>
Date: Mon, 30 Jun 2008 09:12:56 +0530
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

Yes

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

Will fix

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

OK, I can look into that.

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
> 

I'll fix it by taking snapshots only before inserting an element into the heap
(I think I responded to this one in another email, but missed out on the typos).

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
