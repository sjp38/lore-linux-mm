Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 657B46B0012
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 06:13:08 -0400 (EDT)
Date: Tue, 7 Jun 2011 11:13:00 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-ID: <20110607101300.GL5247@suse.de>
References: <20110529231948.e1439ce5.akpm@linux-foundation.org>
 <20110530160114.5a82e590.kamezawa.hiroyu@jp.fujitsu.com>
 <20110530162904.b78bf354.kamezawa.hiroyu@jp.fujitsu.com>
 <20110530165453.845bba09.kamezawa.hiroyu@jp.fujitsu.com>
 <20110530175140.3644b3bf.kamezawa.hiroyu@jp.fujitsu.com>
 <20110606125421.GB30184@cmpxchg.org>
 <20110606144519.1e2e7d86.akpm@linux-foundation.org>
 <20110607095708.6097689a.kamezawa.hiroyu@jp.fujitsu.com>
 <20110607090313.GJ5247@suse.de>
 <20110607180630.be24e7c3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110607180630.be24e7c3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>

On Tue, Jun 07, 2011 at 06:06:30PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 7 Jun 2011 10:03:13 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Tue, Jun 07, 2011 at 09:57:08AM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Mon, 6 Jun 2011 14:45:19 -0700
> > > Andrew Morton <akpm@linux-foundation.org> wrote:
> > > 
> > > > Hopefully he can test this one for us as well, thanks.
> > > > 
> > > 
> > > A  patch with better description (of mine) is here.
> > > Anyway, I felt I needed a fix for ARM special case.
> > > 
> > > ==
> > > fix-init-page_cgroup-for-sparsemem-taking-care-of-broken-page-flags.patch
> > > Even with SPARSEMEM, there are some magical memmap.
> > > 
> > 
> > Who wants to introduce SPARSEMEM_MAGICAL?
> > 
> 
> ARM guys ;)
> 
> > > If a Node is not aligned to SECTION, memmap of pfn which is out of
> > > Node's range is not initialized. And page->flags contains 0.
> > > 
> > 
> > This is tangential but it might be worth introducing
> > CONFIG_DEBUG_MEMORY_MODEL that WARN_ONs page->flag == 0 in
> > pfn_to_page() to catch some accesses outside node boundaries. Not for
> > this bug though.
> > 
> 
> Hmm, buf if zone == 0 && section == 0 && nid == 0, page->flags is 0.
> 

Sorry, what I meant to suggest was that page->flags outside of
boundaries be initialised to a poison value that is an impossible
combination of flags and check that.

> > > If Node(0) doesn't exist, NODE_DATA(pfn_to_nid(pfn)) causes error.
> > > 
> > 
> > Well, not in itself. It causes a bug when we try allocate memory
> > from node 0 but there is a subtle performance bug here as well. For
> > unaligned nodes, the cgroup information can be allocated from node
> > 0 instead of node-local.
> > 
> > > In another case, for example, ARM frees memmap which is never be used
> > > even under SPARSEMEM. In that case, page->flags will contain broken
> > > value.
> > > 
> > 
> > Again, not as such. In that case, struct page is not valid memory
> > at all.
> 
> Hmm, IIUC, ARM's code frees memmap by free_bootmem().....so, memory used 
> for 'struct page' is valid and can access (but it's not struct page.)
> 
> If my English sounds strange, I'm sorry. Hm
> 
> How about this ?
> == 
>  In another case, for example, ARM frees memmap which is never be used
>  and reuse memory for memmap for other purpose. So, in that case,
>  a page got by pfn_to_page(pfn) may not a struct page.
> ==
> 

Much better.

> 
> 
> > 
> > > This patch does a strict check on nid which is obtained by
> > > pfn_to_page() and use proper NID for page_cgroup allocation.
> > > 
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > ---
> > >  mm/page_cgroup.c |   36 +++++++++++++++++++++++++++++++++++-
> > >  1 file changed, 35 insertions(+), 1 deletion(-)
> > > 
> > > Index: linux-3.0-rc1/mm/page_cgroup.c
> > > ===================================================================
> > > --- linux-3.0-rc1.orig/mm/page_cgroup.c
> > > +++ linux-3.0-rc1/mm/page_cgroup.c
> > > @@ -168,6 +168,7 @@ static int __meminit init_section_page_c
> > >  	struct mem_section *section;
> > >  	unsigned long table_size;
> > >  	unsigned long nr;
> > > +	unsigned long tmp;
> > >  	int nid, index;
> > >  
> > >  	nr = pfn_to_section_nr(pfn);
> > > @@ -175,8 +176,41 @@ static int __meminit init_section_page_c
> > >  
> > >  	if (section->page_cgroup)
> > >  		return 0;
> > > +	/*
> > > +	 * check Node-ID. Because we get 'pfn' which is obtained by calculation,
> > > +	 * the pfn may "not exist" or "alreay freed". Even if pfn_valid() returns
> > > +	 * true, page->flags may contain broken value and pfn_to_nid() returns
> > > +	 * bad value.
> > > +	 * (See CONFIG_ARCH_HAS_HOLES_MEMORYMODEL and ARM's free_memmap())
> > > +	 * So, we need to do careful check, here.
> > > +	 */
> > 
> > You don't really need to worry about ARM here as long as you stay
> > within node boundaries and you only care about the first valid page
> > in the node. Why not lookup NODE_DATA(nid) and make sure start and
> > end are within the node boundaries?
> > 
> 
> I thought ARM's code just takes care of MAX_ORDER alignment..

Which is not the same as section alignment and whatever alignment it's
using, the start of the node is still going to be valid.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
