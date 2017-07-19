Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 804696B0279
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 05:59:22 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s21so3424566oie.5
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 02:59:22 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id m93si3689553oik.63.2017.07.19.02.59.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 02:59:21 -0700 (PDT)
Subject: Re: [RFC v2 0/5] surface heterogeneous memory performance information
References: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
From: Bob Liu <liubo95@huawei.com>
Message-ID: <dc224433-3d09-8f2e-d278-fee98ada2afc@huawei.com>
Date: Wed, 19 Jul 2017 17:48:58 +0800
MIME-Version: 1.0
In-Reply-To: <20170706215233.11329-1-ross.zwisler@linux.intel.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jerome Glisse <jglisse@redhat.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On 2017/7/7 5:52, Ross Zwisler wrote:
> ==== Quick Summary ====
> 
> Platforms in the very near future will have multiple types of memory
> attached to a single CPU.  These disparate memory ranges will have some
> characteristics in common, such as CPU cache coherence, but they can have
> wide ranges of performance both in terms of latency and bandwidth.
> 
> For example, consider a system that contains persistent memory, standard
> DDR memory and High Bandwidth Memory (HBM), all attached to the same CPU.
> There could potentially be an order of magnitude or more difference in
> performance between the slowest and fastest memory attached to that CPU.
> 
> With the current Linux code NUMA nodes are CPU-centric, so all the memory
> attached to a given CPU will be lumped into the same NUMA node.  This makes
> it very difficult for userspace applications to understand the performance
> of different memory ranges on a given CPU.
> 
> We solve this issue by providing userspace with performance information on
> individual memory ranges.  This performance information is exposed via
> sysfs:
> 
>   # grep . mem_tgt2/* mem_tgt2/local_init/* 2>/dev/null
>   mem_tgt2/firmware_id:1
>   mem_tgt2/is_cached:0
>   mem_tgt2/is_enabled:1
>   mem_tgt2/is_isolated:0
>   mem_tgt2/phys_addr_base:0x0
>   mem_tgt2/phys_length_bytes:0x800000000
>   mem_tgt2/local_init/read_bw_MBps:30720
>   mem_tgt2/local_init/read_lat_nsec:100
>   mem_tgt2/local_init/write_bw_MBps:30720
>   mem_tgt2/local_init/write_lat_nsec:100
> 
> This allows applications to easily find the memory that they want to use.
> We expect that the existing NUMA APIs will be enhanced to use this new
> information so that applications can continue to use them to select their
> desired memory.
> 
> This series is built upon acpica-1705:
> 
> https://github.com/zetalog/linux/commits/acpica-1705
> 
> And you can find a working tree here:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/zwisler/linux.git/log/?h=hmem_sysfs
> 
> ==== Lots of Details ====
> 
> This patch set is only concerned with CPU-addressable memory types, not
> on-device memory like what we have with Jerome Glisse's HMM series:
> 
> https://lwn.net/Articles/726691/
> 
> This patch set works by enabling the new Heterogeneous Memory Attribute
> Table (HMAT) table, newly defined in ACPI 6.2. One major conceptual change
> in ACPI 6.2 related to this work is that proximity domains no longer need
> to contain a processor.  We can now have memory-only proximity domains,
> which means that we can now have memory-only Linux NUMA nodes.
> 
> Here is an example configuration where we have a single processor, one
> range of regular memory and one range of HBM:
> 
>   +---------------+   +----------------+
>   | Processor     |   | Memory         |
>   | prox domain 0 +---+ prox domain 1  |
>   | NUMA node 1   |   | NUMA node 2    |
>   +-------+-------+   +----------------+
>           |
>   +-------+----------+
>   | HBM              |
>   | prox domain 2    |
>   | NUMA node 0      |
>   +------------------+
> 
> This gives us one initiator (the processor) and two targets (the two memory
> ranges).  Each of these three has its own ACPI proximity domain and
> associated Linux NUMA node.  Note also that while there is a 1:1 mapping
> from each proximity domain to each NUMA node, the numbers don't necessarily
> match up.  Additionally we can have extra NUMA nodes that don't map back to
> ACPI proximity domains.
> 
> The above configuration could also have the processor and one of the two
> memory ranges sharing a proximity domain and NUMA node, but for the
> purposes of the HMAT the two memory ranges will always need to be
> separated.
> 
> The overall goal of this series and of the HMAT is to allow users to
> identify memory using its performance characteristics.  This can broadly be
> done in one of two ways:
> 
> Option 1: Provide the user with a way to map between proximity domains and
> NUMA nodes and a way to access the HMAT directly (probably via
> /sys/firmware/acpi/tables).  Then, through possibly a library and a daemon,
> provide an API so that applications can either request information about
> memory ranges, or request memory allocations that meet a given set of
> performance characteristics.
> 
> Option 2: Provide the user with HMAT performance data directly in sysfs,
> allowing applications to directly access it without the need for the
> library and daemon.
> 

Is it possible to do the memory allocation automatically by the kernel and transparent to users?
It sounds like unreasonable that most users should aware this detail memory topology.

--
Thanks,
Bob Liu

> The kernel work for option 1 is started by patches 1-3.  These just surface
> the minimal amount of information in sysfs to allow userspace to map
> between proximity domains and NUMA nodes so that the raw data in the HMAT
> table can be understood.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
