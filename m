Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DECE46B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 01:50:37 -0500 (EST)
Date: Fri, 19 Dec 2008 07:52:42 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/2] mnt_want_write speedup 1
Message-ID: <20081219065242.GD16268@wotan.suse.de>
References: <20081219061937.GA16268@wotan.suse.de> <1229668492.17206.594.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1229668492.17206.594.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 18, 2008 at 10:34:52PM -0800, Dave Hansen wrote:
> On Fri, 2008-12-19 at 07:19 +0100, Nick Piggin wrote:
> > Hi. Fun, chasing down performance regressions.... I wonder what people think
> > about these patches? Is it OK to bloat struct vfsmount? Any races?
> 
> Very cool stuff, Nick.  I especially like how much it simplifies things
> and removes *SO* much code.

Thanks.

 
> Bloating the vfsmount was one of the things that really, really tried to
> avoid.  When I start to think about the SGI machines, it gets me really
> worried.  I went to a lot of trouble to make sure that the per-vfsmount
> memory overhead didn't scale with the number of cpus.

Well, OTOH, the SGI machines have a lot of memory ;) I *think* that
not many systems probably have thousands of mounts (given that the
mount hashtable is fixed sized single page), but I might be wrong
which is why I ask here.

Let's say a 4096 CPU machine with one mount for each CPU (4096 mounts),
I think should only use about 128MB total for the counters. OK, yes
that is a lot ;) but not exactly insane for such machine size.

Say for 32 CPU system with 10,000 mounts, it's 9MB.


> > This could
> > be made even faster if mnt_make_readonly could tolerate a really high latency
> > synchronize_rcu()... can it?)
> 
> Yes, I think it can tolerate it.  There's a lot of work to do, and we
> already have to go touch all the other per-cpu objects.  There also
> tends to be writeout when this happens, so I don't think a few seconds,
> even, will be noticed.

That would be good. After the first patch, mnt_want_write still shows up
on profiles and almost oall the hits come right after the msync from
the smp_mb there.

It would be really nice to use RCU here. I think it might allow us to
eliminate the memory barriers.


> > This patch speeds up lmbench lat_mmap test by about 8%. lat_mmap is set up
> > basically to mmap a 64MB file on tmpfs, fault in its pages, then unmap it.
> > A microbenchmark yes, but it exercises some important paths in the mm.
> 
> Do you know where the overhead actually came from?  Was it the
> spinlocks?  Was removing all the atomic ops what really helped?

I thnk about 95% of the unhalted cycles were hit against the two
instructions after the call to spin_lock. It wasn't actually flipping 
the write counter per-cpu cache as far as I could see. I didn't save
the instruction level profiles, but I'll do another run if people
think it will be sane to use RCU here.

> I'll take a more in-depth look at your code tomorrow and see if I see
> any races.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
