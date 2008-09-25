Date: Thu, 25 Sep 2008 20:38:46 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: RFC: race between o_direct and fork (harder to fix with
	get_user_page_fast)
Message-ID: <20080925183846.GA6877@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>
List-ID: <linux-mm.kvack.org>

Hi Nick,

with Izik and Avi, we've been discussing on how to best make ksm work
with O_DIRECT. I don't think it's an immediate priority but eventually
we've to fix this as KVM is close to being able to dma from disk
directly into guest physical memory without intermediate copies.

Checking if pages have O_DIRECT (or similar other physical I/O) in
flight is fairly easy, comparing page count with page mapcount should
do the trick. The source of the problem is that this page count ==
page mapcount check should happen under some lock that blocks
get_user_pages and get_user_page_fast. If the page is already shared,
we only need to block the get_user_pages running on the 'mm' of the
'pte' that we're overwriting. So for get_user_pages it'd be enough to
do the check of page count == page mapcount under the PT lock.

1)
       PT lock
       if (page_count != page_mapcount)
       	  goto fail
       make pte readonly
       PT unlock

then in the final stage:

2)
     PT lock
     if (!pte_same)
     	goto fail
     change pte to point to ksm page
     PT unlock

If other tasks are starting in-flight O_DIRECT on the page we don't
care, those will have to copy-on-write it before starting the O_DIRECT
anyway, so there will be still no in-flight I/O on the physical page
we're working on. All we care about is that get_user_pages doesn't run
on our mm/PTlock between the page_count!=page_mapcount check and the
mark of the pte readonly. Otherwise it won't trigger the COW and it
should (for us to later notice it in pte_same!).

Now with get_user_pages_fast the above PT lock isn't enough anymore to
make it safe.

While thinking at get_user_pages_fast I figured another worse way
things can go wrong with ksm and o_direct: think a thread writing
constantly to the last 512bytes of a page, while another thread read
and writes to/from the first 512bytes of the page. We can lose
O_DIRECT reads, the very moment we mark any pte wrprotected. Then Avi
immediately pointed out this means also fork is affected by the same
bug that ksm would have.

So Avi just found a very longstanding bug in fork. Fork has the very
same problem of ksm in marking readonly ptes that could point to pages
that have O_DIRECT in flight.

So this isn't a KSM problem anymore. We've to fix this longstanding
bug in fork first. Then we'll think at KSM and we'll use the same
locking technique to make KSM safe against O_DIRECT too

The best I can think of, is to re-introduce of the brlock (possibly
after making it fair). We can't use RCU as far as I can tell. No idea
why brlock was removed perhaps somebody thought RCU was an equivalent
replacement? RCU/SRCU can't block anything, and we've to block the
get_user_page_fast in the critical section at point 1 to be
safe. There's a practical limit of how much things can be delayed, for
page faults (at least practically) they can't.

ksm

       br_write_lock()
       if (page_count != page_mapcount)
       	  goto fail
       make pte readonly
       br_write_unlock()

fork

	br_write_lock()
	if (page_count != page_mapcount)
	   copy_page()
	else
	   make pte readonly
	br_write_unlock()
       
get_user_page_fast

	br_read_lock()
	walk ptes out of order w/o mmap_sem		
	br_read_unlock()

Another way of course is to take the mmap_sem in read mode around the
out of order part of get_user_page_fast but that'd be invalidating the
'thread vs thread' smp scalability of get_user_page_fast.

If it was just for KSM I suggested we could fix it by sigstopping (or
getting out of the scheduler in some other more reliable mean) all
threads that shared the 'mm' that ksm was working on. That would take
care of the fast path of get_user_page_fast and the PT lock would take
care of the get_user_page_fast slow path. But this schedule technique
ala stop_machine surely isn't workable for fork() for performance
reasons.

Yet another way is as usual to use a page bitflag to serialize things
at the page level. That will prevent multiple O_DIRECT reads to the
same page simultaneously but it'll allow fork to wait IO completion
and avoid the copy_page(). Ages ago I always wanted to keep the
PG_lock for pages under O_DIRECT... We instead relied solely on page
pinning which has a few advantages but it makes things like fork more
complicated and harder to fix.

I'm very interested to know your ideas on how to best fix fork vs
o_direct!

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
