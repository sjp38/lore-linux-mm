Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id BC9C26B0075
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 02:30:44 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so10541117pab.37
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 23:30:44 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id hi3si12116279pac.82.2014.04.15.23.30.42
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 23:30:43 -0700 (PDT)
Date: Wed, 16 Apr 2014 16:30:38 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 13/19] MM: set PF_FSTRANS while allocating per-cpu memory
 to avoid deadlock.
Message-ID: <20140416063038.GH15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
 <20140416040336.10604.67456.stgit@notabene.brown>
 <20140416054942.GD15995@dastard>
 <20140416162201.5dc9ff5c@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140416162201.5dc9ff5c@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com

On Wed, Apr 16, 2014 at 04:22:01PM +1000, NeilBrown wrote:
> On Wed, 16 Apr 2014 15:49:42 +1000 Dave Chinner <david@fromorbit.com> wrote:
> 
> > On Wed, Apr 16, 2014 at 02:03:36PM +1000, NeilBrown wrote:
> > > lockdep reports a locking chain
> > > 
> > >   sk_lock-AF_INET --> rtnl_mutex --> pcpu_alloc_mutex
> > > 
> > > As sk_lock may be needed to reclaim memory, allowing that
> > > reclaim while pcu_alloc_mutex is held can lead to deadlock.
> > > So set PF_FSTRANS while it is help to avoid the FS reclaim.
> > > 
> > > pcpu_alloc_mutex can be taken when rtnl_mutex is held:
> > > 
> > >     [<ffffffff8117f979>] pcpu_alloc+0x49/0x960
> > >     [<ffffffff8118029b>] __alloc_percpu+0xb/0x10
> > >     [<ffffffff8193b9f7>] loopback_dev_init+0x17/0x60
> > >     [<ffffffff81aaf30c>] register_netdevice+0xec/0x550
> > >     [<ffffffff81aaf785>] register_netdev+0x15/0x30
> > > 
> > > Signed-off-by: NeilBrown <neilb@suse.de>
> > 
> > This looks like a workaround to avoid passing a gfp mask around to
> > describe the context in which the allocation is taking place.
> > Whether or not that's the right solution, I can't say, but spreading
> > this "we can turn off all reclaim of filesystem objects" mechanism
> > all around the kernel doesn't sit well with me...
> 
> We are (effectively) passing a gfp mask around, except that it lives in
> 'current' rather than lots of other places.
> I actually like the idea of discarding PF_MEMALLOC, PF_FSTRANS and
> PF_MEMALLOC_NOIO, and just having current->gfp_allowed_mask (to match the
> global variable of the same name).

Given that we've had problems getting gfp flags propagated into the
VM code (vmalloc, I'm looking at you!) making the current task
carry the valid memory allocation and reclaim context mask woul dbe
a good idea. That's effectively the problem PF_MEMALLOC_NOIO is
working around, and we've recently added it to XFS to silence all
the lockdep warnings using vm_map_ram in GFP_NOFS contexts have been
causing us....

> > And, again, PF_FSTRANS looks plainly wrong in this code - it sure
> > isn't a fs transaction context we are worried about here...
> 
> So would PF_MEMALLOC_NOFS work for you?

Better than PF_FSTRANS, that's for sure ;)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
