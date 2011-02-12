Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E33438D0039
	for <linux-mm@kvack.org>; Fri, 11 Feb 2011 19:46:13 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1578148Ab1BLApk (ORCPT <rfc822;linux-mm@kvack.org>);
	Sat, 12 Feb 2011 01:45:40 +0100
Date: Sat, 12 Feb 2011 01:45:40 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH R3 7/7] xen/balloon: Memory hotplug support for Xen balloon driver
Message-ID: <20110212004540.GB9646@router-fw-old.local.net-space.pl>
References: <20110203163033.GJ1364@router-fw-old.local.net-space.pl> <20110210165316.GD12087@dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110210165316.GD12087@dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Feb 10, 2011 at 11:53:16AM -0500, Konrad Rzeszutek Wilk wrote:
> On Thu, Feb 03, 2011 at 05:30:33PM +0100, Daniel Kiper wrote:

[...]

> > +static struct resource *adjust_memory_resource(struct resource *r, unsigned long nr_pages)
> > +{
> > +	int rc;
> > +
> > +	if (r->end + 1 - (nr_pages << PAGE_SHIFT) == r->start) {
>
> Will this actually occur? Say I called 'allocate_additional_memory' with 512
> and got -ENOMEM (so the hypercall failed complelty). The mh->policy 
> MH_POLICY_STOP_AT_FIRST_ERROR. So we end up here. Assume the r_min is
> 0x100000000, then r->start is 0x100000000 and r->end is 0x100200000.
>
> So:
>   100200001 - (200000) == 0x100000000 ?

r->end points always to last byte in currently allocated resource.
It means that: r->end == r->start + size - 1

> > +		rc = release_resource(r);
> > +		BUG_ON(rc < 0);
> > +		kfree(r);
> > +		return NULL;
> > +	}
> > +
> > +	rc = adjust_resource(r, r->start, r->end + 1 - r->start -
> > +				(nr_pages << PAGE_SHIFT));
>
> If we wanted 512 pages, and only got 256 and want to adjust the region, we
> would want it be:
> 0x100000000 -> 0x100100000 right?
>
> So with the third argument that comes out to be:
>
> 0x100200000 + 1 - 0x100000000 - (100000) = 100001
>
> which is just one page above what we requested?

Please, look above.

> > +
> > +	BUG_ON(rc < 0);
>
> Can we just do WARN_ON, and return NULL instead (and also release the resource)?

I will rethink that once again.

> > +
> > +	return r;
> > +}
> > +
> > +static int allocate_additional_memory(struct resource *r, unsigned long nr_pages)
> > +{
> > +	int rc;
> > +	struct xen_memory_reservation reservation = {
> > +		.address_bits = 0,
> > +		.extent_order = 0,
> > +		.domid        = DOMID_SELF
> > +	};
> > +	unsigned long flags, i, pfn, pfn_start;
> > +
> > +	if (!nr_pages)
> > +		return 0;
> > +
> > +	pfn_start = PFN_UP(r->end) - nr_pages;
> > +
> > +	if (nr_pages > ARRAY_SIZE(frame_list))
> > +		nr_pages = ARRAY_SIZE(frame_list);
> > +
> > +	for (i = 0, pfn = pfn_start; i < nr_pages; ++i, ++pfn)
> > +		frame_list[i] = pfn;
> > +
> > +	set_xen_guest_handle(reservation.extent_start, frame_list);
> > +	reservation.nr_extents = nr_pages;
> > +
> > +	spin_lock_irqsave(&xen_reservation_lock, flags);
> > +
> > +	rc = HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
> > +
> > +	if (rc <= 0)
> > +		return (rc < 0) ? rc : -ENOMEM;
> > +
>
> So if we populated some of them (say we want to 512, but only did 64),
> don't we want to do the loop below?  Also you look to be forgetting to
> do a spin_unlock_irqrestore if you quit here.

Loop which you mentioned is skipped only when HYPERVISOR_memory_op()
does not allocate anything (0 pages) or something went wrong and
an error code was returned.

spin_lock_irqsave()/spin_unlock_irqrestore() should be removed
as like it was done in increase_reservation()/decrease_reservation().
I overlooked those calls. Thanks.

> > +	for (i = 0, pfn = pfn_start; i < rc; ++i, ++pfn) {
> > +		BUG_ON(!xen_feature(XENFEAT_auto_translated_physmap) &&
> > +		       phys_to_machine_mapping_valid(pfn));
> > +		set_phys_to_machine(pfn, frame_list[i]);
> > +	}
> > +
> > +	spin_unlock_irqrestore(&xen_reservation_lock, flags);
> > +
> > +	return rc;
> > +}
> > +
> > +static void hotplug_allocated_memory(struct resource *r)
> >  {
> > -	unsigned long target = balloon_stats.target_pages;
> > +	int nid, rc;
> > +	resource_size_t r_size;
> > +	struct memory_block *mem;
> > +	unsigned long pfn;
> > +
> > +	r_size = r->end + 1 - r->start;
>
> Why bump it by one byte?

Please, look above.

> > +	nid = memory_add_physaddr_to_nid(r->start);
> > +
> > +	rc = add_registered_memory(nid, r->start, r_size);
> > +
> > +	if (rc) {
> > +		pr_err("%s: add_registered_memory: Memory hotplug failed: %i\n",
> > +			__func__, rc);
> > +		balloon_stats.target_pages = balloon_stats.current_pages;
> > +		return;
> > +	}
> > +
> > +	if (xen_pv_domain())
> > +		for (pfn = PFN_DOWN(r->start); pfn < PFN_UP(r->end); ++pfn)
>
> I think you the r->start to be PFN_UP just in case the r->start is not page
> aligned. Thought I am not sure it would even happen anymore, as M A Young
> found the culprit that made it possible for us to setup memory regions
> non-aligned and that is fixed now (in 2.6.38).

r->start is always page aligned because allocate_resource()
always returns page aligned resource (it is forced by arguments).

> > +			if (!PageHighMem(pfn_to_page(pfn))) {
> > +				rc = HYPERVISOR_update_va_mapping(
> > +					(unsigned long)__va(pfn << PAGE_SHIFT),
> > +					mfn_pte(pfn_to_mfn(pfn), PAGE_KERNEL), 0);
> > +				BUG_ON(rc);
> > +			}
> >
> > -	target = min(target,
> > -		     balloon_stats.current_pages +
> > -		     balloon_stats.balloon_low +
> > -		     balloon_stats.balloon_high);
> > +	rc = online_pages(PFN_DOWN(r->start), r_size >> PAGE_SHIFT);
> >
> > -	return target;
> > +	if (rc) {
> > +		pr_err("%s: online_pages: Failed: %i\n", __func__, rc);
> > +		balloon_stats.target_pages = balloon_stats.current_pages;
> > +		return;
> > +	}
> > +
> > +	for (pfn = PFN_DOWN(r->start); pfn < PFN_UP(r->end); pfn += PAGES_PER_SECTION) {
>
> Ditto. Can you do PFN_UP(r->start)?

Please, look above.

> > +		mem = find_memory_block(__pfn_to_section(pfn));
> > +		BUG_ON(!mem);
> > +		BUG_ON(!present_section_nr(mem->phys_index));
> > +		mutex_lock(&mem->state_mutex);
> > +		mem->state = MEM_ONLINE;
> > +		mutex_unlock(&mem->state_mutex);
> > +	}
> > +
> > +	balloon_stats.current_pages += r_size >> PAGE_SHIFT;
> >  }
> >
> > +static enum bp_state request_additional_memory(long credit)
> > +{
> > +	int rc;
> > +	static struct resource *r;
> > +	static unsigned long pages_left;
> > +
> > +	if ((credit <= 0 || balloon_stats.balloon_low ||
> > +				balloon_stats.balloon_high) && !r)
> > +		return BP_DONE;
> > +
> > +	if (!r) {
> > +		r = allocate_memory_resource(credit);
> > +
> > +		if (!r)
> > +			return BP_ERROR;
> > +
> > +		pages_left = credit;
> > +	}
> > +
> > +	rc = allocate_additional_memory(r, pages_left);
> > +
> > +	if (rc < 0) {
> > +		if (balloon_stats.mh_policy == MH_POLICY_TRY_UNTIL_SUCCESS)
> > +			return BP_ERROR;
> > +
> > +		r = adjust_memory_resource(r, pages_left);
> > +
> > +		if (!r)
> > +			return BP_ERROR;
>
> Say we failed the hypercall completly and got -ENOMEM from the 'allocate_additional_memory'.
> I presume the adjust_memory_resource at this point would have deleted 'r', which means
> that (!r) and we return BP_ERROR.
>
> But that means that we aren't following the MH_POLICY_STOP_AT_FIRST_ERROR as
> the balloon_process will retry again and the again, and again??

You are right. It should be return BP_DONE.

> > +	} else {
> > +		pages_left -= rc;
> > +
>
> So say I request 512 pages (mh_policy is MH_POLICY_STOP_AT_FIRST_ERROR),
> but only got 256. I adjust the pages_left to be 256 and then
> > +		if (pages_left)
> > +			return BP_HUNGRY;
>
> we return BP_HUNGRY. That makes 'balloon_process' retry with 512 pages, and we
> keep on trying and call "allocate_additional_memory", which fails once more
> (returns 256), and we end up returning BP_HUNGRY, and retry... and so on.
>
> Would it be make sense to have a check here for the MH_POLICY_STOP_AT_FIRST_ERROR
> and if so call the adjust_memory_memory_resource as well?

Here it is OK. First time allocate_additional_memory() returns 256 which
is OK and next time if more memory is not available then it returns rc < 0
which forces execution of "if (rc < 0) {..." (as it was expected).

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
