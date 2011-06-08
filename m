Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 310DA6B00EE
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 06:15:28 -0400 (EDT)
Date: Wed, 8 Jun 2011 12:15:11 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-ID: <20110608101511.GD17886@cmpxchg.org>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110608174505.e4be46d6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>

On Wed, Jun 08, 2011 at 05:45:05PM +0900, KAMEZAWA Hiroyuki wrote:
> @@ -196,7 +195,11 @@ static int __meminit init_section_page_cgroup(unsigned long pfn)
>  		pc = base + index;
>  		init_page_cgroup(pc, nr);
>  	}
> -
> +	/*
> +	 * Even if passed 'pfn' is not aligned to section, we need to align
> +	 * it to section boundary because of SPARSEMEM pfn calculation.
> +	 */
> +	pfn = pfn & ~(PAGES_PER_SECTION - 1);

PAGE_SECTION_MASK?

>  	section->page_cgroup = base - pfn;
>  	total_usage += table_size;
>  	return 0;
> @@ -228,7 +231,7 @@ int __meminit online_page_cgroup(unsigned long start_pfn,
>  	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
>  		if (!pfn_present(pfn))
>  			continue;
> -		fail = init_section_page_cgroup(pfn);
> +		fail = init_section_page_cgroup(pfn, nid);

AFAICS, nid can be -1 in the hotplug callbacks when there is a new
section added to a node that already has memory, and then the
allocation will fall back to numa_node_id().

So I think we either need to trust start_pfn has valid mem map backing
it (ARM has no memory hotplug support) and use pfn_to_nid(start_pfn),
or find another way to the right node, no?

> @@ -285,14 +288,36 @@ void __init page_cgroup_init(void)
>  {
>  	unsigned long pfn;
>  	int fail = 0;
> +	int nid;
>  
>  	if (mem_cgroup_disabled())
>  		return;
>  
> -	for (pfn = 0; !fail && pfn < max_pfn; pfn += PAGES_PER_SECTION) {
> -		if (!pfn_present(pfn))
> -			continue;
> -		fail = init_section_page_cgroup(pfn);
> +	for_each_node_state(nid, N_HIGH_MEMORY) {
> +		unsigned long start_pfn, end_pfn;
> +
> +		start_pfn = NODE_DATA(nid)->node_start_pfn;
> +		end_pfn = start_pfn + NODE_DATA(nid)->node_spanned_pages;
> +		/*
> +		 * Because we cannot trust page->flags of page out of node
> +		 * boundary, we skip pfn < start_pfn.
> +		 */
> +		for (pfn = start_pfn;
> +		     !fail && (pfn < end_pfn);
> +		     pfn = ALIGN(pfn + 1, PAGES_PER_SECTION)) {

If we don't bother to align the pfn on the first iteration, I don't
think we should for subsequent iterations.  init_section_page_cgroup()
has to be able to cope anyway.  How about

	pfn += PAGES_PER_SECTION

instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
