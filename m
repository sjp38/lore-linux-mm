Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA798D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 09:13:20 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1576485Ab1BGOM1 (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 7 Feb 2011 15:12:27 +0100
Date: Mon, 7 Feb 2011 15:12:27 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH R3 7/7] xen/balloon: Memory hotplug support for Xen balloon driver
Message-ID: <20110207141227.GA10852@router-fw-old.local.net-space.pl>
References: <20110203163033.GJ1364@router-fw-old.local.net-space.pl> <1296756744.8299.1440.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1296756744.8299.1440.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Feb 03, 2011 at 10:12:24AM -0800, Dave Hansen wrote:
> On Thu, 2011-02-03 at 17:30 +0100, Daniel Kiper wrote:
> > +static struct resource *allocate_memory_resource(unsigned long nr_pages)
> > +{
> > +	resource_size_t r_min, r_size;
> > +	struct resource *r;
> > +
> > +	/*
> > +	 * Look for first unused memory region starting at page
> > +	 * boundary. Skip last memory section created at boot time
> > +	 * because it may contains unused memory pages with PG_reserved
> > +	 * bit not set (online_pages() require PG_reserved bit set).
> > +	 */
>
> Could you elaborate on this comment a bit?  I think it's covering both
> the "PAGE_SIZE" argument to allocate_resource() and something else, but
> I'm not quite sure.

Yes, you are right. Aligment to PAGE_SIZE is done by allocate_resource().
Additionally, r_min (calculated below) sets lower limit at which hoplugged
memory could be installed (due to PG_reserved bit requirment set up by
online_pages()). Later r_min is put as an argument to allocate_resource() call.

> > +	r = kzalloc(sizeof(struct resource), GFP_KERNEL);
> > +
> > +	if (!r)
> > +		return NULL;
> > +
> > +	r->name = "System RAM";
> > +	r->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> > +	r_min = PFN_PHYS(section_nr_to_pfn(pfn_to_section_nr(balloon_stats.boot_max_pfn) + 1));
>
> Did you do this for alignment reasons?  It might be a better idea to
> just make a nice sparsemem function to do alignment.

Please look above.

> > +	r_size = nr_pages << PAGE_SHIFT;
> > +
> > +	if (allocate_resource(&iomem_resource, r, r_size, r_min,
> > +					ULONG_MAX, PAGE_SIZE, NULL, NULL) < 0) {
> > +		kfree(r);
> > +		return NULL;
> > +	}
> > +
> > +	return r;
> > +}
>
> This function should probably be made generic.  I bet some more
> hypervisors come around and want to use this.  They generally won't care
> where the memory goes, and the kernel can allocate a spot for them.

Yes, you are right. I think about new project in which
this function will be generic and then I would move it to
some more generic place. Now, I think it should stay here.

> ...
> > +static void hotplug_allocated_memory(struct resource *r)
> >  {
> > -	unsigned long target = balloon_stats.target_pages;
> > +	int nid, rc;
> > +	resource_size_t r_size;
> > +	struct memory_block *mem;
> > +	unsigned long pfn;
> > +
> > +	r_size = r->end + 1 - r->start;
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
>
> The memory hotplug code is a bit weird at first glance.  It has two
> distinct stages: first, add_memory() is called from
> architecture-specific code.  Later, online_pages() is called, but that
> part is driven by userspace.
>
> For all the other hotplug users online_pages() is done later, and
> triggered by userspace.  The idea is that you could have memory sitting
> in "added, but offline" state which would be trivial to remove if
> someone else needed it, but also trivial to add without the need to
> allocate additional memory.
>
> In other words, I think you can take everything from and including
> online_pages() down in the function and take it out.  Use a udev hotplug
> rule to online it immediately if that's what you want.

I agree. I discussed a bit about this problem with Jeremy, too. However,
there are some problems to implement that solution now. First of all it is
possible to online hotplugged memory using sysfs interface only in chunks
called sections. It means that it is not possible online once again section
which was onlined ealier partialy populated and now it contains new pages
to online. In this situation sysfs interface emits Invalid argument error.
In theory it should be possible to offline and then online whole section
once again, however, if memory from this section was used is not possible
to do that. It means that those properties does not allow hotplug memory
in guest in finer granulity than section and sysfs interface is too inflexible
to be used in that solution. That is why I decided to online hoplugged memory
using API which does not have those limitations.

I think that two solutions are possible (in order of prefernce) to cope
with that problem and move onlining to user domain:
  - migrate to new sysfs interface for onlining which allows
    address space description when onlining memory,
  - create new onlining sysfs inteface for Xen only (I think that
    first solution is much better because it will be generic).

However, those solution require time to implementation and that is
why, I think, that my solution (let's call it workaround) should
be implemented till new sysfs interface will be available.

> > -	return target;
> > +	if (rc) {
> > +		pr_err("%s: online_pages: Failed: %i\n", __func__, rc);
> > +		balloon_stats.target_pages = balloon_stats.current_pages;
> > +		return;
> > +	}
> > +
> > +	for (pfn = PFN_DOWN(r->start); pfn < PFN_UP(r->end); pfn += PAGES_PER_SECTION) {
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
>
> 'r' is effectively a global variable here.  Could you give it a more
> proper name?  Maybe "last add location" or something.  It might even
> make sense to move it up in to the global scope to make it _much_ more
> clear that it's not just locally used.

This is used between subsequent calls (memory is allocated in chunks
and onlined when all requested memory is allocated) to store address
space for allocation. That is why it is static. It is used only in this
function and if it is required then pointer to this variable is passed
to called functions. I think that it should stay local to this function
and do not pollute global variable namespace. However, I will rename it to
something more meaningful.

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
> > +	} else {
> > +		pages_left -= rc;
> > +
> > +		if (pages_left)
> > +			return BP_HUNGRY;
> > +	}
> > +
> > +	hotplug_allocated_memory(r);
> > +
> > +	r = NULL;
> > +
> > +	return BP_DONE;
> > +}
>
> Could you explain a bit about why you chose to do this stuff with memory
> resources?  Is that the only visibility that you have in to what memory
> the guest actually has?

That depends on balloon_stats.mh_policy. If it is MH_POLICY_TRY_UNTIL_SUCCESS
and memory allocation error appears then *r is not changed and attempts
are made to allocate more memory. If it is MH_POLICY_STOP_AT_FIRST_ERROR
and memory allocation error appears then *r is alligned to currently
successfully allocated memory and memory is onlined (if size != 0).

> What troubles did you run in to when you did
>
> 	add_memory(0, balloon_stats.boot_max_pfn, credit);
>
> ?
>
> It's just that all the other memory hotplug users are _told_ by the
> hardware where to put things.  Is that not the case here?

No. On bare metal BIOS/firmware cares about proper address space and
when everything goes OK then notify operating system about memory hotplug.
In Xen (and probably in others platforms will be) it is not a case and
memory should be allocated ealier by guest. However, before doing
that, I think, address space should be reserved (it is small chance that
something will request overlaping address space, however, I think it is
better to do that than sorry). Additionally, IIRC, add_memory() requires
that underlying memory is available before its call. That is why I
decided to create add_registered_memory() which do all things which are
done by add_memory() excluding address space reservation which is done
by allocate_memory_resource() before memory allocation.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
