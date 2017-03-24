Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A4D126B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 03:04:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e126so11939763pfg.3
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 00:04:21 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id g200si1084981pfb.262.2017.03.24.00.04.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 00:04:20 -0700 (PDT)
Date: Fri, 24 Mar 2017 15:04:28 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2 0/5] mm: support parallel free of memory
Message-ID: <20170324070428.GA7258@aaronlu.sh.intel.com>
References: <1489568404-7817-1-git-send-email-aaron.lu@intel.com>
 <20170315141813.GB32626@dhcp22.suse.cz>
 <20170315154406.GF2442@aaronlu.sh.intel.com>
 <20170315162843.GA27197@dhcp22.suse.cz>
 <1489613914.2733.96.camel@linux.intel.com>
 <20170316090732.GF30501@dhcp22.suse.cz>
 <ae4e3597-f664-e5c4-97fb-e07f230d5017@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="uAKRQypu60I7Lcqm"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ae4e3597-f664-e5c4-97fb-e07f230d5017@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ying Huang <ying.huang@intel.com>


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Tue, Mar 21, 2017 at 07:54:37AM -0700, Dave Hansen wrote:
> On 03/16/2017 02:07 AM, Michal Hocko wrote:
> > On Wed 15-03-17 14:38:34, Tim Chen wrote:
> >> max_active:   time
> >> 1             8.9s   +-0.5%
> >> 2             5.65s  +-5.5%
> >> 4             4.84s  +-0.16%
> >> 8             4.77s  +-0.97%
> >> 16            4.85s  +-0.77%
> >> 32            6.21s  +-0.46%
> > 
> > OK, but this will depend on the HW, right? Also now that I am looking at
> > those numbers more closely. This was about unmapping 320GB area and
> > using 4 times more CPUs you managed to half the run time. Is this really
> > worth it? Sure if those CPUs were idle then this is a clear win but if
> > the system is moderately busy then it doesn't look like a clear win to
> > me.
> 
> This still suffers from zone lock contention.  It scales much better if
> we are freeing memory from more than one zone.  We would expect any
> other generic page allocator scalability improvements to really help
> here, too.
> 
> Aaron, could you make sure to make sure that the memory being freed is
> coming from multiple NUMA nodes?  It might also be interesting to boot
> with a fake NUMA configuration with a *bunch* of nodes to see what the
> best case looks like when zone lock contention isn't even in play where
> one worker would be working on its own zone.

This fake NUMA configuration thing is great for this purpose, I didn't
know we have this support in kernel.

So I added numa=fake=128 and also wrote a new test program(attached)
that mmap() 321G memory and made sure they are distributed equally in
107 nodes, i.e. 3G on each node. This is achieved by using mbind before
touching the memory on each node.

Then I enlarged the max_gather_batch_count to 1543 so that during zap,
3G memory is sent to a kworker for free instead of the default 1G. In
this way, each kworker should be working on a different node.

With this change, time to free the 321G memory is reduced to:

	3.23s +-13.7%  (about 70% decrease)

Lock contention is 1.81%:

        19.60%  [kernel.kallsyms]  [k] release_pages
        13.30%  [kernel.kallsyms]  [k] unmap_page_range
        13.18%  [kernel.kallsyms]  [k] free_pcppages_bulk
         8.34%  [kernel.kallsyms]  [k] __mod_zone_page_state
         7.75%  [kernel.kallsyms]  [k] page_remove_rmap
         7.37%  [kernel.kallsyms]  [k] free_hot_cold_page
         6.06%  [kernel.kallsyms]  [k] free_pages_and_swap_cache
         3.53%  [kernel.kallsyms]  [k] __list_del_entry_valid
         3.09%  [kernel.kallsyms]  [k] __list_add_valid
         1.81%  [kernel.kallsyms]  [k] native_queued_spin_lock_slowpath
         1.79%  [kernel.kallsyms]  [k] uncharge_list
         1.69%  [kernel.kallsyms]  [k] mem_cgroup_update_lru_size
         1.60%  [kernel.kallsyms]  [k] vm_normal_page
         1.46%  [kernel.kallsyms]  [k] __dec_node_state
         1.41%  [kernel.kallsyms]  [k] __mod_node_page_state
         1.20%  [kernel.kallsyms]  [k] __tlb_remove_page_size
         0.85%  [kernel.kallsyms]  [k] mem_cgroup_page_lruvec

>From 'vmstat 1', the runnable process peaked at 6 during munmap():
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0      0 189114560      0 761292    0    0     0     0   70  146  0  0 100  0  0
 3  0      0 189099008      0 759932    0    0     0     0 2536  382  0  0 100  0  0
 6  0      0 274378848      0 759972    0    0     0     0 11332  249  0  3 97  0  0
 5  0      0 374426592      0 759972    0    0     0     0 13576  196  0  3 97  0  0
 4  0      0 474990144      0 759972    0    0     0     0 13250  227  0  3 97  0  0
 0  0      0 526039296      0 759972    0    0     0     0 6799  246  0  2 98  0  0
^C

This appears to be the best result from this approach.

--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="node_alloc.c"

#include <numaif.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#define BITS_PER_LONG 64
#define MAX_THREADS 256

static void *p;
static int maxnode;
static size_t per_node_len;

pthread_t threads[MAX_THREADS];

void *alloc_memory(void *arg)
{
	size_t i;
	int v, r, ret;
	unsigned long nid = (unsigned long)arg;
	unsigned long nodemask[4];
	void *q = (char *)p + per_node_len * nid;

	nodemask[0] = nodemask[1] = nodemask[2] = nodemask[3] = 0;
	v = nid / BITS_PER_LONG;
	r = nid % BITS_PER_LONG;
	nodemask[v] |= 1UL << r;
	printf("node=%d, nodemask=0x%llx 0x%llx 0x%llx 0x%llx\n", nid,
			nodemask[0], nodemask[1], nodemask[2], nodemask[3]);
	ret = mbind(q, per_node_len, MPOL_BIND, nodemask, maxnode, 0);
	if (ret == -1) {
		perror("mbind");
		return (void *)-1;
	}
	for (i = 0; i < per_node_len; i += 0x1000)
		*((char *)q + i) = nid;

	return NULL;
}

int main(int argc, char *argv[])
{
	int ret, node_nr;
	struct timeval t1, t2;
	unsigned long i, deltaus;

	if (argc != 3) {
		fprintf(stderr, "usage: ./node_alloc node_nr per_node_len_in_MB\n");
		return 0;
	}

	node_nr = atoi(argv[1]);
	per_node_len = atoi(argv[2]);
	printf("node_nr=%d, per_node_len=%dMB\n", node_nr, per_node_len);
	per_node_len <<= 20;
	printf("per_node_len=0x%lx\n", per_node_len);
	
	p = mmap(NULL, node_nr * per_node_len, PROT_READ | PROT_WRITE,
			MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	if (p == MAP_FAILED) {
		perror("mmap");
		return -1;
	}

	maxnode = node_nr + 1;
	for (i = 0; i < node_nr; i++)
		pthread_create(&threads[i], NULL, alloc_memory, (void *)i);

	for (i = 0; i < node_nr; i++)
		pthread_join(threads[i], NULL);

	printf("allocation done, press enter to start free\n");
	getchar();

	gettimeofday(&t1, NULL);
	munmap(p, node_nr * per_node_len);
	gettimeofday(&t2, NULL);
	deltaus = (t2.tv_sec - t1.tv_sec) * 1000000 + t2.tv_usec - t1.tv_usec;
	printf("time spent: %fs\n", (float)deltaus / 1000000);

	return 0;
}

--uAKRQypu60I7Lcqm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
