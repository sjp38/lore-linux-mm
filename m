Date: Wed, 10 May 2000 15:11:03 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: A possible winner in pre7-8
In-Reply-To: <Pine.LNX.4.10.10005100817530.1989-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0005101509260.6894-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 May 2000, Linus Torvalds wrote:

> Do you have a SMP machine? If so, I think I found this one.
> And it's been there for ages.
> 
> The bug is that GFP_ATOMIC _really_ must not try to page stuff out,
> eventhe stuff that doesn't need IO to be dropped.
> 
> Why? Because GFP_ATOMIC can be (and mostly is) called from
> interrupts, and even when we don't do IO we _do_ access a number
> of spinlocks in order to see whether we can even just drop it.

I'm sorry to dissapoint you, but I'm afraid this isn't
the bug. Please look at this code from vmscan.c...

int try_to_free_pages(unsigned int gfp_mask, zone_t *zone)
{
        int retval = 1;

        if (gfp_mask & __GFP_WAIT) {
                current->flags |= PF_MEMALLOC;
                retval = do_try_to_free_pages(gfp_mask, zone);
                current->flags &= ~PF_MEMALLOC;
        }
        return retval;
}

As you see, we never call do_try_to_free_pages() if we don't
have __GFP_WAIT set. And GFP_ATOMIC doesn't include __GFP_WAIT.

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
