Message-ID: <3A4D1A47.22DA65E8@innominate.de>
Date: Sat, 30 Dec 2000 00:12:07 +0100
From: Daniel Phillips <phillips@innominate.de>
MIME-Version: 1.0
Subject: Re: Interesting item came up while working on FreeBSD's pageout daemon
References: <Pine.LNX.4.21.0012211741410.1613-100000@duckman.distro.conectiva> 	<00122900094502.00966@gimli> 	<200012290624.eBT6O3s14135@apollo.backplane.com> 	<3A4C9D86.FCF5A8DB@innominate.de> <nnzohfc84q.fsf@code.and.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Antill <james@and.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

James Antill wrote:
> > To estimate the cost of paging io you have to think in terms of the
> > extra work you have to do because you don't have infinite memory.  In
> > other words, you would have had to write those dirty pages anyway - this
> > is an unavoidable cost.  You incur an avoidable cost when you reclaim a
> > page that will be needed again sooner than some other candidate.  If the
> > page was clean the cost is an extra read, if dirty it's a write plus a
> > read.  Alternatively, the dirty page might be written again soon - if
> > it's a partial page write the cost is an extra read and a write, if it's
> > a full page the cost is just a write.  So it costs at most twice as much
> > to guess wrong about a dirty vs clean page.  This difference is
> > significant, but it's not as big as the 1 usec vs 5 msec you suggesed.
> 
>  As I understand it you can't just add the costs of the reads and
> writes as 1 each. So given...
> 
>  Clean = 1r
>  Dirty = 1w + 1r
> 
> ...it's assumed that a 1w is >= than a 1r, but what are the exact
> values ?

By read and write I am talking about the necessary transfers to disk,
not the higher level file IO.  Transfers to and from disk are nearly
equal in cost.

>  It probably gets even more complex as if the dirty page is touched
> between the write and the cleanup then it'll avoid the re-read
> behavior and will appear faster (although it slowed the system down a
> little doing it's write).

Oh yes, it gets more complex.  I'm trying to nail down the main costs by
eliminating the constant factors.

> > If I'm right then making the dirty page go 3 times around the loop
> > should result in worse performance vs 2 times.
> 
>  It's quite possible, but if there were 2 lists and the dirty pages
> were laundered at 33% the rate of the clean pages would that be better
> than 50%?

Eh.  I don't know, I was hoping Matt would try it.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
