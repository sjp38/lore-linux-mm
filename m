Date: Fri, 12 May 2000 14:57:27 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <Pine.LNX.4.10.10005121307370.3348-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0005121419460.554-100000@inspiron>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Fri, 12 May 2000, Ingo Molnar wrote:

>what bad effects? the LRU list of the pagecache is a completely
>independent mechanizm. Highmem pages are LRU-freed just as effectively as
>normal pages. The pagecache LRU list is not per-zone but (IMHO correctly)
>global, so the particular zone of highmem pages is completely transparent

It shouldn't be global but per-NUMA-node as I have in the classzone patch.

>and irrelevant to the LRU mechanizm. I cannot see any bad effects wrt. LRU
>recycling and the highmem zone here. (let me know if you ment some
>different recycling mechanizm)

See line 320 of filemap.c in 2.3.99-pre7-pre9. (ignore the fact it will
recycle 1 page, it's just because they didn't expected pages_high to be
zero)

>'balanced' means: 'keep X amount of highmem free'. What is your point in
>keeping free highmem around?

Assuming there is no point, you still want to free also from the highmem
zone while doing LRU aging of the cache.

And if you don't keep X amount of highmem free you'll break if an irq will
do a GFP_HIGHMEM allocation.

Note also that with highmem I don't mean not the memory between 1giga and
64giga, but the memory between 0 and 64giga. When you allocate with
GFP_HIGHUSER you ask to the MM a page between 0 and 64giga.

And in turn what is the point of keeping X amount of normal/regular memory
free? You just try to keep such X amount of memory free in the DMA zone,
so why you also try to keep it free on the normal zone? The problem is the
same.

Please read my emails on linux-mm of a few weeks ago about classzone
approch. I can forward them to linux-kernel if there is interest (I don't
know if there's a web archive but I guess there is).

If the current strict zone approch wouldn't be broken we could as well
choose to split the ZONE_HIGHMEM in 10/20 zones to scales 10/20 times
better during allocations, no? Is this argulemnt enough to make you to at
least ring a bell that the current design is flawed? The flaw is that we
pay that with drawbacks and by having the VM that does the wrong thing
because it have no enough information (it only see a little part of the
picture). You can't fix it without looking the whole picture (the
classzone).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
