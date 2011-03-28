Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4EAFF8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:38:33 -0400 (EDT)
Date: Mon, 28 Mar 2011 15:37:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] mm: Extend memory hotplug API to allow memory
 hotplug in virtual machines
Message-Id: <20110328153735.d797c5b3.akpm@linux-foundation.org>
In-Reply-To: <20110328092507.GD13826@router-fw-old.local.net-space.pl>
References: <20110328092507.GD13826@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 28 Mar 2011 11:25:07 +0200
Daniel Kiper <dkiper@net-space.pl> wrote:

> This patch contains online_page_chain and apropriate functions
> for registering/unregistering online page notifiers. It allows
> to do some machine specific tasks during online page stage which
> is required to implement memory hotplug in virtual machines.
> Additionally, __online_page_increment_counters() and
> __online_page_free() function was add to ease generic
> hotplug operation.
> 
>  
>  void lock_memory_hotplug(void)
> @@ -361,27 +373,91 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
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
> +
> +void __online_page_increment_counters(struct page *page, int inc_total)
>  {
>  	unsigned long pfn = page_to_pfn(page);
>  
> -	totalram_pages++;
> +	if (inc_total == OP_INCREMENT_TOTAL_COUNTERS)
> +		totalram_pages++;
> +
>  	if (pfn >= num_physpages)
>  		num_physpages = pfn + 1;
>  
>  #ifdef CONFIG_HIGHMEM
> -	if (PageHighMem(page))
> +	if (inc_total == OP_INCREMENT_TOTAL_COUNTERS && PageHighMem(page))
>  		totalhigh_pages++;
>  #endif
>  
>  #ifdef CONFIG_FLATMEM
>  	max_mapnr = max(pfn, max_mapnr);
>  #endif
> +}
> +EXPORT_SYMBOL_GPL(__online_page_increment_counters);
>  
> +void __online_page_free(struct page *page)
> +{
>  	ClearPageReserved(page);
>  	init_page_count(page);
>  	__free_page(page);
>  }
> +EXPORT_SYMBOL_GPL(__online_page_free);
> +
> +static int generic_online_page_notifier(struct notifier_block *nb, unsigned long val, void *v)
> +{
> +	struct page *page = v;
> +
> +	__online_page_increment_counters(page, OP_INCREMENT_TOTAL_COUNTERS);
> +	__online_page_free(page);
> +
> +	return NOTIFY_OK;
> +}
> +
> +/*
> + * 0 priority makes this the fallthrough default. All
> + * architectures wanting to override this should set
> + * a higher priority and return NOTIFY_STOP to keep
> + * this from running.
> + */
> +
> +static struct notifier_block generic_online_page_nb = {
> +	.notifier_call = generic_online_page_notifier,
> +	.priority = 0
> +};
> +
> +static int __init init_online_page_chain(void)
> +{
> +	return register_online_page_notifier(&generic_online_page_nb);
> +}
> +pure_initcall(init_online_page_chain);
> +
> +static void online_page(struct page *page)
> +{
> +	raw_notifier_call_chain(&online_page_chain, 0, page);
> +}
>  

This is a bit strange.  Normally we'll use a notifier chain to tell
listeners "hey, X just happened".  But this code is different - it
instead uses a notifier chain to tell handlers "hey, do X".  Where in
this case, X is "free a page".

And this (ab)use of notifiers is not a good fit!  Because we have the
obvious problem that if there are three registered noftifiers, we don't
want to be freeing the page three times.  Hence the tricks with
notifier callout return values.

If there are multiple independent notifier handlers, how do we manage
their priorities?  And what are the effects of the ordering of the
registration calls?

And when one callback overrides an existing one, is there any point in
leaving the original one installed at all?

I dunno, it's all a bit confusing and strange.  Perhaps it would help
if you were to explain exactly what behaviour you want here, and we can
look to see if there is a more idiomatic way of doing it.



Also...  I don't think we need (the undocumented)
OP_DO_NOT_INCREMENT_TOTAL_COUNTERS and OP_INCREMENT_TOTAL_COUNTERS. 
Just do

void __online_page_increment_counters(struct page *page,
					bool inc_total_counters);

and pass it "true" or false".

And then document it, please.  The code as you have it contains no
explanation of the inc_total_counters argument and hence no guidance to
others regarding how to use it.


I merged your patch 1/3.

I skipped your patch 2/3, as the new macros appear to have no callers
in this patchset.

I suggest that once we're happy with them, your patches 2 and 3 be
merged up via whichever tree merges the Xen balloon driver changes. 
That might be my tree, I forget :) Was anyone else thinking of grabbing
them?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
