Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9746B0012
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 06:19:05 -0400 (EDT)
Date: Tue, 7 Jun 2011 11:18:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-ID: <20110607101857.GM5247@suse.de>
References: <20110530162904.b78bf354.kamezawa.hiroyu@jp.fujitsu.com>
 <20110530165453.845bba09.kamezawa.hiroyu@jp.fujitsu.com>
 <20110530175140.3644b3bf.kamezawa.hiroyu@jp.fujitsu.com>
 <20110606125421.GB30184@cmpxchg.org>
 <20110606144519.1e2e7d86.akpm@linux-foundation.org>
 <20110607084530.8ee571aa.kamezawa.hiroyu@jp.fujitsu.com>
 <20110607084530.GI5247@suse.de>
 <20110607174355.fde99297.kamezawa.hiroyu@jp.fujitsu.com>
 <20110607090900.GK5247@suse.de>
 <20110607183302.666115f1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110607183302.666115f1.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>

On Tue, Jun 07, 2011 at 06:33:02PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 7 Jun 2011 10:09:00 +0100
> Mel Gorman <mgorman@suse.de> wrote:
>  
> > I should have said "nodes" even though the end result is the same. The
> > problem at the moment is cgroup initialisation is checking PFNs outside
> > node boundaries. It should be ensuring that the start and end PFNs it
> > uses are within boundaries.
> > 
> Maybe you like this kind of fix. Yes, this can fix the problem on bugzilla.
> My concern is this will not work for ARM. 
> 
> This patch (and all other patch) works on my test host.
> ==
> make sparsemem's page_cgroup_init to be node aware.
> 
> With sparsemem, page_cgroup_init scans pfn from 0 to max_pfn.
> But this may scan a pfn which is not on any node and can access
> memmap which is not initialized.
> 
> This makes page_cgroup_init() for SPARSEMEM node aware.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/page_cgroup.c |   26 ++++++++++++++++++++++----
>  1 file changed, 22 insertions(+), 4 deletions(-)
> 
> Index: linux-3.0-rc1/mm/page_cgroup.c
> ===================================================================
> --- linux-3.0-rc1.orig/mm/page_cgroup.c
> +++ linux-3.0-rc1/mm/page_cgroup.c
> @@ -285,14 +285,32 @@ void __init page_cgroup_init(void)
>  {
>  	unsigned long pfn;
>  	int fail = 0;
> +	int node;
>  
>  	if (mem_cgroup_disabled())
>  		return;
>  
> -	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
> -		if (!pfn_present(pfn))
> -			continue;
> -		fail = init_section_page_cgroup(pfn);
> +	for_each_node_state(node, N_HIGH_MEMORY) {
> +		unsigned long start_pfn, end_pfn;
> +
> +		start_pfn = NODE_DATA(node)->node_start_pfn;
> +		end_pfn = start_pfn + NODE_DATA(node)->node_spanned_pages;
> +		/*
> +		 * This calculation makes sure that this nid detection for
> +		 * section can work even if node->start_pfn is not aligned to
> +		 * section. For sections on not-node-boundary, we see head
> +		 * page of sections.
> +		 */
> +		for (pfn = start_pfn;
> +		     !fail & (pfn < end_pfn);

&& instead of & there?

> +		     pfn = ALIGN(pfn + PAGES_PER_SECTION, PAGES_PER_SECTION)) {
> +			if (!pfn_present(pfn))
> +				continue;
> +			/* Nodes can be overlapped */
> +			if (pfn_to_nid(pfn) != node)
> +				continue;
> +			fail = init_section_page_cgroup(pfn);
> +		}

So this is finding the first valid PFN in a node. Even the
overlapping problem should not be an issue here as unless node memory
initialisation is overwriting flags belonging to other nodes. The
paranoia does not hurt.

I also don't think the ARM punching holes in the memmap is a problem
because we'd at least expect the start of the node to be valid.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
