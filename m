Date: Thu, 9 Dec 1999 13:25:00 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <384F17BA.174B4C6D@mandrakesoft.com>
Message-ID: <Pine.LNX.4.10.9912091319030.1223-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Dec 1999, Jeff Garzik wrote:

> > > What's the best way to get a large region of DMA'able memory for use
> > > with framegrabbers and other greedy drivers?
> > 
> > Do you need physically linear memory >
> 
> Yes.  For the Meteor-II grabber I don't think so, but it looks like the
> older (but mostly compatible) Corona needs it.

hm, you could use the bootmem allocator for now - it allocates a
physically continuous 165MB mem_map[] on my box just fine. The problem
with bootmem is that it's "too early" in the bootup process, you cannot
cleanly hook into it, because it's use is forbidden after
free_all_bootmem() is called.

hm, does anyone have any conceptual problem with a new
allocate_largemem(pages) interface in page_alloc.c? It's not terribly hard
to scan all bitmaps for available RAM and mark the large memory area
allocated and remove all pages from the freelists. Such areas can only be
freed via free_largemem(pages). Both calls will be slow, so should be only
used at driver initialization time and such.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
