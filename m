Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3925A6B0038
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 15:47:44 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d15so15470055pfl.0
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 12:47:44 -0800 (PST)
Received: from ipmailnode02.adl6.internode.on.net (ipmailnode02.adl6.internode.on.net. [150.101.137.148])
        by mx.google.com with ESMTP id j21si15376825pfh.202.2017.11.22.12.47.42
        for <linux-mm@kvack.org>;
        Wed, 22 Nov 2017 12:47:43 -0800 (PST)
Date: Thu, 23 Nov 2017 07:39:07 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
Message-ID: <20171122203907.GI4094@dastard>
References: <1511265757-15563-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171121134007.466815aa4a0562eaaa223cbf@linux-foundation.org>
 <201711220709.JJJ12483.MtFOOJFHOLQSVF@I-love.SAKURA.ne.jp>
 <201711221953.IDJ12440.OQLtFVOJFMSHFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711221953.IDJ12440.OQLtFVOJFMSHFO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, glauber@scylladb.com, mhocko@kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jack@suse.com, pbonzini@redhat.com, airlied@linux.ie, alexander.deucher@amd.com, shli@fb.com, snitzer@redhat.com

On Wed, Nov 22, 2017 at 07:53:59PM +0900, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > Andrew Morton wrote:
> > > On Tue, 21 Nov 2017 21:02:37 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> > > 
> > > > There are users not checking for register_shrinker() failure.
> > > > Continuing with ignoring failure can lead to later oops at
> > > > unregister_shrinker().
> > > > 
> > > > ...
> > > >
> > > > --- a/include/linux/shrinker.h
> > > > +++ b/include/linux/shrinker.h
> > > > @@ -75,6 +75,6 @@ struct shrinker {
> > > >  #define SHRINKER_NUMA_AWARE	(1 << 0)
> > > >  #define SHRINKER_MEMCG_AWARE	(1 << 1)
> > > >  
> > > > -extern int register_shrinker(struct shrinker *);
> > > > +extern __must_check int register_shrinker(struct shrinker *);
> > > >  extern void unregister_shrinker(struct shrinker *);
> > > >  #endif
> > > 
> > > hm, well, OK, it's a small kmalloc(GFP_KERNEL).  That won't be
> > > failing.
> > 
> > It failed by fault injection and resulted in a report at
> > http://lkml.kernel.org/r/001a113f996099503a055e793dd3@google.com .
> 
> Since kzalloc() can become > 32KB allocation if CONFIG_NODES_SHIFT > 12
> (which might not be impossible in near future), register_shrinker() can
> potentially become a costly allocation which might fail without invoking
> the OOM killer. It is a good opportunity to think whether we should allow
> register_shrinker() to fail.

Just fix the numa aware shrinkers, as they are the only ones that
will have this problem. There are only 6 of them, and only the 3
that existed at the time that register_shrinker() was changed to
return an error fail to check for an error. i.e. the superblock
shrinker, the XFS dquot shrinker and the XFS buffer cache shrinker.

Seems pretty straight forward to me....

> > > Affected code seems to be fs/xfs, fs/super.c, fs/quota,
> > > arch/x86/kvm/mmu, drivers/gpu/drm/ttm, drivers/md and a bunch of
> > > staging stuff.
> > > 
> > > I'm not sure this is worth bothering about?
> > > 
> > 
> > Continuing with failed register_shrinker() is almost always wrong.
> > Though I don't know whether mm/zsmalloc.c case can make sense.
> > 
> 
> Thinking from the fact that register_shrinker() had been "void" until Linux 3.11
> and we did not take appropriate precautions when changing to "int" in Linux 3.12,
> we need to consider making register_shrinker() "void" again.
> 
> If we could agree with opening up the use of __GFP_NOFAIL for allocating a few
> non-contiguous pages on large systems, we can make register_shrinker() "void"
> again. (Draft patch is shown below. I choose array of kmalloc(PAGE_SIZE)
> rather than kvmalloc() in order to use __GFP_NOFAIL.)

That's insane. NACK.

-Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
