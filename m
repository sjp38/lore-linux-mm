Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BCC696B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 00:52:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u84so149468881pfj.6
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 21:52:39 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 62si444431pfi.104.2016.10.25.21.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 21:52:38 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9Q4mfpZ050785
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 00:52:38 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26aexjjmsw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 00:52:38 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 26 Oct 2016 14:52:35 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 53DDE2BB0059
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 15:52:33 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9Q4qXW418350272
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 15:52:33 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9Q4qWrq026447
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 15:52:33 +1100
Subject: Re: [RFC 8/8] mm: Add N_COHERENT_DEVICE node type into node_states[]
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477283517-2504-9-git-send-email-khandual@linux.vnet.ibm.com>
 <14c44d50-3461-8a2c-d043-881110ae6f6b@gmail.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 26 Oct 2016 10:22:30 +0530
MIME-Version: 1.0
In-Reply-To: <14c44d50-3461-8a2c-d043-881110ae6f6b@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5810368E.5070403@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com

On 10/25/2016 12:52 PM, Balbir Singh wrote:
> 
> 
> On 24/10/16 15:31, Anshuman Khandual wrote:
>> Add a new member N_COHERENT_DEVICE into node_states[] nodemask array to
>> enlist all those nodes which contain only coherent device memory. Also
>> creates a new sysfs interface /sys/devices/system/node/is_coherent_device
>> to list down all those nodes which has coherent device memory.
>>
>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>> ---
>>  Documentation/ABI/stable/sysfs-devices-node |  7 +++++++
>>  drivers/base/node.c                         |  6 ++++++
>>  include/linux/nodemask.h                    |  3 +++
>>  mm/memory_hotplug.c                         | 10 ++++++++++
>>  4 files changed, 26 insertions(+)
>>
>> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
>> index 5b2d0f0..5538791 100644
>> --- a/Documentation/ABI/stable/sysfs-devices-node
>> +++ b/Documentation/ABI/stable/sysfs-devices-node
>> @@ -29,6 +29,13 @@ Description:
>>  		Nodes that have regular or high memory.
>>  		Depends on CONFIG_HIGHMEM.
>>  
>> +What:		/sys/devices/system/node/is_coherent_device
>> +Date:		October 2016
>> +Contact:	Linux Memory Management list <linux-mm@kvack.org>
>> +Description:
>> +		Lists the nodemask of nodes that have coherent memory.
>> +		Depends on CONFIG_COHERENT_DEVICE.
>> +
>>  What:		/sys/devices/system/node/nodeX
>>  Date:		October 2002
>>  Contact:	Linux Memory Management list <linux-mm@kvack.org>
>> diff --git a/drivers/base/node.c b/drivers/base/node.c
>> index 5548f96..5b5dd89 100644
>> --- a/drivers/base/node.c
>> +++ b/drivers/base/node.c
>> @@ -661,6 +661,9 @@ static struct node_attr node_state_attr[] = {
>>  	[N_MEMORY] = _NODE_ATTR(has_memory, N_MEMORY),
>>  #endif
>>  	[N_CPU] = _NODE_ATTR(has_cpu, N_CPU),
>> +#ifdef CONFIG_COHERENT_DEVICE
>> +	[N_COHERENT_DEVICE] = _NODE_ATTR(is_coherent_device, N_COHERENT_DEVICE),
>> +#endif
>>  };
>>  
>>  static struct attribute *node_state_attrs[] = {
>> @@ -674,6 +677,9 @@ static struct attribute *node_state_attrs[] = {
>>  	&node_state_attr[N_MEMORY].attr.attr,
>>  #endif
>>  	&node_state_attr[N_CPU].attr.attr,
>> +#ifdef CONFIG_COHERENT_DEVICE
>> +	&node_state_attr[N_COHERENT_DEVICE].attr.attr,
>> +#endif
>>  	NULL
>>  };
>>  
>> diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
>> index f746e44..605cb0d 100644
>> --- a/include/linux/nodemask.h
>> +++ b/include/linux/nodemask.h
>> @@ -393,6 +393,9 @@ enum node_states {
>>  	N_MEMORY = N_HIGH_MEMORY,
>>  #endif
>>  	N_CPU,		/* The node has one or more cpus */
>> +#ifdef CONFIG_COHERENT_DEVICE
>> +	N_COHERENT_DEVICE,	/* The node has coherent device memory */
>> +#endif
>>  	NR_NODE_STATES
>>  };
>>  
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 9629273..8f03962 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1044,6 +1044,11 @@ static void node_states_set_node(int node, struct memory_notify *arg)
>>  	if (arg->status_change_nid_high >= 0)
>>  		node_set_state(node, N_HIGH_MEMORY);
>>  
>> +#ifdef CONFIG_COHERENT_DEVICE
>> +	if (isolated_cdm_node(node))
>> +		node_set_state(node, N_COHERENT_DEVICE);
>> +#endif
>> +
> 
> #ifdef not required, see below
> 

Right, will change.

>>  	node_set_state(node, N_MEMORY);
>>  }
>>  
>> @@ -1858,6 +1863,11 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
>>  	if ((N_MEMORY != N_HIGH_MEMORY) &&
>>  	    (arg->status_change_nid >= 0))
>>  		node_clear_state(node, N_MEMORY);
>> +
>> +#ifdef CONFIG_COHERENT_DEVICE
>> +	if (isolated_cdm_node(node))
>> +		node_clear_state(node, N_COHERENT_DEVICE);
>> +#endif
>>  }
>>  
> 
> I think the #ifdefs are not needed if isolated_cdm_node
> is defined for both with and without CONFIG_COHERENT_DEVICE.
> 
> I think this patch needs to move up in the series so that
> node state can be examined by other core algorithms

Okay, will move up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
