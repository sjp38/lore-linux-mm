From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH -mm] mm: more likely reclaim MADV_SEQUENTIAL mappings
Date: Mon, 21 Jul 2008 15:49:00 +1000
References: <87y73x4w6y.fsf@saeurebad.de> <2f11576a0807201709q45aeec3cvb99b0049421245ae@mail.gmail.com> <20080720184843.9f7b48e9.akpm@linux-foundation.org>
In-Reply-To: <20080720184843.9f7b48e9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807211549.00770.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@saeurebad.de>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 21 July 2008 11:48, Andrew Morton wrote:
> On Mon, 21 Jul 2008 09:09:26 +0900 "KOSAKI Motohiro" 
<kosaki.motohiro@jp.fujitsu.com> wrote:
> > Hi Johannes,
> >
> > > File pages accessed only once through sequential-read mappings between
> > > fault and scan time are perfect candidates for reclaim.
> > >
> > > This patch makes page_referenced() ignore these singular references and
> > > the pages stay on the inactive list where they likely fall victim to
> > > the next reclaim phase.
> > >
> > > Already activated pages are still treated normally.  If they were
> > > accessed multiple times and therefor promoted to the active list, we
> > > probably want to keep them.
> > >
> > > Benchmarks show that big (relative to the system's memory)
> > > MADV_SEQUENTIAL mappings read sequentially cause much less kernel
> > > activity.  Especially less LRU moving-around because we never activate
> > > read-once pages in the first place just to demote them again.
> > >
> > > And leaving these perfect reclaim candidates on the inactive list makes
> > > it more likely for the real working set to survive the next reclaim
> > > scan.
> >
> > looks good to me.
> > Actually, I made similar patch half year ago.
> >
> > in my experience,
> >   - page_referenced_one is performance critical point.
> >     you should test some benchmark.
> >   - its patch improved mmaped-copy performance about 5%.
> >     (Of cource, you should test in current -mm. MM code was changed
> > widely)
> >
> > So, I'm looking for your test result :)
>
> The change seems logical and I queued it for 2.6.28.
>
> But yes, testing for what-does-this-improve is good and useful, but so
> is testing for what-does-this-worsen.  How do we do that in this case?

It's OK, but as always I worry about adding "cool new bells and
whistles" to make already-bad code work a bit faster. It slows
things down. A mispredicted branch btw is about as costly as an
atomic operation.

It is already bad because: if you are doing a big streaming copy
which you know is going to blow the cache and not be used again,
then you should be unmapping behind you as you go. If you do not
do this, then page reclaim has to do the rmap walk, page table
walk, and then the (unbatched, likely IPI delivered) TLB shootdown
for every page. Not to mention churning through the LRU and
chucking other things out just to find these pages.

So what you actually should do is use direct IO, or do page
unmappings and fadvise thingies to throw out the cache.

Adding code and branches to speed up by 5% an already terribly
suboptimal microbenchmark is not very good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
