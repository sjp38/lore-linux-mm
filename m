Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 97ED78E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:00:12 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i55so6669283ede.14
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:00:12 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r24si956323edi.201.2019.01.28.06.00.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 06:00:10 -0800 (PST)
Date: Mon, 28 Jan 2019 15:00:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv5 00/10] Heterogeneuos memory node attributes
Message-ID: <20190128140009.GA11059@dhcp22.suse.cz>
References: <20190124230724.10022-1-keith.busch@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124230724.10022-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-api@vger.kernel.org

Is there any reason why is this not CCing linux-api (Cced now).

On Thu 24-01-19 16:07:14, Keith Busch wrote:
> == Changes since v4 ==
> 
>   All public interfaces have kernel docs.
> 
>   Renamed "class" to "access", docs and changed logs updated
>   accordingly. (Rafael)
> 
>   The sysfs hierarchy is altered to put initiators and targets in their
>   own attribute group directories (Rafael).
> 
>   The node lists are removed. This feedback is in conflict with v1
>   feedback, but consensus wants to remove multi-value sysfs attributes,
>   which includes lists. We only have symlinks now, just like v1 provided.
> 
>   Documentation and code patches are combined such that the code
>   introducing new attributes and its documentation are in the same
>   patch. (Rafael and Dan).
> 
>   The performance attributes, bandwidth and latency, are moved into the
>   initiators directory. This should make it obvious for which node
>   access the attributes apply, which was previously ambiguous.
>   (Jonathan Cameron).
> 
>   The HMAT code selecting "local" initiators is substantially changed.
>   Only PXM's that have identical performance to the HMAT's processor PXM
>   in Address Range Structure are registered. This is to avoid considering
>   nodes identical when only one of several perf attributes are the same.
>   (Jonathan Cameron).
> 
>   Verbose variable naming. Examples include "initiator" and "target"
>   instead of "i" and "t", "mem_pxm" and "cpu_pxm" instead of "m" and
>   "p". (Rafael)
> 
>   Compile fixes for when HMEM_REPORTING is not set. This is not a user
>   selectable config option, default 'n', and will have to be selected
>   by other config options that require it (Greg KH and Rafael).
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

Can you provide a highlevel description of these new attributes and how
they are supposed to be used.

Mentioning usecases is also due consideirng the amount of code this
adds. 

> Keith Busch (10):
>   acpi: Create subtable parsing infrastructure
>   acpi: Add HMAT to generic parsing tables
>   acpi/hmat: Parse and report heterogeneous memory
>   node: Link memory nodes to their compute nodes
>   acpi/hmat: Register processor domain to its memory
>   node: Add heterogenous memory access attributes
>   acpi/hmat: Register performance attributes
>   node: Add memory caching attributes
>   acpi/hmat: Register memory side cache attributes
>   doc/mm: New documentation for memory performance
> 
>  Documentation/ABI/stable/sysfs-devices-node   |  87 ++++-
>  Documentation/admin-guide/mm/numaperf.rst     | 167 ++++++++
>  arch/arm64/kernel/acpi_numa.c                 |   2 +-
>  arch/arm64/kernel/smp.c                       |   4 +-
>  arch/ia64/kernel/acpi.c                       |  12 +-
>  arch/x86/kernel/acpi/boot.c                   |  36 +-
>  drivers/acpi/Kconfig                          |   1 +
>  drivers/acpi/Makefile                         |   1 +
>  drivers/acpi/hmat/Kconfig                     |   9 +
>  drivers/acpi/hmat/Makefile                    |   1 +
>  drivers/acpi/hmat/hmat.c                      | 537 ++++++++++++++++++++++++++
>  drivers/acpi/numa.c                           |  16 +-
>  drivers/acpi/scan.c                           |   4 +-
>  drivers/acpi/tables.c                         |  76 +++-
>  drivers/base/Kconfig                          |   8 +
>  drivers/base/node.c                           | 354 ++++++++++++++++-
>  drivers/irqchip/irq-gic-v2m.c                 |   2 +-
>  drivers/irqchip/irq-gic-v3-its-pci-msi.c      |   2 +-
>  drivers/irqchip/irq-gic-v3-its-platform-msi.c |   2 +-
>  drivers/irqchip/irq-gic-v3-its.c              |   6 +-
>  drivers/irqchip/irq-gic-v3.c                  |  10 +-
>  drivers/irqchip/irq-gic.c                     |   4 +-
>  drivers/mailbox/pcc.c                         |   2 +-
>  include/linux/acpi.h                          |   6 +-
>  include/linux/node.h                          |  60 ++-
>  25 files changed, 1344 insertions(+), 65 deletions(-)
>  create mode 100644 Documentation/admin-guide/mm/numaperf.rst
>  create mode 100644 drivers/acpi/hmat/Kconfig
>  create mode 100644 drivers/acpi/hmat/Makefile
>  create mode 100644 drivers/acpi/hmat/hmat.c
> 
> -- 
> 2.14.4

-- 
Michal Hocko
SUSE Labs
