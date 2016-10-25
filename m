Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 98F3F6B025E
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 03:23:13 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id y9so12159960ywy.2
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 00:23:13 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id k88si12064185iod.248.2016.10.25.00.23.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 00:23:12 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id r16so18758192pfg.3
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 00:23:12 -0700 (PDT)
Subject: Re: [RFC 8/8] mm: Add N_COHERENT_DEVICE node type into node_states[]
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477283517-2504-9-git-send-email-khandual@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <14c44d50-3461-8a2c-d043-881110ae6f6b@gmail.com>
Date: Tue, 25 Oct 2016 18:22:48 +1100
MIME-Version: 1.0
In-Reply-To: <1477283517-2504-9-git-send-email-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com



On 24/10/16 15:31, Anshuman Khandual wrote:
> Add a new member N_COHERENT_DEVICE into node_states[] nodemask array to
> enlist all those nodes which contain only coherent device memory. Also
> creates a new sysfs interface /sys/devices/system/node/is_coherent_device
> to list down all those nodes which has coherent device memory.
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  Documentation/ABI/stable/sysfs-devices-node |  7 +++++++
>  drivers/base/node.c                         |  6 ++++++
>  include/linux/nodemask.h                    |  3 +++
>  mm/memory_hotplug.c                         | 10 ++++++++++
>  4 files changed, 26 insertions(+)
> 
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 5b2d0f0..5538791 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -29,6 +29,13 @@ Description:
>  		Nodes that have regular or high memory.
>  		Depends on CONFIG_HIGHMEM.
>  
> +What:		/sys/devices/system/node/is_coherent_device
> +Date:		October 2016
> +Contact:	Linux Memory Management list <linux-mm@kvack.org>
> +Description:
> +		Lists the nodemask of nodes that have coherent memory.
> +		Depends on CONFIG_COHERENT_DEVICE.
> +
>  What:		/sys/devices/system/node/nodeX
>  Date:		October 2002
>  Contact:	Linux Memory Management list <linux-mm@kvack.org>
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 5548f96..5b5dd89 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -661,6 +661,9 @@ static struct node_attr node_state_attr[] = {
>  	[N_MEMORY] = _NODE_ATTR(has_memory, N_MEMORY),
>  #endif
>  	[N_CPU] = _NODE_ATTR(has_cpu, N_CPU),
> +#ifdef CONFIG_COHERENT_DEVICE
> +	[N_COHERENT_DEVICE] = _NODE_ATTR(is_coherent_device, N_COHERENT_DEVICE),
> +#endif
>  };
>  
>  static struct attribute *node_state_attrs[] = {
> @@ -674,6 +677,9 @@ static struct attribute *node_state_attrs[] = {
>  	&node_state_attr[N_MEMORY].attr.attr,
>  #endif
>  	&node_state_attr[N_CPU].attr.attr,
> +#ifdef CONFIG_COHERENT_DEVICE
> +	&node_state_attr[N_COHERENT_DEVICE].attr.attr,
> +#endif
>  	NULL
>  };
>  
> diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
> index f746e44..605cb0d 100644
> --- a/include/linux/nodemask.h
> +++ b/include/linux/nodemask.h
> @@ -393,6 +393,9 @@ enum node_states {
>  	N_MEMORY = N_HIGH_MEMORY,
>  #endif
>  	N_CPU,		/* The node has one or more cpus */
> +#ifdef CONFIG_COHERENT_DEVICE
> +	N_COHERENT_DEVICE,	/* The node has coherent device memory */
> +#endif
>  	NR_NODE_STATES
>  };
>  
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 9629273..8f03962 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1044,6 +1044,11 @@ static void node_states_set_node(int node, struct memory_notify *arg)
>  	if (arg->status_change_nid_high >= 0)
>  		node_set_state(node, N_HIGH_MEMORY);
>  
> +#ifdef CONFIG_COHERENT_DEVICE
> +	if (isolated_cdm_node(node))
> +		node_set_state(node, N_COHERENT_DEVICE);
> +#endif
> +

#ifdef not required, see below

>  	node_set_state(node, N_MEMORY);
>  }
>  
> @@ -1858,6 +1863,11 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
>  	if ((N_MEMORY != N_HIGH_MEMORY) &&
>  	    (arg->status_change_nid >= 0))
>  		node_clear_state(node, N_MEMORY);
> +
> +#ifdef CONFIG_COHERENT_DEVICE
> +	if (isolated_cdm_node(node))
> +		node_clear_state(node, N_COHERENT_DEVICE);
> +#endif
>  }
>  

I think the #ifdefs are not needed if isolated_cdm_node
is defined for both with and without CONFIG_COHERENT_DEVICE.

I think this patch needs to move up in the series so that
node state can be examined by other core algorithms

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
