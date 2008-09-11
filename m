Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m8B1lUie009974
	for <linux-mm@kvack.org>; Thu, 11 Sep 2008 07:17:30 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8B1lUct1478738
	for <linux-mm@kvack.org>; Thu, 11 Sep 2008 07:17:30 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m8B1lU4M014345
	for <linux-mm@kvack.org>; Thu, 11 Sep 2008 11:47:30 +1000
Message-ID: <48C878AD.4040404@linux.vnet.ibm.com>
Date: Wed, 10 Sep 2008 18:47:25 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [Approach #2] [RFC][PATCH] Remove cgroup member from struct page
References: <48C66AF8.5070505@linux.vnet.ibm.com> <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com> <200809091358.28350.nickpiggin@yahoo.com.au> <20080909135317.cbff4871.kamezawa.hiroyu@jp.fujitsu.com> <200809091500.10619.nickpiggin@yahoo.com.au> <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com> <30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com> <20080910012048.GA32752@balbir.in.ibm.com> <1221085260.6781.69.camel@nimitz> <48C84C0A.30902@linux.vnet.ibm.com> <1221087408.6781.73.camel@nimitz> <20080911103500.d22d0ea1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080911103500.d22d0ea1.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 10 Sep 2008 15:56:48 -0700
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
>> On Wed, 2008-09-10 at 15:36 -0700, Balbir Singh wrote:
>>> Dave Hansen wrote:
>>>> On Tue, 2008-09-09 at 18:20 -0700, Balbir Singh wrote:
>>>>> +       start = pgdat->node_start_pfn;
>>>>> +       end = pgdat->node_start_pfn + pgdat->node_spanned_pages;
>>>>> +       size = (end - start) * sizeof(struct page_cgroup);
>>>>> +       printk("Allocating %lu bytes for node %d\n", size, n);
>>>>> +       pcg_map[n] = alloc_bootmem_node(pgdat, size);
>>>>> +       /*
>>>>> +        * We can do smoother recovery
>>>>> +        */
>>>>> +       BUG_ON(!pcg_map[n]);
>>>>> +       return 0;
>>>>>  }
>>>> This will really suck for sparse memory machines.  Imagine a machine
>>>> with 1GB of memory at 0x0 and another 1GB of memory at 1TB up in the
>>>> address space.
>>>>
>>> I would hate to re-implement the entire sparsemem code :(
>>> Kame did suggest making the memory controller depend on sparsemem (to hook in
>>> from there for allocations)
>> Yeah, you could just make another mem_section member.  Or, you could
>> work to abstract the sparsemem code so that other people can use it, or
>> maybe make it more dynamic so we can have multiple pfn->object lookups
>> in parallel.  Adding the struct member is obviously easier.
>>
> Don't worry. I'll care sparse memory map and hotplug.
> But whether making this depends on SPARSEMEM or not is not fixed yet.
> I'll try generic one, at first. If it's dirty, start discussion about SPARSEMEM.
> 
> (Honestly, I love sparsemem than others ;)

My concern is that if we depend on sparsemem, then we force distros to turn on
sparsemem (which might be the default, but not on all architectures), we might
end up losing those architectures (w.r.t. turning on the memory controller)
where sparsemem is not the default on the distro.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
