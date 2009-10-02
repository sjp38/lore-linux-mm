Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2DADC6B004D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 06:42:41 -0400 (EDT)
Date: Fri, 2 Oct 2009 18:54:59 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] HWPOISON: remove the unsafe __set_page_locked()
Message-ID: <20091002105459.GA14526@localhost>
References: <20090926031537.GA10176@localhost> <20090926034936.GK30185@one.firstfloor.org> <20090926105259.GA5496@localhost> <20090926113156.GA12240@localhost> <20090927104739.GA1666@localhost> <20090927192025.GA6327@wotan.suse.de> <20090928084401.GA22131@localhost> <20091001020207.GL6327@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091001020207.GL6327@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 01, 2009 at 10:02:07AM +0800, Nick Piggin wrote:
> On Mon, Sep 28, 2009 at 04:44:01PM +0800, Wu Fengguang wrote:
> > On Mon, Sep 28, 2009 at 03:20:25AM +0800, Nick Piggin wrote:
> > > On Sun, Sep 27, 2009 at 06:47:39PM +0800, Wu Fengguang wrote:
> > > > > 
> > > > > And standard deviation is 0.04%, much larger than the difference 0.008% ..
> > > > 
> > > > Sorry that's not correct. I improved the accounting by treating
> > > > function0+function1 from two CPUs as an integral entity:
> > > > 
> > > >                  total time      add_to_page_cache_lru   percent  stddev
> > > >          before  3880166848.722  9683329.610             0.250%   0.014%
> > > >          after   3828516894.376  9778088.870             0.256%   0.012%
> > > >          delta                                           0.006%
> > > 
> > > I don't understand why you're doing this NFS workload to measure?
> > 
> > Because it is the first convenient workload hit my mind, and avoids
> > real disk IO :)
> 
> Using tmpfs or sparse files is probably a lot easier.

Good ideas. In fact I tried them in the very beginning.
The ratios are roughly at the same level (which is somehow unexpected):

        total time      add_to_page_cache_lru   percent  stddev
tmpfs   1579056274.576  2615476.234             0.1656354036338758%
sparse  1074931917.425  3001273                 0.27920586888791538%

Workload is to copy 1G /dev/zero to /dev/shm/, or 1G sparse file
(ext2) to /dev/null.

 echo 1 > /debug/tracing/function_profile_enabled
 cp /dev/zero /dev/shm/
 echo 0 > /debug/tracing/function_profile_enabled

 dd if=/dev/zero of=/mnt/test bs=1k count=1 seek=1048575
 echo 1 > /debug/tracing/function_profile_enabled
 cp /mnt/test/sparse /dev/null
 echo 0 > /debug/tracing/function_profile_enabled

> > > I see significant nfs, networking protocol and device overheads in
> > > your profiles, also you're hitting some locks or something which
> > > is causing massive context switching. So I don't think this is a
> > > good test.
> > 
> > Yes there are overheads. However it is a real and common workload.
> 
> Right, but so are lots of other workloads that don't hit
> add_to_page_cache heavily :)
>  
> 
> > > But anyway as Hugh points out, you need to compare with a
> > > *completely* fixed kernel, which includes auditing all users of page
> > > flags non-atomically (slab, notably, but possibly also other
> > > places).
> > 
> > That's good point. We can do more benchmarks when more fixes are
> > available. However I suspect their design goal will be "fix them
> > without introducing noticeable overheads" :)
> 
> s/noticeable//
> 
> The problem with all the non-noticeable overheads that we're
> continually adding to the kernel is that we're adding them to
> the kernel. Non-noticeable part only makes it worse because
> you can't bisect them :)

Yes it makes sense.

> > > One other thing to keep in mind that I will mention is that I am
> > > going to push in a patch to the page allocator to allow callers
> > > to avoid the refcounting (atomic_dec_and_test) in page lifetime,
> > > which is especially important for SLUB and takes more cycles off
> > > the page allocator...
> > >
> > > I don't know exactly what you're going to do after that to get a
> > > stable reference to slab pages. I guess you can read the page
> > > flags and speculatively take some slab locks and recheck etc...
> > 
> > For reliably we could skip page lock on zero refcounted pages.
> > 
> > We may lose the PG_hwpoison bit on races with __SetPageSlub*, however
> > it should be an acceptable imperfection.
> 
> I think if you're wiling to accept these problems, then it is
> completely reasonable to also accept similar races with kernel
> fastpaths to avoid extra overheads there.

Yes I do. Even better, for this perticular race, we managed to avoid
it completely without introducing overheads in fast path :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
