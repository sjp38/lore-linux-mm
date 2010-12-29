Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D03A76B0088
	for <linux-mm@kvack.org>; Wed, 29 Dec 2010 11:42:38 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1554888Ab0L2QmX (ORCPT <rfc822;linux-mm@kvack.org>);
	Wed, 29 Dec 2010 17:42:23 +0100
Date: Wed, 29 Dec 2010 17:42:23 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [Xen-devel] [PATCH 3/3] drivers/xen/balloon.c: Xen memory balloon driver with memory hotplug support
Message-ID: <20101229164223.GC2743@router-fw-old.local.net-space.pl>
References: <20101220134803.GD6749@router-fw-old.local.net-space.pl> <20101227152549.GB3728@dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101227152549.GB3728@dumpdata.com>
Sender: owner-linux-mm@kvack.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Dec 27, 2010 at 10:25:49AM -0500, Konrad Rzeszutek Wilk wrote:
> On Mon, Dec 20, 2010 at 02:48:03PM +0100, Daniel Kiper wrote:
> > +static inline void adjust_memory_resource(struct resource **r, unsigned long nr_pages)
> > +{
> > +	if ((*r)->end + 1 - (nr_pages << PAGE_SHIFT) == (*r)->start) {
> > +		BUG_ON(release_resource(*r) < 0);
> > +		kfree(*r);
> > +		*r = NULL;
> > +		return;
> > +	}
> > +
> > +	BUG_ON(adjust_resource(*r, (*r)->start, (*r)->end + 1 - (*r)->start -
> > +				(nr_pages << PAGE_SHIFT)) < 0);
>
> Why not return a value here instead of BUG-ing out?

If release_resource()/adjust_resource() fail it means
there is no possibility to align resource descpription with
real memory address space. I think it is fatal error. If
we decide to leave system in that state it could lead
to data corruption or crash.

> > +	if (xen_pv_domain())
> > +		for (pfn = PFN_DOWN((*r)->start); pfn < PFN_UP((*r)->end); ++pfn)
> > +			if (!PageHighMem(pfn_to_page(pfn)))
> > +				BUG_ON(HYPERVISOR_update_va_mapping(
> > +					(unsigned long)__va(pfn << PAGE_SHIFT),
> > +					mfn_pte(pfn_to_mfn(pfn), PAGE_KERNEL), 0));
>
> Could we just stop here instead of bugging out? I mean we adding memory so
> if it does not work, the failure path seems to not add the memory?

Very good question. I based that fragment of code on original
increase_reservation()/decrease_reservation(). I attempted to find
any good explanation for that however, without success. That is why
I decided to not touch that fragment of code. If I had any
good argument to change that I will do that.

> > +static inline int request_additional_memory(long credit)
> > +{
> > +	int rc;
> > +	static struct resource *r;
>
> static?

Yes, request_additional_memory() allocate memory in chunks
and r is used between subsequent calls until all memory
is allocated.

> > +	static unsigned long pages_left;
> > +
> > +	if ((credit <= 0 || balloon_stats.balloon_low ||
> > +				balloon_stats.balloon_high) && !r)
> > +		return 0;
> >
> > -	target = min(target,
> > -		     balloon_stats.current_pages +
> > -		     balloon_stats.balloon_low +
> > -		     balloon_stats.balloon_high);
> > +	if (!r) {
> > +		rc = allocate_memory_resource(&r, credit);
> >
> > -	return target;
> > +		if (rc)
> > +			return rc;
> > +
> > +		pages_left = credit;
> > +	}
> > +
> > +	rc = allocate_additional_memory(r, pages_left);
> > +
> > +	if (rc < 0) {
> > +		if (balloon_stats.mh_policy == MH_POLICY_TRY_UNTIL_SUCCESS)
> > +			return rc;
>
> I think you are going to hit a memory leak. If we fail, you do not
> kfree(*r), should you be doing that?

If balloon_stats.mh_policy == MH_POLICY_TRY_UNTIL_SUCCESS then
balloon process attempt to allocate requested memory until success.
*r is freed only when any error appears and no memory is allocated.

> > +
> > +		adjust_memory_resource(&r, pages_left);
>
> Would it make sense to check here as well?

Please look above.

> > +
> > +		if (!r)
> > +			return rc;
> > +	} else {
> > +		pages_left -= rc;
> > +
> > +		if (pages_left)
> > +			return 1;
>
> So wouldn't that mean we could still online the 'rc' amount of pages?

Memory is onlined only when all of it is allocated.

> > +	}
> > +
> > +	hotplug_allocated_memory(&r);
> > +
> > +	return 0;
> >  }

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
