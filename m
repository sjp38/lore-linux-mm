Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA00384
	for <linux-mm@kvack.org>; Sat, 6 Feb 1999 22:08:42 -0500
Date: Sun, 7 Feb 1999 03:43:10 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] kpiod fixes and improvements
In-Reply-To: <199902062108.VAA05084@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.990207031823.505C-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 6 Feb 1999, Stephen C. Tweedie wrote:

>Hi,
>
>On Sat, 6 Feb 1999 17:24:30 +0100 (CET), Andrea Arcangeli
><andrea@e-mind.com> said:
>
>> Hi Stephen.
>> I applyed 2.2.2-pre2 and I seen your kpiod. I tried it and it was working
>> bad (as anticipated by your email ;).
>
>> The main problem is that you forget to set PF_MEMALLOC in kpiod, so it was
>> recursing and was making pio request to itself and was stalling completly

My "stalling completly" was seen from a performance point of view. kpiod
was used to stall for some seconds in try_to_free_pages(). Then some I/O
for a msec, then stall again for some seconds.

>> in try_to_free_pages and shrink_mmap(). 
>
>shrink_mmap() should never be able to call kpiod.  The source also
>includes this commented fragment:

It's an English problem, excuse me. I mean that the point of kpiod is to
sync to disk the pages and to _decrease_ the kpiod queue of request. But
since it was calling try_to_free_pages() it was stalling for a _long_ time
in shrink_mmap() and so was doing a very little I/O and was not decreasing
the size of the pio_request_queue. The recursion I mean about is that I
though that kpiod could add request to itself instead of only flush to
disk its request queue. If kpiod increase its request queue instead of
flushing it to disk it's a major problem according to me. Maybe that was
not happening because filemap_write_page() was allocing only GFP_BUFFER
memory though (I realized it now ;). But the
shrink_mmap()/try_to_swapout() wasted time is a big issue here.

>This applies to swapouts made by kpiod itself, and that is quite
>deliberate.  If, in the process of performing its IO, kpiod calls
>try_to_free_page and ends up back in filemap_write_page, the result will
>just be another pio requests added to the queue: there will be _no_
>recursive IO, and no recursive entering of the kpiod loop.

Yes yes, _no_ deadlock issues at all! No fs recursion! Excuse me for the
english mistake.

>> At least that was happening with my VM (never tried clean 2.2.2-pre2,
>> but it should make no differences).
>
>Could you please try?  The design of kpiod already takes that recursion

Ok, I can try of course (too late now, but I can do that tomorrow).

>into account and _does_ avoid it.

Yes yes, there's no problem at all about fs recursion in kpiod.

>That will just end up forcing huge numbers of extra, unnecessary context
>switches, reducing performance further.  ...

A context switch is zero compared with the other operation we are doing at
that time. Having a constant I/O traffic is a more important thing for
performances than avoiding some context switch accoding to me.

>Ah, so the sched_yield is keyed on a maximum pio request size.  Fine, I

Yes, the point is that if you have enough pages to do on I/O it make sense
to me to allow kpiod to run. It improved global performance here. The
reason is that it reduced the high peak of request queue (and when you
have an high peak you are likely to have passed too much time in
shrink_mmap() and try_to_swap_out()). 

>can live with that, and I'll assemble the patch agains 2.2.2-pre2 for
>Linus.

Ok. The really really important thing here is the PF_MEMALLOC otherwise
kpiod was passing the majority of its time in shrink_mmap() and
try_to_swapout() instead of in filemap_write_page().

>However, I really would appreciate it if you could double-check your
>concerns about the recursive behaviour of kpiod.  That should be

There's no fs recursion at all. Excuse me, I should have no used the word
`recursion` in this case.

>completely impossible due to the kpiod design, so any problems there
>must be due to some other interaction between the vm components.

Infact, everything is ok here.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
