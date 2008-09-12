Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m8CGCuk9031638
	for <linux-mm@kvack.org>; Fri, 12 Sep 2008 21:42:56 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8CGCuLQ1802372
	for <linux-mm@kvack.org>; Fri, 12 Sep 2008 21:42:56 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m8CGCtAE019383
	for <linux-mm@kvack.org>; Fri, 12 Sep 2008 21:42:56 +0530
Message-ID: <48CA9500.5060309@linux.vnet.ibm.com>
Date: Fri, 12 Sep 2008 09:12:48 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH 8/9] memcg: remove page_cgroup pointer from memmap
References: <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com> <20080911202249.df6026ae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080911202249.df6026ae.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Remove page_cgroup pointer from struct page.
> 
> This patch removes page_cgroup pointer from struct page and make it be able
> to get from pfn. Then, relationship of them is
> 
> Before this:
>   pfn <-> struct page <-> struct page_cgroup.
> After this:
>   struct page <-> pfn -> struct page_cgroup -> struct page.
> 
> Benefit of this approach is we can remove 8(4) bytes from struct page.
> 
> Other changes are:
>   - lock/unlock_page_cgroup() uses its own bit on struct page_cgroup.
>   - all necessary page_cgroups are allocated at boot.
> 
> Characteristics:
>   - page cgroup is allocated as some amount of chunk.
>     This patch uses SECTION_SIZE as size of chunk if 64bit/SPARSEMEM is enabled.
>     If not, appropriate default number is selected.
>   - all page_cgroup struct is maintained by hash. 
>     I think we have 2 ways to handle sparse index in general
>     ...radix-tree and hash. This uses hash because radix-tree's layout is
>     affected by memory map's layout.
>   - page_cgroup.h/page_cgroup.c is added.
> 
> TODO:
>   - memory hotplug support. (not difficult)

Kamezawa,

I feel we can try the following approaches

1. Try per-node per-zone radix tree with dynamic allocation
2. Try the approach you have
3. Integrate with sparsemem (last resort for performance), Dave Hansen suggested
adding a mem_section member and using that.

I am going to try #1 today and see what the performance looks like


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
