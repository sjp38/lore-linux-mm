Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6654B5F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 21:05:30 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] SLQB slab allocator (try 2)
Date: Tue, 3 Feb 2009 13:04:58 +1100
References: <20090123154653.GA14517@wotan.suse.de> <1233047272.4984.12.camel@laptop> <alpine.DEB.1.10.0901271509170.3114@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0901271509170.3114@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902031304.59592.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 28 January 2009 07:21:58 Christoph Lameter wrote:
> On Tue, 27 Jan 2009, Peter Zijlstra wrote:
> > > Well there is the problem in SLAB and SLQB that they *continue* to do
> > > processing after an allocation. They defer queue cleaning. So your
> > > latency critical paths are interrupted by the deferred queue
> > > processing.
> >
> > No they're not -- well, only if you let them that is, and then its your
> > own fault.
>
> So you can have priority over kernel threads.... Sounds very dangerous.

Groan.


> > Like Nick has been asking, can you give a solid test case that
> > demonstrates this issue?
>
> Run a loop reading tsc and see the variances?
>
> In HPC apps a series of processors have to sync repeatedly in order to
> complete operations. An event like cache cleaning can cause a disturbance
> in one processor that delays this sync in the system as a whole. And
> having it run at offsets separately on all processor causes the
> disturbance to happen on one processor after another. In extreme cases all
> syncs are delayed. We have seen this effect have a major delay on HPC app
> performance.

Now we are starting to get somewhere slightly useful. Can we have more
details about this workload please? Was there a test program coded up
to run the same sequence of MPI operations? Or can they at least be
described?


> Note that SLAB scans through all slab caches in the system and expires
> queues that are active. The more slab caches there are and the more data
> is in queues the longer the process takes.

And the larger the number of nodes and CPUs, because SLAB can have so
many queues. This is not an issue with SLQB, so I don't think it will
be subject to the same magnitude of problem on your large machines.

Periodic cleaning in SLAB was never shown to be a problem with large
HPC clusters in the past, so that points to SGI's problem as being due
to explosion of queues in big machines rather than the whole concept
of periodic cleaning.

And we have lots of periodic things going on. Periodic journal flushing,
periodic dirty watermark checking, periodic timers, multiprocessor CPU
scheduler balancing etc etc. So no, I totally reject the assertion that
periodic slab cleaning is a showstopper. Without actual numbers or test
cases, I don't need to hear any more assertions in this vein.

(But note, numbers and/or test cases etc would be very very welcome
because I would like to tune SLQB performance on HPC as much as possible
and as I have already said, there are ways we can improve or mitigate
periodic trimming overheads).


> > I'm thinking getting git of those cross-bar queues hugely reduces that
> > problem.
>
> The cross-bar queues are a significant problem because they mean operation
> on objects that are relatively far away. So the time spend in cache
> cleaning increases significantly. But as far as I can see SLQB also has
> cross-bar queues like SLAB.

Well it doesn't.


> SLUB does all necessary actions during the
> actual allocation or free so there is no need to run cache cleaning.

And SLUB can actually leave free pages lying around that never get cleaned
up because of this. As I said, I have seen SLQB use less memory than SLUB
in some situations I assume because of this (although now that I think
about it, perhaps it was due to increased internal fragmentation in bigger
pages).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
