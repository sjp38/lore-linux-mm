Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m8AMbHQW007662
	for <linux-mm@kvack.org>; Thu, 11 Sep 2008 08:37:17 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8AMb20o3629290
	for <linux-mm@kvack.org>; Thu, 11 Sep 2008 08:37:02 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8AMb1NZ030416
	for <linux-mm@kvack.org>; Thu, 11 Sep 2008 08:37:02 +1000
Message-ID: <48C84C0A.30902@linux.vnet.ibm.com>
Date: Wed, 10 Sep 2008 15:36:58 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [Approach #2] [RFC][PATCH] Remove cgroup member from struct page
References: <48C66AF8.5070505@linux.vnet.ibm.com> <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com> <200809091358.28350.nickpiggin@yahoo.com.au> <20080909135317.cbff4871.kamezawa.hiroyu@jp.fujitsu.com> <200809091500.10619.nickpiggin@yahoo.com.au> <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com> <30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com> <20080910012048.GA32752@balbir.in.ibm.com> <1221085260.6781.69.camel@nimitz>
In-Reply-To: <1221085260.6781.69.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kamezawa.hiroyu@jp.fujitsu.com, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Tue, 2008-09-09 at 18:20 -0700, Balbir Singh wrote:
>> +       start = pgdat->node_start_pfn;
>> +       end = pgdat->node_start_pfn + pgdat->node_spanned_pages;
>> +       size = (end - start) * sizeof(struct page_cgroup);
>> +       printk("Allocating %lu bytes for node %d\n", size, n);
>> +       pcg_map[n] = alloc_bootmem_node(pgdat, size);
>> +       /*
>> +        * We can do smoother recovery
>> +        */
>> +       BUG_ON(!pcg_map[n]);
>> +       return 0;
>>  }
> 
> This will really suck for sparse memory machines.  Imagine a machine
> with 1GB of memory at 0x0 and another 1GB of memory at 1TB up in the
> address space.
> 

I would hate to re-implement the entire sparsemem code :(
Kame did suggest making the memory controller depend on sparsemem (to hook in
from there for allocations)

> You also need to consider how it works with memory hotplug and how
> you're going to grow it at runtime.
> 

Yes, true. This is not the final version, a very very early version that I
posted for initial comments.

> Oh, and doesn't alloc_bootmem() panic() if it fails internally anyway?
> 
> I need to look at your other approach. :)

We'll need some slab_is_available() sort of checks that sparse.c uses and also
deal with memory hotplug add and remove.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
