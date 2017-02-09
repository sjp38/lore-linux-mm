Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 694296B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 04:39:57 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id v96so18519116ioi.5
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 01:39:57 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m3si17361918ioo.158.2017.02.09.01.39.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 01:39:56 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v199cXLY109593
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 04:39:56 -0500
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28gm30dr6t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 09 Feb 2017 04:39:56 -0500
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 9 Feb 2017 19:39:53 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id B9FC23578057
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 20:39:51 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v199dhi930605408
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 20:39:51 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v199dJhP006882
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 20:39:19 +1100
Subject: Re: [PATCH 1/3] mm: Define coherent device memory (CDM) node
References: <20170208140148.16049-1-khandual@linux.vnet.ibm.com>
 <20170208140148.16049-2-khandual@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 9 Feb 2017 15:08:59 +0530
MIME-Version: 1.0
In-Reply-To: <20170208140148.16049-2-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <48b685aa-af17-2726-0af3-0099b684844e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/08/2017 07:31 PM, Anshuman Khandual wrote:
> There are certain devices like specialized accelerator, GPU cards, network
> cards, FPGA cards etc which might contain onboard memory which is coherent
> along with the existing system RAM while being accessed either from the CPU
> or from the device. They share some similar properties with that of normal
> system RAM but at the same time can also be different with respect to
> system RAM.
> 
> User applications might be interested in using this kind of coherent device
> memory explicitly or implicitly along side the system RAM utilizing all
> possible core memory functions like anon mapping (LRU), file mapping (LRU),
> page cache (LRU), driver managed (non LRU), HW poisoning, NUMA migrations
> etc. To achieve this kind of tight integration with core memory subsystem,
> the device onboard coherent memory must be represented as a memory only
> NUMA node. At the same time arch must export some kind of a function to
> identify of this node as a coherent device memory not any other regular
> cpu less memory only NUMA node.
> 
> After achieving the integration with core memory subsystem coherent device
> memory might still need some special consideration inside the kernel. There
> can be a variety of coherent memory nodes with different expectations from
> the core kernel memory. But right now only one kind of special treatment is
> considered which requires certain isolation.
> 
> Now consider the case of a coherent device memory node type which requires
> isolation. This kind of coherent memory is onboard an external device
> attached to the system through a link where there is always a chance of a
> link failure taking down the entire memory node with it. More over the
> memory might also have higher chance of ECC failure as compared to the
> system RAM. Hence allocation into this kind of coherent memory node should
> be regulated. Kernel allocations must not come here. Normal user space
> allocations too should not come here implicitly (without user application
> knowing about it). This summarizes isolation requirement of certain kind of
> coherent device memory node as an example. There can be different kinds of
> isolation requirement also.
> 
> Some coherent memory devices might not require isolation altogether after
> all. Then there might be other coherent memory devices which might require
> some other special treatment after being part of core memory representation
> . For now, will look into isolation seeking coherent device memory node not
> the other ones.
> 
> To implement the integration as well as isolation, the coherent memory node
> must be present in N_MEMORY and a new N_COHERENT_DEVICE node mask inside
> the node_states[] array. During memory hotplug operations, the new nodemask
> N_COHERENT_DEVICE is updated along with N_MEMORY for these coherent device
> memory nodes. This also creates the following new sysfs based interface to
> list down all the coherent memory nodes of the system.
> 
> 	/sys/devices/system/node/is_coherent_node
> 
> Architectures must export function arch_check_node_cdm() which identifies
> any coherent device memory node in case they enable CONFIG_COHERENT_DEVICE.
> 
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> ---
>  Documentation/ABI/stable/sysfs-devices-node |  7 +++++
>  arch/powerpc/Kconfig                        |  1 +
>  arch/powerpc/mm/numa.c                      |  7 +++++
>  drivers/base/node.c                         |  6 ++++
>  include/linux/node.h                        | 49 +++++++++++++++++++++++++++++
>  include/linux/nodemask.h                    |  3 ++
>  mm/Kconfig                                  |  4 +++
>  mm/memory_hotplug.c                         | 10 ++++++
>  mm/page_alloc.c                             | 14 +++++++--
>  9 files changed, 99 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> index 5b2d0f0..fa2f105 100644
> --- a/Documentation/ABI/stable/sysfs-devices-node
> +++ b/Documentation/ABI/stable/sysfs-devices-node
> @@ -29,6 +29,13 @@ Description:
>  		Nodes that have regular or high memory.
>  		Depends on CONFIG_HIGHMEM.
>  
> +What:		/sys/devices/system/node/is_coherent_device
> +Date:		January 2017
> +Contact:	Linux Memory Management list <linux-mm@kvack.org>
> +Description:
> +		Lists the nodemask of nodes that have coherent device memory.
> +		Depends on CONFIG_COHERENT_DEVICE.
> +
>  What:		/sys/devices/system/node/nodeX
>  Date:		October 2002
>  Contact:	Linux Memory Management list <linux-mm@kvack.org>
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 281f4f1..77b97fe 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -164,6 +164,7 @@ config PPC
>  	select ARCH_HAS_SCALED_CPUTIME if VIRT_CPU_ACCOUNTING_NATIVE
>  	select HAVE_ARCH_HARDENED_USERCOPY
>  	select HAVE_KERNEL_GZIP
> +	select COHERENT_DEVICE if PPC_BOOK3S_64
>

The following change here will fix the build problems in both the configs
ps3_defconfig and maple_defconfig. Will include this in next version.

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 77b97fe..1cff239 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -164,7 +164,7 @@ config PPC
        select ARCH_HAS_SCALED_CPUTIME if VIRT_CPU_ACCOUNTING_NATIVE
        select HAVE_ARCH_HARDENED_USERCOPY
        select HAVE_KERNEL_GZIP
-       select COHERENT_DEVICE if PPC_BOOK3S_64
+       select COHERENT_DEVICE if PPC_BOOK3S_64 && NEED_MULTIPLE_NODES

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
