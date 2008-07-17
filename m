From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: madvise(2) MADV_SEQUENTIAL behavior
Date: Thu, 17 Jul 2008 16:14:29 +1000
References: <1216163022.3443.156.camel@zenigma> <487E628A.3050207@redhat.com> <1216252910.3443.247.camel@zenigma>
In-Reply-To: <1216252910.3443.247.camel@zenigma>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807171614.29594.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Rannaud <eric.rannaud@gmail.com>
Cc: Chris Snook <csnook@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thursday 17 July 2008 10:01, Eric Rannaud wrote:
> On Wed, 2008-07-16 at 17:05 -0400, Chris Snook wrote:
> > Rik van Riel wrote:
> > > I believe that for mmap MADV_SEQUENTIAL, we will have to do
> > > an unmap-behind from the fault path.  Not every time, but
> > > maybe once per megabyte, unmapping the megabyte behind us.
> >
> > Wouldn't it just be easier to not move pages to the active list when
> > they're referenced via an MADV_SEQUENTIAL mapping?  If we keep them on
> > the inactive list, they'll be candidates for reclaiming, but they'll
> > still be in pagecache when another task scans through, as long as we're
> > not under memory pressure.
>
> This approach, instead of invalidating the pages right away would
> provide a middle ground: a way to tell the kernel "these pages are not
> too important".
>
> Whereas if MADV_SEQUENTIAL just invalidates the pages once per megabyte
> (say), then it's only doing what is already possible using MADV_DONTNEED
> ("drop this pages now"). It would automate the process, but it would not
> provide a more subtle hint, which could be quite useful.
>
> As I see it, there are two basic concepts here:
> - no_reuse (like FADV_NOREUSE)
> - more_ra (more readahead)
> (DONTNEED being another different concept)
>
> Then:
> MADV_SEQUENTIAL = more_ra | no_reuse
> FADV_SEQUENTIAL = more_ra | no_reuse
> FADV_NOREUSE = no_reuse
>
> Right now, only the 'more_ra' part is implemented. 'no_reuse' could be
> implemented as Chris suggests.
>
> It looks like the disagreement a year ago around Peter's approach was
> mostly around the question of whether using read ahead as a heuristic
> for "drop behind" was safe for all workloads.
>
> Would it be less controversial to remove the heuristic (ra->size ==
> ra->ra_pages), and to do something only if the user asked for
> _SEQUENTIAL or _NOREUSE?

It's far far easier to tell the kernel "I am no longer using these
pages" than to say "I will not use these pages sometime in the future
after I have used them". The former can be done synchronously and with
a much higher efficiency than it takes to scan through LRU lists to
figure this out.

We should be using the SEQUENTIAL to open up readahead windows, and ask
userspace applications to use DONTNEED to drop if it is important. IMO.


> It might encourage user space applications to start using
> FADV_SEQUENTIAL or FADV_NOREUSE more often (as it would become
> worthwhile to do so), and if they do (especially cron jobs), the problem
> of the slow desktop in the morning would progressively solve itself.

The slow desktop in the morning should not happen even without such a
call, because the kernel should not throw out frequently used data (even
if it is not quite so recent) in favour of streaming data.

OK, I figure it doesn't do such a good job now, which is sad, but making
all apps micromanage the pagecache to get reasonable performance on a
2GB+ desktop system is even more sad ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
