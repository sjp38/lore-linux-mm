Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA30174
	for <linux-mm@kvack.org>; Sat, 6 Feb 1999 16:08:26 -0500
Date: Sat, 6 Feb 1999 21:08:03 GMT
Message-Id: <199902062108.VAA05084@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [patch] kpiod fixes and improvements
In-Reply-To: <Pine.LNX.3.96.990206165047.209A-100000@laser.bogus>
References: <Pine.LNX.3.96.990206165047.209A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 6 Feb 1999 17:24:30 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

> Hi Stephen.
> I applyed 2.2.2-pre2 and I seen your kpiod. I tried it and it was working
> bad (as anticipated by your email ;).

> The main problem is that you forget to set PF_MEMALLOC in kpiod, so it was
> recursing and was making pio request to itself and was stalling completly
> in try_to_free_pages and shrink_mmap(). 

shrink_mmap() should never be able to call kpiod.  The source also
includes this commented fragment:

static inline void make_pio_request(struct file *file,
				    unsigned long offset,
				    unsigned long page)
{
	struct pio_request *p;

	atomic_inc(&mem_map[MAP_NR(page)].count);

	/* 
	 * We need to allocate without causing any recursive IO in the
	 * current thread's context.  We might currently be swapping out
	 * as a result of an allocation made while holding a critical
	 * filesystem lock.  To avoid deadlock, we *MUST* not reenter
	 * the filesystem in this thread.
	 *
	 * We can wait for kswapd to free memory, or we can try to free
	 * pages without actually performing further IO, without fear of
	 * deadlock.  --sct
	 */

This applies to swapouts made by kpiod itself, and that is quite
deliberate.  If, in the process of performing its IO, kpiod calls
try_to_free_page and ends up back in filemap_write_page, the result will
just be another pio requests added to the queue: there will be _no_
recursive IO, and no recursive entering of the kpiod loop.

> At least that was happening with my VM (never tried clean 2.2.2-pre2,
> but it should make no differences).

Could you please try?  The design of kpiod already takes that recursion
into account and _does_ avoid it.

> Fixed this bug kpiod was working rasonable well but the number of pio
> request had too high numbers.

We regularly have 5000 or more dirty buffers on the locked queue
awaiting IO when doing intensive sequential writes() to a file.  I don't
think that the pio request queue is even remotely significant from this
point of view!

> So I've changed make_pio_request() to do a schedule_yield() to allow kpiod
> to run in the meantime. 

That will just end up forcing huge numbers of extra, unnecessary context
switches, reducing performance further.  ...

> [patch deleted]

Ah, so the sched_yield is keyed on a maximum pio request size.  Fine, I
can live with that, and I'll assemble the patch agains 2.2.2-pre2 for
Linus.

However, I really would appreciate it if you could double-check your
concerns about the recursive behaviour of kpiod.  That should be
completely impossible due to the kpiod design, so any problems there
must be due to some other interaction between the vm components.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
