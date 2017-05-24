Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D13B6B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 08:54:35 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 44so15516086wry.5
        for <linux-mm@kvack.org>; Wed, 24 May 2017 05:54:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2si21472008edi.240.2017.05.24.05.54.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 05:54:33 -0700 (PDT)
Subject: Re: [RFC PATCH 2/2] mm, memory_hotplug: drop CONFIG_MOVABLE_NODE
References: <20170524122411.25212-1-mhocko@kernel.org>
 <20170524122411.25212-3-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3a85146e-2f31-8a9e-26da-6051119586fe@suse.cz>
Date: Wed, 24 May 2017 14:53:57 +0200
MIME-Version: 1.0
In-Reply-To: <20170524122411.25212-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 05/24/2017 02:24 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 20b2f52b73fe ("numa: add CONFIG_MOVABLE_NODE for movable-dedicated
> node") has introduced CONFIG_MOVABLE_NODE without a good explanation on
> why it is actually useful. It makes a lot of sense to make movable node
> semantic opt in but we already have that because the feature has to be
> explicitly enabled on the kernel command line. A config option on top
> only makes the configuration space larger without a good reason. It also
> adds an additional ifdefery that pollutes the code. Just drop the config
> option and make it de-facto always enabled. This shouldn't introduce any
> change to the semantic.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

I agree with the intention.

> ---
>  Documentation/admin-guide/kernel-parameters.txt |  7 +++++--
>  drivers/base/node.c                             |  4 ----
>  include/linux/memblock.h                        | 18 -----------------
>  include/linux/nodemask.h                        |  4 ----
>  mm/Kconfig                                      | 26 -------------------------
>  mm/memblock.c                                   |  2 --
>  mm/memory_hotplug.c                             |  4 ----
>  mm/page_alloc.c                                 |  2 --
>  8 files changed, 5 insertions(+), 62 deletions(-)
> 
> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> index facc20a3f962..ec7d6ae01c96 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -2246,8 +2246,11 @@
>  			that the amount of memory usable for all allocations
>  			is not too small.
>  
> -	movable_node	[KNL] Boot-time switch to enable the effects
> -			of CONFIG_MOVABLE_NODE=y. See mm/Kconfig for details.
> +	movable_node	[KNL] Boot-time switch to make hotplugable to be

			hotplugable what, memory? nodes?

> +			movable. This means that the memory of such nodes
> +			will be usable only for movable allocations which
> +			rules out almost all kernel allocations. Use with
> +			caution!
>  
>  	MTD_Partition=	[MTD]
>  			Format: <name>,<region-number>,<size>,<offset>

...

> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -149,32 +149,6 @@ config NO_BOOTMEM
>  config MEMORY_ISOLATION
>  	bool
>  
> -config MOVABLE_NODE
> -	bool "Enable to assign a node which has only movable memory"
> -	depends on HAVE_MEMBLOCK
> -	depends on NO_BOOTMEM
> -	depends on X86_64 || OF_EARLY_FLATTREE || MEMORY_HOTPLUG
> -	depends on NUMA

That's a lot of depends. What happens if some of them are not met and
the movable_node bootparam is used?

> -	default n
> -	help
> -	  Allow a node to have only movable memory.  Pages used by the kernel,
> -	  such as direct mapping pages cannot be migrated.  So the corresponding
> -	  memory device cannot be hotplugged.  This option allows the following
> -	  two things:
> -	  - When the system is booting, node full of hotpluggable memory can
> -	  be arranged to have only movable memory so that the whole node can
> -	  be hot-removed. (need movable_node boot option specified).

> -	  - After the system is up, the option allows users to online all the
> -	  memory of a node as movable memory so that the whole node can be
> -	  hot-removed.

Strictly speaking this part is already gone with patch 1/2. Only matters
in case this one is rejected for some reason.

> -	  Users who don't use the memory hotplug feature are fine with this
> -	  option on since they don't specify movable_node boot option or they
> -	  don't online memory as movable.
> -
> -	  Say Y here if you want to hotplug a whole node.
> -	  Say N here if you want kernel to use memory on all nodes evenly.
> -
>  #
>  # Only be set on architectures that have completely implemented memory hotplug
>  # feature. If you are not sure, don't touch it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
