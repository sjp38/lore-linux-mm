Date: Wed, 19 Sep 2007 22:50:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 7/8] oom: only kill tasks that share zones with
 zonelist
In-Reply-To: <Pine.LNX.4.64.0709191156480.2241@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709192245070.22371@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350560.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190351140.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190351290.23538@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709190351460.23538@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709191156480.2241@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, Christoph Lameter wrote:

> > +		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > +			unsigned long pfn;
> > +			struct zone *zone;
> > +
> > +			pfn = PFN_DOWN(vma->vm_start);
> > +			zone = page_zone(pfn_to_page(pfn));
> 
> This seems to assume that all pages in a vma are in the same zone? That is 
> not the case. On a NUMA system pages may be allocated round robin. Meaning 
> lots of zones are used that this approach does not catch.
> 

Setting the CONSTRAINT_MEMORY_POLICY case aside for a moment, what stops 
us from getting rid of taking callback_mutex and simply relying on the 
following to filter for candidate tasks:

	do_each_thread(g, p) {
		...
		/*
		 * Check if it will do any good to kill this task based
		 * on where it is allowed to allocate.
		 */
		if (!nodes_intersects(current->mems_allowed,
				      p->mems_allowed))
			continue;
		...
	} while_each_thread(g, p);

We shouldn't really be concerned with the changing cpuset states during 
out_of_memory() since we're only using it as a hint and we're not 
dereferencing current->cpuset or p->cpuset.  This eliminates the need for 
cpuset_{lock,unlock}() and cpuset_excl_nodes_overlap().

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
