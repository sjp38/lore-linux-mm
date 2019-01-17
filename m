Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3EB188E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 10:03:56 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id o13so4987250otl.20
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 07:03:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32sor877304otc.45.2019.01.17.07.03.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 07:03:54 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-8-keith.busch@intel.com>
In-Reply-To: <20190116175804.30196-8-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 17 Jan 2019 16:03:42 +0100
Message-ID: <CAJZ5v0jCEdhKndgZgJ=SdHgFBM1Bcxusm_crYzAOTZDx3s=PdQ@mail.gmail.com>
Subject: Re: [PATCHv4 07/13] node: Add heterogenous memory access attributes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>

 On Wed, Jan 16, 2019 at 6:59 PM Keith Busch <keith.busch@intel.com> wrote:
>
> Heterogeneous memory systems provide memory nodes with different latency
> and bandwidth performance attributes. Provide a new kernel interface for
> subsystems to register the attributes under the memory target node's
> initiator access class. If the system provides this information, applications
> may query these attributes when deciding which node to request memory.
>
> The following example shows the new sysfs hierarchy for a node exporting
> performance attributes:
>
>   # tree -P "read*|write*" /sys/devices/system/node/nodeY/classZ/
>   /sys/devices/system/node/nodeY/classZ/
>   |-- read_bandwidth
>   |-- read_latency
>   |-- write_bandwidth
>   `-- write_latency
>
> The bandwidth is exported as MB/s and latency is reported in nanoseconds.
> Memory accesses from an initiator node that is not one of the memory's
> class "Z" initiator nodes may encounter different performance than
> reported here. When a subsystem makes use of this interface, initiators
> of a lower class number, "Z", have better performance relative to higher
> class numbers. When provided, class 0 is the highest performing access
> class.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/base/Kconfig |  8 ++++++++
>  drivers/base/node.c  | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/node.h | 25 +++++++++++++++++++++++++
>  3 files changed, 81 insertions(+)
>
> diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
> index 3e63a900b330..6014980238e8 100644
> --- a/drivers/base/Kconfig
> +++ b/drivers/base/Kconfig
> @@ -149,6 +149,14 @@ config DEBUG_TEST_DRIVER_REMOVE
>           unusable. You should say N here unless you are explicitly looking to
>           test this functionality.
>
> +config HMEM_REPORTING
> +       bool
> +       default y
> +       depends on NUMA
> +       help
> +         Enable reporting for heterogenous memory access attributes under
> +         their non-uniform memory nodes.

Why would anyone ever want to say "no" to this?

Distros will set it anyway.

> +
>  source "drivers/base/test/Kconfig"
>
>  config SYS_HYPERVISOR
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 1da5072116ab..1e909f61e8b1 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -66,6 +66,9 @@ struct node_class_nodes {
>         unsigned                class;
>         nodemask_t              initiator_nodes;
>         nodemask_t              target_nodes;
> +#ifdef CONFIG_HMEM_REPORTING
> +       struct node_hmem_attrs  hmem_attrs;
> +#endif
>  };
>  #define to_class_nodes(dev) container_of(dev, struct node_class_nodes, dev)
>
> @@ -145,6 +148,51 @@ static struct node_class_nodes *node_init_node_class(struct device *parent,
>         return NULL;
>  }
>
> +#ifdef CONFIG_HMEM_REPORTING
> +#define ACCESS_ATTR(name)                                                 \
> +static ssize_t name##_show(struct device *dev,                            \
> +                          struct device_attribute *attr,                  \
> +                          char *buf)                                      \
> +{                                                                         \
> +       return sprintf(buf, "%u\n", to_class_nodes(dev)->hmem_attrs.name); \
> +}                                                                         \
> +static DEVICE_ATTR_RO(name);
> +
> +ACCESS_ATTR(read_bandwidth)
> +ACCESS_ATTR(read_latency)
> +ACCESS_ATTR(write_bandwidth)
> +ACCESS_ATTR(write_latency)
> +
> +static struct attribute *access_attrs[] = {
> +       &dev_attr_read_bandwidth.attr,
> +       &dev_attr_read_latency.attr,
> +       &dev_attr_write_bandwidth.attr,
> +       &dev_attr_write_latency.attr,
> +       NULL,
> +};
> +ATTRIBUTE_GROUPS(access);
> +

Kerneldoc?

And who is going to call this?

> +void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
> +                        unsigned class)
> +{
> +       struct node_class_nodes *c;
> +       struct node *node;
> +
> +       if (WARN_ON_ONCE(!node_online(nid)))
> +               return;
> +
> +       node = node_devices[nid];
> +       c = node_init_node_class(&node->dev, &node->class_list, class);
> +       if (!c)
> +               return;
> +
> +       c->hmem_attrs = *hmem_attrs;
> +       if (sysfs_create_groups(&c->dev.kobj, access_groups))
> +               pr_info("failed to add performance attribute group to node %d\n",
> +                       nid);
> +}
> +#endif
> +
>  #define K(x) ((x) << (PAGE_SHIFT - 10))
>  static ssize_t node_read_meminfo(struct device *dev,
>                         struct device_attribute *attr, char *buf)
> diff --git a/include/linux/node.h b/include/linux/node.h
> index 8e3666c12ef2..e22940a593c2 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -20,6 +20,31 @@
>  #include <linux/list.h>
>  #include <linux/workqueue.h>
>
> +#ifdef CONFIG_HMEM_REPORTING
> +/**
> + * struct node_hmem_attrs - heterogeneous memory performance attributes
> + *
> + * @read_bandwidth:    Read bandwidth in MB/s
> + * @write_bandwidth:   Write bandwidth in MB/s
> + * @read_latency:      Read latency in nanoseconds
> + * @write_latency:     Write latency in nanoseconds
> + */
> +struct node_hmem_attrs {
> +       unsigned int read_bandwidth;
> +       unsigned int write_bandwidth;
> +       unsigned int read_latency;
> +       unsigned int write_latency;
> +};
> +void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
> +                        unsigned class);
> +#else
> +static inline void node_set_perf_attrs(unsigned int nid,
> +                                      struct node_hmem_attrs *hmem_attrs,
> +                                      unsigned class)
> +{
> +}

Have you tried to compile this with CONFIG_HMEM_REPORTING unset?

> +#endif
> +
>  struct node {
>         struct device   dev;
>         struct list_head class_list;
> --
