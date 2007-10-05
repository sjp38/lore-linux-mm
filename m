Date: Thu, 4 Oct 2007 17:48:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] remove throttle_vm_writeout()
Message-Id: <20071004174851.b34a3220.akpm@linux-foundation.org>
In-Reply-To: <E1Idanu-0002c1-00@dorka.pomaz.szeredi.hu>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	<20071004145640.18ced770.akpm@linux-foundation.org>
	<E1IdZLg-0002Wr-00@dorka.pomaz.szeredi.hu>
	<20071004160941.e0c0c7e5.akpm@linux-foundation.org>
	<E1Ida56-0002Zz-00@dorka.pomaz.szeredi.hu>
	<20071004164801.d8478727.akpm@linux-foundation.org>
	<E1Idanu-0002c1-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: wfg@mail.ustc.edu.cn, a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 05 Oct 2007 02:12:30 +0200 Miklos Szeredi <miklos@szeredi.hu> wrote:

> > 
> > I don't think I understand that.  Sure, it _shouldn't_ be a problem.  But it
> > _is_.  That's what we're trying to fix, isn't it?
> 
> The problem, I believe is in the memory allocation code, not in fuse.

fuse is trying to do something which page reclaim was not designed for. 
Stuff broke.

> In the example, memory allocation may be blocking indefinitely,
> because we have 4MB under writeback, even though 28MB can still be
> made available.  And that _should_ be fixable.

Well yes.  But we need to work out how, without re-breaking the thing which
throttle_vm_writeout() fixed.

> > > So the only thing the kernel should be careful about, is not to block
> > > on an allocation if not strictly necessary.
> > > 
> > > Actually a trivial fix for this problem could be to just tweak the
> > > thresholds, so to make the above scenario impossible.  Although I'm
> > > still not convinced, this patch is perfect, because the dirty
> > > threshold can actually change in time...
> > > 
> > > Index: linux/mm/page-writeback.c
> > > ===================================================================
> > > --- linux.orig/mm/page-writeback.c      2007-10-05 00:31:01.000000000 +0200
> > > +++ linux/mm/page-writeback.c   2007-10-05 00:50:11.000000000 +0200
> > > @@ -515,6 +515,12 @@ void throttle_vm_writeout(gfp_t gfp_mask
> > >          for ( ; ; ) {
> > >                 get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
> > > 
> > > +               /*
> > > +                * Make sure the theshold is over the hard limit of
> > > +                * dirty_thresh + ratelimit_pages * nr_cpus
> > > +                */
> > > +               dirty_thresh += ratelimit_pages * num_online_cpus();
> > > +
> > >                  /*
> > >                   * Boost the allowable dirty threshold a bit for page
> > >                   * allocators so they don't get DoS'ed by heavy writers
> > 
> > I can probably kind of guess what you're trying to do here.  But if
> > ratelimit_pages * num_online_cpus() exceeds the size of the offending zone
> > then things might go bad.
> 
> I think the admin can do quite a bit of other damage, by setting
> dirty_ratio too high.
> 
> Maybe this writeback throttling should just have a fixed limit of 80%
> ZONE_NORMAL, and limit dirty_ratio to something like 50%.

Bear in mind that the same problem will occur for the 16MB ZONE_DMA, and
we cannot limit the system-wide dirty-memory threshold to 12MB.

iow, throttle_vm_writeout() needs to become zone-aware.  Then it only
throttles when, say, 80% of ZONE_FOO is under writeback.

Except I don't think that'll fix the problem 100%: if your fuse kernel
component somehow manages to put 80% of ZONE_FOO under writeback (and
remmeber this might be only 12MB on a 16GB machine) then we get stuck again
- the fuse server process (is that the correct terminology, btw?) ends up
waiting upon itself.

I'll think about it a bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
