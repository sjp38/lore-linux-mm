Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2408D0039
	for <linux-mm@kvack.org>; Tue,  8 Feb 2011 12:22:39 -0500 (EST)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p18HCGiB008834
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 10:12:16 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p18HMVi6104028
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 10:22:31 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p18HK6iX003208
	for <linux-mm@kvack.org>; Tue, 8 Feb 2011 10:20:07 -0700
Subject: Re: [PATCH R3 7/7] xen/balloon: Memory hotplug support for Xen
 balloon driver
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110207141227.GA10852@router-fw-old.local.net-space.pl>
References: <20110203163033.GJ1364@router-fw-old.local.net-space.pl>
	 <1296756744.8299.1440.camel@nimitz>
	 <20110207141227.GA10852@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 08 Feb 2011 09:22:26 -0800
Message-ID: <1297185746.6737.12110.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2011-02-07 at 15:12 +0100, Daniel Kiper wrote:
> On Thu, Feb 03, 2011 at 10:12:24AM -0800, Dave Hansen wrote:
> > On Thu, 2011-02-03 at 17:30 +0100, Daniel Kiper wrote:
> > > +static struct resource *allocate_memory_resource(unsigned long nr_pages)
> > > +{
> > > +	resource_size_t r_min, r_size;
> > > +	struct resource *r;
> > > +
> > > +	/*
> > > +	 * Look for first unused memory region starting at page
> > > +	 * boundary. Skip last memory section created at boot time
> > > +	 * because it may contains unused memory pages with PG_reserved
> > > +	 * bit not set (online_pages() require PG_reserved bit set).
> > > +	 */
> >
> > Could you elaborate on this comment a bit?  I think it's covering both
> > the "PAGE_SIZE" argument to allocate_resource() and something else, but
> > I'm not quite sure.
> 
> Yes, you are right. Aligment to PAGE_SIZE is done by allocate_resource().
> Additionally, r_min (calculated below) sets lower limit at which hoplugged
> memory could be installed (due to PG_reserved bit requirment set up by
> online_pages()). Later r_min is put as an argument to allocate_resource() call.

OK, and you'll update the comment on that?

> > > +	r = kzalloc(sizeof(struct resource), GFP_KERNEL);
> > > +
> > > +	if (!r)
> > > +		return NULL;
> > > +
> > > +	r->name = "System RAM";
> > > +	r->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> > > +	r_min = PFN_PHYS(section_nr_to_pfn(pfn_to_section_nr(balloon_stats.boot_max_pfn) + 1));
> >
> > Did you do this for alignment reasons?  It might be a better idea to
> > just make a nice sparsemem function to do alignment.
> 
> Please look above.

You spoke about page alignment up there.  Why is this section-aligned?
Should we make an "align to section" function in generic sparsemem code?

> > > +	r_size = nr_pages << PAGE_SHIFT;
> > > +
> > > +	if (allocate_resource(&iomem_resource, r, r_size, r_min,
> > > +					ULONG_MAX, PAGE_SIZE, NULL, NULL) < 0) {
> > > +		kfree(r);
> > > +		return NULL;
> > > +	}
> > > +
> > > +	return r;
> > > +}
> >
> > This function should probably be made generic.  I bet some more
> > hypervisors come around and want to use this.  They generally won't care
> > where the memory goes, and the kernel can allocate a spot for them.
> 
> Yes, you are right. I think about new project in which
> this function will be generic and then I would move it to
> some more generic place. Now, I think it should stay here.

Please move it to generic code.  It doesn't belong in Xen code.  

> > In other words, I think you can take everything from and including
> > online_pages() down in the function and take it out.  Use a udev hotplug
> > rule to online it immediately if that's what you want.
> 
> I agree. I discussed a bit about this problem with Jeremy, too. However,
> there are some problems to implement that solution now. First of all it is
> possible to online hotplugged memory using sysfs interface only in chunks
> called sections. It means that it is not possible online once again section
> which was onlined ealier partialy populated and now it contains new pages
> to online. In this situation sysfs interface emits Invalid argument error.
> In theory it should be possible to offline and then online whole section
> once again, however, if memory from this section was used is not possible
> to do that. It means that those properties does not allow hotplug memory
> in guest in finer granulity than section and sysfs interface is too inflexible
> to be used in that solution. That is why I decided to online hoplugged memory
> using API which does not have those limitations.

Sure, you have to _online_ the whole thing at once, but you don't have
to actually make the pages available.  You also don't need to hook in to
the memory resource code like you're doing.  It's sufficient to just try
and add the memory.  If you get -EEXIST, then you can't add it there, so
move up and try again.  

int xen_balloon_add_memory(u64 size)
{
	unsigned long top_of_mem = max_pfn;
	top_of_mem = section_align_up(top_of_mem);

	while (1) {
		int ret = add_memory(nid, top_of_mem, size);
		if (ret == -EEXIST)
			continue;
		// error handling...
		break;
	}
	return...;
}

As for telling the hypervisor where you've mapped things, that should be
done in arch_add_memory().  

When it comes down to online_page(), you don't want your pages freed
back in to the buddy allocator, you want them put in to the balloon.
So, take the __free_page() in online_page(), and put a Xen hook in
there.  

+void __attribute__((weak)) arch_free_hotplug_page(struct page *page)
+{
+	__free_page(page);
+}

void online_page(struct page *page)
{
        unsigned long pfn = page_to_pfn(page);
...
-       __free_page(page);
+	arch_free_hotplug_page(page);
}

Then, have Xen override it:

void arch_free_hotplug_page(struct page *page)
{
	if (xen_need_to_inflate_balloon())
		put_page_in_balloon(page);	
	else
		__free_page(page);
}

> Additionally, IIRC, add_memory() requires
> that underlying memory is available before its call.

No, that's not correct.  s390's memory isn't available until after it
calls vmem_add_mapping().  See arch/s390/mm/init.c

> That is why I
> decided to create add_registered_memory() which do all things which are
> done by add_memory() excluding address space reservation which is done
> by allocate_memory_resource() before memory allocation.

The added memory itself isn't touched until online_pages() time.  That's
yet another reason it was separated out logically in the code.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
