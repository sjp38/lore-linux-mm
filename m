Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA00667
	for <linux-mm@kvack.org>; Sun, 7 Feb 1999 17:27:59 -0500
Date: Mon, 8 Feb 1999 09:32:24 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Re: swapcache bug?
In-Reply-To: <199902081639.QAA03290@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.990208092701.31153B-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: masp0008@stud.uni-sb.de, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Mon, 8 Feb 1999, Stephen C. Tweedie wrote:
> 
> Good point, the line include/linux/pagemap.h:39,
> 
> 	return s(i+o) & (PAGE_HASH_SIZE-1);
> 
> should probably be 
> 
> 	return s(i+o+offset) & (PAGE_HASH_SIZE-1);
> 
> to mix in the low order bits for swap entries.  Well spotted.  Anyone
> see anything wrong with this one-liner change?

Yes, the above will potentially result in different hash entries for the
same page, which means that we now have aliasing and basically just random
behaviour. 

It _may_ be that the hash function is always called with a page-aligned
offset, but that was not how it was strictly meant to be: the way the
thing was envisioned you could just find the page at "offset" by doing

	page_hash(inode,offset)

without page-aligning offset before you did this.

If anything, maybe the swap cache should just use the high bits in the
"offset" field (or at least prefer to do so: something like

	page->offset = swap_entry_to_offset(entry);

and 
	entry = offset_to_swap_entry(page->offset);

that does a PAGE_MASK_BITS rotate on the bits..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
