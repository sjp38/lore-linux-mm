Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id A97E76B0006
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 21:17:19 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 7 Apr 2013 06:41:57 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 6FABFE0055
	for <linux-mm@kvack.org>; Sun,  7 Apr 2013 06:48:57 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r371H4Y33670284
	for <linux-mm@kvack.org>; Sun, 7 Apr 2013 06:47:05 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r371H9v5013818
	for <linux-mm@kvack.org>; Sun, 7 Apr 2013 11:17:10 +1000
Date: Sun, 7 Apr 2013 09:17:08 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] x86: numa: mm: kill double initialization for NODE_DATA
Message-ID: <20130407011708.GA27751@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1364897675-15523-1-git-send-email-linfeng@cn.fujitsu.com>
 <20130402105709.GA10095@hacker.(null)>
 <515B8BD9.7060308@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515B8BD9.7060308@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, yinghai@kernel.org, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com

On Wed, Apr 03, 2013 at 09:54:33AM +0800, Lin Feng wrote:
>Hi Wanpeng,
>
>On 04/02/2013 06:57 PM, Wanpeng Li wrote:
>>> >PS. For clarifying calling chains are showed as follows:
>>> >setup_arch()
>>> >  ...
>>> >  initmem_init()
>>> >    x86_numa_init()
>>> >      numa_init()
>>> >        numa_register_memblks()
>>> >          setup_node_data()
>>> >            NODE_DATA(nid)->node_id = nid;
>>> >            NODE_DATA(nid)->node_start_pfn = start >> PAGE_SHIFT;
>>> >            NODE_DATA(nid)->node_spanned_pages = (end - start) >> PAGE_SHIFT;
>>> >  ...
>>> >  x86_init.paging.pagetable_init()
>>> >  paging_init()
>>> >    ...
>>> >    sparse_init()
>>> >      sparse_early_usemaps_alloc_node()
>>> >        sparse_early_usemaps_alloc_pgdat_section()
>>> >          ___alloc_bootmem_node_nopanic()
>>> >            __alloc_memory_core_early(pgdat->node_id,...)
>>> >    ...
>>> >    zone_sizes_init()
>>> >      free_area_init_nodes()
>>> >        free_area_init_node()
>>> >          pgdat->node_id = nid;
>>> >          pgdat->node_start_pfn = node_start_pfn;
>>> >          calculate_node_totalpages();
>>> >            pgdat->node_spanned_pages = totalpages;
>>> >
>> You miss the nodes which could become online at some point, but not
>> online currently. 
>

Hi Feng,

>Sorry, I'm not quite understanding what you said.
>
>I keep node_set_online(nid) there. In boot phase if a node is online now it wil be 
>reinitialized later by zone_sizes_init() else if a node is hotpluged after system is
>up it will also be initialized by hotadd_new_pgdat() which falls into calling 
>free_area_init_node().

I miss it.

>
>Besides this I'm not sure there are any other dependency besides what you worry about,
>while I tested this on a x86_64 numa system with hot-add nodes and the meminfo statics
>looks right before and after hot-add memory.

Fair enough. ;-)

Regards,
Wanpeng Li 

>
>thanks for your patient,
>linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
