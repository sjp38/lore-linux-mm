Date: Mon, 21 Jul 2008 23:04:05 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm] mm: more likely reclaim MADV_SEQUENTIAL mappings
Message-ID: <20080721230405.6cfde9bd@bree.surriel.com>
In-Reply-To: <200807221254.28473.nickpiggin@yahoo.com.au>
References: <87y73x4w6y.fsf@saeurebad.de>
	<200807221202.27169.nickpiggin@yahoo.com.au>
	<20080721223609.70e93725@bree.surriel.com>
	<200807221254.28473.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@saeurebad.de>, Peter Zijlstra <peterz@infradead.org>, Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Jul 2008 12:54:28 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> On Tuesday 22 July 2008 12:36, Rik van Riel wrote:
> > On Tue, 22 Jul 2008 12:02:26 +1000
> >
> > Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > > I don't actually care what the man page or posix says if it is obviously
> > > silly behaviour. If you want to dispute the technical points of my post,
> > > that would be helpful.
> >
> > Application writers read the man page and expect MADV_SEQUENTIAL
> > to do roughly what the name and description imply.
> >
> > If you think that the kernel should not bother implementing
> > what the application writers expect, and the application writers
> > should implement special drop-behind magic for Linux, your
> > expectations may not be entirely realistic.
> 
> The simple fact is that if you already have the knowledge and custom
> code for sequentially accessed mappings, then if you know the pages
> are not going to be used, there is a *far* better way to do it by
> unmapping them than the kernel will ever be able to do itself.

Applications are not developed just for Linux.

Application writers expect MADV_SEQUENTIAL to behave
a certain way and this 5 line patch implements that.

> Also, it would be perfectly valid to want a sequentially accessed
> mapping but not want to drop the pages early.

That is exactly what Johannes' patch does.  All it does is
change the behaviour of pages that have already reached the
end of the LRU lists.

It does not do any kind of early drop-behind or other strange
magic.

> > > Consider this: if the app already has dedicated knowledge and
> > > syscalls to know about this big sequential copy, then it should
> > > go about doing it the *right* way and really get performance
> > > improvement. Automatic unmap-behind even if it was perfect still
> > > needs to scan LRU lists to reclaim.
> >
> > Doing nothing _also_ ends up with the kernel scanning the
> > LRU lists, once memory fills up.
> 
> But we are not doing nothing because we already know and have coded
> for the fact that the mapping will be accessed once, sequentially.
> Now that we have gone this far, we should actually do it properly and
> 1. unmap after use, 2. POSIX_FADV_DONTNEED after use. This will give
> you much better performance and cache behaviour than any automatic
> detection scheme, and it doesn't introduce any regressions for existing
> code.

If you run just one instance of the application!

Think about something like an ftp server or a media server,
where you want to cache the data that is served up many
times, while evicting the data that got served just once.

The kernel has much better knowledge of what the aggregate
of all processes in the system are doing than any individual
process has.

> > Scanning the LRU lists is a given.
> 
> It is not.

Regardless of whether or not the application unmaps the pages
by itself, the pages will still be on the LRU lists.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
