Date: Fri, 8 Sep 2000 19:58:27 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Multiqueue VM Patch OK?  Does page-aging really work?
In-Reply-To: <39B95B5D.F8BD7B51@ucla.edu>
Message-ID: <Pine.LNX.4.21.0009081937020.1206-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Sep 2000, Benjamin Redelings I wrote:

> 	Problem #1: 
> 	Simply untarring a large file (e.g. linux-2.4.0-test7.tar) evicts most
> of the working set.  Example: I was running a few programs, including
> netscape, with little swap in use.  Then I untarred a linux source tree,
> and lo and behold, look at this!  44Mb swap!
> 
> Now I have __44Mb__ of swap??  Interestingly there is about 41Mb
> cached. One question I guess that needs to be asked is: is this
> cached data "dirty data" in the newly created "linux/" tree , or
> is it "clean data" from "linux.tar"?

Indeed, this is something which still has to be fixed.
You have to keep in mind that the new VM has received
about 5 days of performance tweaking right now and has
only received very limited testing. Most of the time
working on the new VM has been spent tracking down the
(now fixed) SMP bug...

> Maybe the problem is that dirty data is given preference over
> other data, and tyrannically takes over the cache.

Please try to understand the code before saying something
like this.

We age all active pages the same and the distiction is only
made between pages which are already "evicted" from the
active queue and moved to an inactive queue, so aging and
flushing definately do NOT interfere with each other.

> 	Problem #2:
> 	Programs that are basically unused, like (for example) an
> apache server that I am running on my home computer, no longer
> have their RSS go down to 4K.  Simply put, unused processes are
> not evicted, while data from used processes IS evicted.

This is not a problem but only looks like one. We only evict
pages which are not in active use anywhere, but keep shared
pages from glibc in memory (and mapped) when they are in
active use in other processes.

> 	Conclusion:
> 	1. Aren't BOTH these problems supposed to be solved by page aging?
> Then, shouldn't the multiqueue-patched kernel do BETTER than test8? 
> Apparently page-aging is not quite doing its job.  Why?

The one problem you saw is indeed in need of some tuning
and I'm working on it right now. One of the things which
would help identifying all the problems (so we can get
them fixed faster) would be having a larger test base..

> 	2. With the drop_behind stuff, I'm sure the kernel will perform better,
> at least with problem #1, to some extent.  However, even if the
> drop_behind stuff is moved to the VMA level, I still think this is a
> "special case hack".  I am not trying to be overly negative or critical
> - it is just that the NEED for drop_behind this indicates that page
> aging (the general solution) is not working.  Or am I missing something?

While page aging can be used to make the distinction between
pages which have been used once and pages which are being
used all the time, every use-once page puts a little bit of
"pressure" on the working set and it is still possible to
completely overwhelm (and evict) the working set by doing
very fast streaming IO.

Drop-behind is a way to detect the difference between pages
which are used once and pages which are used more often, while
at the same time not putting the pages we just read ahead in
jeopardy of being evicted before they are being put to use.

> 	In any case, what I am not missing is the fact that the
> multi-queue patch is failing to reform the VM system in some of
> its most important aspects.  I don't see how it could go into
> 2.4.0 in its current state.

Define "most important". You only gave me one thing
which still needs to be tweaked a bit and an optical
illusion with no memory use in reality.

Things like interactive latency and speed increase
for workloads which exhibit locality of reference
(say, big compiles) are important as well...

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
