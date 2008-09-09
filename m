Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m89COAAC019277
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 22:24:10 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m89CObWI103584
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 22:25:06 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m89COW8M025708
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 22:24:32 +1000
Message-ID: <48C66AF8.5070505@linux.vnet.ibm.com>
Date: Tue, 09 Sep 2008 05:24:24 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
References: <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com> <200809091358.28350.nickpiggin@yahoo.com.au> <20080909135317.cbff4871.kamezawa.hiroyu@jp.fujitsu.com> <200809091500.10619.nickpiggin@yahoo.com.au> <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 9 Sep 2008 15:00:10 +1000
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>>> maybe a routine like SPARSEMEM is a choice.
>>>
>>> Following is pointer pre-allocation. (just pointer, not page_cgroup itself)
>>> ==
>>> #define PCG_SECTION_SHIFT	(10)
>>> #define PCG_SECTION_SIZE	(1 << PCG_SECTION_SHIFT)
>>>
>>> struct pcg_section {
>>> 	struct page_cgroup **map[PCG_SECTION_SHIFT]; //array of pointer.
>>> };
>>>
>>> struct page_cgroup *get_page_cgroup(unsigned long pfn)
>>> {
>>> 	struct pcg_section *sec;
>>> 	sec = pcg_section[(pfn >> PCG_SECTION_SHIFT)];
>>> 	return *sec->page_cgroup[(pfn & ((1 << PCG_SECTTION_SHIFT) - 1];
>>> }
>>> ==
>>> If we go extreme, we can use kmap_atomic() for pointer array.
>>>
>>> Overhead of pointer-walk is not so bad, maybe.
>>>
>>> For 64bit systems, we can find a way like SPARSEMEM_VMEMMAP.
>> Yes I too think that would be the ideal way to go to get the best of
>> performance in the enabled case. However Balbir I believe is interested
>> in memory savings if not all pages have cgroups... I don't know, I don't
>> care so much about the "enabled" case, so I'll leave you two to fight it
>> out :)
>>
> I'll add a new patch on my set.
> 
> Balbir, are you ok to CONFIG_CGROUP_MEM_RES_CTLR depends on CONFIG_SPARSEMEM ?
> I thinks SPARSEMEM(SPARSEMEM_VMEMMAP) is widely used in various archs now.

Can't we make it more generic. I was thinking of allocating memory for each node
for page_cgroups (of the size of spanned_pages) at initialization time. I've not
yet prototyped the idea. BTW, even with your approach I fail to see why we need
to add a dependency on CONFIG_SPARSEMEM (but again it is 4:30 in the morning and
I might be missing the obvious)

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
