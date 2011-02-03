Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6488C8D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 13:12:38 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p13HmeZj017949
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 12:48:40 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C934B728065
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 13:12:31 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p13ICVwb409604
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:12:31 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p13ICS6d003218
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 16:12:31 -0200
Subject: Re: [PATCH R3 7/7] xen/balloon: Memory hotplug support for Xen
 balloon driver
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110203163033.GJ1364@router-fw-old.local.net-space.pl>
References: <20110203163033.GJ1364@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 03 Feb 2011 10:12:24 -0800
Message-ID: <1296756744.8299.1440.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2011-02-03 at 17:30 +0100, Daniel Kiper wrote:
> +static struct resource *allocate_memory_resource(unsigned long nr_pages)
> +{
> +	resource_size_t r_min, r_size;
> +	struct resource *r;
> +
> +	/*
> +	 * Look for first unused memory region starting at page
> +	 * boundary. Skip last memory section created at boot time
> +	 * because it may contains unused memory pages with PG_reserved
> +	 * bit not set (online_pages() require PG_reserved bit set).
> +	 */

Could you elaborate on this comment a bit?  I think it's covering both
the "PAGE_SIZE" argument to allocate_resource() and something else, but
I'm not quite sure.

> +	r = kzalloc(sizeof(struct resource), GFP_KERNEL);
> +
> +	if (!r)
> +		return NULL;
> +
> +	r->name = "System RAM";
> +	r->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> +	r_min = PFN_PHYS(section_nr_to_pfn(pfn_to_section_nr(balloon_stats.boot_max_pfn) + 1));

Did you do this for alignment reasons?  It might be a better idea to
just make a nice sparsemem function to do alignment.  

> +	r_size = nr_pages << PAGE_SHIFT;
> +
> +	if (allocate_resource(&iomem_resource, r, r_size, r_min,
> +					ULONG_MAX, PAGE_SIZE, NULL, NULL) < 0) {
> +		kfree(r);
> +		return NULL;
> +	}
> +
> +	return r;
> +}

This function should probably be made generic.  I bet some more
hypervisors come around and want to use this.  They generally won't care
where the memory goes, and the kernel can allocate a spot for them.

...
> +static void hotplug_allocated_memory(struct resource *r)
>  {
> -	unsigned long target = balloon_stats.target_pages;
> +	int nid, rc;
> +	resource_size_t r_size;
> +	struct memory_block *mem;
> +	unsigned long pfn;
> +
> +	r_size = r->end + 1 - r->start;
> +	nid = memory_add_physaddr_to_nid(r->start);
> +
> +	rc = add_registered_memory(nid, r->start, r_size);
> +
> +	if (rc) {
> +		pr_err("%s: add_registered_memory: Memory hotplug failed: %i\n",
> +			__func__, rc);
> +		balloon_stats.target_pages = balloon_stats.current_pages;
> +		return;
> +	}
> +
> +	if (xen_pv_domain())
> +		for (pfn = PFN_DOWN(r->start); pfn < PFN_UP(r->end); ++pfn)
> +			if (!PageHighMem(pfn_to_page(pfn))) {
> +				rc = HYPERVISOR_update_va_mapping(
> +					(unsigned long)__va(pfn << PAGE_SHIFT),
> +					mfn_pte(pfn_to_mfn(pfn), PAGE_KERNEL), 0);
> +				BUG_ON(rc);
> +			}
> 
> -	target = min(target,
> -		     balloon_stats.current_pages +
> -		     balloon_stats.balloon_low +
> -		     balloon_stats.balloon_high);
> +	rc = online_pages(PFN_DOWN(r->start), r_size >> PAGE_SHIFT);

The memory hotplug code is a bit weird at first glance.  It has two
distinct stages: first, add_memory() is called from
architecture-specific code.  Later, online_pages() is called, but that
part is driven by userspace.

For all the other hotplug users online_pages() is done later, and
triggered by userspace.  The idea is that you could have memory sitting
in "added, but offline" state which would be trivial to remove if
someone else needed it, but also trivial to add without the need to
allocate additional memory.

In other words, I think you can take everything from and including
online_pages() down in the function and take it out.  Use a udev hotplug
rule to online it immediately if that's what you want.  

> -	return target;
> +	if (rc) {
> +		pr_err("%s: online_pages: Failed: %i\n", __func__, rc);
> +		balloon_stats.target_pages = balloon_stats.current_pages;
> +		return;
> +	}
> +
> +	for (pfn = PFN_DOWN(r->start); pfn < PFN_UP(r->end); pfn += PAGES_PER_SECTION) {
> +		mem = find_memory_block(__pfn_to_section(pfn));
> +		BUG_ON(!mem);
> +		BUG_ON(!present_section_nr(mem->phys_index));
> +		mutex_lock(&mem->state_mutex);
> +		mem->state = MEM_ONLINE;
> +		mutex_unlock(&mem->state_mutex);
> +	}
> +
> +	balloon_stats.current_pages += r_size >> PAGE_SHIFT;
>  }
> 
> +static enum bp_state request_additional_memory(long credit)
> +{
> +	int rc;
> +	static struct resource *r;
> +	static unsigned long pages_left;
> +
> +	if ((credit <= 0 || balloon_stats.balloon_low ||
> +				balloon_stats.balloon_high) && !r)
> +		return BP_DONE;
> +
> +	if (!r) {
> +		r = allocate_memory_resource(credit);
> +
> +		if (!r)
> +			return BP_ERROR;
> +
> +		pages_left = credit;
> +	}

'r' is effectively a global variable here.  Could you give it a more
proper name?  Maybe "last add location" or something.  It might even
make sense to move it up in to the global scope to make it _much_ more
clear that it's not just locally used.

> +	rc = allocate_additional_memory(r, pages_left);
> +
> +	if (rc < 0) {
> +		if (balloon_stats.mh_policy == MH_POLICY_TRY_UNTIL_SUCCESS)
> +			return BP_ERROR;
> +
> +		r = adjust_memory_resource(r, pages_left);
> +
> +		if (!r)
> +			return BP_ERROR;
> +	} else {
> +		pages_left -= rc;
> +
> +		if (pages_left)
> +			return BP_HUNGRY;
> +	}
> +
> +	hotplug_allocated_memory(r);
> +
> +	r = NULL;
> +
> +	return BP_DONE;
> +}

Could you explain a bit about why you chose to do this stuff with memory
resources?  Is that the only visibility that you have in to what memory
the guest actually has?

What troubles did you run in to when you did

	add_memory(0, balloon_stats.boot_max_pfn, credit);

?

It's just that all the other memory hotplug users are _told_ by the
hardware where to put things.  Is that not the case here?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
