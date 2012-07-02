Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 3F5056B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 02:37:45 -0400 (EDT)
Message-ID: <4FF14196.6040106@redhat.com>
Date: Mon, 02 Jul 2012 02:37:10 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 36/40] autonuma: page_autonuma
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-37-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-37-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:

> +++ b/include/linux/autonuma_flags.h
> @@ -15,6 +15,12 @@ enum autonuma_flag {
>
>   extern unsigned long autonuma_flags;
>
> +static inline bool autonuma_impossible(void)
> +{
> +	return num_possible_nodes()<= 1 ||
> +		test_bit(AUTONUMA_IMPOSSIBLE_FLAG,&autonuma_flags);
> +}

When you fix the name of this function, could you also put it
in the right spot, in the patch where it is originally introduced?

Moving stuff around for no reason in a patch series is not very
reviewer friendly.

> diff --git a/include/linux/autonuma_types.h b/include/linux/autonuma_types.h
> index 9e697e3..1e860f6 100644
> --- a/include/linux/autonuma_types.h
> +++ b/include/linux/autonuma_types.h
> @@ -39,6 +39,61 @@ struct task_autonuma {
>   	unsigned long task_numa_fault[0];
>   };
>
> +/*
> + * Per page (or per-pageblock) structure dynamically allocated only if
> + * autonuma is not impossible.
> + */

Double negatives are not easy to read.

s/not impossible/enabled/

> +struct page_autonuma {
> +	/*
> +	 * To modify autonuma_last_nid lockless the architecture,
> +	 * needs SMP atomic granularity<  sizeof(long), not all archs
> +	 * have that, notably some ancient alpha (but none of those
> +	 * should run in NUMA systems). Archs without that requires
> +	 * autonuma_last_nid to be a long.
> +	 */

If only all your data structures were documented like this.

I guess that will give you something to do, when addressing
the comments on the other patches :)

> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index bcaa8ac..c5e47bc 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c

>   #ifdef CONFIG_AUTONUMA
> -			/* pick the last one, better than nothing */
> -			autonuma_last_nid =
> -				ACCESS_ONCE(src_page->autonuma_last_nid);
> -			if (autonuma_last_nid>= 0)
> -				ACCESS_ONCE(page->autonuma_last_nid) =
> -					autonuma_last_nid;
> +			if (!autonuma_impossible()) {
> +				int autonuma_last_nid;
> +				src_page_an = lookup_page_autonuma(src_page);
> +				/* pick the last one, better than nothing */
> +				autonuma_last_nid =
> +					ACCESS_ONCE(src_page_an->autonuma_last_nid);
> +				if (autonuma_last_nid>= 0)
> +					ACCESS_ONCE(page_an->autonuma_last_nid) =
> +						autonuma_last_nid;
> +			}

Remembering the last page the loop went through, and then
looking up the autonuma struct after you exit the loop could
be better.

> diff --git a/mm/page_autonuma.c b/mm/page_autonuma.c
> new file mode 100644
> index 0000000..bace9b8
> --- /dev/null
> +++ b/mm/page_autonuma.c
> @@ -0,0 +1,234 @@
> +#include<linux/mm.h>
> +#include<linux/memory.h>
> +#include<linux/autonuma_flags.h>

This should be <linux/autonuma.h>

There is absolutely no good reason why that one-liner change
is a separate patch.

> +struct page_autonuma *lookup_page_autonuma(struct page *page)
> +{

> +	offset = pfn - NODE_DATA(page_to_nid(page))->node_start_pfn;
> +	return base + offset;
> +}

Doing this and the reverse allows you to drop the page pointer
in struct autonuma.

It would make sense to do that either in this patch, or in a
new one, but either way pulling it forward out of patch 40
would make the series easier to review for the next round.

 > +fail:
 > +	printk(KERN_CRIT "allocation of page_autonuma failed.\n");
 > +	printk(KERN_CRIT "please try the 'noautonuma' boot option\n");
 > +	panic("Out of memory");
 > +}

The system can run just fine without autonuma.

Would it make sense to simply disable autonuma at this point,
but to try continue running?

> @@ -700,8 +780,14 @@ static void free_section_usemap(struct page *memmap, unsigned long *usemap)
>   	 */
>   	if (PageSlab(usemap_page)) {
>   		kfree(usemap);
> -		if (memmap)
> +		if (memmap) {
>   			__kfree_section_memmap(memmap, PAGES_PER_SECTION);
> +			if (!autonuma_impossible())
> +				__kfree_section_page_autonuma(page_autonuma,
> +							      PAGES_PER_SECTION);
> +			else
> +				BUG_ON(page_autonuma);

VM_BUG_ON ?

> +		if (!autonuma_impossible()) {
> +			struct page *page_autonuma_page;
> +			page_autonuma_page = virt_to_page(page_autonuma);
> +			free_map_bootmem(page_autonuma_page, nr_pages);
> +		} else
> +			BUG_ON(page_autonuma);

ditto

>   	pgdat_resize_unlock(pgdat,&flags);
>   	if (ret<= 0) {
> +		if (!autonuma_impossible())
> +			__kfree_section_page_autonuma(page_autonuma, nr_pages);
> +		else
> +			BUG_ON(page_autonuma);

VM_BUG_ON ?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
