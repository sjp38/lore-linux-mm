Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAT6PurS015337
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 01:25:56 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAT6Pun0472684
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 01:25:56 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAT6Pt0e011189
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 01:25:55 -0500
Subject: Re: [RFC PATCH] LTTng instrumentation mm (using page_to_pfn)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071129023421.GA711@Krystal>
References: <20071113193349.214098508@polymtl.ca>
	 <20071113194025.150641834@polymtl.ca> <1195160783.7078.203.camel@localhost>
	 <20071115215142.GA7825@Krystal> <1195164977.27759.10.camel@localhost>
	 <20071116143019.GA16082@Krystal> <1195495485.27759.115.camel@localhost>
	 <20071128140953.GA8018@Krystal> <1196268856.18851.20.camel@localhost>
	 <20071129023421.GA711@Krystal>
Content-Type: text/plain
Date: Wed, 28 Nov 2007 22:25:52 -0800
Message-Id: <1196317552.18851.47.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-11-28 at 21:34 -0500, Mathieu Desnoyers wrote:
> Before I start digging deeper in checking whether it is already
> instrumented by the fs instrumentation (and would therefore be
> redundant), is there a particular data structure from mm/ that you
> suggest taking the swap file number and location in swap from ?

page_private() at this point stores a swp_entry_t.  There are swp_type()
and swp_offset() helpers to decode the two bits you need after you've
turned page_private() into a swp_entry_t.  See how get_swap_bio()
creates a temporary swp_entry_t from the page_private() passed into it,
then uses swp_type/offset() on it?

I don't know if there is some history behind it, but it doesn't make a
whole ton of sense to me to be passing page_private(page) into
get_swap_bio() (which happens from its only two call sites).  It just
kinda obfuscates where 'index' came from.

It think we probably could just be doing

	swp_entry_t entry = { .val = page_private(page), };

in get_swap_bio() and not passing page_private().  We have the page in
there already, so we don't need to pass a derived value like
page_private().  At the least, it'll save some clutter in the function
declaration.  

Or, make a helper:

static swp_entry_t page_swp_entry(struct page *page)
{
	swp_entry_t entry;
	VM_BUG_ON(!PageSwapCache(page));
	entry.val = page_private(page);
	return entry;
}

I see at least 4 call sites that could use this.  The try_to_unmap_one()
caller would trip over the debug check, so you'd have to move the call
inside of the if(PageSwapCache(page)) statement.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
