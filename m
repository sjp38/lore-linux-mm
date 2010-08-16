Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 994206B01F1
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 11:46:22 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1546366Ab0HPPop (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 16 Aug 2010 17:44:45 +0200
Date: Mon, 16 Aug 2010 17:44:44 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: Re: [PATCH] GSoC 2010 - Memory hotplug support for Xen guests - third fully working version
Message-ID: <20100816154444.GA28219@router-fw-old.local.net-space.pl>
References: <20100812012224.GA16479@router-fw-old.local.net-space.pl> <4C649535.8050800@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C649535.8050800@goop.org>
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: dkiper@net-space.pl, konrad.wilk@oracle.com, stefano.stabellini@eu.citrix.com, linux-mm@kvack.org, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, v.tolstov@selfip.ru, gregkh@suse.de
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Aug 12, 2010 at 05:43:33PM -0700, Jeremy Fitzhardinge wrote:
>  On 08/11/2010 06:22 PM, Daniel Kiper wrote:
> >>Overall, this looks much better.  The next step is to split this into at
> >>least two patches: one for the core code, and one for the Xen bits.
> >>Each patch should do just one logical operation, so if you have several
> >>distinct changes to the core code, put them in separate patches.
> >I will do that if this patch will be accepted.
>
> First step is to post it to lkml for discussion, cc:ing the relevant
> maintainers. (I'm not really sure who that is at the moment.  It will
> take some digging around in the history.)

I took all relevant addresses (sorry if I missed somebody) from MAINTAINERS
file and they are in To in most of e-mails from me.

> >>Can you find a clean way to prevent/disable ARCH_MEMORY_PROBE at runtime
> >>when in a Xen context?
> >There is no simple way to do that. It requiers to do some
> >changes in drivers/base/memory.c code. I think it should
> >be done as kernel boot option (on by default to not break
> >things using this interface now). If it be useful for maintainers
> >of mm/memory_hotplug.c and drivers/base/memory.c code then
> >I could do that. Currently original arch/x86/Kconfig version
> >is restored.
>
> I think adding a global flag which the Xen balloon driver can disable
> should be sufficient.  There's no need to make an separate user-settable
> control.

OK.

> >>>+/* we are OK calling __meminit stuff here - we have
> >>>CONFIG_MEMORY_HOTPLUG
> >>>*/
> >>>+static int __ref xen_add_memory(int nid, u64 start, u64 size)
> >>Could this be __meminit too then?
> >Good question. I looked throught the code and could
> >not find any simple explanation why mm/memory_hotplug.c
> >authors used __ref instead __meminit. Could you (mm/memory_hotplug.c
> >authors/maintainers) tell us why ???
>
> Quite possibly a left-over from something else.  You could just try
> making it __meminit, then compile with, erm, the option which shows you
> section conflicts (it shows the number of conflicts at the end of the
> kernel build by default, and tells you how to explicitly list them).

Small reminder: make CONFIG_DEBUG_SECTION_MISMATCH=y

I reviewed kernel source code once again. It is OK. Normaly it is
not allowed to reference code/data tagged as .init.* because
that sections are freed at the end of kernel boot sequence and
they do not exists any more in memory. However it is sometimes
required to use code/data marked .init.*. To allow that __ref
tag is used and then referenced objects are not removed from
memory (and no warnings are displayed during kernel compilation).

> >>What's this for?  I see all its other users are in the memory hotplug
> >>code, but presumably they're concerned about a real S3 suspend.  Do we
> >>care about that here?
> >Yes, because as I know S3 state is supported by Xen guests.
>
> Yes, but I'm assuming the interaction between S3 and ACPI hotplug memory
> isn't something that concerns a Xen guest; our hotplug mechanism is
> completely different.

Suspend/Hibernation code in Linux Kernel is platform independent
to some extent and it does not require ACPI. It means that
lock_system_sleep/unlock_system_sleep is required in that
place to have memory state intact during suspend/hibernation.

> >>>+		r->name = "System RAM";
> >>How about making it clear its Xen hotplug RAM?  Or do things care about
> >>the "System RAM" name?
> >As I know no however as I saw anybody do not differentiate between
> >normal and hotplugged memory. I thought about that ealier however
> >stated that this soultion does not give us any real gain. That is why
> >I decided to use standard name for hotplugged memory.
>
> Its cosmetic, but it would be useful to see what's going on.

If you wish I will do that, however then it should be changed
as well add_registered_memory() function syntax. It should
contain pointer to name published through /sys/firmware/memmap
interface. I am not sure it is good solution to change
add_registered_memory() function syntax which I think should be
same as add_memory() function syntax.

> >+#ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG + unsigned long
> >boot_max_pfn; + u64 hotplug_start_paddr; + u64 hotplug_size;
>
> So does this mean you only support adding a single hotplug region?  What
> happens if your initial increase wasn't enough and you want to add
> more?  Would you make this a list of hot-added memory or something?
>
> But I'm not even quite sure why you need to keep this as global data.

No. It supports multiple allocations. This variables are
used mostly for communication between allocate_additional_memory
and hotplug_allocated_memory functions.

> >PFN_PHYS(section_nr_to_pfn(pfn_to_section_nr(balloon_stats.boot_max_pfn)
> >+ 1)); + r_size = (balloon_stats.target_pages -
> >balloon_stats.current_pages) << PAGE_SHIFT;
>
> So this just reserves enough resource to satisfy the current outstanding
> requirement?  That's OK if we can repeat it, but it looks like it will
> only do this once?

For full description of current algorithm
please look at the end of this e-mail.

> >+ + rc = allocate_resource(&iomem_resource, r, r_size, r_min, +
> >ULONG_MAX, PAGE_SIZE, NULL, NULL);
>
> Does this need to be section aligned, with a section size?  Or is any old
> place OK?

It is always PAGE_SIZE aligned and not below than
<max_address_of_section_allocated_at_boot> + 1.

> >reservation.nr_extents = nr_pages; + + rc =
> >HYPERVISOR_memory_op(XENMEM_populate_physmap, &reservation);
>
> Allocating all the memory here seems sub-optimal.

Here is allocated min(nr_pages, ARRAY_SIZE(frame_list)) of pages.

> >0 ? rc : rc != nr_pages; +} + +static void hotplug_allocated_memory(void)
>
> Why is this done separately from the reservation/allocation from xen?

First memory is allocated in batches of min(nr_pages, ARRAY_SIZE(frame_list))
of pages and then whole allocated memory is hotplugged.

> >{ - unsigned long target = balloon_stats.target_pages; + int nid, ret;
> >+ struct memory_block *mem; + unsigned long pfn, pfn_limit; + + nid =
> >memory_add_physaddr_to_nid(balloon_stats.hotplug_start_paddr);
>
> Is the entire reserved memory range guaranteed to be within one node?
>
> I see that this function has multiple definitions depending on a number
> of config settings.  Do we care about what definition it has?

As I know (maybe I have missed something) currently Xen does not support
NUMA in guests and nid is always 0. However maybe it will be good to create
Xen specific version of memory_add_physaddr_to_nid function.

> >= online_pages(PFN_DOWN(balloon_stats.hotplug_start_paddr), +
> >balloon_stats.hotplug_size >> PAGE_SHIFT);
>
> Are the pages available for allocation by the rest of the kernel from
> this point on?

Yes.

> Which function allocates the actual page structures?

add_registered_memory()

>
> >+ + if (ret) { + pr_err("%s: online_pages: Failed: %i\n", __func__,
> >ret); + goto error; + } + + pfn =
> >PFN_DOWN(balloon_stats.hotplug_start_paddr); + pfn_limit = pfn +
> >(balloon_stats.hotplug_size >> PAGE_SHIFT); - return target; + for (;
> >pfn < pfn_limit; pfn += PAGES_PER_SECTION) { + mem =
> >find_memory_block(__pfn_to_section(pfn)); + BUG_ON(!mem); +
> >BUG_ON(!present_section_nr(mem->phys_index)); +
> >mutex_lock(&mem->state_mutex); + mem->state = MEM_ONLINE; +
> >mutex_unlock(&mem->state_mutex); + }
>
> What does this do?  How is it different from what online_pages() does?

This updates /sys/devices/system/memory/memory*/state files
which contain information about states of sections.

> >+ else if (is_memory_resource_reserved()) + hotplug_allocated_memory();
>
> Why can't this be done in allocate_additional_memory()?

Because memory is allocated in relatively small
batches and then whole memory is hotplugged.

> In your earlier, patch I think you made the firmware_map_add_hotplug()
> be specific to add_memory, but now you have it in __add_memory.  Does it
> make a difference either way?

It was not available in Linux Kernel Ver. 2.6.32.*
on which based first versions of this patch.
It updates /sys/firmware/memmap.

> As before, this all looks reasonably good.  I think the next steps
> should be:
>
>   1. identify how to incrementally allocate the memory from Xen, rather
>      than doing it at hotplug time
>   2. identify how to disable the sysfs online interface for Xen
>      hotplugged memory
>
> For 1., I think the code should be something like:
>
> increase_address_space(unsigned long pages)
> {
> 	- reserve resource for memory section
> 	- online section
> 	for each page in section {
> 		online page
> 		mark page structure allocated
> 		add page to ballooned_pages list
> 		balloon_stats.balloon_(low|high)++;
> 	}
> }

Here is current algorithm:
  - allocate_resource() with size requested by user,
  - allocate memory in relatively small batches,
  - add_registered_memory(),
  - online_pages(),
  - update /sys/devices/system/memory/memory*/state files.

> The tricky part is making sure that the memory for the page structures
> has been populated so it can be used.  Aside from that, there should be
> no need to have another call to
> HYPERVISOR_memory_op(XENMEM_populate_physmap, ...) aside from the
> existing one.

Currently it is.

> 2 requires a deeper understanding of the existing hotplug code.  It
> needs to be refactored so that you can use the core hotplug machinery
> without enabling the sysfs page-onlining mechanism, while still leaving
> it available for physical hotplug.  In the short term, having a boolean
> to disable the onlining mechanism is probably the pragmatic solution, so
> the balloon code can simply disable it.

I think that sysfs should stay intact because it contains some
useful information for admins. We should reconsider avaibilty
of /sys/devices/system/memory/probe. In physical systems it
is available however usage without real hotplug support
lead to big crash. I am not sure we should disable probe in Xen.
Maybe it is better to stay in sync with standard behavior.
Second solution is to prepare an interface (kernel option
or only some enable/disable functions) which give possibilty
to enable/disable probe interface when it is required.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
