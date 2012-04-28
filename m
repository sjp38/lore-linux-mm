Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 405D66B0044
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 23:59:06 -0400 (EDT)
Received: by iajr24 with SMTP id r24so2720022iaj.14
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 20:59:05 -0700 (PDT)
Date: Fri, 27 Apr 2012 20:58:55 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: swapcache size oddness
In-Reply-To: <f0b2f4a3-f6d4-41e9-943b-d083eec9e106@default>
Message-ID: <alpine.LSU.2.00.1204272021030.28310@eggly.anvils>
References: <f0b2f4a3-f6d4-41e9-943b-d083eec9e106@default>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org

On Fri, 27 Apr 2012, Dan Magenheimer wrote:

> In continuing digging through the swap code (with the
> overall objective of improving zcache policy), I was
> looking at the size of the swapcache.
> 
> My understanding was that the swapcache is simply a
> buffer cache for pages that are actively in the process
> of being swapped in or swapped out.

It's that part of the pagecache for pages on swap.

Once written out, as with other pagecache pages written out under
reclaim, we do expect to reclaim them fairly soon (they're moved to
the bottom of the inactive list).  But when read back in, we read a
cluster at a time, hoping to pick up some more useful pages while the
disk head is there (though of course it may be a headless disk).  We
don't disassociate those from swap until they're dirtied (or swap
looks fullish), why should we?

> And keeping pages
> around in the swapcache is inefficient because every
> process access to a page in the swapcache causes a
> minor page fault.

What's inefficient about that?  A minor fault is much less
costly than the major fault of reading them back from disk.

> 
> So I was surprised to see that, under a memory intensive
> workload, the swapcache can grow quite large.  I have
> seen it grow to almost half of the size of RAM.

Nothing wrong with that, so long as they can be freed and
used for better purpose when needed.

> 
> Digging into this oddity, I re-discovered the definition
> for "vm_swap_full()" which, in scan_swap_map() is a
> pre-condition for calling __try_to_reclaim_swap().
> But vm_swap_full() compares how much free swap space
> there is "on disk", with the total swap space available
> "on disk" with no regard to how much RAM there is.
> So on my system, which is running with 1GB RAM and
> 10GB swap, I think this is the reason that swapcache
> is growing so large.
> 
> Am I misunderstanding something?  Or is this code
> making some (possibly false) assumptions about how
> swap is/should be sized relative to RAM?  Or maybe the
> size of swapcache is harmless as long as it doesn't
> approach total "on disk" size?

The size of swapcache is harmless: we break those pages' association
with swap once a better use for the page comes up.  But the size of
swapcache does (of course) represent a duplication of what's on swap.

As swap becomes full, that duplication becomes wasteful: we may need
some of the swap already in memory for saving other pages; so break
the association, freeing the swap for reuse but keeping the page
(but now it's no longer swapcache).

That's what the vm_swap_full() tests are about: choosing to free swap
when it's duplicated in memory, once it's becoming a scarce resource.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
