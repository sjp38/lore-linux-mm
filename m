Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DAC1A6B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 19:53:00 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p58NeBNF021818
	for <linux-mm@kvack.org>; Wed, 8 Jun 2011 17:40:11 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p58NqrT5240154
	for <linux-mm@kvack.org>; Wed, 8 Jun 2011 17:52:54 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p58HqPxl028598
	for <linux-mm@kvack.org>; Wed, 8 Jun 2011 11:52:26 -0600
Subject: Re: [PATCH] Add debugging boundary check to pfn_to_page
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1307560734-3915-1-git-send-email-emunson@mgebm.net>
References: <1307560734-3915-1-git-send-email-emunson@mgebm.net>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 08 Jun 2011 13:49:28 -0700
Message-ID: <1307566168.3048.137.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: arnd@arndb.de, akpm@linux-foundation.org, paulmck@linux.vnet.ibm.com, mingo@elte.hu, randy.dunlap@oracle.com, josh@joshtriplett.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, mgorman@suse.de, linux-mm@kvack.org

On Wed, 2011-06-08 at 15:18 -0400, Eric B Munson wrote:
> -#define __pfn_to_page(pfn)                             \
> -({     unsigned long __pfn = (pfn);                    \
> -       struct mem_section *__sec = __pfn_to_section(__pfn);    \
> -       __section_mem_map_addr(__sec) + __pfn;          \
> +#ifdef CONFIG_DEBUG_MEMORY_MODEL
> +#define __pfn_to_page(pfn)                                             \
> +({     unsigned long __pfn = (pfn);                                    \
> +       struct mem_section *__sec = __pfn_to_section(__pfn);            \
> +       struct page *__page = __section_mem_map_addr(__sec) + __pfn;    \
> +       WARN_ON(__page->flags == 0);                                    \
> +       __page;                                                         \

What was the scenario you're trying to catch here?  If you give a really
crummy __pfn, you'll probably go off the end of one of the mem_section[]
arrays, and get garbage back for __sec.  You might also get a NULL back
from __section_mem_map_addr() if the section is possibly valid, but just
not present on this particular system.

I _think_ the only kind of bug this will catch is if you have a valid
section, with a valid section_mem_map[] but still manage to find
yourself with an 'struct page' unclaimed by any zone and thus
uninitialized.

You could catch a lot more cases by being a bit more paranoid:

void check_pfn(unsigned long pfn)
{
	int nid;
	
	// hacked in from pfn_to_nid:
	// Don't actually do this, add a new helper near pfn_to_nid()
	// Can this even fit in the physnode_map?
	if (pfn / PAGES_PER_ELEMENT > ARRAY_SIZE(physnode_map))
		WARN();

	// Is there a valid nid there?
	nid = pfn_to_nid(pfn);
	if (nid == -1)
		WARN();
	
	// check against NODE_DATA(nid)->node_start_pfn;
	// check against NODE_DATA(nid)->node_spanned_pages;
}
>  })
> +#else
> +#define __pfn_to_page(pfn)                                             \
> +({     unsigned long __pfn = (pfn);                                    \
> +       struct mem_section *__sec = __pfn_to_section(__pfn);            \
> +       __section_mem_map_addr(__sec) + __pfn;  \
> +})
> +#endif /* CONFIG_DEBUG_MEMORY_MODEL */ 

Instead of making a completely new __pfn_to_page() in the debugging
case, I'd probably do something like this:

#ifdef CONFIG_DEBUG_MEMORY_MODEL
#define check_foo(foo) {\
	some_check_here(foo);\
	WARN_ON(foo->flags);\
}
#else
#define check_foo(foo) do{}while(0)
#endif;

#define __pfn_to_page(pfn)                                             \
({     unsigned long __pfn = (pfn);                                    \
       struct mem_section *__sec = __pfn_to_section(__pfn);            \
       struct page *__page = __section_mem_map_addr(__sec) + __pfn;    \
       check_foo(page)							\
       __page;                                                         \
 })

That'll make sure that the two copies of __pfn_to_page() don't
accidentally diverge.  It also makes it a lot easier to read, I think.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
