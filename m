Date: Fri, 12 May 2000 10:20:19 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.21.0005121419460.554-100000@inspiron>
Message-ID: <Pine.LNX.4.21.0005121011140.28943-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Fri, 12 May 2000, Andrea Arcangeli wrote:
> On Fri, 12 May 2000, Ingo Molnar wrote:
> 
> >what bad effects? the LRU list of the pagecache is a completely
> >independent mechanizm. Highmem pages are LRU-freed just as effectively as
> >normal pages. The pagecache LRU list is not per-zone but (IMHO correctly)
> >global, so the particular zone of highmem pages is completely transparent
> 
> It shouldn't be global but per-NUMA-node as I have in the classzone patch.

*nod*

This change is in my source tree too (but the active/inactive
page list thing doesn't work yet).

> >and irrelevant to the LRU mechanizm. I cannot see any bad effects wrt. LRU
> >recycling and the highmem zone here. (let me know if you ment some
> >different recycling mechanizm)
> 
> See line 320 of filemap.c in 2.3.99-pre7-pre9. (ignore the fact
> it will recycle 1 page, it's just because they didn't expected
> pages_high to be zero)

Indeed, pages_high for the higmem zone probably shouldn't be zero.

pages_min and pages_low:  0
pages_high:               128???  (free up to 512kB of high memory)

> >'balanced' means: 'keep X amount of highmem free'. What is your point in
> >keeping free highmem around?
> 
> Assuming there is no point, you still want to free also from the
> highmem zone while doing LRU aging of the cache.

True, but this just involves setting the watermarks right. The
current code supports the balancing just fine.

> And if you don't keep X amount of highmem free you'll break if
> an irq will do a GFP_HIGHMEM allocation.

GFP_HIGHMEM will automatically fallback to the NORMAL zone.
There's no problem here.

> Note also that with highmem I don't mean not the memory between
> 1giga and 64giga, but the memory between 0 and 64giga.

Why do you keep insisting on meaning other things with words than
what everybody else means with them? ;)

> Please read my emails on linux-mm of a few weeks ago about
> classzone approch.

I've read them and it's overly complex and doesn't make much
sense for what we need.

> I can forward them to linux-kernel if there is interest (I don't
> know if there's a web archive but I guess there is).

http://mail.nl.linux.org/linux-mm/
http://www.linux.eu.org/Linux-MM/

> If the current strict zone approch wouldn't be broken we could
> as well choose to split the ZONE_HIGHMEM in 10/20 zones to
> scales 10/20 times better during allocations, no?

This would work just fine, except for the fact that we have
only one pagecache_lock ... maybe we want to have multiple
pagecache_locks based on a hash of the inode number? ;)

> Is this argulemnt enough to make you to at least ring a bell
> that the current design is flawed?

But we *can* split the HIGHMEM zone into a bunch of smaller
ones without affecting performance. Just set zone->pages_min
and zone->pages_low to 0 and zone->pages_high to some smallish
value. Then we can teach the allocator to skip the zone if:
1) no obscenely large amount of free pages
2) zone is locked by somebody else (TryLock(zone->lock))

This will work just fine with the current code (plus these
two minor tweaks). No big changes are needed to support this
idea.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
