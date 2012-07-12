Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 810086B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 15:58:39 -0400 (EDT)
Date: Thu, 12 Jul 2012 21:58:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 36/40] autonuma: page_autonuma
Message-ID: <20120712195815.GQ20382@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-37-git-send-email-aarcange@redhat.com>
 <4FF14196.6040106@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FF14196.6040106@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Mon, Jul 02, 2012 at 02:37:10AM -0400, Rik van Riel wrote:
>  > +fail:
>  > +	printk(KERN_CRIT "allocation of page_autonuma failed.\n");
>  > +	printk(KERN_CRIT "please try the 'noautonuma' boot option\n");
>  > +	panic("Out of memory");
>  > +}
> 
> The system can run just fine without autonuma.
> 
> Would it make sense to simply disable autonuma at this point,
> but to try continue running?

BTW, the same would apply to mm/page_cgroup.c, but I think the idea
here is that something serious went wrong. Workaround with noautonuma
boot option is enough.

> 
> > @@ -700,8 +780,14 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
> >   	 */
> >   	if (PageSlab(usemap_page)) {
> >   		kfree(usemap);
> > -		if (memmap)
> > +		if (memmap) {
> >   			__kfree_section_memmap(memmap, PAGES_PER_SECTION);
> > +			if (!autonuma_impossible())
> > +				__kfree_section_page_autonuma(page_autonuma,
> > +							      PAGES_PER_SECTION);
> > +			else
> > +				BUG_ON(page_autonuma);
> 
> VM_BUG_ON ?
> 
> > +		if (!autonuma_impossible()) {
> > +			struct page *page_autonuma_page;
> > +			page_autonuma_page = virt_to_page(page_autonuma);
> > +			free_map_bootmem(page_autonuma_page, nr_pages);
> > +		} else
> > +			BUG_ON(page_autonuma);
> 
> ditto
> 
> >   	pgdat_resize_unlock(pgdat,&flags);
> >   	if (ret<= 0) {
> > +		if (!autonuma_impossible())
> > +			__kfree_section_page_autonuma(page_autonuma, nr_pages);
> > +		else
> > +			BUG_ON(page_autonuma);
> 
> VM_BUG_ON ?

These only run at the very boot stage, so performance is irrelevant
and it's safer to keep them on.

The rest was corrected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
