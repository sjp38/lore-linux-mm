Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8E9veYn015760
	for <linux-mm@kvack.org>; Wed, 14 Sep 2005 05:57:40 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8E9vemZ086282
	for <linux-mm@kvack.org>; Wed, 14 Sep 2005 05:57:40 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j8E9veJo030544
	for <linux-mm@kvack.org>; Wed, 14 Sep 2005 05:57:40 -0400
Date: Wed, 14 Sep 2005 15:22:07 +0530
From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: VM balancing issues on 2.6.13: dentry cache not getting shrunk enough
Message-ID: <20050914095207.GA4833@in.ibm.com>
Reply-To: dipankar@in.ibm.com
References: <20050911105709.GA16369@thunk.org> <20050913084752.GC4474@in.ibm.com> <20050913215932.GA1654338@melbourne.sgi.com> <200509141101.16781.ak@suse.de> <4327EA6B.6090102@colorfullife.com> <20050914024313.1e70f2a3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050914024313.1e70f2a3.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Manfred Spraul <manfred@colorfullife.com>, ak@suse.de, dgc@sgi.com, bharata@in.ibm.com, tytso@mit.edu, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 14, 2005 at 02:43:13AM -0700, Andrew Morton wrote:
> Manfred Spraul <manfred@colorfullife.com> wrote:
> >
> > One tricky point are directory dentries: As far as I see, they are 
> >  pinned and unfreeable if a (freeable) directory entry is in the cache.
> >
> I don't think it's been demonstrated that Ted's problem was caused by
> internal fragementation, btw.  Ted, could you run slabtop, see what the
> dcache occupancy is?  Monitor it as you start to manually apply pressure? 
> If the occupancy falls to 10% and not many slab pages are freed up yet then
> yup, it's internal fragmentation.
> 
> I've found that internal fragmentation due to pinned directory dentries can
> be very high if you're running silly benchmarks which create some
> regular-shaped directory tree which can easily create pathological
> patterns.  For real-world things with irregular creation and access
> patterns and irregular directory sizes the fragmentation isn't as easy to
> demonstrate.
> 
> Another approach would be to do an aging round on a directory's children
> when an unfreeable dentry is encountered on the LRU.  Something like that. 
> If internal fragmentation is indeed the problem.

One other point to look at is whether fragmentation is due to pinned
dentries or not. We can get that information only from dcache itself.
That is what we need to acertain first using the instrumentation
patch. Solving the problem of large # of pinned dentries and large # of LRU 
free dentries will likely require different approaches. Even the
LRU dentries are sometimes pinned due to the lazy-lru stuff that
we did for lock-free dcache. Let us get some accurate dentry
stats first from the instrumentation patch.

Thanks
Dipankar
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
