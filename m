Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6FA736B01E3
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 04:29:02 -0400 (EDT)
Subject: Re: vmalloc performance
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <1271262948.2233.14.camel@barrios-desktop>
References: <1271089672.7196.63.camel@localhost.localdomain>
	 <1271249354.7196.66.camel@localhost.localdomain>
	 <m2g28c262361004140813j5d70a80fy1882d01436d136a6@mail.gmail.com>
	 <1271262948.2233.14.camel@barrios-desktop>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 15 Apr 2010 09:33:08 +0100
Message-ID: <1271320388.2537.30.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 2010-04-15 at 01:35 +0900, Minchan Kim wrote:
> On Thu, 2010-04-15 at 00:13 +0900, Minchan Kim wrote:
> > Cced Nick.
> > He's Mr. Vmalloc.
> > 
> > On Wed, Apr 14, 2010 at 9:49 PM, Steven Whitehouse <swhiteho@redhat.com> wrote:
> > >
> > > Since this didn't attract much interest the first time around, and at
> > > the risk of appearing to be talking to myself, here is the patch from
> > > the bugzilla to better illustrate the issue:
> > >
> > >
> > > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > > index ae00746..63c8178 100644
> > > --- a/mm/vmalloc.c
> > > +++ b/mm/vmalloc.c
> > > @@ -605,8 +605,7 @@ static void free_unmap_vmap_area_noflush(struct
> > > vmap_area *va)
> > >  {
> > >        va->flags |= VM_LAZY_FREE;
> > >        atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
> > > -       if (unlikely(atomic_read(&vmap_lazy_nr) > lazy_max_pages()))
> > > -               try_purge_vmap_area_lazy();
> > > +       try_purge_vmap_area_lazy();
> > >  }
> > >
> > >  /*
> > >
> > >
> > > Steve.
> > >
> > > On Mon, 2010-04-12 at 17:27 +0100, Steven Whitehouse wrote:
> > >> Hi,
> > >>
> > >> I've noticed that vmalloc seems to be rather slow. I wrote a test kernel
> > >> module to track down what was going wrong. The kernel module does one
> > >> million vmalloc/touch mem/vfree in a loop and prints out how long it
> > >> takes.
> > >>
> > >> The source of the test kernel module can be found as an attachment to
> > >> this bz: https://bugzilla.redhat.com/show_bug.cgi?id=581459
> > >>
> > >> When this module is run on my x86_64, 8 core, 12 Gb machine, then on an
> > >> otherwise idle system I get the following results:
> > >>
> > >> vmalloc took 148798983 us
> > >> vmalloc took 151664529 us
> > >> vmalloc took 152416398 us
> > >> vmalloc took 151837733 us
> > >>
> > >> After applying the two line patch (see the same bz) which disabled the
> > >> delayed removal of the structures, which appears to be intended to
> > >> improve performance in the smp case by reducing TLB flushes across cpus,
> > >> I get the following results:
> > >>
> > >> vmalloc took 15363634 us
> > >> vmalloc took 15358026 us
> > >> vmalloc took 15240955 us
> > >> vmalloc took 15402302 us
> 
> 
> > >>
> > >> So thats a speed up of around 10x, which isn't too bad. The question is
> > >> whether it is possible to come to a compromise where it is possible to
> > >> retain the benefits of the delayed TLB flushing code, but reduce the
> > >> overhead for other users. My two line patch basically disables the delay
> > >> by forcing a removal on each and every vfree.
> > >>
> > >> What is the correct way to fix this I wonder?
> > >>
> > >> Steve.
> > >>
> 
> In my case(2 core, mem 2G system), 50300661 vs 11569357. 
> It improves 4 times. 
> 
Looking at the code, it seems that the limit, against which my patch
removes a test, scales according to the number of cpu cores. So with
more cores, I'd expect the difference to be greater. I have a feeling
that the original reporter had a greater number than the 8 of my test
machine.

> It would result from larger number of lazy_max_pages.
> It would prevent many vmap_area freed.
> So alloc_vmap_area takes long time to find new vmap_area. (ie, lookup
> rbtree)
> 
> How about calling purge_vmap_area_lazy at the middle of loop in
> alloc_vmap_area if rbtree lookup were long?
> 
That may be a good solution - I'm happy to test any patches but my worry
is that any change here might result in a regression in whatever
workload the lazy purge code was originally designed to improve. Is
there any way to test that I wonder?

> BTW, Steve. Is is real issue or some test?
> I doubt such vmalloc bomb workload is real. 

Well the answer is both yes and no :-) So this is how I came across the
issue. I received a report that GFS2 performance had regressed in recent
kernels in relation to a test which basically fires lots of requests at
it via NFS. The reporter of this problem gave me two bits of
information: firstly that by eliminating all readdir calls from the
test, the regression is never seen and secondly that oprofile showed
that two functions related to vmalloc (rb_next, find_vmap_area,
alloc_vmap_area in that order) were taking between them about 60% of the
total cpu time.

Now between the two kernel versions being tested, probably not a single
line of GFS2 code for readdir has changed since that code has been
stable for a fair while now. So my attention turned to vmalloc, even
though it would be unusual for a filesystem to be limited by cpu, it did
seem odd that it was so high in the oprofile result. I should also
mention at this point that the backing device for the fs is a very high
performance disk array, so that increases the chances of cpu being a
limiting factor.

Anyway, having looked briefly at the vmalloc code, I spotted that there
was a cache of objects which might have an effect, so I wrote the test
kernel module in the bz to test the two line patch just to see what
effect it had.

Since I got a good speed up, I sent the patch to the reporter who was
able to get further on the NFS/GFS2 tests before running into the oops.
I hadn't spotted that there had been a fix for that bug in the mean time
though, so I'll get that applied. Thanks for pointing it out.

We'll try and get some more testing done in order to try and prove
whether the regression we are seeing in GFS2 readdir performance is
entirely due to this factor, or only partially. I think it does have a
measurable effect though, even if it is not the whole story,

Steve.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
