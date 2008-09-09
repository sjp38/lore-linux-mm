From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page
Date: Tue, 9 Sep 2008 15:00:10 +1000
References: <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com> <200809091358.28350.nickpiggin@yahoo.com.au> <20080909135317.cbff4871.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080909135317.cbff4871.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200809091500.10619.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 09 September 2008 14:53, KAMEZAWA Hiroyuki wrote:
> On Tue, 9 Sep 2008 13:58:27 +1000
>
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > On Tuesday 09 September 2008 13:57, KAMEZAWA Hiroyuki wrote:
> > > On Mon, 8 Sep 2008 20:58:10 +0530
> > >
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > Sorry for the delay in sending out the new patch, I am traveling and
> > > > thus a little less responsive. Here is the update patch
> > >
> > > Hmm.. I've considered this approach for a while and my answer is that
> > > this is not what you really want.
> > >
> > > Because you just moves the placement of pointer from memmap to
> > > radix_tree both in GFP_KERNEL, total kernel memory usage is not
> > > changed. So, at least, you have to add some address calculation (as I
> > > did in March) to getting address of page_cgroup. But page_cgroup itself
> > > consumes 32bytes per page. Then.....
> >
> > Just keep in mind that an important point is to make it more attractive
> > to configure cgroup into the kernel, but have it disabled or unused at
> > runtime.
>
> Hmm..kicking out 4bytes per 4096bytes if disabled ?

Yeah of course. 4 or 8 bytes. Everything adds up. There is nothing special
about cgroups that says it is allowed to use fields in struct page where
others cannot. Put it in perspective: we try very hard not to allocate new
*bits* in page flags, which is only 4 bytes per 131072 bytes.


> maybe a routine like SPARSEMEM is a choice.
>
> Following is pointer pre-allocation. (just pointer, not page_cgroup itself)
> ==
> #define PCG_SECTION_SHIFT	(10)
> #define PCG_SECTION_SIZE	(1 << PCG_SECTION_SHIFT)
>
> struct pcg_section {
> 	struct page_cgroup **map[PCG_SECTION_SHIFT]; //array of pointer.
> };
>
> struct page_cgroup *get_page_cgroup(unsigned long pfn)
> {
> 	struct pcg_section *sec;
> 	sec = pcg_section[(pfn >> PCG_SECTION_SHIFT)];
> 	return *sec->page_cgroup[(pfn & ((1 << PCG_SECTTION_SHIFT) - 1];
> }
> ==
> If we go extreme, we can use kmap_atomic() for pointer array.
>
> Overhead of pointer-walk is not so bad, maybe.
>
> For 64bit systems, we can find a way like SPARSEMEM_VMEMMAP.

Yes I too think that would be the ideal way to go to get the best of
performance in the enabled case. However Balbir I believe is interested
in memory savings if not all pages have cgroups... I don't know, I don't
care so much about the "enabled" case, so I'll leave you two to fight it
out :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
