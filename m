Date: Tue, 9 Sep 2008 14:12:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
Message-Id: <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200809091500.10619.nickpiggin@yahoo.com.au>
References: <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com>
	<200809091358.28350.nickpiggin@yahoo.com.au>
	<20080909135317.cbff4871.kamezawa.hiroyu@jp.fujitsu.com>
	<200809091500.10619.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Sep 2008 15:00:10 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > maybe a routine like SPARSEMEM is a choice.
> >
> > Following is pointer pre-allocation. (just pointer, not page_cgroup itself)
> > ==
> > #define PCG_SECTION_SHIFT	(10)
> > #define PCG_SECTION_SIZE	(1 << PCG_SECTION_SHIFT)
> >
> > struct pcg_section {
> > 	struct page_cgroup **map[PCG_SECTION_SHIFT]; //array of pointer.
> > };
> >
> > struct page_cgroup *get_page_cgroup(unsigned long pfn)
> > {
> > 	struct pcg_section *sec;
> > 	sec = pcg_section[(pfn >> PCG_SECTION_SHIFT)];
> > 	return *sec->page_cgroup[(pfn & ((1 << PCG_SECTTION_SHIFT) - 1];
> > }
> > ==
> > If we go extreme, we can use kmap_atomic() for pointer array.
> >
> > Overhead of pointer-walk is not so bad, maybe.
> >
> > For 64bit systems, we can find a way like SPARSEMEM_VMEMMAP.
> 
> Yes I too think that would be the ideal way to go to get the best of
> performance in the enabled case. However Balbir I believe is interested
> in memory savings if not all pages have cgroups... I don't know, I don't
> care so much about the "enabled" case, so I'll leave you two to fight it
> out :)
> 
I'll add a new patch on my set.

Balbir, are you ok to CONFIG_CGROUP_MEM_RES_CTLR depends on CONFIG_SPARSEMEM ?
I thinks SPARSEMEM(SPARSEMEM_VMEMMAP) is widely used in various archs now.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
