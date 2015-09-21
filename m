Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF7B6B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 05:24:33 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so136931376wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 02:24:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z17si29802044wjr.115.2015.09.21.02.24.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Sep 2015 02:24:32 -0700 (PDT)
Date: Mon, 21 Sep 2015 11:24:29 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] fs-writeback: drop wb->list_lock during blk_finish_plug()
Message-ID: <20150921092429.GB9028@quack.suse.cz>
References: <20150917021453.GO3902@dastard>
 <CA+55aFz6zfHQnrwtimgm9v10s8dkF-e1w1aQQ3aWperbZGT1Jg@mail.gmail.com>
 <20150917224230.GF8624@ret.masoncoding.com>
 <CA+55aFw40VNejeCtHC+-fPThK+xp9WnoNGQUwYW2JEVoVp5JJw@mail.gmail.com>
 <20150917235647.GG8624@ret.masoncoding.com>
 <20150918003735.GR3902@dastard>
 <CA+55aFzXW7t+1v3tmW2sxn-BLpvZ1_Ye6epiPWBeq70FoaSmFQ@mail.gmail.com>
 <20150918054044.GT3902@dastard>
 <CA+55aFw3Y51ZtaPK=r1dp66hDsGmc-dFz9wf-gYMGi5B0FP4KQ@mail.gmail.com>
 <20150918221714.GU3902@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150918221714.GU3902@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@lst.de>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Sat 19-09-15 08:17:14, Dave Chinner wrote:
> On Thu, Sep 17, 2015 at 11:04:03PM -0700, Linus Torvalds wrote:
> > On Thu, Sep 17, 2015 at 10:40 PM, Dave Chinner <david@fromorbit.com> wrote:
> > > PS: just hit another "did this just get broken in 4.3-rc1" issue - I
> > > can't run blktrace while there's a IO load because:
> > >
> > > $ sudo blktrace -d /dev/vdc
> > > BLKTRACESETUP(2) /dev/vdc failed: 5/Input/output error
> > > Thread 1 failed open /sys/kernel/debug/block/(null)/trace1: 2/No such file or directory
> > > ....
> > >
> > > [  641.424618] blktrace: page allocation failure: order:5, mode:0x2040d0
> > > [  641.438933]  [<ffffffff811c1569>] kmem_cache_alloc_trace+0x129/0x400
> > > [  641.440240]  [<ffffffff811424f8>] relay_open+0x68/0x2c0
> > > [  641.441299]  [<ffffffff8115deb1>] do_blk_trace_setup+0x191/0x2d0
> > >
> > > gdb) l *(relay_open+0x68)
> > > 0xffffffff811424f8 is in relay_open (kernel/relay.c:582).
> > > 577                     return NULL;
> > > 578             if (subbuf_size > UINT_MAX / n_subbufs)
> > > 579                     return NULL;
> > > 580
> > > 581             chan = kzalloc(sizeof(struct rchan), GFP_KERNEL);
> > > 582             if (!chan)
> > > 583                     return NULL;
> > > 584
> > > 585             chan->version = RELAYFS_CHANNEL_VERSION;
> > > 586             chan->n_subbufs = n_subbufs;
> > >
> > > and struct rchan has a member struct rchan_buf *buf[NR_CPUS];
> > > and CONFIG_NR_CPUS=8192, hence the attempt at an order 5 allocation
> > > that fails here....
> > 
> > Hm. Have you always had MAX_SMP (and the NR_CPU==8192 that it causes)?
> > From a quick check, none of this code seems to be new.
> 
> Yes, I always build MAX_SMP kernels for testing, because XFS is
> often used on such machines and so I want to find issues exactly
> like this in my testing rather than on customer machines... :/
> 
> > That said, having that
> > 
> >         struct rchan_buf *buf[NR_CPUS];
> > 
> > in "struct rchan" really is something we should fix. We really should
> > strive to not allocate things by CONFIG_NR_CPU's, but by the actual
> > real CPU count.
> 
> *nod*. But it doesn't fix the problem of the memory allocation
> failing when there's still gigabytes of immediately reclaimable
> memory available in the page cache. If this is failing under page
> cache memory pressure, then we're going to be doing an awful lot
> more falling back to vmalloc in the filesystem code where large
> allocations like this are done e.g. extended attribute buffers are
> order-5, and used a lot when doing things like backups which tend to
> also produce significant page cache memory pressure.
> 
> Hence I'm tending towards there being a memory reclaim behaviour
> regression, not so much worrying about whether this specific
> allocation is optimal or not.

Yup, looks like a regression in reclaim. Added linux-mm folks to CC.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
