Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BCA5C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 11:35:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3C7321907
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 11:35:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3C7321907
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 525928E0029; Thu,  7 Feb 2019 06:35:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AC7F8E0002; Thu,  7 Feb 2019 06:35:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34CA28E0029; Thu,  7 Feb 2019 06:35:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 04D6B8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 06:35:57 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id r15so8997598ota.0
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 03:35:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=bXRIqAKncEZo989hqjTVv6bqL+jW1UMlxpHm6TTpyKU=;
        b=rV1eXnozhxkD0yXRtiOqv7vGIfBOJNAGyI8XVwrJfCElGORb1pYijDBPnU1Nc/8PnP
         lC/hqk4Q+DIzE8yl0lJd5enj442S3k05pgAeqthJiAw1K6YntRJ2R1i+df51LKfqH46M
         CcAZINN1wyrKggDJCfVTd+895cbn5B6KR5mFaj+10oS0maOuUQTfJOPaR2HH3Gp7j69h
         fH7MAK2hXsK0/Vpj1OG8+ubRwFdoovKmTEly3Vg2hDq6lucRbPezbsW0/d9/hiqftLuC
         GiRTZdvdUY2YTgFOu2YDXjch1jB4jc8j47A8pQyuby2I54llavzrPotfLX+xickcO5RP
         toiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubn/cmgH6wY5ZqhUoxbkaI7Q+IGUQ0DPAv+FnSldY5ezWbHP/0z
	1jZVeOdl4iDNFvu9lrlTy8EH1/GlKqFg/7S1Bue/IvIVk4INH9bJAoDX2tnUgLPTMVUQGzMyuay
	zOP+N8kqcePmJloYL7nnGmPPJ86YLeWIdsmgCuxFMSLnYUsiYEpMnjMMu5fwGej95MK8NaCHTJy
	lufjRtbwVlrv5FN+mY5wz96kcGKrcyL0oJFwQTV4K1wQ0YH0W9wRsZ0srAgqXA/JmXNEAPay4ji
	ou9jG6EyIrpW2RCf7Kw4JIAWeD0Yra7yuVuYTDCZo4H4TwcIdzwCxSugQqNmm4eegnK6EeSI7xO
	dqkSdWewuNkyNOaWMUhXr5f0LVsrSfkK3pnUIKAlh4D8bo7m6BrrR7BgjaA/NHz7+UVitJGfkg=
	=
X-Received: by 2002:aca:af41:: with SMTP id y62mr53655oie.24.1549539356688;
        Thu, 07 Feb 2019 03:35:56 -0800 (PST)
X-Received: by 2002:aca:af41:: with SMTP id y62mr53620oie.24.1549539355605;
        Thu, 07 Feb 2019 03:35:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549539355; cv=none;
        d=google.com; s=arc-20160816;
        b=KnCepnkmgXAqskJh8vjxq5htT/S/ofzUx7qWmbEUqDL4Ez1TU0XOv91+jVLqDPKULz
         LzKAFeO7aH09Aiv/3x1+ill0XCj8flayq+yHe6gFYbeH+uAqh0F4fgSCcnfE3u7LdQnM
         thcfAq8kqfEvudkAq82H8fZvxtq/orUQhWk2oQyiyh6ihuT8xdUHktcvDLkNXtiWuoby
         Ia3FhafZavY6IVnAI94XB48BM8740e3LzTQmMzINRJxfSDJvyehAuOVk69ZBzS/Bit70
         oQG25obNbrp2cX3oUHBxKCIU8FUEGbhp3ccIGTDRiB7tyRaoZ86OZy4WKslaOIDuN//+
         +J/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=bXRIqAKncEZo989hqjTVv6bqL+jW1UMlxpHm6TTpyKU=;
        b=FLGY+42Sa95/yvsjHGPXwAD2wazq+A7fsISKVM4M1NqapwEV0Yt6sQ1AdtkcIFTWSz
         dopAZIuPW1GQtIEp2X3lvb/zO9dvPfrZoLS60VP+2yreyBPcKLOtxCOBpCzY3AUIcfSY
         +5KBrbkupyamfHHuIBN2Vv1OZT8dnS8Itne2zW7YNwj00MITC17nXx/qvJGehhj91xlE
         dyCNIGc258mh2W3b9JxiVNsJ3icdwcTp9/xnl6ruVNcUYoBQ9+5VP2QHnYkSZ0vT3Nj2
         z3CDXUSc+ZqsMfA3xJ91J3+EmAfR40FsDkULRURCtVC8EWEDyTWJil5AWgoxv5/Fq1li
         86iQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor793983otf.164.2019.02.07.03.35.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 03:35:55 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IZ/kYNG/nEaudruGZ0roQVS4dPg0LalQ5OZrcQqHaY4Ios48tWkf/7v7yzA01QJBoBETuBmYqxxykclW8NLG6M=
X-Received: by 2002:a9d:4c84:: with SMTP id m4mr7936754otf.124.1549539354981;
 Thu, 07 Feb 2019 03:35:54 -0800 (PST)
MIME-Version: 1.0
References: <20190124230724.10022-1-keith.busch@intel.com> <20190124230724.10022-5-keith.busch@intel.com>
In-Reply-To: <20190124230724.10022-5-keith.busch@intel.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 7 Feb 2019 12:35:43 +0100
Message-ID: <CAJZ5v0jO5O36fkv2w5o_C-8g4TOY2wnmDiu0sGt9EhVQD++=rg@mail.gmail.com>
Subject: Re: [PATCHv5 04/10] node: Link memory nodes to their compute nodes
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 25, 2019 at 12:08 AM Keith Busch <keith.busch@intel.com> wrote:
>
> Systems may be constructed with various specialized nodes. Some nodes
> may provide memory, some provide compute devices that access and use
> that memory, and others may provide both. Nodes that provide memory are
> referred to as memory targets, and nodes that can initiate memory access
> are referred to as memory initiators.
>
> Memory targets will often have varying access characteristics from
> different initiators, and platforms may have ways to express those
> relationships. In preparation for these systems, provide interfaces for
> the kernel to export the memory relationship among different nodes memory
> targets and their initiators with symlinks to each other.
>
> If a system provides access locality for each initiator-target pair, nodes
> may be grouped into ranked access classes relative to other nodes. The
> new interface allows a subsystem to register relationships of varying
> classes if available and desired to be exported.
>
> A memory initiator may have multiple memory targets in the same access
> class. The target memory's initiators in a given class indicate the
> nodes access characteristics share the same performance relative to other
> linked initiator nodes. Each target within an initiator's access class,
> though, do not necessarily perform the same as each other.
>
> A memory target node may have multiple memory initiators. All linked
> initiators in a target's class have the same access characteristics to
> that target.
>
> The following example show the nodes' new sysfs hierarchy for a memory
> target node 'Y' with access class 0 from initiator node 'X':
>
>   # symlinks -v /sys/devices/system/node/nodeX/access0/
>   relative: /sys/devices/system/node/nodeX/access0/targets/nodeY -> ../../nodeY
>
>   # symlinks -v /sys/devices/system/node/nodeY/access0/
>   relative: /sys/devices/system/node/nodeY/access0/initiators/nodeX -> ../../nodeX
>
> The new attributes are added to the sysfs stable documentation.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>

Overall, if you decide to go for full struct device embedded in struct
node_access_nodes, feel free to add

Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

to this patch.

> ---
>  Documentation/ABI/stable/sysfs-devices-node |  25 ++++-
>  drivers/base/node.c                         | 142 +++++++++++++++++++++++++++-
>  include/linux/node.h                        |   7 +-
>  3 files changed, 171 insertions(+), 3 deletions(-)
>
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 3e90e1f3bf0a..fb843222a281 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -90,4 +90,27 @@ Date:                December 2009
>  Contact:       Lee Schermerhorn <lee.schermerhorn@hp.com>
>  Description:
>                 The node's huge page size control/query attributes.
> -               See Documentation/admin-guide/mm/hugetlbpage.rst
> \ No newline at end of file
> +               See Documentation/admin-guide/mm/hugetlbpage.rst
> +
> +What:          /sys/devices/system/node/nodeX/accessY/
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The node's relationship to other nodes for access class "Y".
> +
> +What:          /sys/devices/system/node/nodeX/accessY/initiators/
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The directory containing symlinks to memory initiator
> +               nodes that have class "Y" access to this target node's
> +               memory. CPUs and other memory initiators in nodes not in
> +               the list accessing this node's memory may have different
> +               performance.
> +
> +What:          /sys/devices/system/node/nodeX/classY/targets/
> +Date:          December 2018
> +Contact:       Keith Busch <keith.busch@intel.com>
> +Description:
> +               The directory containing symlinks to memory targets that
> +               this initiator node has class "Y" access.
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 86d6cd92ce3d..6f4097680580 100644
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
> @@ -59,6 +60,94 @@ static inline ssize_t node_read_cpulist(struct device *dev,
>  static DEVICE_ATTR(cpumap,  S_IRUGO, node_read_cpumask, NULL);
>  static DEVICE_ATTR(cpulist, S_IRUGO, node_read_cpulist, NULL);
>
> +/**
> + * struct node_access_nodes - Access class device to hold user visible
> + *                           relationships to other nodes.
> + * @dev:       Device for this memory access class
> + * @list_node: List element in the node's access list
> + * @access:    The access class rank
> + */
> +struct node_access_nodes {
> +       struct device           dev;
> +       struct list_head        list_node;
> +       unsigned                access;
> +};
> +#define to_access_nodes(dev) container_of(dev, struct node_access_nodes, dev)
> +
> +static struct attribute *node_init_access_node_attrs[] = {
> +       NULL,
> +};
> +
> +static struct attribute *node_targ_access_node_attrs[] = {
> +       NULL,
> +};
> +
> +static const struct attribute_group initiators = {
> +       .name   = "initiators",
> +       .attrs  = node_init_access_node_attrs,
> +};
> +
> +static const struct attribute_group targets = {
> +       .name   = "targets",
> +       .attrs  = node_targ_access_node_attrs,
> +};
> +
> +static const struct attribute_group *node_access_node_groups[] = {
> +       &initiators,
> +       &targets,
> +       NULL,
> +};
> +
> +static void node_remove_accesses(struct node *node)
> +{
> +       struct node_access_nodes *c, *cnext;
> +
> +       list_for_each_entry_safe(c, cnext, &node->access_list, list_node) {
> +               list_del(&c->list_node);
> +               device_unregister(&c->dev);
> +       }
> +}
> +
> +static void node_access_release(struct device *dev)
> +{
> +       kfree(to_access_nodes(dev));
> +}
> +
> +static struct node_access_nodes *node_init_node_access(struct node *node,
> +                                                      unsigned access)
> +{
> +       struct node_access_nodes *access_node;
> +       struct device *dev;
> +
> +       list_for_each_entry(access_node, &node->access_list, list_node)
> +               if (access_node->access == access)
> +                       return access_node;
> +
> +       access_node = kzalloc(sizeof(*access_node), GFP_KERNEL);
> +       if (!access_node)
> +               return NULL;
> +
> +       access_node->access = access;
> +       dev = &access_node->dev;
> +       dev->parent = &node->dev;
> +       dev->release = node_access_release;
> +       dev->groups = node_access_node_groups;
> +       if (dev_set_name(dev, "access%u", access))
> +               goto free;
> +
> +       if (device_register(dev))
> +               goto free_name;
> +
> +       pm_runtime_no_callbacks(dev);
> +       list_add_tail(&access_node->list_node, &node->access_list);
> +       return access_node;
> +free_name:
> +       kfree_const(dev->kobj.name);
> +free:
> +       kfree(access_node);
> +       return NULL;
> +}
> +
>  #define K(x) ((x) << (PAGE_SHIFT - 10))
>  static ssize_t node_read_meminfo(struct device *dev,
>                         struct device_attribute *attr, char *buf)
> @@ -340,7 +429,7 @@ static int register_node(struct node *node, int num)
>  void unregister_node(struct node *node)
>  {
>         hugetlb_unregister_node(node);          /* no-op, if memoryless node */
> -
> +       node_remove_accesses(node);
>         device_unregister(&node->dev);
>  }
>
> @@ -372,6 +461,56 @@ int register_cpu_under_node(unsigned int cpu, unsigned int nid)
>                                  kobject_name(&node_devices[nid]->dev.kobj));
>  }
>
> +/**
> + * register_memory_node_under_compute_node - link memory node to its compute
> + *                                          node for a given access class.
> + * @mem_node:  Memory node number
> + * @cpu_node:  Cpu  node number
> + * @access:    Access class to register
> + *
> + * Description:
> + *     For use with platforms that may have separate memory and compute nodes.
> + *     This function will export node relationships linking which memory
> + *     initiator nodes can access memory targets at a given ranked access
> + *     class.
> + */
> +int register_memory_node_under_compute_node(unsigned int mem_nid,
> +                                           unsigned int cpu_nid,
> +                                           unsigned access)
> +{
> +       struct node *init_node, *targ_node;
> +       struct node_access_nodes *initiator, *target;
> +       int ret;
> +
> +       if (!node_online(cpu_nid) || !node_online(mem_nid))
> +               return -ENODEV;
> +
> +       init_node = node_devices[cpu_nid];
> +       targ_node = node_devices[mem_nid];
> +       initiator = node_init_node_access(init_node, access);
> +       target = node_init_node_access(targ_node, access);
> +       if (!initiator || !target)
> +               return -ENOMEM;
> +
> +       ret = sysfs_add_link_to_group(&initiator->dev.kobj, "targets",
> +                                     &targ_node->dev.kobj,
> +                                     dev_name(&targ_node->dev));
> +       if (ret)
> +               return ret;
> +
> +       ret = sysfs_add_link_to_group(&target->dev.kobj, "initiators",
> +                                     &init_node->dev.kobj,
> +                                     dev_name(&init_node->dev));
> +       if (ret)
> +               goto err;
> +
> +       return 0;
> + err:
> +       sysfs_remove_link_from_group(&initiator->dev.kobj, "targets",
> +                                    dev_name(&targ_node->dev));
> +       return ret;
> +}
> +
>  int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
>  {
>         struct device *obj;
> @@ -580,6 +719,7 @@ int __register_one_node(int nid)
>                         register_cpu_under_node(cpu, nid);
>         }
>
> +       INIT_LIST_HEAD(&node_devices[nid]->access_list);
>         /* initialize work queue for memory hot plug */
>         init_node_hugetlb_work(nid);
>
> diff --git a/include/linux/node.h b/include/linux/node.h
> index 257bb3d6d014..f34688a203c1 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -17,11 +17,12 @@
>
>  #include <linux/device.h>
>  #include <linux/cpumask.h>
> +#include <linux/list.h>
>  #include <linux/workqueue.h>
>
>  struct node {
>         struct device   dev;
> -
> +       struct list_head access_list;
>  #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
>         struct work_struct      node_work;
>  #endif
> @@ -75,6 +76,10 @@ extern int register_mem_sect_under_node(struct memory_block *mem_blk,
>  extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>                                            unsigned long phys_index);
>
> +extern int register_memory_node_under_compute_node(unsigned int mem_nid,
> +                                                  unsigned int cpu_nid,
> +                                                  unsigned access);
> +
>  #ifdef CONFIG_HUGETLBFS
>  extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
>                                          node_registration_func_t unregister);
> --
> 2.14.4
>

