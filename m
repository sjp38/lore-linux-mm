Date: Thu, 22 Jun 2000 16:47:50 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Re: latancy test of -ac22-riel
In-Reply-To: <m2ya3xsf8e.fsf@boreas.southchinaseas>
Message-ID: <Pine.LNX.4.21.0006221644310.1170-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@penguinpowered.com>
Cc: Roger Larsson <roger.larsson@norran.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 22 Jun 2000, John Fremlin wrote:
> Roger Larsson <roger.larsson@norran.net> writes:
> 
> [...]
> 
> > I retried running with normal prio - then I get stalls
> > of > 350ms...
> 
> I think some stalls are most probably due to try_to_free_pages below
> 
> page_alloc.c::__alloc_pages
> 	/*
> 	 * Uhhuh. All the zones have been critical, which means that
> 	 * we'd better do some synchronous swap-out. kswapd has not
> 	 * been able to cope..
> 	 */
> 	if (!(current->flags & PF_MEMALLOC)) {
> 		if (!try_to_free_pages(gfp_mask)) {
> 			if (!(gfp_mask & __GFP_HIGH))
> 				goto fail;
> 		}
> 		goto fail;
> 	}
> 
> That is, it happens in times of high memory stress and when I
> comment it out the pauses go away but I'm not sure that this is
> a good long-term solution ;-) though IMHO the behaviour without
> it (VM killing process) is better than the behaviour with it
> (paging until power is cycled).

You're confusing things here.

If kswapd was too slow in freeing up memory, but there is
still more memory available, then we should NOT kill a
process but just stall the process until more memory is
available.

OTOH, when we are truly Out Of Memory, then (and only then)
should we kill a process.

Killing a process before we are out of memory is just not
acceptable and should never be done.

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
