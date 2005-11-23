Subject: Re: [PATCH]: Free pages from local pcp lists under tight memory
	conditions
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <20051122213612.4adef5d0.akpm@osdl.org>
References: <20051122161000.A22430@unix-os.sc.intel.com>
	 <20051122213612.4adef5d0.akpm@osdl.org>
Content-Type: text/plain
Date: Wed, 23 Nov 2005 09:54:42 -0800
Message-Id: <1132768482.25086.16.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <christoph@lameter.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-11-22 at 21:36 -0800, Andrew Morton wrote:
> Rohit Seth <rohit.seth@intel.com> wrote:
> >
> > Andrew, Linus,
> > 
> > [PATCH]: This patch free pages (pcp->batch from each list at a time) from
> > local pcp lists when a higher order allocation request is not able to 
> > get serviced from global free_list.
> > 
> > This should help fix some of the earlier failures seen with order 1 allocations.
> > 
> > I will send separate patches for:
> > 
> > 1- Reducing the remote cpus pcp
> > 2- Clean up page_alloc.c for CONFIG_HOTPLUG_CPU to use this code appropiately
> > 
> > +static int
> > +reduce_cpu_pcp(void )
> >
> This significantly duplicates the existing drain_local_pages().

Yes.  The main change in this new function is I'm only freeing batch
number of pages from each pcp rather than draining out all of them (even
under a little memory pressure).  IMO, we should be more opportunistic
here in alloc_pages in moving pages back to global page pool list.
Thoughts?

As said earlier, I will be cleaning up the existing drain_local_pages in
next follow up patch.

> 
> >  
> > +	if (order > 0) 
> > +		while (reduce_cpu_pcp()) {
> > +			if (get_page_from_freelist(gfp_mask, order, zonelist, alloc_flags))
> 
> This forgot to assign to local variable `page'!  It'll return NULL and will
> leak memory.
> 
My bad.  Will fix it.

> The `while' loop worries me for some reason, so I wimped out and just tried
> the remote drain once.
> 
Even after direct reclaim it probably does make sense to see how
minimally we can service a higher order request.

> > +				goto got_pg;
> > +		}
> > +	/* FIXME: Add the support for reducing/draining the remote pcps.
> 
> This is easy enough to do.
> 

The couple of options that I wanted to think little more were (before
attempting to do this part):

1- Whether use the IPI to get the remote CPUs to free pages from pcp or
do it lazily (using work_pending or such).  As at this point in
execution we can definitely afford to get scheduled out.

2- Do we drain the whole pcp on remote processors or again follow the
stepped approach (but may be with a steeper slope).


> We need to verify that this patch actually does something useful.
> 
> 
I'm working on this.  Will let you know later today if I can come with
some workload easily hitting this additional logic.

Thanks,
-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
