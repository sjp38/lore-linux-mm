Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m9RHxTO4158684
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 17:59:29 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9RHxUfa1576996
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 18:59:30 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9RHxTLJ023753
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 18:59:30 +0100
Subject: Re: [PATCH] memory hotplug: fix page_zone() calculation in
	test_pages_isolated()
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
In-Reply-To: <1225128359.12673.101.camel@nimitz>
References: <4905F114.3030406@de.ibm.com>
	 <1225128359.12673.101.camel@nimitz>
Content-Type: text/plain
Date: Mon, 27 Oct 2008 18:59:29 +0100
Message-Id: <1225130369.20384.33.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-10-27 at 10:25 -0700, Dave Hansen wrote:
> I'm not sure I follow.  Let's look at the code, pre-patch:
> 
> > 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
> >                 page = __first_valid_page(pfn, pageblock_nr_pages);
> >                 if (page && get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
> >                         break;
> >         }
> >         if (pfn < end_pfn)
> >                 return -EBUSY;
> 
> We have two ways out of the loop:
> 1. 'page' is valid, and not isolated, so we did a 'break'
> 2. No page hit (1) in the range and we broke out of the loop because
>    of the for() condition: (pfn < end_pfn).  
> 
> So, when the condition happens that you mentioned in your changelog
> above: "pfn then points to the first pfn after end_pfn", we jump out at
> the 'return -EBUSY;'.  We don't ever do pfn_to_page() in that case since
> we've returned befoer.
> 
> Either 'page' is valid *OR* you return -EBUSY.  I don't think you need
> to check both.

We only return -EBUSY if pfn < end_pfn, but after completing the loop w/o
a break pfn will be > end_pfn. Also, the last call to __first_valid_page()
may return NULL w/o causing a break, so page may also be invalid after the
loop.

> > Using the last valid page that was found inside the for() loop, instead
> > of pfn_to_page(), should fix this.
> > @@ -130,10 +130,10 @@ int test_pages_isolated(unsigned long st
> > 		if (page && get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
> > 			break;
> > 	}
> > -	if (pfn < end_pfn)
> > +	if ((pfn < end_pfn) || !page)
> > 		return -EBUSY;
> > 	/* Check all pages are free or Marked as ISOLATED */
> > -	zone = page_zone(pfn_to_page(pfn));
> > +	zone = page_zone(page);
> 
> I think this patch fixes the bug, but for reasons other than what you
> said. :)
> 
> The trouble here is that the 'pfn' could have been in the middle of a
> hole somewhere, which __first_valid_page() worked around.  Since you
> saved off the result of __first_valid_page(), it ends up being OK with
> your patch.

I think pfn will always be > end_pfn if we complete the loop. And breaking
out of the loop earlier will always return -EBUSY.

> Instead of using pfn_to_page() you could also have just called
> __first_valid_page() again.  But, that would have duplicated a bit of
> work, even though not much in practice because the caches are still hot.
> 
> Technically, you wouldn't even need to check the return from
> __first_valid_page() since you know it has a valid result because you
> made the exact same call a moment before.
> 
> Anyway, can you remove the !page check, fix up the changelog and resend?

Calling __first_valid_page() again might be a good idea. Thinking about it
now, I guess there is still a problem left with my patch, but for reasons
other than what you said :) If the loop is completed with page == NULL,
we will return -EBUSY with the new patch. But there may have been valid
pages before, and only some memory hole at the end. In this case, returning
-EBUSY would probably be wrong.

Kamezawa, this loop/function was added by you, what do you think?

--
Thanks,
Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
