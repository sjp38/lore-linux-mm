Subject: Re: Interesting item came up while working on FreeBSD's pageout daemon
References: <Pine.LNX.4.21.0012211741410.1613-100000@duckman.distro.conectiva>
	<00122900094502.00966@gimli>
	<200012290624.eBT6O3s14135@apollo.backplane.com>
	<3A4C9D86.FCF5A8DB@innominate.de>
From: James Antill <james@and.org>
Content-Type: text/plain; charset=US-ASCII
Date: 29 Dec 2000 14:58:13 -0500
In-Reply-To: Daniel Phillips's message of "Fri, 29 Dec 2000 15:19:50 +0100"
Message-ID: <nnzohfc84q.fsf@code.and.org>
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@innominate.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Matthew Dillon wrote:
> >     The effect of this (and, more importantly, limiting the number of dirty
> >     pages one is willing to launder in the first pageout pass) is rather
> >     significant due to the big difference in cost in dealing with clean
> >     pages verses dirty pages.
> > 
> >     'cleaning' a clean page means simply throwing it away, which costs maybe
> >     a microsecond of cpu time and no I/O.  'cleaning' a dirty page requires
> >     flushing it to its backing store prior to throwing it away, which costs
> >     a significant bit of cpu and at least one write I/O.  One write I/O
> >     may not seem like a lot, but if the disk is already loaded down and the
> >     write I/O has to seek we are talking at least 5 milliseconds of disk
> >     time eaten by the operation.  Multiply this by the number of dirty pages
> >     being flushed and it can cost a huge and very noticeable portion of
> >     your disk bandwidth, verses zip for throwing away a clean page.
> 
> To estimate the cost of paging io you have to think in terms of the
> extra work you have to do because you don't have infinite memory.  In
> other words, you would have had to write those dirty pages anyway - this
> is an unavoidable cost.  You incur an avoidable cost when you reclaim a
> page that will be needed again sooner than some other candidate.  If the
> page was clean the cost is an extra read, if dirty it's a write plus a
> read.  Alternatively, the dirty page might be written again soon - if
> it's a partial page write the cost is an extra read and a write, if it's
> a full page the cost is just a write.  So it costs at most twice as much
> to guess wrong about a dirty vs clean page.  This difference is
> significant, but it's not as big as the 1 usec vs 5 msec you suggesed.

 As I understand it you can't just add the costs of the reads and
writes as 1 each. So given...

 Clean = 1r
 Dirty = 1w + 1r

...it's assumed that a 1w is >= than a 1r, but what are the exact
values ?
 It probably gets even more complex as if the dirty page is touched
between the write and the cleanup then it'll avoid the re-read
behavior and will appear faster (although it slowed the system down a
little doing it's write).

> If I'm right then making the dirty page go 3 times around the loop
> should result in worse performance vs 2 times.

 It's quite possible, but if there were 2 lists and the dirty pages
were laundered at 33% the rate of the clean pages would that be better
than 50%?

-- 
# James Antill -- james@and.org
:0:
* ^From: .*james@and.org
/dev/null
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
