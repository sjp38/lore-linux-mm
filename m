Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 566836B01B2
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 05:02:16 -0400 (EDT)
Date: Thu, 1 Jul 2010 19:02:11 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: vmap area cache
Message-ID: <20100701090211.GI22976@laptop>
References: <20100531080757.GE9453@laptop>
 <20100602144905.aa613dec.akpm@linux-foundation.org>
 <20100603135533.GO6822@laptop>
 <1277470817.3158.386.camel@localhost.localdomain>
 <20100626083122.GE29809@laptop>
 <20100630162602.874ebd2a.akpm@linux-foundation.org>
 <1277974154.2477.3.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1277974154.2477.3.camel@localhost>
Sender: owner-linux-mm@kvack.org
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, "Barry J. Marson" <bmarson@redhat.com>, avi@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, Jul 01, 2010 at 09:49:14AM +0100, Steven Whitehouse wrote:
> Hi,
> 
> On Wed, 2010-06-30 at 16:26 -0700, Andrew Morton wrote:
> > On Sat, 26 Jun 2010 18:31:22 +1000
> > Nick Piggin <npiggin@suse.de> wrote:
> > 
> > > On Fri, Jun 25, 2010 at 02:00:17PM +0100, Steven Whitehouse wrote:
> > > > Hi,
> > > > 
> > > > Barry Marson has now tested your patch and it seems to work just fine.
> > > > Sorry for the delay,
> > > > 
> > > > Steve.
> > > 
> > > Hi Steve,
> > > 
> > > Thanks for that, do you mean that it has solved thee regression?
> > 
> > Nick, can we please have an updated changelog for this patch?  I didn't
> > even know it fixed a regression (what regression?).  Barry's tested-by:
> > would be nice too, along with any quantitative results from that.
> > 
> > Thanks.
> 
> Barry is running a benchmark test against GFS2 which simulates NFS
> activity on the filesystem. Without this patch, the GFS2 ->readdir()
> function (the only part of GFS2 which uses vmalloc) runs so slowly that
> the test does not complete. With the patch, the test runs the same speed
> as it did on earlier kernels.

It would have been due to the commit I referenced.

 
> I don't have an exact pointer to when the regression was introduced, but
> it was after RHEL5 branched.

OK the patch should be pretty fine to go into RHEL5, I'd think.

Interesting that it slowed down so much for you. I would say this is due
to a few differences between your testing and mine.

Firstly, I was using a 64 CPU machine, and hammering vmap flushing on
all CPUs. TLB broadcasting and flushing cost is going to be much much
higher because there is an O(n^2) effect (N CPUs worth of work, each
unit of work requires TLB flush to N CPUs). Interconnect cost would be
much higher too compared to your 2s8c machine. So the cost of searching
vmaps would be more hidden by the gains from avoiding flushing.

Secondly, you were testing with probably 4K vmallocs. Wheras I was using
64K vmallocs on a 16KB page size machine with XFS. So in your testing
there would be significantly more vmaps build up, by a factor of 10.

Your workload is similar to Avi's as well.

So in summary, I should have paid attention to the search complexity
aspect and designed cases specifically to test that aspect. Oh well...
thanks for the reporting and testing :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
