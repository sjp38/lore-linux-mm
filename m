Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBDAD6B027A
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 07:45:59 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id x66so14510473pfe.21
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:45:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a3si8070996pld.306.2017.11.22.04.45.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 04:45:58 -0800 (PST)
Date: Wed, 22 Nov 2017 13:45:51 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
Message-ID: <20171122124551.tjxt7td5fmfqifnc@dhcp22.suse.cz>
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
Cc: akpm@linux-foundation.org, glauber@scylladb.com, linux-mm@kvack.org, david@fromorbit.com, viro@zeniv.linux.org.uk, jack@suse.com, pbonzini@redhat.com, airlied@linux.ie, alexander.deucher@amd.com, shli@fb.com, snitzer@redhat.com

On Wed 22-11-17 19:53:59, Tetsuo Handa wrote:
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

Is it really that hard to fix callers to handle the error?

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

I am not sure we want to overcomplicate the code too much. Most
architectures do not have that many numa nodes to care. If we really
need to care maybe we should rethink and get rid of the per numa
deferred count altogether.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
