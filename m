Date: Mon, 13 Dec 1999 16:05:24 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: PG_DMA
In-Reply-To: <199912140001.QAA07712@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9912131603110.835-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Mon, 13 Dec 1999, Kanoj Sarcar wrote:
>
> In 2.3.32-pre, I see that the PageDMA(page) macro has been changed to
> 
> #define PageDMA(page)            (contig_page_data.node_zones + ZONE_DMA == (page)->zone)
> 
> Why was this done? I would still prefer to see the PG_DMA bit, because
> for discontig platforms, there is not a "contig_page_data". In short, 
> this will break any platform that does use the CONFIG_DISCONTIGMEM code.

Actually, the REAL reason this was done is that PageDMA should just go
away completely.

If you grep for where it is actually used, you'll see that it's only used
in the page freeing code to see if this is a page we're interested in
freeing. And that needs to be eithe rremoved or revamped anyway - whether
it's going to be per-zone or global or whatever, the current test is just
noth worth it (what KIND of DMA? Is it the 20-bit ISA DMA or the 31-bit
broken PCI dma or the 32-bit real PCI dma or what?)

The DMA'ness of the page should be encoded as just the kind of zone it is
part of.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
