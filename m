Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EA29B6B01F7
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 04:46:40 -0400 (EDT)
Subject: Re: vmalloc performance
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <20100416061226.GJ5683@laptop>
References: <1271089672.7196.63.camel@localhost.localdomain>
	 <1271249354.7196.66.camel@localhost.localdomain>
	 <m2g28c262361004140813j5d70a80fy1882d01436d136a6@mail.gmail.com>
	 <1271262948.2233.14.camel@barrios-desktop>
	 <1271320388.2537.30.camel@localhost>  <20100416061226.GJ5683@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 16 Apr 2010 09:50:46 +0100
Message-ID: <1271407846.2548.31.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 2010-04-16 at 16:12 +1000, Nick Piggin wrote:
> On Thu, Apr 15, 2010 at 09:33:08AM +0100, Steven Whitehouse wrote:
> > Hi,
> > 
> > On Thu, 2010-04-15 at 01:35 +0900, Minchan Kim wrote:
> > > On Thu, 2010-04-15 at 00:13 +0900, Minchan Kim wrote:
> > > > On Wed, Apr 14, 2010 at 9:49 PM, Steven Whitehouse <swhiteho@redhat.com> wrote:
> > > > >> When this module is run on my x86_64, 8 core, 12 Gb machine, then on an
> > > > >> otherwise idle system I get the following results:
> > > > >>
> > > > >> vmalloc took 148798983 us
> > > > >> vmalloc took 151664529 us
> > > > >> vmalloc took 152416398 us
> > > > >> vmalloc took 151837733 us
> > > > >>
> > > > >> After applying the two line patch (see the same bz) which disabled the
> > > > >> delayed removal of the structures, which appears to be intended to
> > > > >> improve performance in the smp case by reducing TLB flushes across cpus,
> > > > >> I get the following results:
> > > > >>
> > > > >> vmalloc took 15363634 us
> > > > >> vmalloc took 15358026 us
> > > > >> vmalloc took 15240955 us
> > > > >> vmalloc took 15402302 us
> > > 
> > > 
> > > > >>
> > > > >> So thats a speed up of around 10x, which isn't too bad. The question is
> > > > >> whether it is possible to come to a compromise where it is possible to
> > > > >> retain the benefits of the delayed TLB flushing code, but reduce the
> > > > >> overhead for other users. My two line patch basically disables the delay
> > > > >> by forcing a removal on each and every vfree.
> > > > >>
> > > > >> What is the correct way to fix this I wonder?
> > > > >>
> > > > >> Steve.
> > > > >>
> > > 
> > > In my case(2 core, mem 2G system), 50300661 vs 11569357. 
> > > It improves 4 times. 
> > > 
> > Looking at the code, it seems that the limit, against which my patch
> > removes a test, scales according to the number of cpu cores. So with
> > more cores, I'd expect the difference to be greater. I have a feeling
> > that the original reporter had a greater number than the 8 of my test
> > machine.
> > 
> > > It would result from larger number of lazy_max_pages.
> > > It would prevent many vmap_area freed.
> > > So alloc_vmap_area takes long time to find new vmap_area. (ie, lookup
> > > rbtree)
> > > 
> > > How about calling purge_vmap_area_lazy at the middle of loop in
> > > alloc_vmap_area if rbtree lookup were long?
> > > 
> > That may be a good solution - I'm happy to test any patches but my worry
> > is that any change here might result in a regression in whatever
> > workload the lazy purge code was originally designed to improve. Is
> > there any way to test that I wonder?
> 
> Ah this is interesting. What we could do is have a "free area cache"
> like the user virtual memory allocator has, which basically avoids
> restarting the search from scratch.
> 
> Or we could perhaps go one better and do a more sophisticated free space
> allocator.
> 
> Bigger systems will indeed get hurt by increasing flushes so I'd prefer
> to avoid that. But that's not a good justification for a slowdown for
> small systems. What good is having cake if you can't also eat it? :)
> 
I'm all for cake, particularly if its lemon cake :-)

> 
> > > BTW, Steve. Is is real issue or some test?
> > > I doubt such vmalloc bomb workload is real. 
> > 
> > Well the answer is both yes and no :-) So this is how I came across the
> > issue. I received a report that GFS2 performance had regressed in recent
> > kernels in relation to a test which basically fires lots of requests at
> > it via NFS. The reporter of this problem gave me two bits of
> > information: firstly that by eliminating all readdir calls from the
> > test, the regression is never seen and secondly that oprofile showed
> > that two functions related to vmalloc (rb_next, find_vmap_area,
> > alloc_vmap_area in that order) were taking between them about 60% of the
> > total cpu time.
> 
> Thanks for tracking this down. I didn't realize GFS2 used vmalloc
> extensively. How large are typical vmalloc requests here, can you
> tell me? There is a per-cpu virtual memory allocator that is more
> scalable than the global one, and would help avoid these problems
> too.
> 
> XFS is using it at the moment, but we are looking for some more
> users of the API so as to get more testing coverage. I was
> considering moving vmalloc over to use it (vm_map_ram).
> 
> It's still probably a good idea to improve the global allocator
> regression first, but that might get you even more performance.
> 
> Thanks,
> Nick
> 

Well, I wouldn't say extensively... its used just once in readdir. Even
then we only use it for larger directories. We use it for two things,
basically as a temporary buffer to record pointers to all the "leaf
blocks" in one hash chain, and also as a temporary buffer to record
pointers to all the directory entries in the same hash chain. The only
reason that its used to keep track of the pointers to the leaf blocks
themselves is simply that it was easier than having two separate
allocations.

The reason that we need a list of pointers to hash entries is so that we
can feed the resulting buffer to sort() in order to put the entries into
hash order. Sorting into hash order isn't really the optimal way to
return the entries in readdir() but due to the slightly odd way in which
directories expand as entries are added, it is the only ordering which
allows us to be certain of not listing entries twice or missing entries
if insertions are made by one process while another process is making
successive calls to readdir().

The per-cpu virtual memory allocator though, sounds like a better fit
for GFS2's needs here, so we should look into using that in future I
think.

As for the size of the allocations, that depends a entirely on the
directory size. It could be anything from a single page to a couple of
dozen or more.

For the test which the original reporter was running, I suspect that it
would be multiple pages, but probably less than 10.

If a readdir spans multiple hash chains, then its possible that there
will be two or more calls to vmalloc/vfree per readdir. However since
readdir calls tend to use buffers based on the inode's optimal I/O size,
its pretty unlikely that this will happen very often, and even then its
only likely to span two hash chains at most.

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
