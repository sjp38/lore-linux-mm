From: Mark_H_Johnson.RTS@raytheon.com
Message-ID: <852568CC.004F0BB1.00@raylex-gh01.eo.ray.com>
Date: Tue, 25 Apr 2000 09:27:57 -0500
Subject: Re: pressuring dirty pages (2.3.99-pre6)
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederman@uswest.net>
Cc: linux-mm@kvack.org, riel@nl.linux.org, sct@redhat.com
List-ID: <linux-mm.kvack.org>


Re: "RSS limits"

It would be great to have a dynamic max limit. However I can see a lot of
complexity in doing so. May I make a few suggestions.
 - take a few moments to model the system operation under load. If the model
says RSS limits would help, by all means lets do it. If not, fix what we have.
If RSS limits are what we need, then
 - implement the RSS limit using the current mechanism [e.g., ulimit]
 - use a simple page removal algorithm to start with [e.g.,"oldest page first"
or "address space order"]. The only caution I might add on this is to check that
the page you are removing isn't the one w/ the instruction you are executing
[else you page fault again on returning to the process].
 - get measurements under load to validate the model and determine if the
solution is "good enough"
Then add the bells & whistles once the basic capability is proven.

Yes, it would be nice to remove the "least recently used" page - however, for
many applications this is quite similar to "oldest page". If I remember from a
DECUS meeting (talk about VMS's virtual memory system), they saw perhaps 5-10%
improvement using LRU with a lot of extra overhead in the kernel. [you have to
remember that taking the "wrong page" out of the process will result in a low
cost page fault - that page didn't actually go into the swap area]

Yes, a dynamic max limit would be good. But even with a highly dynamic load on
the system [cycles of a burst of activity, then a quiet period], for this kind
of load, small RSS sizes may also be "good enough". You can't tell w/o a model
of system performance or real measurements.

If we get to the point of implementing a dynamic RSS limit, let's make sure it
gets done with the right information and at the "right time". I suggest it not
be done at page fault time - give it to a process like kswapd where you can
review page fault rates and memory sizes and make a global adjustment.
--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>


|--------+----------------------->
|        |          ebiederman@us|
|        |          west.net     |
|        |          (Eric W.     |
|        |          Biederman)   |
|        |                       |
|        |          04/25/00     |
|        |          08:58 AM     |
|        |                       |
|--------+----------------------->
  >----------------------------------------------------------------------------|
  |                                                                            |
  |       To:     riel@nl.linux.org                                            |
  |       cc:     "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org,   |
  |       (bcc: Mark H Johnson/RTS/Raytheon/US)                                |
  |       Subject:     Re: pressuring dirty pages (2.3.99-pre6)                |
  >----------------------------------------------------------------------------|



Rik van Riel <riel@conectiva.com.br> writes:

> On Mon, 24 Apr 2000, Stephen C. Tweedie wrote:
> > On Mon, Apr 24, 2000 at 04:54:38PM -0300, Rik van Riel wrote:
> > >
> > > I've been trying to fix the VM balance for a week or so now,
> > > and things are mostly fixed except for one situation.
> > >
> > > If there is a *heavy* write going on and the data is in the
> > > page cache only .. ie. no buffer heads available, then the
> > > page cache will grow almost without bounds and kswapd and
> > > the rest of the system will basically spin in shrink_mmap()...
> >
> > shrink_mmap is the problem then -- it should be giving up sooner
> > and letting try_to_swap_out() deal with the pages.  mmap()ed
> > dirty pages can only be freed through swapper activity, not via
> > shrink_mmap().
>
> That will not work. The problem isn't that kswapd eats cpu,
> but the problem is that the dirty pages completely dominate
> physical memory.
>
> I've tried the "giving up earlier" option in shrink_mmap(),
> but that leads to memory filling up just as badly and giving
> us the same kind of trouble.
>
> I guess what we want is the kind of callback that we do in
> the direction of the buffer cache, using something like the
> bdflush wakeup call done in try_to_free_buffers() ...
>
> Maybe a "special" return value from shrink_mmap() telling
> do_try_to_free_pages() to run swap_out() unconditionally
> after this succesful shrink_mmap() call?  Maybe even with
> severity levels?
>
> Eg. more calls to swap_out() if we encountered a lot of
> dirty pages in shrink_mmap() ???

I suspect the simplest thing we could do would be to actually implement
a RSS limit per struct mm.  Roughly in handle_pte_fault if the page isn't
present and we are at our rss limit call swap_out_mm, until we are
below the limit.

This won't hurt much in the uncontended case, because the page
cache will still keep everything anyway, some dirty pages
will just get buffer_heads, and bdflush might clean those pages.

In the contended case, it removes some of the burden from swap_out,
and it should give shrink_mmap some pages to work with...

How we can approach the ideal of dynamically managed max RSS
sizes is another question...

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
