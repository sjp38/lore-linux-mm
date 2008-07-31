Date: Thu, 31 Jul 2008 09:56:02 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch v3] splice: fix race with page invalidation
In-Reply-To: <20080731132953.GB1120@2ka.mipt.ru>
Message-ID: <alpine.LFD.1.10.0807310936120.3277@nehalem.linux-foundation.org>
References: <E1KOIYA-0002FG-Rg@pomaz-ex.szeredi.hu> <20080731001131.GA30900@shareable.org> <20080731004214.GA32207@shareable.org> <alpine.LFD.1.10.0807301746500.3277@nehalem.linux-foundation.org> <20080731061201.GA7156@shareable.org> <20080731102612.GA29766@2ka.mipt.ru>
 <20080731123350.GB16481@shareable.org> <20080731132953.GB1120@2ka.mipt.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Cc: Jamie Lokier <jamie@shareable.org>, Miklos Szeredi <miklos@szeredi.hu>, jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 31 Jul 2008, Evgeniy Polyakov wrote:
> 
> It depends... COW can DoS the system: consider attacker who sends a
> page, writes there, sends again and so on in lots of threads. Depending
> on link capacity eventually COW will eat the whole RAM.

Yes, COW is complex, and the complexity would be part of the cost. But the 
much bigger cost is the fact that COW is simply most costly than copying 
the data in the first place.

A _single_ page fault is usually much much more expensive than copying a 
page, especially if you can do the copy well wrt caches. For example, a 
very common case is that the data you're writing is already in the CPU 
caches.

In fact, even if you can avoid the fault, the cost of doing all the 
locking and looking up the pages for COW is likely already bigger than the 
memcpy. The memcpy() is a nice linear access which both the CPU and the 
memory controller can optimize and can get almost perfect CPU throughput 
for. In contrast, doing a COW implies a lot of random walking over 
multiple data structures. And _if_ it's all in cache, it's probably ok, 
but you're totally screwed if you need to send an IPI to another CPU to 
actually flush the TLB (to make the COW actually take effect!).

So yes, you can win by COW'ing, but it's rare, and it mainly happens in 
benchmarks.

For example, I had a trial patch long long ago (I think ten years by now) 
to do pipe transfers as copying pages around with COW. It was absolutely 
_beautiful_ in benchmarks. I could transfer gigabytes per second, and this 
was on something like a Pentium/MMX which had what, 7-10MB/s memcpy 
performance?

In other words, I don't dispute at all that COW schemes can perform really 
really well.

HOWEVER - the COW scheme actually performed _worse_ in any real world 
benchmark, including just compiling the kernel (we used to use -pipe to 
gcc to transfer data between cc/as).

The reason? The benchmark worked _really_ well, because what it did was 
basically to do a trivial microbenchmark that did

	for (;;) {
		write(fd, buffer, bufsize);
	}

and do you see something unrealistic there? Right: it never actually 
touched the buffer itself, so it would not ever actually trigger the COW 
case, and as a result, the memory got marked read-only on the first time, 
and it never ever took a fault, and in fact the TLB never ever needed to 
be flushed after the first one because the page was already marked 
read-only.

That's simply not _realistic_. It's hardly how any real load work.

> > > There was a linux aio_sendfile() too. Google still knows about its
> > > numbers, graphs and so on... :)
> > 
> > I vaguely remember it's performance didn't seem that good.
> 
> <q>
> Benchmark of the 100 1MB files transfer (files are in VFS already) using
> sync sendfile() against aio_sendfile_path() shows about 10MB/sec
> performance win (78 MB/s vs 66-72 MB/s over 1 Gb network, sendfile
> sending server is one-way AMD Athlong 64 3500+) for aio_sendfile_path().
> </q>
> 
> So, it was really better that sync sendfile :)

I suspect it wasn't any better with small files and small transfers.

Yes, some people do big files. Physicists have special things where they 
get a few terabytes per second from some high-energy experiment. The 
various people spying on you have special setups where they move gigabytes 
of satellite map data around to visualize it.

So there are undeniably cases like that, but they are also usually so 
special that they really don't even care about COW, because they sure as 
hell don't care about somebody else modifying the file they're sending at 
the same time.

In fact the whole point is that they don't touch the data at teh CPU 
_at_all_, and the reason they want zero-copy sending is that they 
literally want to DMA from disk buffers to memory, and then from memory to 
a network interface, and they don't want the CPU _ever_ seeing it with all 
the cache invalidations etc.

And _that_ is the case where you should use sendfile(). If your CPU has 
actually touched the data, you should probably just use read()/write().

Of course, one of the really nice things about splice() (which was not 
true about sendfile()) is that you can actually mix-and-match. You can 
splice data from kernel buffers, but you can also splice data from user 
VM, or you can do regular "write()" calls to fill (or read) the data from 
the splice pipe.

This is useful in ways that sendfile() never was. You can write() headers 
into the pipe buffer, and then splice() the file data into it, and the 
user only sees a pipe (and can either read from it or splice it or tee it 
or whatever). IOW, splice very much has the UNIX model of "everything is 
a pipe", taken to one (admittedly odd) extreme.

Anyway, the correct way to use splice() is to either just know the data is 
"safe" (either because you are _ok_ with people modifying it after the 
splice op took place, or because you know nobody will). The alternative is 
to expect an acknowledgement from the other side, because then you know 
the buffer is done.

				Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
