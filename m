Date: Mon, 17 Jul 2000 12:31:08 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
In-Reply-To: <39731E78.C152D049@cs.amherst.edu>
Message-ID: <Pine.LNX.4.21.0007171223210.30603-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Scott F. Kaplan" <sfkaplan@cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 17 Jul 2000, Scott F. Kaplan wrote:
> Alan Cox wrote:
> > Modern OS designers are consistently seeing LFU work better. In our case this
> > is partly theory in the FreeBSD case its proven by trying it.
> 
> Have any of the FreeBSD people compiled some results to this
> effect?  I'd be interested to see under what circumstances LFU
> works better,

Say you're in the situation where 1/2 of your memory is
memory used by programs, memory which is used over and
over again.

The other half of your memory is used to cache the
multimedia data you're streaming or the files you're
exporting over NFS. This is mostly use-once memory.

If a sudden burst of IO occurs, LRU would evict memory
from the programs, memory which will be used again soon.
LFU, on the other hand, correctly evicts memory from the
cache ... especially the memory which was used only once.

> and just what approximations of both LRU and LFU are being used.  

Page aging. Basically the pages in memory are scanned periodically
(with the period being driven by memory pressure), if a page was
referenced since the last time, the page age/act_count is increased,
otherwise the page age/act_count is decreased. Pages are deactivated
(moved to the inactive list) when the age/act_count reaches 0.

if (test_and_clear_referenced(page)) {
	page->age += PG_AGE_ADV;
	if (page->age > PG_AGE_MAX)
		page->age = PG_AGE_MAX;
} else {
	page->age -= min(page->age, PG_AGE_DECL);
	if (page->age == 0)
		deactivate_page(page);
}

This is a nice approximation of LRU and LFU, one which comes
pretty close to LFU because of the linear decline. If we were
to use

	page->age /= 2;

as page age decreaser instead, we'd probably be closer to LRU.

It would be worth it to experiment a bit to see which of these
will work best.

> There could be something interesting in such results, as years
> of other experiments have shown otherwise.

I wonder if the speed difference between CPU, memory and hard disk
have changed over the years .. ;)

(or if system loads have changed a bit ... nowadays the working
set of processes usually fits in memory but there is a lot of
streaming IO going on in the background)

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
