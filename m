Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B87F16B0078
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 04:37:11 -0400 (EDT)
Date: Tue, 7 Jun 2011 09:37:01 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-ID: <20110607083701.GH5247@suse.de>
References: <bug-36192-10286@https.bugzilla.kernel.org/>
 <20110529231948.e1439ce5.akpm@linux-foundation.org>
 <20110530160114.5a82e590.kamezawa.hiroyu@jp.fujitsu.com>
 <20110530162904.b78bf354.kamezawa.hiroyu@jp.fujitsu.com>
 <20110530165453.845bba09.kamezawa.hiroyu@jp.fujitsu.com>
 <20110530175140.3644b3bf.kamezawa.hiroyu@jp.fujitsu.com>
 <20110606125421.GB30184@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110606125421.GB30184@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>

On Mon, Jun 06, 2011 at 02:54:21PM +0200, Johannes Weiner wrote:
> Cc Mel for memory model
> 
> On Mon, May 30, 2011 at 05:51:40PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Mon, 30 May 2011 16:54:53 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Mon, 30 May 2011 16:29:04 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > SRAT: Node 1 PXM 1 0-a0000
> > > SRAT: Node 1 PXM 1 100000-c8000000
> > > SRAT: Node 1 PXM 1 100000000-438000000
> > > SRAT: Node 3 PXM 3 438000000-838000000
> > > SRAT: Node 5 PXM 5 838000000-c38000000
> > > SRAT: Node 7 PXM 7 c38000000-1038000000
> > > 
> > > Initmem setup node 1 0000000000000000-0000000438000000
> > >   NODE_DATA [0000000437fd9000 - 0000000437ffffff]
> > > Initmem setup node 3 0000000438000000-0000000838000000
> > >   NODE_DATA [0000000837fd9000 - 0000000837ffffff]
> > > Initmem setup node 5 0000000838000000-0000000c38000000
> > >   NODE_DATA [0000000c37fd9000 - 0000000c37ffffff]
> > > Initmem setup node 7 0000000c38000000-0000001038000000
> > >   NODE_DATA [0000001037fd7000 - 0000001037ffdfff]
> > > [ffffea000ec40000-ffffea000edfffff] potential offnode page_structs
> > > [ffffea001cc40000-ffffea001cdfffff] potential offnode page_structs
> > > [ffffea002ac40000-ffffea002adfffff] potential offnode page_structs
> > > ==
> > > 
> > > Hmm..there are four nodes 1,3,5,7 but....no memory on node 0 hmm ?
> > > 
> > 
> > I think I found a reason and this is a possible fix. But need to be tested.
> > And suggestion for better fix rather than this band-aid is appreciated.
> > 
> > ==
> > >From b95edcf43619312f72895476c3e6ef46079bb05f Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Mon, 30 May 2011 16:49:59 +0900
> > Subject: [PATCH][BUGFIX] fallbacks at page_cgroup allocation.
> > 
> > Under SPARSEMEM, the page_struct is allocated per section.
> > Then, pfn_valid() for the whole section is "true" and there are page
> > structs. But, it's not related to valid range of [start_pfn, end_pfn)
> > and some page structs may not be initialized collectly because
> > it's not a valid pages.
> > (memmap_init_zone() skips a page which is not correct in
> >  early_node_map[] and page->flags is initialized to be 0.)
> > 
> > In this case, a page->flags can be '0'. Assume a case where
> > node 0 has no memory....
> > 
> > page_cgroup is allocated onto the node
> > 
> >    - page_to_nid(head of section pfn)
> > 
> > Head's pfn will be valid (struct page exists) but page->flags is 0 and contains
> > node_id:0. This causes allocation onto NODE_DATA(0) and cause panic.
> > 
> > This patch makes page_cgroup to use alloc_pages_exact() only
> > when NID is N_NORMAL_MEMORY.
> 
> I don't like this much as it essentially will allocate the array from
> a (semantically) random node, as long as it has memory.
> 

Agreed. It means on some configurations the struct pages will be
node-local and on others will be node-remote depending on whether
the node starts are section-aligned or not. That will be difficult to
detect so minimally it would spit out a big warning when the struct
pages are allocated on remote nodes.

> IMO, the problem is either 1) looking at PFNs outside known node
> ranges, or 2) having present/valid sections partially outside of node
> ranges. 
> I am leaning towards 2), so I am wondering about the
> following fix:
> 

I strongly suspect it's 1 :)

While sections have valid (albeit potentially uninitialised) struct
pages outside node boundaries, within the node boundaries the
page-to-nid mapping is always valid.

> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] sparse: only mark sections present when fully covered by memory
> 
> When valid memory ranges are to be registered with sparsemem, make
> sure that only fully covered sections are marked as present.
> 

This potentially wastes a lot of memory on architectures with large
sections.

> Otherwise we end up with PFN ranges that are reported present and
> valid but are actually backed by uninitialized mem map.
> 
> The page_cgroup allocator relies on pfn_present() being reliable for
> all PFNs between 0 and max_pfn, then retrieve the node id stored in
> the corresponding page->flags to allocate the per-section page_cgroup
> arrays on the local node.
> 
> This lead to at least one crash in the page allocator on a system
> where the uninitialized page struct returned the id for node 0, which
> had no memory itself.
> 
> Reported-by: qcui@redhat.com
> Debugged-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Not-Yet-Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index aa64b12..a4fbeb8 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -182,7 +182,9 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
>  {
>  	unsigned long pfn;
>  
> -	start &= PAGE_SECTION_MASK;
> +	start = ALIGN(start, PAGES_PER_SECTION);
> +	end &= PAGE_SECTION_MASK;
> +
>  	mminit_validate_memmodel_limits(&start, &end);
>  	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION) {
>  		unsigned long section = pfn_to_section_nr(pfn);
> 

I'm afraid I do not like this because of the potential memory wastage.

I think the real problem is that the page cgroup allocator expects that
sections are fully populated. Look at this place for example

int __meminit online_page_cgroup(unsigned long start_pfn,
                        unsigned long nr_pages,
                        int nid)
{
        unsigned long start, end, pfn;
        int fail = 0;

        start = start_pfn & ~(PAGES_PER_SECTION - 1);
        end = ALIGN(start_pfn + nr_pages, PAGES_PER_SECTION);

        for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
                if (!pfn_present(pfn))
                        continue;
                fail = init_section_page_cgroup(pfn);
        }
        if (!fail)

That is fully expecting aligned sections and there is no guarantee of
that.

During this walk, you also need to verify that the struct page is for a
node that you expect with something like

       for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
                if (!pfn_present(pfn))
                        continue;
		/* Watch for overlapping or unaligned nodes */
		if (page_to_nid(pfn_to_page(pfn)) != nid)
			continue;
                fail = init_section_page_cgroup(pfn);
        }


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
