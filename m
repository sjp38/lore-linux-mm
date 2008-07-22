From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH -mm] mm: more likely reclaim MADV_SEQUENTIAL mappings
Date: Tue, 22 Jul 2008 12:54:28 +1000
References: <87y73x4w6y.fsf@saeurebad.de> <200807221202.27169.nickpiggin@yahoo.com.au> <20080721223609.70e93725@bree.surriel.com>
In-Reply-To: <20080721223609.70e93725@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807221254.28473.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@saeurebad.de>, Peter Zijlstra <peterz@infradead.org>, Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 22 July 2008 12:36, Rik van Riel wrote:
> On Tue, 22 Jul 2008 12:02:26 +1000
>
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > I don't actually care what the man page or posix says if it is obviously
> > silly behaviour. If you want to dispute the technical points of my post,
> > that would be helpful.
>
> Application writers read the man page and expect MADV_SEQUENTIAL
> to do roughly what the name and description imply.
>
> If you think that the kernel should not bother implementing
> what the application writers expect, and the application writers
> should implement special drop-behind magic for Linux, your
> expectations may not be entirely realistic.

The simple fact is that if you already have the knowledge and custom
code for sequentially accessed mappings, then if you know the pages
are not going to be used, there is a *far* better way to do it by
unmapping them than the kernel will ever be able to do itself.

Also, it would be perfectly valid to want a sequentially accessed
mapping but not want to drop the pages early.

What we should do is update the man page now rather than try adding
things to support it.


> > Consider this: if the app already has dedicated knowledge and
> > syscalls to know about this big sequential copy, then it should
> > go about doing it the *right* way and really get performance
> > improvement. Automatic unmap-behind even if it was perfect still
> > needs to scan LRU lists to reclaim.
>
> Doing nothing _also_ ends up with the kernel scanning the
> LRU lists, once memory fills up.

But we are not doing nothing because we already know and have coded
for the fact that the mapping will be accessed once, sequentially.
Now that we have gone this far, we should actually do it properly and
1. unmap after use, 2. POSIX_FADV_DONTNEED after use. This will give
you much better performance and cache behaviour than any automatic
detection scheme, and it doesn't introduce any regressions for existing
code.


> Scanning the LRU lists is a given.

It is not.


> All that the patch by Johannes does is make sure the kernel
> does the right thing when it runs into an MADV_SEQUENTIAL
> page on the inactive_file list: evict the page immediately,
> instead of having it pass through the active list and the
> inactive list again.
>
> This reduces the number of times that MADV_SEQUENTIAL pages
> get scanned from 3 to 1, while protecting the working set
> from MADV_SEQUENTIAL pages.

We should update the man page. And seeing as Linux had never preferred
to drop behind *before* now, it is crazy to add such a feature that
we will then have a much harder time to remove, given that it is
clearly suboptimal. Update the man page to sketch the *correct* way to
optimise this type of access.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
