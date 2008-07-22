From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH -mm] mm: more likely reclaim MADV_SEQUENTIAL mappings
Date: Tue, 22 Jul 2008 13:49:28 +1000
References: <87y73x4w6y.fsf@saeurebad.de> <20080721230405.6cfde9bd@bree.surriel.com> <200807221343.40017.nickpiggin@yahoo.com.au>
In-Reply-To: <200807221343.40017.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807221349.28641.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@saeurebad.de>, Peter Zijlstra <peterz@infradead.org>, Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 22 July 2008 13:43, Nick Piggin wrote:
> On Tuesday 22 July 2008 13:04, Rik van Riel wrote:
> > On Tue, 22 Jul 2008 12:54:28 +1000

> > > But we are not doing nothing because we already know and have coded
> > > for the fact that the mapping will be accessed once, sequentially.
> > > Now that we have gone this far, we should actually do it properly and
> > > 1. unmap after use, 2. POSIX_FADV_DONTNEED after use. This will give
> > > you much better performance and cache behaviour than any automatic
> > > detection scheme, and it doesn't introduce any regressions for existing
> > > code.
> >
> > If you run just one instance of the application!
> >
> > Think about something like an ftp server or a media server,
> > where you want to cache the data that is served up many
> > times, while evicting the data that got served just once.
> >
> > The kernel has much better knowledge of what the aggregate
> > of all processes in the system are doing than any individual
> > process has.
>
> That's true, but this case isn't really very good anyway. The information
> goes away after you drop the mapping anyway. Or did you hope that the
> backup program or indexer keeps all those mappings open until all the pages
> have filtered through? Or maybe we can add yet more branches into the unmap
> path to test for this flag as well?
>
> I don't think it is a good idea to add random things just because they seem
> at first glance like a good idea.

BTW. in the backup of a busy fileserver or some case like that, I'd
bet that even using FADV_DONTNEED would be much faster than leaving
these mappings around to try to drop them due to the decreased churn
on the LRUs overall anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
