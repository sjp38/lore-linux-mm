Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1FBAE6B0038
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 17:11:38 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id v123so6649871oif.23
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 14:11:38 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t5si5497792oig.188.2017.11.21.14.11.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Nov 2017 14:11:36 -0800 (PST)
Subject: Re: [PATCH] mm,vmscan: Mark register_shrinker() as __must_check
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511265757-15563-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171121134007.466815aa4a0562eaaa223cbf@linux-foundation.org>
In-Reply-To: <20171121134007.466815aa4a0562eaaa223cbf@linux-foundation.org>
Message-Id: <201711220709.JJJ12483.MtFOOJFHOLQSVF@I-love.SAKURA.ne.jp>
Date: Wed, 22 Nov 2017 07:09:33 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, david@fromorbit.com, viro@zeniv.linux.org.uk, jack@suse.com, pbonzini@redhat.com, airlied@linux.ie, alexander.deucher@amd.com, shli@fb.com, snitzer@redhat.com

Andrew Morton wrote:
> On Tue, 21 Nov 2017 21:02:37 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
> > There are users not checking for register_shrinker() failure.
> > Continuing with ignoring failure can lead to later oops at
> > unregister_shrinker().
> > 
> > ...
> >
> > --- a/include/linux/shrinker.h
> > +++ b/include/linux/shrinker.h
> > @@ -75,6 +75,6 @@ struct shrinker {
> >  #define SHRINKER_NUMA_AWARE	(1 << 0)
> >  #define SHRINKER_MEMCG_AWARE	(1 << 1)
> >  
> > -extern int register_shrinker(struct shrinker *);
> > +extern __must_check int register_shrinker(struct shrinker *);
> >  extern void unregister_shrinker(struct shrinker *);
> >  #endif
> 
> hm, well, OK, it's a small kmalloc(GFP_KERNEL).  That won't be
> failing.

It failed by fault injection and resulted in a report at
http://lkml.kernel.org/r/001a113f996099503a055e793dd3@google.com .

> 
> Affected code seems to be fs/xfs, fs/super.c, fs/quota,
> arch/x86/kvm/mmu, drivers/gpu/drm/ttm, drivers/md and a bunch of
> staging stuff.
> 
> I'm not sure this is worth bothering about?
> 

Continuing with failed register_shrinker() is almost always wrong.
Though I don't know whether mm/zsmalloc.c case can make sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
