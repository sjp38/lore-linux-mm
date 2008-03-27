Date: Thu, 27 Mar 2008 17:44:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [-mm] [PATCH 0/4] memcg : radix-tree page_cgroup v2
Message-Id: <20080327174435.e69f5b45.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, lizf@cn.fujitsu.com, a.p.zijlstra@chello.nl, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, this is updated version, but still against 2.6.25-rc5-mm1.

Now, a memory controller needs an extra member in 'struct page' to manage 
'struct page_cgroup'. This patch tries to remove it by radix-tree.

Before this patch, page and page_cgroup relationship is

    pfn <-> struct page <-> struct page_cgroup
    lock for page_cgroup is in struct page.

After this patch, 
    struct page <-> pfn <-> struct page_cgroup.
    lock for page_cgroup is in struct page_cgroup itself.

Pros.
   - we can remove an extra pointer in struct page.
   - lock for page_cgroup is moved to page_cgroup inself from struct page.
Cons.
   - For avoiding too much access to radix-tree, some kind of workaround is
     necessary. On this patch set, page_cgroup is managed by chunk of an order.
   - you'll see small performance regression.

I measured UnixBench execl test (this is very sensitive to page_cgroup).
and adjusted codes to get better performance.

Below is a test result on x86-64/2cpu/1core machine.
(All below result is under memory controller with unlimited limit.
 kmem allocator is SLAB.
 All tests are done right after boot.)

(1) is a result before this set, (4) is after.

         TEST                                BASELINE     RESULT      INDEX
(1)      Execl Throughput                        43.0     2868.8      667.2
(2)      Execl Throughput                        43.0     2810.3      653.6
(3)      Execl Throughput                        43.0     2836.9      659.7
(4)      Execl Throughput                        43.0     2846.0      661.9
(5)      Execl Throughput                        43.0     2862.0      665.6
(6)      Execl Throughput                        43.0     3110.0      723.3

(1) .... rc5-mm1 + memory controller
(2) .... patch 1/4 is applied.      (use radix-tree always.)
(3) .... patch [1-3]/4 are applied. (caching by percpu)
(4) .... patch [1-4]/4 are applied. (uses prefetch)
(5) .... adjust sizeof(struct page) to be 64 bytes by padding.
(6) .... rc5-mm1 *without* memory controller

If you notice something good to be tried, please teach me :)

ia64 8cpu/NUMA shows similar results.

Changelog:
 - folded into a big patch to make bisect easier. The number of patches is 4, now.
 - updated to comments on version 1.
 - small performance improvemnts against version 1.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
