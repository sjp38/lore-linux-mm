Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 264C08D003B
	for <linux-mm@kvack.org>; Sun, 10 Apr 2011 20:50:08 -0400 (EDT)
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p3B0o68a010736
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sun, 10 Apr 2011 20:50:06 -0400
Received: from annuminas.surriel.com ([10.3.113.14])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p3B0o2Gp029720
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Sun, 10 Apr 2011 20:50:06 -0400
Message-ID: <4DA25039.3020700@redhat.com>
Date: Sun, 10 Apr 2011 20:50:01 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: [LSF/Collab] swap cache redesign idea
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>

On Thursday after LSF, Hugh, Minchan, Mel, Johannes and I were
sitting in the hallway talking about yet more VM things.

During that discussion, we came up with a way to redesign the
swap cache.  During my flight home, I came with ideas on how
to use that redesign, that may make the changes worthwhile.

Currently, the page table entries that have swapped out pages
associated with them contain a swap entry, pointing directly
at the swap device and swap slot containing the data. Meanwhile,
the swap count lives in a separate array.

The redesign we are considering moving the swap entry to the
page cache radix tree for the swapper_space and having the pte
contain only the offset into the swapper_space.  The swap count
info can also fit inside the swapper_space page cache radix
tree (at least on 64 bits - on 32 bits we may need to get
creative or accept a smaller max amount of swap space).

This extra layer of indirection allows us to do several things:

1) get rid of the virtual address scanning swapoff; instead
    we just swap the data in and mark the pages as present in
    the swapper_space radix tree

2) free swap entries as the are read in, without waiting for
    the process to fault it in - this may be useful for memory
    types that have a large erase block

3) together with the defragmentation from (2), we can always
    do writes in large aligned blocks - the extra indirection
    will make it relatively easy to have special backend code
    for different kinds of swap space, since all the state can
    now live in just one place

4) skip writeout of zero-filled pages - this can be a big help
    for KVM virtual machines running Windows, since Windows zeroes
    out free pages;   simply discarding a zero-filled page is not
    at all simple in the current VM, where we would have to iterate
    over all the ptes to free the swap entry before being able to
    free the swap cache page (I am not sure how that locking would
    even work)

    with the extra layer of indirection, the locking for this scheme
    can be trivial - either the faulting process gets the old page,
    or it gets a new one, either way it'll be zero filled

5) skip writeout of pages the guest has marked as free - same as
    above, with the same easier locking

Only one real question remaining - how do we handle the swap count
in the new scheme?  On 64 bit systems we have enough space in the
radix tree, on 32 bit systems maybe we'll have to start overflowing
into the "swap_count_continued" logic a little sooner than we are
now and reduce the maximum swap size a little?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
