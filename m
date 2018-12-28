Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 181C48E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 00:08:12 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id i3so22508338pfj.4
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 21:08:12 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 9si33215894pgn.524.2018.12.27.21.08.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 21:08:10 -0800 (PST)
Date: Fri, 28 Dec 2018 13:08:06 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
References: <20181226131446.330864849@intel.com>
 <20181227203158.GO16738@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181227203158.GO16738@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 27, 2018 at 09:31:58PM +0100, Michal Hocko wrote:
>On Wed 26-12-18 21:14:46, Wu Fengguang wrote:
>> This is an attempt to use NVDIMM/PMEM as volatile NUMA memory that's
>> transparent to normal applications and virtual machines.
>>
>> The code is still in active development. It's provided for early design review.
>
>So can we get a high level description of the design and expected
>usecases please?

Good question.

Use cases
=========

The general use case is to use PMEM as slower but cheaper "DRAM".
The suitable ones can be

- workloads care memory size more than bandwidth/latency
- workloads with a set of warm/cold pages that don't change rapidly over time
- low cost VM/containers

Foundation: create PMEM NUMA nodes
==================================

To create PMEM nodes in native kernel, Dave Hansen and Dan Williams
have working patches for kernel and ndctl. According to Ying, it'll
work like this

        ndctl destroy-namespace -f namespace0.0
        ndctl destroy-namespace -f namespace1.0
        ipmctl create -goal MemoryMode=100
        reboot

To create PMEM nodes in QEMU VMs, current Debian/Fedora etc. distros
already support this

	qemu-system-x86_64
	-machine pc,nvdimm
        -enable-kvm
        -smp 64
        -m 256G
        # DRAM node 0
        -object memory-backend-file,size=128G,share=on,mem-path=/dev/shm/qemu_node0,id=tmpfs-node0
	-numa node,cpus=0-31,nodeid=0,memdev=tmpfs-node0
        # PMEM node 1
        -object memory-backend-file,size=128G,share=on,mem-path=/dev/dax1.0,align=128M,id=dax-node1
        -numa node,cpus=32-63,nodeid=1,memdev=dax-node1

Optimization: do hot/cold page tracking and migration
=====================================================

Since PMEM is slower than DRAM, we need to make sure hot pages go to
DRAM and cold pages stay in PMEM, to get the best out of PMEM and DRAM.

- DRAM=>PMEM cold page migration

It can be done in kernel page reclaim path, near the anonymous page
swap out point. Instead of swapping out, we now have the option to
migrate cold pages to PMEM NUMA nodes.

User space may also do it, however cannot act on-demand, when there
are memory pressure in DRAM nodes.

- PMEM=>DRAM hot page migration

While LRU can be good enough for identifying cold pages, frequency
based accounting can be more suitable for identifying hot pages.

Our design choice is to create a flexible user space daemon to drive
the accounting and migration, with necessary kernel supports by this
patchset.

Linux kernel already offers move_pages(2) for user space to migrate
pages to specified NUMA nodes. The major gap lies in hotness accounting.

User space driven hotness accounting
====================================

One way to find out hot/cold pages is to scan page table multiple
times and collect the "accessed" bits.

We created the kvm-ept-idle kernel module to provide the "accessed"
bits via interface /proc/PID/idle_pages. User space can open it and
read the "accessed" bits for a range of virtual address.

Inside kernel module, it implements 2 independent set of page table
scan code, seamlessly providing the same interface:

- for QEMU, scan HVA range of the VM's EPT(Extended Page Table)
- for others, scan VA range of the process page table 

With /proc/PID/idle_pages and move_pages(2), the user space daemon
can work like this

One round of scan+migration:

        loop N=(3-10) times:
                sleep 0.01-10s (typical values)
                scan page tables and read/accumulate accessed bits into arrays
        treat pages with accessed_count == N as hot  pages
        treat pages with accessed_count == 0 as cold pages
        migrate hot  pages to DRAM nodes
        migrate cold pages to PMEM nodes (optional, may do it once on multi scan rounds, to make sure they are really cold)

That just describes the bare minimal working model. A real world
daemon should consider lots more to be useful and robust. The notable
one is to avoid thrashing.

Hotness accounting can be rough and workload can be unstable. We need
to avoid promoting a warm page to DRAM and then demoting it soon.

The basic scheme is to auto control scan interval and count, so that
each round of scan will get hot pages < 1/2 DRAM size.

May also do multiple round of scans before migration, to filter out
unstable/burst accesses.

In long run, most of the accounted hot pages will already be in DRAM.
So only need to migrate the new ones to DRAM. When doing so, should
consider QoS and rate limiting to reduce impacts to user workloads.

When user space drives hot page migration, the DRAM nodes may well be
pressured, which will in turn trigger in-kernel cold page migration.
The above 1/2 DRAM size hot pages target can help kernel easily find
cold pages on LRU scan.

To avoid thrashing, it's also important to maintain persistent kernel
and user-space view of hot/cold pages. Since they will do migrations
in 2 different directions.

- the regular page table scans will clear PMD/PTE young
- user space compensate that by setting PG_referenced on
  move_pages(hot pages, MPOL_MF_SW_YOUNG)

That guarantees the user space collected view of hot pages will be
conveyed to kernel.

Regards,
Fengguang
