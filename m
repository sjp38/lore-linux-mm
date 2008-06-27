Received: from spaceape24.eur.corp.google.com (spaceape24.eur.corp.google.com [172.28.16.76])
	by smtp-out.google.com with ESMTP id m5RG9CUv023084
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 17:09:12 +0100
Received: from an-out-0708.google.com (andd30.prod.google.com [10.100.30.30])
	by spaceape24.eur.corp.google.com with ESMTP id m5RG9BJG012161
	for <linux-mm@kvack.org>; Fri, 27 Jun 2008 17:09:11 +0100
Received: by an-out-0708.google.com with SMTP id d30so114663and.30
        for <linux-mm@kvack.org>; Fri, 27 Jun 2008 09:09:11 -0700 (PDT)
Message-ID: <6599ad830806270909w6a2c26d8mcf406856c06c5da@mail.gmail.com>
Date: Fri, 27 Jun 2008 09:09:10 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC 5/5] Memory controller soft limit reclaim on contention
In-Reply-To: <20080627151906.31664.7247.sendpatchset@balbir-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop>
	 <20080627151906.31664.7247.sendpatchset@balbir-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 27, 2008 at 8:19 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> +/*
> + * Create a heap of memory controller structures. The heap is reverse
> + * sorted by size. This heap is used for implementing soft limits. Our
> + * current heap implementation does not allow dynamic heap updates, but
> + * eventually, the costliest controller (over it's soft limit should

it's -> its

> +                       old_mem = heap_insert(&mem_cgroup_heap, mem,
> +                                               HEAP_REP_LEAF);
> +                       mem->on_heap = 1;
> +                       if (old_mem)
> +                               old_mem->on_heap = 0;

Maybe a comment here that mem might == old_mem?

> + * When the soft limit is exceeded, look through the heap and start
> + * reclaiming from all groups over thier soft limit

thier -> their

> +               if (!res_counter_check_under_soft_limit(&mem->res)) {
> +                       /*
> +                        * The current task might already be over it's soft
> +                        * limit and trying to aggressively grow. We check to
> +                        * see if it the memory group associated with the
> +                        * current task is on the heap when the current group
> +                        * is over it's soft limit. If not, we add it
> +                        */
> +                       if (!mem->on_heap) {
> +                               struct mem_cgroup *old_mem;
> +
> +                               old_mem = heap_insert(&mem_cgroup_heap, mem,
> +                                                       HEAP_REP_LEAF);
> +                               mem->on_heap = 1;
> +                               if (old_mem)
> +                                       old_mem->on_heap = 0;
> +                       }
> +               }

This and the other similar code for adding to the heap should be
refactored into a separate function.

>
> +static int mem_cgroup_compare_soft_limits(void *p1, void *p2)
> +{
> +       struct mem_cgroup *mem1 = (struct mem_cgroup *)p1;
> +       struct mem_cgroup *mem2 = (struct mem_cgroup *)p2;
> +       unsigned long long delta1, delta2;
> +
> +       delta1 = res_counter_soft_limit_delta(&mem1->res);
> +       delta2 = res_counter_soft_limit_delta(&mem2->res);
> +
> +       return delta1 > delta2;
> +}

This isn't a valid comparator, since it isn't a constant function of
its two input pointers - calling mem_cgroup_compare_soft_limits(m1,
m2) can give different results at different times. So your heap
invariant will become invalid over time.

I think if you want to do this, you're going to need to periodically
take a snapshot of each cgroup's excess and use that snapshot in the
comparator; whenever you update the snapshots, you'll need to restore
the heap invariant.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
