Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 915336B004D
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 01:08:13 -0400 (EDT)
Subject: Re: [PATCH 2/2][v3] powerpc: Make the CMM memory hotplug aware
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20091009204126.GD19114@austin.ibm.com>
References: <20091009203803.GC19114@austin.ibm.com>
	 <20091009204126.GD19114@austin.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 12 Oct 2009 16:06:47 +1100
Message-Id: <1255324007.2192.106.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robert Jennings <rcj@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Badari Pulavarty <pbadari@us.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Gerald Schaefer <geralds@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-10-09 at 15:41 -0500, Robert Jennings wrote:
> The Collaborative Memory Manager (CMM) module allocates individual pages
> over time that are not migratable.  On a long running system this can
> severely impact the ability to find enough pages to support a hotplug
> memory remove operation.
> 
> This patch adds a memory isolation notifier and a memory hotplug notifier.
> The memory isolation notifier will return the number of pages found
> in the range specified.  This is used to determine if all of the used
> pages in a pageblock are owned by the balloon (or other entities in
> the notifier chain).  The hotplug notifier will free pages in the range
> which is to be removed.  The priority of this hotplug notifier is low
> so that it will be called near last, this helps avoids removing loaned
> pages in operations that fail due to other handlers.
> 
> CMM activity will be halted when hotplug remove operations are active
> and resume activity after a delay period to allow the hypervisor time
> to adjust.
> 
> Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>

Do you need me to merge that via the powerpc tree after the relevant
generic parts go in ? This is 2.6.33 material ?

> +module_param_named(hotplug_delay, hotplug_delay, uint, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(delay, "Delay (in seconds) after memory hotplug remove "
> +		 "before activity resumes. "
> +		 "[Default=" __stringify(CMM_HOTPLUG_DELAY) "]");

What is the above ? That sounds scary :-)

>  module_param_named(oom_kb, oom_kb, uint, S_IRUGO | S_IWUSR);
>  MODULE_PARM_DESC(oom_kb, "Amount of memory in kb to free on OOM. "
>  		 "[Default=" __stringify(CMM_OOM_KB) "]");
> @@ -88,6 +101,8 @@ struct cmm_page_array {
>  static unsigned long loaned_pages;
>  static unsigned long loaned_pages_target;
>  static unsigned long oom_freed_pages;
> +static atomic_t hotplug_active = ATOMIC_INIT(0);
> +static atomic_t hotplug_occurred = ATOMIC_INIT(0);

That sounds like a hand made lock with atomics... rarely a good idea,
tends to miss appropriate barriers etc...
 
>  static struct cmm_page_array *cmm_page_list;
>  static DEFINE_SPINLOCK(cmm_lock);
> @@ -110,6 +125,9 @@ static long cmm_alloc_pages(long nr)
>  	cmm_dbg("Begin request for %ld pages\n", nr);
>  
>  	while (nr) {
> +		if (atomic_read(&hotplug_active))
> +			break;
> +

Ok so I'm not familiar with that whole memory hotplug stuff, so the code
might be right, but wouldn't the above be racy anyways in case hotplug
just becomes active after this statement ?

Shouldn't you use a mutex_trylock instead ? That has clearer semantics
and will provide the appropriate memory barriers.

>  		addr = __get_free_page(GFP_NOIO | __GFP_NOWARN |
>  				       __GFP_NORETRY | __GFP_NOMEMALLOC);
>  		if (!addr)
> @@ -119,8 +137,10 @@ static long cmm_alloc_pages(long nr)
>  		if (!pa || pa->index >= CMM_NR_PAGES) {
>  			/* Need a new page for the page list. */
>  			spin_unlock(&cmm_lock);
> -			npa = (struct cmm_page_array *)__get_free_page(GFP_NOIO | __GFP_NOWARN |
> -								       __GFP_NORETRY | __GFP_NOMEMALLOC);
> +			npa = (struct cmm_page_array *)__get_free_page(
> +					GFP_NOIO | __GFP_NOWARN |
> +					__GFP_NORETRY | __GFP_NOMEMALLOC |
> +					__GFP_MOVABLE);
>  			if (!npa) {
>  				pr_info("%s: Can not allocate new page list\n", __func__);
>  				free_page(addr);
> @@ -273,9 +293,23 @@ static int cmm_thread(void *dummy)
>  	while (1) {
>  		timeleft = msleep_interruptible(delay * 1000);
> 
> -		if (kthread_should_stop() || timeleft) {
> -			loaned_pages_target = loaned_pages;
> +		if (kthread_should_stop() || timeleft)
>  			break;
> +
> +		if (atomic_read(&hotplug_active)) {
> +			cmm_dbg("Hotplug operation in progress, activity "
> +					"suspended\n");
> +			continue;
> +		}
> +
> +		if (atomic_dec_if_positive(&hotplug_occurred) >= 0) {
> +			cmm_dbg("Hotplug operation has occurred, loaning "
> +					"activity suspended for %d seconds.\n",
> +					hotplug_delay);
> +			timeleft = msleep_interruptible(hotplug_delay * 1000);
> +			if (kthread_should_stop() || timeleft)
> +				break;
> +			continue;
>  		}

I have less problems with hotplug_occured but if you use a
mutex_trylock, overall, you can turn the above into a normal int instead
of an atomic.

 ../..

> +static int cmm_memory_cb(struct notifier_block *self,
> +			unsigned long action, void *arg)
> +{
> +	int ret = 0;
> +
> +	switch (action) {
> +	case MEM_GOING_OFFLINE:
> +		atomic_set(&hotplug_active, 1);

So that would become a mutex_lock(). Added advantage is that
it would wait for a current CMM operation to complete.
 
Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
