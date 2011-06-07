Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 578086B0012
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 05:13:30 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 43CD23EE0BD
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 18:13:25 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D44945DE6A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 18:13:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0507445DE61
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 18:13:25 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EBF511DB803F
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 18:13:24 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A98F61DB803B
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 18:13:24 +0900 (JST)
Date: Tue, 7 Jun 2011 18:06:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 36192] New: Kernel panic when boot the 2.6.39+
 kernel based off of 2.6.32 kernel
Message-Id: <20110607180630.be24e7c3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110607090313.GJ5247@suse.de>
References: <bug-36192-10286@https.bugzilla.kernel.org/>
	<20110529231948.e1439ce5.akpm@linux-foundation.org>
	<20110530160114.5a82e590.kamezawa.hiroyu@jp.fujitsu.com>
	<20110530162904.b78bf354.kamezawa.hiroyu@jp.fujitsu.com>
	<20110530165453.845bba09.kamezawa.hiroyu@jp.fujitsu.com>
	<20110530175140.3644b3bf.kamezawa.hiroyu@jp.fujitsu.com>
	<20110606125421.GB30184@cmpxchg.org>
	<20110606144519.1e2e7d86.akpm@linux-foundation.org>
	<20110607095708.6097689a.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607090313.GJ5247@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>

On Tue, 7 Jun 2011 10:03:13 +0100
Mel Gorman <mgorman@suse.de> wrote:

> On Tue, Jun 07, 2011 at 09:57:08AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Mon, 6 Jun 2011 14:45:19 -0700
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > > Hopefully he can test this one for us as well, thanks.
> > > 
> > 
> > A  patch with better description (of mine) is here.
> > Anyway, I felt I needed a fix for ARM special case.
> > 
> > ==
> > fix-init-page_cgroup-for-sparsemem-taking-care-of-broken-page-flags.patch
> > Even with SPARSEMEM, there are some magical memmap.
> > 
> 
> Who wants to introduce SPARSEMEM_MAGICAL?
> 

ARM guys ;)

> > If a Node is not aligned to SECTION, memmap of pfn which is out of
> > Node's range is not initialized. And page->flags contains 0.
> > 
> 
> This is tangential but it might be worth introducing
> CONFIG_DEBUG_MEMORY_MODEL that WARN_ONs page->flag == 0 in
> pfn_to_page() to catch some accesses outside node boundaries. Not for
> this bug though.
> 

Hmm, buf if zone == 0 && section == 0 && nid == 0, page->flags is 0.



> > If Node(0) doesn't exist, NODE_DATA(pfn_to_nid(pfn)) causes error.
> > 
> 
> Well, not in itself. It causes a bug when we try allocate memory
> from node 0 but there is a subtle performance bug here as well. For
> unaligned nodes, the cgroup information can be allocated from node
> 0 instead of node-local.
> 
> > In another case, for example, ARM frees memmap which is never be used
> > even under SPARSEMEM. In that case, page->flags will contain broken
> > value.
> > 
> 
> Again, not as such. In that case, struct page is not valid memory
> at all.

Hmm, IIUC, ARM's code frees memmap by free_bootmem().....so, memory used 
for 'struct page' is valid and can access (but it's not struct page.)

If my English sounds strange, I'm sorry. Hm

How about this ?
== 
 In another case, for example, ARM frees memmap which is never be used
 and reuse memory for memmap for other purpose. So, in that case,
 a page got by pfn_to_page(pfn) may not a struct page.
==



> 
> > This patch does a strict check on nid which is obtained by
> > pfn_to_page() and use proper NID for page_cgroup allocation.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > ---
> >  mm/page_cgroup.c |   36 +++++++++++++++++++++++++++++++++++-
> >  1 file changed, 35 insertions(+), 1 deletion(-)
> > 
> > Index: linux-3.0-rc1/mm/page_cgroup.c
> > ===================================================================
> > --- linux-3.0-rc1.orig/mm/page_cgroup.c
> > +++ linux-3.0-rc1/mm/page_cgroup.c
> > @@ -168,6 +168,7 @@ static int __meminit init_section_page_c
> >  	struct mem_section *section;
> >  	unsigned long table_size;
> >  	unsigned long nr;
> > +	unsigned long tmp;
> >  	int nid, index;
> >  
> >  	nr = pfn_to_section_nr(pfn);
> > @@ -175,8 +176,41 @@ static int __meminit init_section_page_c
> >  
> >  	if (section->page_cgroup)
> >  		return 0;
> > +	/*
> > +	 * check Node-ID. Because we get 'pfn' which is obtained by calculation,
> > +	 * the pfn may "not exist" or "alreay freed". Even if pfn_valid() returns
> > +	 * true, page->flags may contain broken value and pfn_to_nid() returns
> > +	 * bad value.
> > +	 * (See CONFIG_ARCH_HAS_HOLES_MEMORYMODEL and ARM's free_memmap())
> > +	 * So, we need to do careful check, here.
> > +	 */
> 
> You don't really need to worry about ARM here as long as you stay
> within node boundaries and you only care about the first valid page
> in the node. Why not lookup NODE_DATA(nid) and make sure start and
> end are within the node boundaries?
> 

I thought ARM's code just takes care of MAX_ORDER alignment..and doesn't
take care of making holes in a zone/node. Am I wrong ?

== arch/arm/mm/init.c===
        for_each_bank(i, mi) {
                struct membank *bank = &mi->bank[i];

                bank_start = bank_pfn_start(bank);

#ifdef CONFIG_SPARSEMEM
                /*
                 * Take care not to free memmap entries that don't exist
                 * due to SPARSEMEM sections which aren't present.
                 */
                bank_start = min(bank_start,
                                 ALIGN(prev_bank_end, PAGES_PER_SECTION));
#endif
                /*
                 * If we had a previous bank, and there is a space
                 * between the current bank and the previous, free it.
                 */
                if (prev_bank_end && prev_bank_end < bank_start)
                        free_memmap(prev_bank_end, bank_start);

                /*
                 * Align up here since the VM subsystem insists that the
                 * memmap entries are valid from the bank end aligned to
                 * MAX_ORDER_NR_PAGES.
                 */
                prev_bank_end = ALIGN(bank_pfn_end(bank), MAX_ORDER_NR_PAGES);
        }
===

ARM frees memmap for holes between valid memory bank.

Do you mean this one "memory bank" represents a node finally ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
