Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 339B68E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 13:19:02 -0500 (EST)
Received: by mail-vk1-f200.google.com with SMTP id t192so2447999vkt.9
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 10:19:02 -0800 (PST)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id q11si1993225vsc.45.2019.01.17.10.18.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 10:19:00 -0800 (PST)
Date: Thu, 17 Jan 2019 18:18:35 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
Subject: Re: [PATCHv4 00/13] Heterogeneuos memory node attributes
Message-ID: <20190117181835.000034ab@huawei.com>
In-Reply-To: <20190116175804.30196-1-keith.busch@intel.com>
References: <20190116175804.30196-1-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, linuxarm@huawei.com

On Wed, 16 Jan 2019 10:57:51 -0700
Keith Busch <keith.busch@intel.com> wrote:

> The series seems quite calm now. I've received some approvals of the
> on the proposal, and heard no objections on the new core interfaces.
> 
> Please let me know if there is anyone or group of people I should request
> and wait for a review. And if anyone reading this would like additional
> time as well before I post a potentially subsequent version, please let
> me know.
> 
> I also wanted to inquire on upstream strategy if/when all desired
> reviews are received. The series is spanning a few subsystems, so I'm
> not sure who's tree is the best candidate. I could see an argument for
> driver-core, acpi, or mm as possible paths. Please let me know if there's
> a more appropriate option or any other gating concerns.
> 
> == Changes from v3 ==
> 
>   I've fixed the documentation issues that have been raised for v3 
> 
>   Moved the hmat files according to Rafael's recommendation
> 
>   Added received Reviewed-by's
> 
> Otherwise this v4 is much the same as v3.
> 
> == Background ==
> 
> Platforms may provide multiple types of cpu attached system memory. The
> memory ranges for each type may have different characteristics that
> applications may wish to know about when considering what node they want
> their memory allocated from. 
> 
> It had previously been difficult to describe these setups as memory
> rangers were generally lumped into the NUMA node of the CPUs. New
> platform attributes have been created and in use today that describe
> the more complex memory hierarchies that can be created.
> 
> This series' objective is to provide the attributes from such systems
> that are useful for applications to know about, and readily usable with
> existing tools and libraries.
> 

Hi Keith, 

I've been having a play with various hand constructed HMAT tables to allow
me to try breaking them in all sorts of ways.

Mostly working as expected.

Two places I am so far unsure on...

1. Concept of 'best' is not implemented in a consistent fashion.

I don't agree with the logic to match on 'best' because it can give some counter
intuitive sets of target nodes.

For my simple test case we have both the latency and bandwidth specified (using
access as I'm lazy and it saves typing).

Rather that matching when both are the best value, we match when _any_ of the
measurements is the 'best' for the type of measurement.

A simple system with a high bandwidth interconnect between two SoCs
might well have identical bandwidths to memory connected to each node, but
much worse latency to the remote one.  Another simple case would be DDR and
SCM on roughly the same memory controller.  Bandwidths likely to be equal,
latencies very different.

Right now we get both nodes in the list of 'best' ones because the bandwidths
are equal which is far from ideal.  It also means we are presenting one value
for both latency and bandwidth, misrepresenting the ones where it doesn't apply.

If we aren't going to specify that both must be "best", then I think we should
separate the bandwidth and latency classes, requiring userspace to check
both if they want the best combination of latency and bandwidth. I'm also
happy enough (having not thought about it much) to have one class where the 'best'
is the value sorted first on best latency and then on best bandwidth.

2. Handling of memory only nodes - that might have a device attached - _PXM

This is a common situation in CCIX for example where you have an accelerator
with coherent memory homed at it. Looks like a pci device in a domain with
the memory.   Right now you can't actually do this as _PXM is processed
for pci devices, but we'll get that fixed (broken threadripper firmwares
meant it got reverted last cycle).

In my case I have 4 nodes with cpu and memory (0,1,2,3) and 2 memory only (4,5)
Memory only are longer latency and lower bandwidth.

Now
ls /sys/bus/nodes/devices/node0/class0/
...

initiator0
target0
target4
target5

read_bandwidth = 15000
read_latency = 10000

These two values (and their paired write values) are correct for initiator0 to target0
but completely wrong for initiator0 to target4 or target5.

This occurs because we loop over the targets looking for the best values and add
set the relevant bit in t->p_nodes based on that.  These memory only nodes have
a best value that happens to be equal from all the initiators.  The issue is it
isn't the one reported in the node0/class0.

Also if we look in
/sys/bus/nodes/devices/node4/class0 there are no targets listed (there are the expected
4 initiators 0-3).

I'm not sure what the intended behavior would be in this case.

I'll run some more tests tomorrow.

Jonathan

> Keith Busch (13):
>   acpi: Create subtable parsing infrastructure
>   acpi: Add HMAT to generic parsing tables
>   acpi/hmat: Parse and report heterogeneous memory
>   node: Link memory nodes to their compute nodes
>   Documentation/ABI: Add new node sysfs attributes
>   acpi/hmat: Register processor domain to its memory
>   node: Add heterogenous memory access attributes
>   Documentation/ABI: Add node performance attributes
>   acpi/hmat: Register performance attributes
>   node: Add memory caching attributes
>   Documentation/ABI: Add node cache attributes
>   acpi/hmat: Register memory side cache attributes
>   doc/mm: New documentation for memory performance
> 
>  Documentation/ABI/stable/sysfs-devices-node   |  87 +++++-
>  Documentation/admin-guide/mm/numaperf.rst     | 184 +++++++++++++
>  arch/arm64/kernel/acpi_numa.c                 |   2 +-
>  arch/arm64/kernel/smp.c                       |   4 +-
>  arch/ia64/kernel/acpi.c                       |  12 +-
>  arch/x86/kernel/acpi/boot.c                   |  36 +--
>  drivers/acpi/Kconfig                          |   1 +
>  drivers/acpi/Makefile                         |   1 +
>  drivers/acpi/hmat/Kconfig                     |   9 +
>  drivers/acpi/hmat/Makefile                    |   1 +
>  drivers/acpi/hmat/hmat.c                      | 375 ++++++++++++++++++++++++++
>  drivers/acpi/numa.c                           |  16 +-
>  drivers/acpi/scan.c                           |   4 +-
>  drivers/acpi/tables.c                         |  76 +++++-
>  drivers/base/Kconfig                          |   8 +
>  drivers/base/node.c                           | 317 +++++++++++++++++++++-
>  drivers/irqchip/irq-gic-v2m.c                 |   2 +-
>  drivers/irqchip/irq-gic-v3-its-pci-msi.c      |   2 +-
>  drivers/irqchip/irq-gic-v3-its-platform-msi.c |   2 +-
>  drivers/irqchip/irq-gic-v3-its.c              |   6 +-
>  drivers/irqchip/irq-gic-v3.c                  |  10 +-
>  drivers/irqchip/irq-gic.c                     |   4 +-
>  drivers/mailbox/pcc.c                         |   2 +-
>  include/linux/acpi.h                          |   6 +-
>  include/linux/node.h                          |  70 ++++-
>  25 files changed, 1172 insertions(+), 65 deletions(-)
>  create mode 100644 Documentation/admin-guide/mm/numaperf.rst
>  create mode 100644 drivers/acpi/hmat/Kconfig
>  create mode 100644 drivers/acpi/hmat/Makefile
>  create mode 100644 drivers/acpi/hmat/hmat.c
> 
