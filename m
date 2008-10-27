Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9RHMdEg003663
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 13:22:39 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9RHQ11S080280
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 13:26:01 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9RHQ1j0026304
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 13:26:01 -0400
Subject: Re: [PATCH] memory hotplug: fix page_zone() calculation in
	test_pages_isolated()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4905F114.3030406@de.ibm.com>
References: <4905F114.3030406@de.ibm.com>
Content-Type: text/plain
Date: Mon, 27 Oct 2008 10:25:59 -0700
Message-Id: <1225128359.12673.101.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: gerald.schaefer@de.ibm.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-10-27 at 17:49 +0100, Gerald Schaefer wrote:
> My last bugfix here (adding zone->lock) introduced a new problem: Using
> pfn_to_page(pfn) to get the zone after the for() loop is wrong. pfn then
> points to the first pfn after end_pfn, which may be in a different zone
> or not present at all. This may lead to an addressing exception in
> page_zone() or spin_lock_irqsave().

I'm not sure I follow.  Let's look at the code, pre-patch:

> 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
>                 page = __first_valid_page(pfn, pageblock_nr_pages);
>                 if (page && get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
>                         break;
>         }
>         if (pfn < end_pfn)
>                 return -EBUSY;

We have two ways out of the loop:
1. 'page' is valid, and not isolated, so we did a 'break'
2. No page hit (1) in the range and we broke out of the loop because
   of the for() condition: (pfn < end_pfn).  

So, when the condition happens that you mentioned in your changelog
above: "pfn then points to the first pfn after end_pfn", we jump out at
the 'return -EBUSY;'.  We don't ever do pfn_to_page() in that case since
we've returned befoer.

Either 'page' is valid *OR* you return -EBUSY.  I don't think you need
to check both.

> Using the last valid page that was found inside the for() loop, instead
> of pfn_to_page(), should fix this.
> @@ -130,10 +130,10 @@ int test_pages_isolated(unsigned long st
> 		if (page && get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
> 			break;
> 	}
> -	if (pfn < end_pfn)
> +	if ((pfn < end_pfn) || !page)
> 		return -EBUSY;
> 	/* Check all pages are free or Marked as ISOLATED */
> -	zone = page_zone(pfn_to_page(pfn));
> +	zone = page_zone(page);

I think this patch fixes the bug, but for reasons other than what you
said. :)

The trouble here is that the 'pfn' could have been in the middle of a
hole somewhere, which __first_valid_page() worked around.  Since you
saved off the result of __first_valid_page(), it ends up being OK with
your patch.

Instead of using pfn_to_page() you could also have just called
__first_valid_page() again.  But, that would have duplicated a bit of
work, even though not much in practice because the caches are still hot.

Technically, you wouldn't even need to check the return from
__first_valid_page() since you know it has a valid result because you
made the exact same call a moment before.

Anyway, can you remove the !page check, fix up the changelog and resend?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
