Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0786B0055
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 05:28:40 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n969SZgN031717
	for <linux-mm@kvack.org>; Tue, 6 Oct 2009 10:28:35 +0100
Received: from pxi31 (pxi31.prod.google.com [10.243.27.31])
	by spaceape11.eur.corp.google.com with ESMTP id n969SW5n003636
	for <linux-mm@kvack.org>; Tue, 6 Oct 2009 02:28:33 -0700
Received: by pxi31 with SMTP id 31so4204647pxi.19
        for <linux-mm@kvack.org>; Tue, 06 Oct 2009 02:28:32 -0700 (PDT)
Date: Tue, 6 Oct 2009 02:28:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/11] hugetlb:  add generic definition of NUMA_NO_NODE
In-Reply-To: <20091006031815.22576.16375.sendpatchset@localhost.localdomain>
Message-ID: <alpine.DEB.1.00.0910060223370.1327@chino.kir.corp.google.com>
References: <20091006031739.22576.5248.sendpatchset@localhost.localdomain> <20091006031815.22576.16375.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Randy Dunlap <randy.dunlap@oracle.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, 5 Oct 2009, Lee Schermerhorn wrote:

> Index: linux-2.6.31-mmotm-090925-1435/arch/ia64/include/asm/numa.h
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/arch/ia64/include/asm/numa.h	2009-09-30 15:04:40.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/arch/ia64/include/asm/numa.h	2009-09-30 15:05:19.000000000 -0400
> @@ -22,8 +22,6 @@
>  
>  #include <asm/mmzone.h>
>  
> -#define NUMA_NO_NODE	-1
> -
>  extern u16 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
>  extern cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
>  extern pg_data_t *pgdat_list[MAX_NUMNODES];
> Index: linux-2.6.31-mmotm-090925-1435/arch/x86/include/asm/topology.h
> ===================================================================
> --- linux-2.6.31-mmotm-090925-1435.orig/arch/x86/include/asm/topology.h	2009-09-30 15:04:40.000000000 -0400
> +++ linux-2.6.31-mmotm-090925-1435/arch/x86/include/asm/topology.h	2009-09-30 15:05:19.000000000 -0400
> @@ -35,11 +35,10 @@
>  # endif
>  #endif
>  
> -/* Node not present */
> -#define NUMA_NO_NODE	(-1)
> -
>  #ifdef CONFIG_NUMA
>  #include <linux/cpumask.h>
> +#include <linux/numa.h>
> +
>  #include <asm/mpspec.h>
>  
>  #ifdef CONFIG_X86_32

This could get nasty later because this is now only defining NUMA_NO_NODE 
for CONFIG_NUMA yet it's used in generic hugetlb code that you add in 
patch 7 that isn't dependent on that configuration.

It doesn't cause a compile error at this time, probably because some other 
header in mm/hugetlb.c is including linux/numa.h indirectly.  I'd err on 
the side of caution, however, and move the #include here out from under 
#ifdef CONFIG_NUMA to avoid that header file dependency.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
