Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 659206B00AE
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 17:38:29 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id lx4so3117394iec.17
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 14:38:29 -0700 (PDT)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id i12si35464294ics.22.2014.06.09.14.38.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 14:38:28 -0700 (PDT)
Received: by mail-ie0-f177.google.com with SMTP id tp5so4487502ieb.8
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 14:38:28 -0700 (PDT)
Date: Mon, 9 Jun 2014 14:38:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: NUMA topology question wrt. d4edc5b6
In-Reply-To: <537E6285.3050000@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1406091436090.5271@chino.kir.corp.google.com>
References: <20140521200451.GB5755@linux.vnet.ibm.com> <537E6285.3050000@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, benh@kernel.crashing.org, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, nfont@linux.vnet.ibm.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Anton Blanchard <anton@samba.org>, Dave Hansen <dave@sr71.net>, "linuxppc-dev@lists.ozlabs.org list" <linuxppc-dev@lists.ozlabs.org>, Linux MM <linux-mm@kvack.org>

On Fri, 23 May 2014, Srivatsa S. Bhat wrote:

> diff --git a/arch/powerpc/include/asm/topology.h b/arch/powerpc/include/asm/topology.h
> index c920215..58e6469 100644
> --- a/arch/powerpc/include/asm/topology.h
> +++ b/arch/powerpc/include/asm/topology.h
> @@ -18,6 +18,7 @@ struct device_node;
>   */
>  #define RECLAIM_DISTANCE 10
>  
> +#include <linux/nodemask.h>
>  #include <asm/mmzone.h>
>  
>  static inline int cpu_to_node(int cpu)
> @@ -30,7 +31,7 @@ static inline int cpu_to_node(int cpu)
>  	 * During early boot, the numa-cpu lookup table might not have been
>  	 * setup for all CPUs yet. In such cases, default to node 0.
>  	 */
> -	return (nid < 0) ? 0 : nid;
> +	return (nid < 0) ? first_online_node : nid;
>  }
>  
>  #define parent_node(node)	(node)

I wonder what would happen on ppc if we just returned NUMA_NO_NODE here 
for cpus that have not been mapped (they shouldn't even be possible).  
This would at least allow callers that do
kmalloc_node(..., cpu_to_node(cpu)) to be allocated on the local cpu 
rather than on a perhaps offline or remote node 0.

It would seem better to catch callers that do 
cpu_to_node(<not-possible-cpu>) rather than blindly return an online node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
