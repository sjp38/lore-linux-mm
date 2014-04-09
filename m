Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id D9AC56B003B
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 19:23:19 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so3128696pbb.19
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 16:23:19 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id pb4si1125624pac.236.2014.04.09.16.23.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Apr 2014 16:23:17 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so3165385pad.28
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 16:23:17 -0700 (PDT)
Date: Wed, 9 Apr 2014 16:22:07 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC v5] mm: prototype: rid swapoff of quadratic complexity
In-Reply-To: <20140401051638.GA13715@kelleynnn-virtual-machine>
Message-ID: <alpine.LSU.2.11.1404091424500.3327@eggly.anvils>
References: <20140401051638.GA13715@kelleynnn-virtual-machine>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kelley Nielsen <kelleynnn@gmail.com>
Cc: linux-mm@kvack.org, riel@surriel.com, riel@redhat.com, opw-kernel@googlegroups.com, hughd@google.com, akpm@linux-foundation.org, jamieliu@google.com, sjenning@linux.vnet.ibm.com, sarah.a.sharp@intel.com

On Mon, 31 Mar 2014, Kelley Nielsen wrote:

> The function try_to_unuse() is of quadratic complexity, with a lot of
> wasted effort. It unuses swap entries one by one, potentially iterating
> over all the page tables for all the processes in the system for each
> one.
> 
> This new proposed implementation of try_to_unuse simplifies its
> complexity to linear. It iterates over the system's mms once, unusing
> all the affected entries as it walks each set of page tables. It also
> makes similar changes to shmem_unuse.

I have now given this v5 a try, and it seems to be working well for the
normal case, but not when under global memory pressure: swapoff gets
stuck going round and around in the find_next_to_unuse() loop.

The reason is, that loop thinks it's just cleaning up the orphaned
swapcache pages, but in fact there can be swap entries reinserted back
into process space since the mmlist loop passed over them: on those the
find_next_to_unuse() loop keeps on reading in from swap, then deleting
from swapcache; but does nothing actually to free up the swap.

Which draws attention to a feature of the old per-page approach, which
you need to incorporate into your approach.  To make forward progress
under global memory pressure, a page should be mapped into all its mms
and the swap then freed as soon as possible.  Any delay makes it more
likely that page reclaim will reinsert a swap entry; and until the
page is removed from swapcache, reclaim cannot assign new swap to it.

So, don't just add allowance for still-mapped pages into that final
find_next_to_unuse() loop - that's necessary (a goto back to the start,
or perhaps to after the shmem_unuse - I'm not certain), but you also
need to delete_from_swap_cache() each page in turn as soon as its
swapcount goes down to 0, to minimize the chance of reusing the swap.

Given the way copy_one_pte() adds dst_mm to mmlist after src_mm,
mms sharing the same page should be clustered closely in the mmlist.
For this patch it will probably be good enough not to complicate your
current structure, but just add the delete_from_swap_cache() when
swapcount 0 into unuse_pte() or nearby.

(And don't be disheartened if once you've put it in, I suggest you
move it around: this code has been stable for a long while, there's
a lot to consider in reorganizing it, not obvious to either of us.)

I think a further patch, which does an rmap walk when the first pte
has been found (if swapcount indicates more entries to update) while
still holding the page lock, will probably be a good addition on top.
(That ksm_might_need_to_copy(): hmm, yes, KSM complicates this.)

It's tempting to think that with such an rmap walk under page lock
in place, there would no longer be a need for the find_next_to_unuse()
loop to terminate and go back to mmlist.  Tempting, but I wouldn't bet
on it: we shall probably find odd corners which still make retry
necessary (KSM? mremap move? others?).

While I remember, two other things you can address in separate
patches (no need to worry until this is stable).  Don't forget to
delete __locate() and radix_tree_locate_item() from lib/radix-tree.c
and include/linux/radix-tree.h: that will improve your diffstat.
And I think it would help everyone if you change the ancient strange
"unuse" throughout to "swapoff" (particularly now that s390 are
adding a pte_unused() which has nothing to do with all this).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
