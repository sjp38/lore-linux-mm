Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A20BC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 10:35:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26D852084F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 10:35:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26D852084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0A8A8E0016; Mon, 11 Mar 2019 06:34:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBB148E0002; Mon, 11 Mar 2019 06:34:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5B4E8E0016; Mon, 11 Mar 2019 06:34:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 747388E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 06:34:59 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id h127so2163818oib.20
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 03:34:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=jlOT4JU8hyfBXhzrzsM62mIfrjTH8IwzUVURf8QTCJw=;
        b=SpZldw9SxUXpj89/+jFG/UHG9oihlRk5ChsO5IBwV9RjngykWD8PQMzIQUGZhCdP8G
         Eg0jyuAiY+zgs26WRIbWJCKiz0JefFu3dRLwzIENzwyof53VuoQYSmQMW/gxtJcRcZ2+
         4BQP93lLcRos1tjgS3n8EWYfeEfJzX3D9yvnxvsZa9QW2SbLoizIbTsvkmUzVEW3MRV7
         jALOF9lASKOMQJmEjV+CdcCn8Q+AmmUAI79U0iVO6D86A9tOnuKQ566u7xfzIyDnzbgl
         DJRwEXY5U6Q2wuGo0OzzztA/tI7K3SthlRhhiaz3jdQbU7g8J1WNgWyEOAFGTP5/tNyp
         EsRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAXACBAfMk17iPu4w9mNuOeZ5eUm7I7OBM3ynAQ2XdKQ/97OGK5q
	ujR+LyBW/gF7FhY6BEFxLNsjHpNG5ejWv71LlhWaE8iu7cJDqApGt0njtqE0bXZNkBTyq9EP1aZ
	W5gqmOuDiDCEqk4nSABPdAh7gen63t+lY1AckvRLAkXBm2smJrCnOOMCrVZgzL+hJuw==
X-Received: by 2002:a9d:5889:: with SMTP id x9mr19474990otg.109.1552300499078;
        Mon, 11 Mar 2019 03:34:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTCSoeL3ELhyASRdadOYUDvNkZVN/f5QzJs5rO6mCJazxn8CY/pBWMkdWeneLAXX8+Is2O
X-Received: by 2002:a9d:5889:: with SMTP id x9mr19474944otg.109.1552300497749;
        Mon, 11 Mar 2019 03:34:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552300497; cv=none;
        d=google.com; s=arc-20160816;
        b=P+Or6K9tFlF8WgqDJge812XRG7o9o+RZNmsQBeVfuZNnU5R/VxaGxO98Aj+Hq6lof6
         3iA1kB0xvQG/8eZgK/VlWKSMkxvyLjMNNWqoYXI+slJpo+0irmqj4iaNYIvz8l/EFdWj
         dMaJOSQyIvWQzv4vnIJakPKpw4o2ATWXS3CBBp49sWiCsz5xeiaXbevR/VC7zKgyqAQl
         nxtQKZg7MMF3kag0hcjHRYDmU+R37YSojg7IrK/oRSr9tsz7Z3UxN1CVnQwPys4w/Bzu
         sne5E5FoJaLFU0FSlkdapx1TwO01akGnB+dvqU7XTmM01GLyDFWfufpWJFeHsqaarrHL
         IQtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=jlOT4JU8hyfBXhzrzsM62mIfrjTH8IwzUVURf8QTCJw=;
        b=DENNwUuzNm84K7mIVx73/THT2ybFKn1R/sso1xWFZkCNKmf+/E7FpsW3AxvCkh2rEa
         yDuMiReckVCNyxKhASUFaeAQ7gXAT5ejot7nI9yLzN/BsJ62s1qHNcTYoflSIgCiBUNM
         OpfkX7KL64afRhFrAzI5ShqdaQ0TYpeSxlqDYhzEhgKmtWL8Vd47HAm1CXLAI0vpnILV
         m3d2RnanDnhJ9keJ/pPzS6ForZrGkFfAnm+1Uz+AEYubsc6yKjdCr8HtXvwSszuOL+lt
         fva1NwrwlS2A6vu7T8LOTe55gJgrwHAT4Kbu10zzPA0YhRFURLPpZZTJNLSXuwPHKJM7
         Zlkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id x127si2298658oif.244.2019.03.11.03.34.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 03:34:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 2F60CA7D5E58BD7558A1;
	Mon, 11 Mar 2019 18:34:53 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS402-HUB.china.huawei.com
 (10.3.19.202) with Microsoft SMTP Server id 14.3.408.0; Mon, 11 Mar 2019
 18:34:48 +0800
Date: Mon, 11 Mar 2019 10:34:35 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-api@vger.kernel.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, "Dave
 Hansen" <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv7 04/10] node: Link memory nodes to their compute nodes
Message-ID: <20190311103435.0000316c@huawei.com>
In-Reply-To: <20190227225038.20438-5-keith.busch@intel.com>
References: <20190227225038.20438-1-keith.busch@intel.com>
	<20190227225038.20438-5-keith.busch@intel.com>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2019 15:50:32 -0700
Keith Busch <keith.busch@intel.com> wrote:

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
A couple of minor bits inline.  With those tidied up.

Reviewed-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

Thanks,

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
> @@ -90,4 +90,27 @@ Date:		December 2009
>  Contact:	Lee Schermerhorn <lee.schermerhorn@hp.com>
>  Description:
>  		The node's huge page size control/query attributes.
> -		See Documentation/admin-guide/mm/hugetlbpage.rst
> \ No newline at end of file
> +		See Documentation/admin-guide/mm/hugetlbpage.rst
> +
> +What:		/sys/devices/system/node/nodeX/accessY/
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The node's relationship to other nodes for access class "Y".
> +
> +What:		/sys/devices/system/node/nodeX/accessY/initiators/
> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The directory containing symlinks to memory initiator
> +		nodes that have class "Y" access to this target node's
> +		memory. CPUs and other memory initiators in nodes not in
> +		the list accessing this node's memory may have different
> +		performance.
> +
> +What:		/sys/devices/system/node/nodeX/classY/targets/

accessY

> +Date:		December 2018
> +Contact:	Keith Busch <keith.busch@intel.com>
> +Description:
> +		The directory containing symlinks to memory targets that
> +		this initiator node has class "Y" access.

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
> + * 			      relationships to other nodes.
> + * @dev:	Device for this memory access class
> + * @list_node:	List element in the node's access list
> + * @access:	The access class rank
> + */
> +struct node_access_nodes {
> +	struct device		dev;
> +	struct list_head	list_node;
> +	unsigned		access;
> +};
> +#define to_access_nodes(dev) container_of(dev, struct node_access_nodes, dev)
> +
> +static struct attribute *node_init_access_node_attrs[] = {
> +	NULL,
> +};
> +
> +static struct attribute *node_targ_access_node_attrs[] = {
> +	NULL,
> +};
> +
> +static const struct attribute_group initiators = {
> +	.name	= "initiators",
> +	.attrs	= node_init_access_node_attrs,
> +};
> +
> +static const struct attribute_group targets = {
> +	.name	= "targets",
> +	.attrs	= node_targ_access_node_attrs,
> +};
> +
> +static const struct attribute_group *node_access_node_groups[] = {
> +	&initiators,
> +	&targets,
> +	NULL,
> +};
> +
> +static void node_remove_accesses(struct node *node)
> +{
> +	struct node_access_nodes *c, *cnext;
> +
> +	list_for_each_entry_safe(c, cnext, &node->access_list, list_node) {
> +		list_del(&c->list_node);
> +		device_unregister(&c->dev);
> +	}
> +}
> +
> +static void node_access_release(struct device *dev)
> +{
> +	kfree(to_access_nodes(dev));
> +}
> +
> +static struct node_access_nodes *node_init_node_access(struct node *node,
> +						       unsigned access)
> +{
> +	struct node_access_nodes *access_node;
> +	struct device *dev;
> +
> +	list_for_each_entry(access_node, &node->access_list, list_node)
> +		if (access_node->access == access)
> +			return access_node;
> +
> +	access_node = kzalloc(sizeof(*access_node), GFP_KERNEL);
> +	if (!access_node)
> +		return NULL;
> +
> +	access_node->access = access;
> +	dev = &access_node->dev;
> +	dev->parent = &node->dev;
> +	dev->release = node_access_release;
> +	dev->groups = node_access_node_groups;
> +	if (dev_set_name(dev, "access%u", access))
> +		goto free;
> +
> +	if (device_register(dev))
> +		goto free_name;
> +
> +	pm_runtime_no_callbacks(dev);
> +	list_add_tail(&access_node->list_node, &node->access_list);
> +	return access_node;
> +free_name:
> +	kfree_const(dev->kobj.name);
> +free:
> +	kfree(access_node);
> +	return NULL;
> +}
> +
>  #define K(x) ((x) << (PAGE_SHIFT - 10))
>  static ssize_t node_read_meminfo(struct device *dev,
>  			struct device_attribute *attr, char *buf)
> @@ -340,7 +429,7 @@ static int register_node(struct node *node, int num)
>  void unregister_node(struct node *node)
>  {
>  	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
> -
> +	node_remove_accesses(node);
>  	device_unregister(&node->dev);
>  }
>  
> @@ -372,6 +461,56 @@ int register_cpu_under_node(unsigned int cpu, unsigned int nid)
>  				 kobject_name(&node_devices[nid]->dev.kobj));
>  }
>  
> +/**
> + * register_memory_node_under_compute_node - link memory node to its compute
> + *					     node for a given access class.
> + * @mem_node:	Memory node number
> + * @cpu_node:	Cpu  node number
> + * @access:	Access class to register
> + *
> + * Description:
> + * 	For use with platforms that may have separate memory and compute nodes.
> + * 	This function will export node relationships linking which memory
> + * 	initiator nodes can access memory targets at a given ranked access
> + * 	class.
> + */
> +int register_memory_node_under_compute_node(unsigned int mem_nid,
> +					    unsigned int cpu_nid,
> +					    unsigned access)
> +{
> +	struct node *init_node, *targ_node;
> +	struct node_access_nodes *initiator, *target;
> +	int ret;
> +
> +	if (!node_online(cpu_nid) || !node_online(mem_nid))
> +		return -ENODEV;
> +
> +	init_node = node_devices[cpu_nid];
> +	targ_node = node_devices[mem_nid];
> +	initiator = node_init_node_access(init_node, access);
> +	target = node_init_node_access(targ_node, access);
> +	if (!initiator || !target)
> +		return -ENOMEM;
> +
> +	ret = sysfs_add_link_to_group(&initiator->dev.kobj, "targets",
> +				      &targ_node->dev.kobj,
> +				      dev_name(&targ_node->dev));
> +	if (ret)
> +		return ret;
> +
> +	ret = sysfs_add_link_to_group(&target->dev.kobj, "initiators",
> +				      &init_node->dev.kobj,
> +				      dev_name(&init_node->dev));
> +	if (ret)
> +		goto err;
> +
> +	return 0;
> + err:
> +	sysfs_remove_link_from_group(&initiator->dev.kobj, "targets",
> +				     dev_name(&targ_node->dev));
> +	return ret;
> +}
> +
>  int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
>  {
>  	struct device *obj;
> @@ -580,6 +719,7 @@ int __register_one_node(int nid)
>  			register_cpu_under_node(cpu, nid);
>  	}
>  
> +	INIT_LIST_HEAD(&node_devices[nid]->access_list);
>  	/* initialize work queue for memory hot plug */
>  	init_node_hugetlb_work(nid);
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
>  	struct device	dev;
> -
> +	struct list_head access_list;

Nitpick if you are rerolling for some reason. The separation before
the ifdef was nice from a readability point of view.

>  #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
>  	struct work_struct	node_work;
>  #endif
> @@ -75,6 +76,10 @@ extern int register_mem_sect_under_node(struct memory_block *mem_blk,
>  extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
>  					   unsigned long phys_index);
>  
> +extern int register_memory_node_under_compute_node(unsigned int mem_nid,
> +						   unsigned int cpu_nid,
> +						   unsigned access);
> +
>  #ifdef CONFIG_HUGETLBFS
>  extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
>  					 node_registration_func_t unregister);


