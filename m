Date: Mon, 29 Jan 2001 16:24:34 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Linux-2.4.1-pre11
In-Reply-To: <Pine.LNX.4.21.0101291717500.1321-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0101291548400.14756-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2001, Rik van Riel wrote:

> Wouldn't that be:
> 	if (nr < MINSCAN)
> 		nr = MINSCAN;
> 
> Btw, if we fix the inactive_shortage() function to take
> per-zone inactive shortage into account, we can just skip
> scanning if we only have a free shortage but no inactive
> shortage.

inactive_shortage() already takes this into account. 

> Page_launder() then needs to be changed a bit too. If it's
> called from a user process, it can have the same behaviour
> it has now.

Btw, look at this part of code from kswapd: 

                /* 
                 * We go to sleep if either the free page shortage
                 * or the inactive page shortage is gone. We do this
                 * because:
                 * 1) we need no more free pages   or
                 * 2) the inactive pages need to be flushed to disk,
                 *    it wouldn't help to eat CPU time now ...
                 *
                 * We go to sleep for one second, but if it's needed
                 * we'll be woken up earlier...
                 */
                if (!free_shortage() || !inactive_shortage()) {
                        interruptible_sleep_on_timeout(&kswapd_wait, HZ);


kswapd goes to sleep if there is no free shortage, even if the inactive
list is under shortage.

Why not refill the inactive list when the inactive list is under
shortage? :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
