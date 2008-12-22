Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4C26B0044
	for <linux-mm@kvack.org>; Sun, 21 Dec 2008 23:35:30 -0500 (EST)
Date: Mon, 22 Dec 2008 05:35:26 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/2] mnt_want_write speedup 1
Message-ID: <20081222043526.GC13406@wotan.suse.de>
References: <20081219061937.GA16268@wotan.suse.de> <1229669697.17206.602.camel@nimitz> <20081219070311.GA26419@wotan.suse.de> <1229700721.17206.634.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1229700721.17206.634.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 19, 2008 at 07:32:01AM -0800, Dave Hansen wrote:
> On Fri, 2008-12-19 at 08:03 +0100, Nick Piggin wrote:
> > MNT_WRITE_HOLD is set, so any writer that has already made it past
> > the MNT_WANT_WRITE loop will have its count visible here. Any writer
> > that has not made it past that loop will wait until the slowpath
> > completes and then the fastpath will go on to check whether the
> > mount is still writeable.
> 
> Ahh, got it.  I'm slowly absorbing the barriers.  Not the normal way, I
> code.
> 
> I thought there was another race with MNT_WRITE_HOLD since mnt_flags
> isn't really managed atomically.  But, by only modifying with the
> vfsmount_lock, I think it is OK.
> 
> I also wondered if there was a possibility of getting a spurious -EBUSY
> when remounting r/w->r/o.  But, that turned out to just happen when the
> fs was *already* r/o.  So that looks good.
> 
> While this has cleared out a huge amount of complexity, I can't stop
> wondering if this could be done with a wee bit more "normal" operations.
> I'm pretty sure I couldn't have come up with this by myself, and I'm a
> bit worried that I wouldn't be able to find a race in it if one reared
> its ugly head.  

It could be done with a seqcounter I think, but that adds more branches,
variables, and barriers to this fastpath. Perhaps I should simply add
a bit more documentation.

 
> Is there a real good reason to allocate the percpu counters dynamically?
> Might as well stick them in the vfsmount and let the one
> kmem_cache_zalloc() in alloc_vfsmnt() do a bit larger of an allocation.
> Did you think that was going to bloat it to a compound allocation or
> something?  I hate the #ifdefs. :)

Distros want to ship big NR_CPUS kernels and have them run reasonably on
small num_possible_cpus() systems. But also, it would help to avoid
cacheline bouncing from false sharing (allocpercpu.c code can also mess
this bug for small objects like these counters, but that's a problem
with the allocpercpu code which should be fixed anyway).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
