Date: Tue, 9 Jan 2001 20:11:30 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Yet another bogus piece of do_try_to_free_pages() 
In-Reply-To: <Pine.LNX.4.21.0101091929140.7500-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0101091959560.7500-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
Hi,

Look at this piece of code from kswapd: 

                /* If needed, try to free some memory. */
                if (inactive_shortage() || free_shortage()) {
                        int wait = 0;
                        /* Do we need to do some synchronous flushing? */
                        if (waitqueue_active(&kswapd_done))
                                wait = 1;
                        do_try_to_free_pages(GFP_KSWAPD, wait);
                }

The problem is that do_try_to_free_pages uses the "wait" argument when
calling page_launder() (where the paramater is used to indicate if we want
todo sync or async IO) _and_ used to call refill_inactive(), where this
parameter is used to indicate if its being called from a normal process or
from kswapd:

 * OTOH, if we're a user process (and not kswapd), we
 * really care about latency. In that case we don't try
 * to free too many pages.
 */
static int refill_inactive(unsigned int gfp_mask, int user)
{
        int priority, count, start_count;

        count = inactive_shortage() + free_shortage();
        if (user)
                count = (1 << page_cluster);
        start_count = count;


This is probably quite nasty in practice (low memory conditions) because
if we have waiters on kswapd, we want to free more memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
