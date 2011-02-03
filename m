Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 029F28D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 10:32:28 -0500 (EST)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1575108Ab1BCPbs (ORCPT <rfc822;linux-mm@kvack.org>);
	Thu, 3 Feb 2011 16:31:48 +0100
Date: Thu, 3 Feb 2011 16:31:48 +0100
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH R2 7/7] xen/balloon: Xen memory balloon driver with memory hotplug support
Message-ID: <20110203153148.GB1364@router-fw-old.local.net-space.pl>
References: <20101229170702.GL2743@router-fw-old.local.net-space.pl> <1294094002.18937.110.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1294094002.18937.110.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jan 03, 2011 at 02:33:22PM -0800, Dave Hansen wrote:
> On Wed, 2010-12-29 at 18:07 +0100, Daniel Kiper wrote:
> > +config XEN_BALLOON_MEMORY_HOTPLUG
> > +	bool "Xen memory balloon driver with memory hotplug support"
> > +	default n
> > +	depends on XEN_BALLOON && MEMORY_HOTPLUG
> > +	help
> > +	  Xen memory balloon driver with memory hotplug support allows expanding
> > +	  memory available for the system above limit declared at system startup.
> > +	  It is very useful on critical systems which require long run without
> > +	  rebooting.
>
> This might be better phrased as "Memory hotplug support for Xen balloon
> driver".  It might otherwise confuse people about whether they're seeing
> some kind of choice or an _enhancement_ to the existing driver.

Thx. Done. I will send new patch release today.

> Also, why bother even making this a config option?  What are the
> downsides if it was always compiled in?  You could even make it a
> non-prompting Kconfig option and just automatically turn it on with
> XEN_BALLOON && MEMORY_HOTPLUG.

At this stage of development I think it is better to leave this
as an option for user. Later when this future will be mature it could
be removed. However, I realized that this solution does not give
possibility for user to disable this future at runtime. Maybe
it shoudl be as boot/sysfs option. I am not sure it is required or not.
Currently it is not implemented.

> > +static int allocate_memory_resource(struct resource **r, unsigned long nr_pages)
> >  {
> > -	unsigned long target = balloon_stats.target_pages;
> > +	int rc;
> > +	resource_size_t r_min, r_size;
> > +
> > +	/*
> > +	 * Look for first unused memory region starting at page
> > +	 * boundary. Skip last memory section created at boot time
> > +	 * becuase it may contains unused memory pages with PG_reserved
> > +	 * bit not set (online_pages require PG_reserved bit set).
> > +	 */
> > +
> > +	*r = kzalloc(sizeof(struct resource), GFP_KERNEL);
> >
> > -	target = min(target,
> > -		     balloon_stats.current_pages +
> > -		     balloon_stats.balloon_low +
> > -		     balloon_stats.balloon_high);
> > +	if (!*r)
> > +		return -ENOMEM;
> >
> > -	return target;
> > +	(*r)->name = "System RAM";
> > +	(*r)->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> > +	r_min = PFN_PHYS(section_nr_to_pfn(pfn_to_section_nr(balloon_stats.boot_max_pfn) + 1));
> > +	r_size = nr_pages << PAGE_SHIFT;
> > +
> > +	rc = allocate_resource(&iomem_resource, *r, r_size, r_min,
> > +					ULONG_MAX, PAGE_SIZE, NULL, NULL);
> > +
> > +	if (rc < 0) {
> > +		kfree(*r);
> > +		*r = NULL;
> > +	}
> > +
> > +	return rc;
> >  }
>
> The double-pointer stuff here ends up looking a little funky.  Is there
> any reason you don't just use ERR_PTRs?  That might look a bit more
> sane.

After another review I removed all double-pointer stuff (it was
very simple, however, if I read many times code written by myself
it was very difficult to discover that). Now I think it is much better.
Thanks.

> > +static void adjust_memory_resource(struct resource **r, unsigned long nr_pages)
> > +{
> > +	if ((*r)->end + 1 - (nr_pages << PAGE_SHIFT) == (*r)->start) {
> > +		BUG_ON(release_resource(*r) < 0);
>
> In some kernels, people do:
>
> 	#define BUG_ON(...) do{}while(0)
>
> to save space.  If anyone ever does that with this code, it'll break
> horribly.  It's also hard to read these.  So, please break logic actions
> _out_ of the BUG_ON() arguments.
>
> That's repeated in quite a few places in here.  Make sure to go get them
> all.

Done.

> It also isn't evident what this patch set is trying to do until you get
> down to this 7/7 patch.  You might want to put a more complete
> description in 0/7.

Will be done. :-))) Thank you for your help.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
