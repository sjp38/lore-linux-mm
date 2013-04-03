Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 841CC6B0081
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 21:52:38 -0400 (EDT)
Message-ID: <515B8BD9.7060308@cn.fujitsu.com>
Date: Wed, 03 Apr 2013 09:54:33 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: numa: mm: kill double initialization for NODE_DATA
References: <1364897675-15523-1-git-send-email-linfeng@cn.fujitsu.com> <20130402105709.GA10095@hacker.(null)>
In-Reply-To: <20130402105709.GA10095@hacker.(null)>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, yinghai@kernel.org, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com

Hi Wanpeng,

On 04/02/2013 06:57 PM, Wanpeng Li wrote:
>> >PS. For clarifying calling chains are showed as follows:
>> >setup_arch()
>> >  ...
>> >  initmem_init()
>> >    x86_numa_init()
>> >      numa_init()
>> >        numa_register_memblks()
>> >          setup_node_data()
>> >            NODE_DATA(nid)->node_id = nid;
>> >            NODE_DATA(nid)->node_start_pfn = start >> PAGE_SHIFT;
>> >            NODE_DATA(nid)->node_spanned_pages = (end - start) >> PAGE_SHIFT;
>> >  ...
>> >  x86_init.paging.pagetable_init()
>> >  paging_init()
>> >    ...
>> >    sparse_init()
>> >      sparse_early_usemaps_alloc_node()
>> >        sparse_early_usemaps_alloc_pgdat_section()
>> >          ___alloc_bootmem_node_nopanic()
>> >            __alloc_memory_core_early(pgdat->node_id,...)
>> >    ...
>> >    zone_sizes_init()
>> >      free_area_init_nodes()
>> >        free_area_init_node()
>> >          pgdat->node_id = nid;
>> >          pgdat->node_start_pfn = node_start_pfn;
>> >          calculate_node_totalpages();
>> >            pgdat->node_spanned_pages = totalpages;
>> >
> You miss the nodes which could become online at some point, but not
> online currently. 

Sorry, I'm not quite understanding what you said.

I keep node_set_online(nid) there. In boot phase if a node is online now it wil be 
reinitialized later by zone_sizes_init() else if a node is hotpluged after system is
up it will also be initialized by hotadd_new_pgdat() which falls into calling 
free_area_init_node().

Besides this I'm not sure there are any other dependency besides what you worry about,
while I tested this on a x86_64 numa system with hot-add nodes and the meminfo statics
looks right before and after hot-add memory.

thanks for your patient,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
