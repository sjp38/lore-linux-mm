Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3D66B0083
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 04:52:35 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 35C2C3EE0BB
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 17:52:31 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A92645DE5C
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 17:52:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E440A45DE55
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 17:52:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D4094EF8003
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 17:52:30 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FCB5E08002
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 17:52:30 +0900 (JST)
Date: Wed, 8 Jun 2011 17:45:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-Id: <20110608174505.e4be46d6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110608074350.GP5247@suse.de>
References: <20110606125421.GB30184@cmpxchg.org>
	<20110606144519.1e2e7d86.akpm@linux-foundation.org>
	<20110607084530.8ee571aa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607084530.GI5247@suse.de>
	<20110607174355.fde99297.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607090900.GK5247@suse.de>
	<20110607183302.666115f1.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607101857.GM5247@suse.de>
	<20110608084034.29f25764.kamezawa.hiroyu@jp.fujitsu.com>
	<20110608094219.823c24f7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110608074350.GP5247@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>

On Wed, 8 Jun 2011 08:43:50 +0100
Mel Gorman <mgorman@suse.de> wrote:

> On Wed, Jun 08, 2011 at 09:42:19AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Wed, 8 Jun 2011 08:40:34 +0900
> > <SNIP>
> 
> Missing a subject 
> 
> > 
> > With sparsemem, page_cgroup_init scans pfn from 0 to max_pfn.
> > But this may scan a pfn which is not on any node and can access
> > memmap which is not initialized.
> > 
> > This makes page_cgroup_init() for SPARSEMEM node aware and remove
> > a code to get nid from page->flags. (Then, we'll use valid NID
> > always.)
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/page_cgroup.c |   41 +++++++++++++++++++++++++++++++++--------
> >  1 file changed, 33 insertions(+), 8 deletions(-)
> > 
> > Index: linux-3.0-rc1/mm/page_cgroup.c
> > ===================================================================
> > --- linux-3.0-rc1.orig/mm/page_cgroup.c
> > +++ linux-3.0-rc1/mm/page_cgroup.c
> > @@ -162,21 +162,25 @@ static void free_page_cgroup(void *addr)
> >  }
> >  #endif
> >  
> > -static int __meminit init_section_page_cgroup(unsigned long pfn)
> > +static int __meminit init_section_page_cgroup(unsigned long pfn, int nid)
> >  {
> >  	struct page_cgroup *base, *pc;
> >  	struct mem_section *section;
> >  	unsigned long table_size;
> >  	unsigned long nr;
> > -	int nid, index;
> > +	int index;
> >  
> > +	/*
> > +	 * Even if passed 'pfn' is not aligned to section, we need to align
> > +	 * it to section boundary because of SPARSEMEM pfn calculation.
> > +	 */
> > +	pfn = ALIGN(pfn, PAGES_PER_SECTION);
> >  	nr = pfn_to_section_nr(pfn);
> 
> This comment is a bit opaque and from the context of the patch,
> it's hard to know why the alignment is necessary. At least move the
> alignment to beside where section->page_cgroup is set because it'll
> be easier to understand what is going on and why.
> 

ok.


> >  	section = __nr_to_section(nr);
> >  
> >  	if (section->page_cgroup)
> >  		return 0;
> >  
> > -	nid = page_to_nid(pfn_to_page(pfn));
> >  	table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
> >  	base = alloc_page_cgroup(table_size, nid);
> >  
> > @@ -228,7 +232,7 @@ int __meminit online_page_cgroup(unsigne
> >  	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
> >  		if (!pfn_present(pfn))
> >  			continue;
> > -		fail = init_section_page_cgroup(pfn);
> > +		fail = init_section_page_cgroup(pfn, nid);
> >  	}
> >  	if (!fail)
> >  		return 0;
> > @@ -285,14 +289,35 @@ void __init page_cgroup_init(void)
> >  {
> >  	unsigned long pfn;
> >  	int fail = 0;
> > +	int node;
> >  
> 
> Very nit-picky but you sometimes use node and sometimes use nid.
> Personally, nid is my preferred choice of name as its meaning is
> unambigious.
> 

ok.


> >  	if (mem_cgroup_disabled())
> >  		return;
> >  
> > -	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
> > -		if (!pfn_present(pfn))
> > -			continue;
> > -		fail = init_section_page_cgroup(pfn);
> > +	for_each_node_state(node, N_HIGH_MEMORY) {
> > +		unsigned long start_pfn, end_pfn;
> > +
> > +		start_pfn = NODE_DATA(node)->node_start_pfn;
> > +		end_pfn = start_pfn + NODE_DATA(node)->node_spanned_pages;
> > +		/*
> > +		 * Because we cannot trust page->flags of page out of node
> > +		 * boundary, we skip pfn < start_pfn.
> > +		 */
> > +		for (pfn = start_pfn;
> > +		     !fail && (pfn < end_pfn);
> > +		     pfn = ALIGN(pfn + PAGES_PER_SECTION, PAGES_PER_SECTION)) {
> > +			if (!pfn_present(pfn))
> > +				continue;
> 
> Why did you not use pfn_valid()? 
> 
> pfn_valid checks a section has SECTION_HAS_MEM_MAP
> pfn_present checks a section has SECTION_MARKED_PRESENT
> 
> SECTION_MARKED_PRESENT does not necessarily mean mem_map has been
> allocated although I admit that this is somewhat unlikely. I'm just
> curious if you had a reason for avoiding pfn_valid()?
> 

hm, maybe I misunderstand some. I'll use pfn_valid().


> > +			/*
> > +			 * Nodes can be overlapped
> > +			 * We know some arch can have nodes layout as
> > +			 * -------------pfn-------------->
> > +			 * N0 | N1 | N2 | N0 | N1 | N2 |.....
> > +			 */
> > +			if (pfn_to_nid(pfn) != node)
> > +				continue;
> > +			fail = init_section_page_cgroup(pfn, node);
> > +		}
> >  	}
> >  	if (fail) {
> >  		printk(KERN_CRIT "try 'cgroup_disable=memory' boot option\n");
> > 
> 
> FWIW, overall I think this is heading in the right direction.
> 
Thank you. and I noticed I misunderstood what ALIGN() does.

This patch is made agaisnt the latest mainline git tree.
Tested on my host, at least.
==
