Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5766B0260
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:00:35 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id k126so2595331wmd.5
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 05:00:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si3469779wrb.286.2017.12.14.05.00.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 05:00:34 -0800 (PST)
Date: Thu, 14 Dec 2017 14:00:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 0/3] create sysfs representation of ACPI HMAT
Message-ID: <20171214130032.GK16951@dhcp22.suse.cz>
References: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171214021019.13579-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>, "Box, David E" <david.e.box@intel.com>, "Kogut, Jaroslaw" <Jaroslaw.Kogut@intel.com>, "Koss, Marcin" <marcin.koss@intel.com>, "Koziej, Artur" <artur.koziej@intel.com>, "Lahtinen, Joonas" <joonas.lahtinen@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Nachimuthu, Murugasamy" <murugasamy.nachimuthu@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "Schmauss, Erik" <erik.schmauss@intel.com>, "Verma, Vishal L" <vishal.l.verma@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Brice Goglin <brice.goglin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Len Brown <lenb@kernel.org>, Tim Chen <tim.c.chen@linux.intel.com>, devel@acpica.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-api@vger.kernel.org

[CC linix-api]

On Wed 13-12-17 19:10:16, Ross Zwisler wrote:
> This is the third revision of my patches adding a sysfs representation
> of the ACPI Heterogeneous Memory Attribute Table (HMAT).  These patches
> are based on v4.15-rc3 and a working tree can be found here:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/zwisler/linux.git/log/?h=hmat_v3
> 
> My goal is to get these patches merged for v4.16.

Has actually reviewed the overal design already for this to be 4.16
thing? I do not see any acks/reviewed-bys in any of the patches...

> Changes from previous version (https://lkml.org/lkml/2017/7/6/749):

... comments on this last posting are touching the surface rather than
really discuss the overal design.

>  - Changed "HMEM" to "HMAT" and "hmem" to "hmat" throughout to make sure
>    that this effort doesn't get confused with Jerome's HMM work and to
>    make it clear that this enabling is tightly tied to the ACPI HMAT
>    table.  (John Hubbard)
> 
>  - Moved the link in the initiator (i.e. mem_init0/mem_tgt2) from
>    pointing to the "mem_tgt2/local_init" attribute group to instead
>    point at the mem_tgt2 target itself.  (Brice Goglin)
> 
>  - Simplified the contents of both the initiators and the targets so
>    that we just symlink to the NUMA node and don't duplicate
>    information.  For initiators this means that we no longer enumerate
>    CPUs, and for targets this means that we don't provide physical
>    address start and length information.  All of this is already
>    available in the NUMA node directory itself (i.e.
>    /sys/devices/system/node/node0), and it already accounts for the fact
>    that both multiple CPUs and multiple memory regions can be owned by a
>    given NUMA node.  Also removed some extra attributes (is_enabled,
>    is_isolated) which I don't think are useful at this point in time.
> 
> I have tested this against many different configs that I implemented
> using qemu.

What is the testing procedure? How can I setup qemu to simlate such HW?

[Keeping the rest of the email for linux-api reference]

> ---
> 
> ==== Quick Summary ====
> 
> Platforms exist today which have multiple types of memory attached to a
> single CPU.  These disparate memory ranges have some characteristics in
> common, such as CPU cache coherence, but they can have wide ranges of
> performance both in terms of latency and bandwidth.
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
>   mem_tgt2/local_init/read_bw_MBps:40960
>   mem_tgt2/local_init/read_lat_nsec:50
>   mem_tgt2/local_init/write_bw_MBps:40960
>   mem_tgt2/local_init/write_lat_nsec:50
> 
> This allows applications to easily find the memory that they want to use.
> We expect that the existing NUMA APIs will be enhanced to use this new
> information so that applications can continue to use them to select their
> desired memory.

How? Could you provide some examples?

> ==== Lots of Details ====
> 
> This patch set provides a sysfs representation of parts of the
> Heterogeneous Memory Attribute Table (HMAT), newly defined in ACPI 6.2.
> One major conceptual change in ACPI 6.2 related to this work is that
> proximity domains no longer need to contain a processor.  We can now
> have memory-only proximity domains, which means that we can now have
> memory-only Linux NUMA nodes.
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
> purposes of the HMAT the two memory ranges will need to be separated.
> 
> The overall goal of this series and of the HMAT is to allow users to
> identify memory using its performance characteristics.  This is
> complicated by the amount of HMAT data that could be present in very
> large systems, so in this series we only surface performance information
> for local (initiator,target) pairings.  The changelog for patch 5
> discusses this in detail.
> 
> Ross Zwisler (3):
>   acpi: HMAT support in acpi_parse_entries_array()
>   hmat: add heterogeneous memory sysfs support
>   hmat: add performance attributes
> 
>  MAINTAINERS                         |   6 +
>  drivers/acpi/Kconfig                |   1 +
>  drivers/acpi/Makefile               |   1 +
>  drivers/acpi/hmat/Kconfig           |   7 +
>  drivers/acpi/hmat/Makefile          |   2 +
>  drivers/acpi/hmat/core.c            | 797 ++++++++++++++++++++++++++++++++++++
>  drivers/acpi/hmat/hmat.h            |  64 +++
>  drivers/acpi/hmat/initiator.c       |  43 ++
>  drivers/acpi/hmat/perf_attributes.c |  56 +++
>  drivers/acpi/hmat/target.c          |  55 +++
>  drivers/acpi/tables.c               |  52 ++-
>  11 files changed, 1073 insertions(+), 11 deletions(-)
>  create mode 100644 drivers/acpi/hmat/Kconfig
>  create mode 100644 drivers/acpi/hmat/Makefile
>  create mode 100644 drivers/acpi/hmat/core.c
>  create mode 100644 drivers/acpi/hmat/hmat.h
>  create mode 100644 drivers/acpi/hmat/initiator.c
>  create mode 100644 drivers/acpi/hmat/perf_attributes.c
>  create mode 100644 drivers/acpi/hmat/target.c
> 
> -- 
> 2.14.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
