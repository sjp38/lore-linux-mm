Date: Tue, 25 Apr 2000 16:47:52 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: Re: pressuring dirty pages (2.3.99-pre6)
In-Reply-To: <m1snwadmcp.fsf@flinx.biederman.org>
Message-ID: <Pine.LNX.4.21.0004251642500.10408-100000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederman@uswest.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Mark_H_Johnson.RTS@raytheon.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 25 Apr 2000, Eric W. Biederman wrote:
> "Stephen C. Tweedie" <sct@redhat.com> writes:

> > On Tue, Apr 25, 2000 at 09:27:57AM -0500, Mark_H_Johnson.RTS@raytheon.com wrote:
> > 
> > > It would be great to have a dynamic max limit. However I can see a lot of
> > > complexity in doing so. May I make a few suggestions.
> 
> Agreed all I suggest for now was implement a max limit.
> The dynamic was just food for thought.

I have a solution for this.

My current anti-hog code already looks at what the biggest
process is. Any process which is in the same size class will
get a special bit set and has to call swap_out() on allocation
of a new page.

This will:
1) slow down the hogs a little, but give most slowdown to the
   hog that does most allocations
2) will cause memory in processes to be unmapped, populating
   the lru queue without the help of kswapd ...
3) ... this makes sure we have a whole bunch of easily freeable
   memory around ...
4) ... which in turn makes it easy to keep up with the high IO
   rates which some memory hogs require, because it's easier to
   free memory

So in __alloc_pages():

	if (current->hog)
		swap_out();

Of course this won't penalise processes like bonnie, which just
do a lot of IO, but that *isn't needed* at all because the cache
memory used for these processes is not mapped and occupies a big
portion of the lru queue .. so it's quite likely that we'll free
memory from this process when we free something.

In fact, the MM code I'm playing with at the moment seems pretty
resistant against things like bonnie and tar ...

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
