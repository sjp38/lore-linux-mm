Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA15785
	for <linux-mm@kvack.org>; Sun, 8 Sep 2002 15:31:33 -0700 (PDT)
Message-ID: <3D7BD32F.D8807152@digeo.com>
Date: Sun, 08 Sep 2002 15:46:07 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slabasap-mm5_A2
References: <200209071006.18869.tomlins@cam.org> <200209081714.54110.tomlins@cam.org> <3D7BC58F.D8AC82E8@digeo.com> <200209081748.19674.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
> 
> ...
> > That would make the slab pruning less aggressive than the code I'm
> > testing now.  I'm not sure it needs that change.  Not sure...
> 
> Well without this change slab sometimes really get hurt.  It took me a while
> to figure out what was happening in when I coded slablru.  In any case you
> do have the code to fix it.

Yup, let's run with that.
 
> > > Ah thanks.  Was wondering the best way to do this.  Will read the code.
> >
> > Then again, shrinking slab harder for big highmem machines is good ;)
> 
> That was Rik's comment too...  Just figured it best to mention the options.
> 
> > But the prunes are miles too small at present.  We go into
> > try_to_free_pages() and reclaim 32 pages.  And we also call into
> > prune_cache() and free about 0.3 pages.  It's out of whack.  I'd suggest
> > not calling out to the pruner until we want at least several pages' worth
> > of objects.
> 
> Agreed.  I had not quite digested your last comments when I wrote this.
> Once we are happy I will readd the callbacks (using a second call to set
> the callback - btw I have some nice oak hiking sticks here...) and fix this
> as you sugested.

Thanks.  Shrinking seems to work well now.  Plus, if we need, we have
a single, nice linear knob with whichto twiddle the aging: just scale
the ratio up and down.
 
> > > The other thing we want to be careful with is to make sure the lack of
> > > free page accounting is detected by oom - we definitly do not want to
> > > oom when slab has freed memory by try_to_free_pages does not
> > > realize it..
> >
> > How much memory are we talking about here?  Not much I think?
> 
> Usually not much.  I do know that when Rik added my slab accounting to rmap
> the number of oom reports dropped.  We just need to be aware there is a
> hole and there might be a small problem.
> 
> > > This converts the prunes in inode and dcache to age <n> entries rather
> > > than purge them.  Think this is the more correct behavior.  Code is from
> > > slablru.
> >
> > Makes sense (I think).
> 
> As I mentioned above I needed this to make slablru stable...  Might be since you
> now limit the number of pages scanned to 2*nr_pages we can get away without
> this - not at all sure though.  Going back the basics.  Without this are we not
> devaluating seeks required to rebuild slab objects vs lru pages?

Yes, we are.  It's a relatively small deal anyway.  The success rate in
reclaiming pages coming off the tail of the LRU is currently in the 50%
to 90% range, depending on what's going on.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
