Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 13F176B0038
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 12:47:53 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id k19so6878258igc.1
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 09:47:52 -0800 (PST)
Date: Tue, 17 Dec 2013 11:47:59 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [RFC PATCH 0/3] Change how we determine when to hand out THPs
Message-ID: <20131217174759.GL18680@sgi.com>
References: <20131212180037.GA134240@sgi.com>
 <20131213214437.6fdbf7f2.akpm@linux-foundation.org>
 <20131216171214.GA15663@sgi.com>
 <CALCETrW9uGYzckWg3Wcsu-VV-vbXxUCr+Dv0kXqE5VMKopjn+A@mail.gmail.com>
 <20131217160455.GG18680@sgi.com>
 <CALCETrX_B0D+XyYD8P6mfS4uqty1vzYpOmR-0Mx-yee=wtyR8g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrX_B0D+XyYD8P6mfS4uqty1vzYpOmR-0Mx-yee=wtyR8g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, Dec 17, 2013 at 08:54:10AM -0800, Andy Lutomirski wrote:
> On Tue, Dec 17, 2013 at 8:04 AM, Alex Thorlton <athorlton@sgi.com> wrote:
> > On Mon, Dec 16, 2013 at 05:43:40PM -0800, Andy Lutomirski wrote:
> >> On Mon, Dec 16, 2013 at 9:12 AM, Alex Thorlton <athorlton@sgi.com> wrote:
> >> >> Please cc Andrea on this.
> >> >
> >> > I'm going to clean up a few small things for a v2 pretty soon, I'll be
> >> > sure to cc Andrea there.
> >> >
> >> >> > My proposed solution to the problem is to allow users to set a
> >> >> > threshold at which THPs will be handed out.  The idea here is that, when
> >> >> > a user faults in a page in an area where they would usually be handed a
> >> >> > THP, we pull 512 pages off the free list, as we would with a regular
> >> >> > THP, but we only fault in single pages from that chunk, until the user
> >> >> > has faulted in enough pages to pass the threshold we've set.  Once they
> >> >> > pass the threshold, we do the necessary work to turn our 512 page chunk
> >> >> > into a proper THP.  As it stands now, if the user tries to fault in
> >> >> > pages from different nodes, we completely give up on ever turning a
> >> >> > particular chunk into a THP, and just fault in the 4K pages as they're
> >> >> > requested.  We may want to make this tunable in the future (i.e. allow
> >> >> > them to fault in from only 2 different nodes).
> >> >>
> >> >> OK.  But all 512 pages reside on the same node, yes?  Whereas with thp
> >> >> disabled those 512 pages would have resided closer to the CPUs which
> >> >> instantiated them.
> >> >
> >> > As it stands right now, yes, since we're pulling a 512 page contiguous
> >> > chunk off the free list, everything from that chunk will reside on the
> >> > same node, but as I (stupidly) forgot to mention in my original e-mail,
> >> > one piece I have yet to add is the functionality to put the remaining
> >> > unfaulted pages from our chunk *back* on the free list after we give up
> >> > on handing out a THP.  Once this is in there, things will behave more
> >> > like they do when THP is turned completely off, i.e. pages will get
> >> > faulted in closer to the CPU that first referenced them once we give up
> >> > on handing out the THP.
> >>
> >> This sounds like it's almost the worst possible behavior wrt avoiding
> >> memory fragmentation.  If userspace mmaps a very large region and then
> >> starts accessing it randomly, it will allocate a bunch of contiguous
> >> 512-page regions, claim one page from each, and return the other 511
> >> pages to the free list.  Memory is now maximally fragmented from the
> >> point of view of future THP allocations.
> >
> > Maybe I'm missing the point here to some degree, but the way I think
> > about this is that if we trigger the behavior to return the pages to the
> > free list, we don't *want* future THP allocations in that range of
> > memory for the current process anyways.  So, having the memory be
> > fragmented from the point of view of future THP allocations isn't an
> > issue.
> >
> 
> Except that you're causing a problem for the whole system because one
> process is triggering the "hugepages aren't helpful" heuristic.

I do see where you're coming from here.  Do you have any good tests
that can cause this type of memory fragmentation that I might be able to
take a look at, to see how we might combat that issue in this case?
It seems like something that could occur anyways, but my patch would
create a situation where it could become a problem much more quickly.

Also, just a side note, I see this being more of a problem on a smaller
system, where swap is enabled.  However, on larger systems where swap is
turned off, I think that this scenario might be a bit tougher to hit.  I
understand that we don't want to hurt the average small system in favor
of large ones, but that's why we leave it as a tunable and leave it up
to the system administrator to decide whether or not this is appropriate
to enable.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
