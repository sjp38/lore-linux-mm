Received: from noc.nyx.net (mail@noc.nyx.net [206.124.29.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA20465
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 16:32:00 -0500
Date: Wed, 13 Jan 1999 14:31:41 -0700 (MST)
From: Colin Plumb <colin@nyx.net>
Message-Id: <199901132131.OAA09149@nyx10.nyx.net>
Subject: Re: Why don't shared anonymous mappings work?
Sender: owner-linux-mm@kvack.org
To: sct@redhat.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Um, I just thought of another problem with shared anonymous pages.
It's similar to the zero-page issue you raised, but it's no longer
a single special case.

Copy-on-write and shared mappings.  Let's say that process 1 has a COW
copy of page X.  Then the page is shared (via mmap /proc/1/mem or some
such) with process 2.  Now process A writes to the page.

While copying the page, we have to update B's pte to point to the new copy.
But we have no data structure to keep track of the sharing structure.

It's a fairly simple structure, really, since a given physical page maps
(via COW) to one or more separate logical pages, which are in turn each
mapped into one or more memory maps.  Becasue of the "one or more", you
can hope to integrate it into another structure, but ugh.  For n copies,
you need n-1 non-null pointers.  That's a lot of null pointers when n
has its usual value of 1.

One possible fix is to consider multiple mappings of a logical page to
be a write for the purposes of COW copying.  That way, each physical
page is *either* COW-mapped to multiple logical pages, each present in
*one* mmap, or corresponds to one logical page which is present in one
or more maps.  This reduces the tree down to one level, and a type bit
in the page structure will do.

It *is* possible to link PTE entries together in a singly-linked list
where a pointer to another PTE is distinguishable from a pointer to
a disk block or a valid PTE.  I have thought of using this to update
more PTEs when a page is swapped in, as the swapper-in would traverse
the list to find the page at the end, swap it in if necessary, and
copy the mapping to all the entries it traversed.

Come to think of it, this *could* be used for zero-mapped pages.
Make it a circularly linked list.  (You could even distinguish
circular and non-circular lists if you need both.)  Then when
the page is accessed, allocate it and copy the pointer to all the
other PTEs on the list.

Do you have any other ideas?
-- 
	-Colin
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
