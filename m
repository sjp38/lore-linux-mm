Subject: Re: [PATCH] a simple OOM killer to save me from Netscape
References: <Pine.LNX.4.21.0104131317110.12164-100000@imladris.rielhome.conectiva>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 14 Apr 2001 01:00:20 -0600
In-Reply-To: Rik van Riel's message of "Fri, 13 Apr 2001 13:20:07 -0300 (BRST)"
Message-ID: <m1ofu0t18b.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Slats Grobnik <kannzas@excite.com>, linux-mm@kvack.org, Andrew Morton <andrewm@uow.edu.au>
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On 13 Apr 2001, Eric W. Biederman wrote:
> 
> > > Any suggestions for making Slats' ideas more generic so they work
> > > on every system ?
> > 
> > Well I don't see how thrashing is necessarily connected to oom
> > at all.  You could have Gigs of swap not even touched and still
> > thrash.  
> 
> OOM leads to thrashing, however.
> 
> If we run out of memory and swap, all we can evict are the
> filesystem-backed parts of memory, which includes mapped
> executables.  This is how OOM and thrashing are connected.

I agree.  I just said there wasn't necessarily a connection.

> What we'd like to see is have the OOM killer act before the
> system thrashes ... if only because this thrashing could mean
> we never actually reach OOM because everything grinds to a
> halt.

Seriously you could do this in user-space with a 16KB or so mlocked
binary.  If you can detected OOM before thrashing I don't have a
problem.  But acting before OOM hits can be a pain.  

Suppose you have a computation that has been running for a month.  You
failed to add enough swap for it to run comfortably, and you forgot to
write check-pointing code.  It starts thrashing, but eventually it
will complete in another week pushing the system to the edge of OOM
the whole time (It will only use another hour of cpu in that time).
The OOM killer is broken if it kills this application.

But assuming we have swap-cache reclaim going on.  The conditions for
OOM are fairly simple.  
- All-caches are shrunk to minimal.
- We have no swap-cache pages.
- We have no swap.
- We have no mmaped pages in core.
- We have no ram (except a very small portion reserved for the kernel).

> Thrashing when we still have swap free is an entirely different
> matter, which I want to solve with load control code. That is,
> when the load gets too high, we temporarily suspend processes
> to bring the load down to more acceptable levels.

That's not bad but when it starts coming to policy, the policy
decisions are much more safely made in user space rather than the
kernel.  And we just allow the kernel to completely swap-out suspended
processes. 

Hmm. The more I look at this the more I keep thinking we should have a
process management daemon, enforcing some of these interesting
policies.  This would have to be small so it could be mlocked, and it
should take care of the following tasks. 

- Suspending processes in a high load/thrashing situation
- Creating swap files when we approach oom.
- Killing processes when oom is close and we can't add swap.

But since I can kill the daemon I don't have to use it.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
