Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 716208E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 06:26:29 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id q11so4683001otl.23
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 03:26:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y10sor618523oia.59.2019.01.17.03.26.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 03:26:28 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-5-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-5-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 17 Jan 2019 12:26:16 +0100
Message-ID: <CAJZ5v0hRsW037B1uPMYj=UO6TWDX9CWVyhYYjVjnvKQ=4ZaU5w@mail.gmail.com>
Subject: Re: [PATCHv4 04/13] node: Link memory nodes to their compute nodes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Systems may be constructed with various specialized nodes. Some nodes
> may provide memory, some provide compute devices that access and use
> that memory, and others may provide both. Nodes that provide memory are
> referred to as memory targets, and nodes that can initiate memory access
> are referred to as memory initiators.
>
> Memory targets will often have varying access characteristics from
> different initiators, and platforms may have ways to express those
> relationships. In preparation for these systems, provide interfaces
> for the kernel to export the memory relationship among different nodes
> memory targets and their initiators with symlinks to each other's nodes,
> and export node lists showing the same relationship.
>
> If a system provides access locality for each initiator-target pair, nodes
> may be grouped into ranked access classes relative to other nodes. The new
> interface allows a subsystem to register relationships of varying classes
> if available and desired to be exported. A lower class number indicates
> a higher performing tier, with 0 being the best performing class.
>
> A memory initiator may have multiple memory targets in the same access
> class. The initiator's memory targets in given class indicate the node's
> access characteristics perform better relative to other initiator nodes
> either unreported or in lower class numbers. The targets within an
> initiator's class, though, do not necessarily perform the same as each
> other.
>
> A memory target node may have multiple memory initiators. All linked
> initiators in a target's class have the same access characteristics to
> that target.
>
> The following example show the nodes' new sysfs hierarchy for a memory
> target node 'Y' with class 0 access from initiator node 'X':
>
>   # symlinks -v /sys/devices/system/node/nodeX/class0/
>   relative: /sys/devices/system/node/nodeX/class0/targetY -> ../../nodeY

If you added one more directory level and had "targets" and
"initiators" under "class0", the names of the symlinks could be the
same as the names of the nodes themselves, that is

/sys/devices/system/node/nodeX/class0/targets/nodeY -> ../../../nodeY

and the whole "nodelist" part wouldn't be necessary any more.

Also, it looks like "class0" is just a name at this point, but it will
represent an access class going forward.  Maybe it would be better to
use the word "access" in the directory name to indicate that (so there
would be "access0" instead of "class0").

>
>   # symlinks -v /sys/devices/system/node/nodeY/class0/
>   relative: /sys/devices/system/node/nodeY/class0/initiatorX -> ../../nodeX
>
> And the same information is reflected in the nodelist:
>
>   # cat /sys/devices/system/node/nodeX/class0/target_nodelist
>   Y
>
>   # cat /sys/devices/system/node/nodeY/class0/initiator_nodelist
>   X
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/base/node.c  | 127 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/node.h |   6 ++-
>  2 files changed, 131 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 86d6cd92ce3d..1da5072116ab 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -17,6 +17,7 @@
>  #include <linux/nodemask.h>
>  #include <linux/cpu.h>
>  #include <linux/device.h>
> +#include <linux/pm_runtime.h>
>  #include <linux/swap.h>
>  #include <linux/slab.h>
>
> @@ -59,6 +60,91 @@ static inline ssize_t node_read_cpulist(struct device *dev,
>  static DEVICE_ATTR(cpumap,  S_IRUGO, node_read_cpumask, NULL);
>  static DEVICE_ATTR(cpulist, S_IRUGO, node_read_cpulist, NULL);
>

A kerneldoc describing the struct type, please.

> +struct node_class_nodes {
> +       struct device           dev;
> +       struct list_head        list_node;
> +       unsigned                class;
> +       nodemask_t              initiator_nodes;
> +       nodemask_t              target_nodes;
> +};
> +#define to_class_nodes(dev) container_of(dev, struct node_class_nodes, dev)
> +

Generally speaking, your code is devoid of comments.

To a minimum, there should be kerneldoc comments for non-static
functions to explain what they are for.
