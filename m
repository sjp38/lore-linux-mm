Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0EADD6B0078
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 21:11:32 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2228D3EE0BC
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 10:11:30 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0926B45DEA3
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 10:11:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D929345DE9F
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 10:11:29 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C9A97E38002
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 10:11:29 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 878A2E38001
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 10:11:29 +0900 (JST)
Date: Thu, 9 Jun 2011 10:04:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-Id: <20110609100434.64898575.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110608101511.GD17886@cmpxchg.org>
References: <20110607084530.8ee571aa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607084530.GI5247@suse.de>
	<20110607174355.fde99297.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607090900.GK5247@suse.de>
	<20110607183302.666115f1.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607101857.GM5247@suse.de>
	<20110608084034.29f25764.kamezawa.hiroyu@jp.fujitsu.com>
	<20110608094219.823c24f7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110608074350.GP5247@suse.de>
	<20110608174505.e4be46d6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110608101511.GD17886@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>

On Wed, 8 Jun 2011 12:15:11 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Wed, Jun 08, 2011 at 05:45:05PM +0900, KAMEZAWA Hiroyuki wrote:
> > @@ -196,7 +195,11 @@ static int __meminit init_section_page_cgroup(unsigned long pfn)
> >  		pc = base + index;
> >  		init_page_cgroup(pc, nr);
> >  	}
> > -
> > +	/*
> > +	 * Even if passed 'pfn' is not aligned to section, we need to align
> > +	 * it to section boundary because of SPARSEMEM pfn calculation.
> > +	 */
> > +	pfn = pfn & ~(PAGES_PER_SECTION - 1);
> 
> PAGE_SECTION_MASK?
> 
will use it.

> >  	section->page_cgroup = base - pfn;
> >  	total_usage += table_size;
> >  	return 0;
> > @@ -228,7 +231,7 @@ int __meminit online_page_cgroup(unsigned long start_pfn,
> >  	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
> >  		if (!pfn_present(pfn))
> >  			continue;
> > -		fail = init_section_page_cgroup(pfn);
> > +		fail = init_section_page_cgroup(pfn, nid);
> 
> AFAICS, nid can be -1 in the hotplug callbacks when there is a new
> section added to a node that already has memory, and then the
> allocation will fall back to numa_node_id().
> 
Ah, thank you for pointing out.

> So I think we either need to trust start_pfn has valid mem map backing
> it (ARM has no memory hotplug support) and use pfn_to_nid(start_pfn),
> or find another way to the right node, no?
> 

memory hotplug itself does nid = page_to_nid(pfn_to_page(pfn))..
so we can assume memmap of start_pfn will be valid..



> > @@ -285,14 +288,36 @@ void __init page_cgroup_init(void)
> >  {
> >  	unsigned long pfn;
> >  	int fail = 0;
> > +	int nid;
> >  
> >  	if (mem_cgroup_disabled())
> >  		return;
> >  
> > -	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
> > -		if (!pfn_present(pfn))
> > -			continue;
> > -		fail = init_section_page_cgroup(pfn);
> > +	for_each_node_state(nid, N_HIGH_MEMORY) {
> > +		unsigned long start_pfn, end_pfn;
> > +
> > +		start_pfn = NODE_DATA(nid)->node_start_pfn;
> > +		end_pfn = start_pfn + NODE_DATA(nid)->node_spanned_pages;
> > +		/*
> > +		 * Because we cannot trust page->flags of page out of node
> > +		 * boundary, we skip pfn < start_pfn.
> > +		 */
> > +		for (pfn = start_pfn;
> > +		     !fail && (pfn < end_pfn);
> > +		     pfn = ALIGN(pfn + 1, PAGES_PER_SECTION)) {
> 
> If we don't bother to align the pfn on the first iteration, I don't
> think we should for subsequent iterations.  init_section_page_cgroup()
> has to be able to cope anyway.  How about
> 
> 	pfn += PAGES_PER_SECTION
> 
> instead?
> 

I thought of that but it means (pfn < end_pfn) goes wrong.
If pfn is not aligned.

                   pfn-------->end_pfn----------->pfn+PAGES_PER_SECTION

pages in [pfn..end_pfn) will not be handled. But I'd like to think about
this in the next version.

Thank you for review.

Thanks,
-Kame













--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
