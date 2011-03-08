Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 38A398D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 18:51:22 -0500 (EST)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p28Nilib004292
	for <linux-mm@kvack.org>; Tue, 8 Mar 2011 16:44:47 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p28NpGbm073474
	for <linux-mm@kvack.org>; Tue, 8 Mar 2011 16:51:16 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p28NpEqZ021247
	for <linux-mm@kvack.org>; Tue, 8 Mar 2011 16:51:16 -0700
Subject: Re: [PATCH R4 6/7] mm: Extend memory hotplug API to allow memory
 hotplug in virtual guests
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110308215003.GG27331@router-fw-old.local.net-space.pl>
References: <20110308215003.GG27331@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 08 Mar 2011 15:51:12 -0800
Message-ID: <1299628272.9014.3465.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2011-03-08 at 22:50 +0100, Daniel Kiper wrote:
> This patch extends memory hotplug API to allow easy memory hotplug
> in virtual guests. It contains:
>   - generic section aligment macro,
>   - online_page_chain and apropriate functions for registering/unregistering
>     online page notifiers,
>   - add_virtual_memory(u64 *size) function which adds memory region
>     of size >= *size above max_pfn; new region is section aligned
>     and size is modified to be multiple of section size.

Usually, when you can list stuff out like this, it's a good sign that
they belong in separate patches.  I think it's true here as well.

But, these are looking a lot better.  It looks like much less code, and
it's quite a bit simpler.

> +/*
> + * online_page_chain contains chain of notifiers called when page is onlined.
> + * When kernel is booting native_online_page_notifier() is registered with
> + * priority 0 as default notifier. Custom notifier should be registered with
> + * pririty > 0. It could be terminal (it should return NOTIFY_STOP on success)

"pririty"?

> + * or not (it should return NOTIFY_DONE or NOTIFY_OK on success; for full list
> + * of return codes look into include/linux/notifier.h).
> + *
> + * Working example of usage: drivers/xen/balloon.c
> + */
> +
> +static RAW_NOTIFIER_HEAD(online_page_chain);
> +
>  DEFINE_MUTEX(mem_hotplug_mutex);
> 
>  void lock_memory_hotplug(void)
> @@ -361,8 +375,33 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
>  }
>  EXPORT_SYMBOL_GPL(__remove_pages);
> 
> -void online_page(struct page *page)
> +int register_online_page_notifier(struct notifier_block *nb)
> +{
> +	int rc;
> +
> +	lock_memory_hotplug();
> +	rc = raw_notifier_chain_register(&online_page_chain, nb);
> +	unlock_memory_hotplug();
> +
> +	return rc;
> +}
> +EXPORT_SYMBOL_GPL(register_online_page_notifier);
> +
> +int unregister_online_page_notifier(struct notifier_block *nb)
> +{
> +	int rc;
> +
> +	lock_memory_hotplug();
> +	rc = raw_notifier_chain_unregister(&online_page_chain, nb);
> +	unlock_memory_hotplug();
> +
> +	return rc;
> +}
> +EXPORT_SYMBOL_GPL(unregister_online_page_notifier);

The whole "native" thing really is Xen terminology.  Could we call this
"generic_online_page_notifier()" perhaps?  This really isn't even
"native" either since some hypervisors actually do use this code.

> +static int native_online_page_notifier(struct notifier_block *nb, unsigned long val, void *v)
>  {
> +	struct page *page = v;
>  	unsigned long pfn = page_to_pfn(page);
> 
>  	totalram_pages++;
> @@ -375,12 +414,30 @@ void online_page(struct page *page)
>  #endif
> 
>  #ifdef CONFIG_FLATMEM
> -	max_mapnr = max(page_to_pfn(page), max_mapnr);
> +	max_mapnr = max(pfn, max_mapnr);
>  #endif

This is another tidbit that's probably good to do, but it's superfluous
here.  

>  	ClearPageReserved(page);
>  	init_page_count(page);
>  	__free_page(page);
> +
> +	return NOTIFY_OK;
> +}
> +
> +static struct notifier_block native_online_page_nb = {
> +	.notifier_call = native_online_page_notifier,
> +	.priority = 0
> +};

That comment about priority really belongs here.  

 /*
  * 0 priority makes this the fallthrough default.  All
  * architectures wanting to override this should set a
  * higher priority and return NOTIFY_STOP to keep this
  * from running.
  */

> +static int __init init_online_page_chain(void)
> +{
> +	return register_online_page_notifier(&native_online_page_nb);
> +}
> +pure_initcall(init_online_page_chain);
> +
> +static void online_page(struct page *page)
> +{
> +	raw_notifier_call_chain(&online_page_chain, 0, page);
>  }
> 
>  static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
> @@ -591,6 +648,36 @@ out:
>  }
>  EXPORT_SYMBOL_GPL(add_memory);
> 
> +/*
> + * add_virtual_memory() adds memory region of size >= *size above max_pfn.
> + * New region is section aligned and size is modified to be multiple of
> + * section size.

Aligned up or down?  Why did you choose up or down?

> Those features allow optimal use of address space and
> + * establish proper aligment when this function is called first time after

                      ^^^^^^^^ alignment?

> + * boot (last section not fully populated at boot time may contains unused
> + * memory pages with PG_reserved bit not set; online_pages() does not allow
> + * page onlining in whole section if first page does not have PG_reserved
> + * bit set). Real size of added memory should be established at page onlining
> + * stage.
> + *
> + * This function is often used in virtual guests because mainly they do not
> + * care about new memory region address.

Remember, you're touching generic memory hotplug code here.  I really
don't know what a "virtual guest" is or how it relates to this code.
How about something like this?

        This code is expected to be used in cases where a certain amount
        of memory needs to get added, but when the hardware or
        hypervisor does not dictate where it will be placed.

> + * Working example of usage: drivers/xen/balloon.c

Please pull this out.  It'll probably become stale before anyone uses
it.  I trust people to know how to use cscope. :)

> +int add_virtual_memory(u64 *size)
> +{
> +	int nid;
> +	u64 start;
> +
> +	start = PFN_PHYS(SECTION_ALIGN(max_pfn));
> +	*size = (((*size >> PAGE_SHIFT) & PAGE_SECTION_MASK) + PAGES_PER_SECTION) << PAGE_SHIFT;

Why use PFN_PHYS() in one case but not the other?

I'd also highly suggest using the ALIGN() macro in cases like this.  It
makes it much more readable:

	*size = PFN_PHYS(ALIGN(*size, SECTION_SIZE)));	

> +	nid = memory_add_physaddr_to_nid(start);
> +
> +	return add_memory(nid, start, *size);
> +}

Could you talk a little bit more about how 'size' gets used?  Also, are
we sure we want an interface where we're so liberal with 'size'?  It
seems like requiring that it be section-aligned is a fair burden to
place on the caller.  That way, we're not in a position of _guessing_
what the caller wants (aligning up or down).

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
