Date: Fri, 30 Oct 1998 15:58:22 GMT
Message-Id: <199810301558.PAA03792@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: mmap() for a cluster of pages
In-Reply-To: <Pine.LNX.3.95.981026121852.9207B-100000@as200.spellcast.com>
References: <199810261144.MAA12564@faun.cs.tu-berlin.de>
	<Pine.LNX.3.95.981026121852.9207B-100000@as200.spellcast.com>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Gilles Pokam <pokam@cs.tu-berlin.de>, sct@redhat.com, Linux-MM@kvack.org, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 26 Oct 1998 12:39:33 -0500 (EST), "Benjamin C.R. LaHaise" <blah@kvack.org> said:

> Stephen, in replying to this, I glanced at the sound driver's mmap
> routine.  They use an order > 0 buffer that they map, but don't do
> anything to prevent its being touched by the swap routines.  

I'm not sure quite which bit of the sound code you mean.  I can't see
anything wrong.  When we create a sound buffer (drivers/sound/dmabuf.c),
we explicitly set PG_reserved on every page in the buffer.  In
remap_page_range, there is the test

		mapnr = MAP_NR(__va(phys_addr));
		if (mapnr >= max_mapnr || PageReserved(mem_map+mapnr))
 			set_pte(pte, mk_pte_phys(phys_addr, prot));

which means that we won't do a remap on any page unless that page is
already protected against being seen by the swapper.  I think we're
quite safe here.

> My guess is simply that noone's encountered this bug before, but it's
> there.  

We should be OK.  Alan will no doubt scream if I'm wrong here.

> Also, is PG_reserved the best flag for this case?

Absolutely, it's the only flag we test for consistently when playing
silly buggers with page-present page table entries.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
