Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id CA37B6B0253
	for <linux-mm@kvack.org>; Fri, 28 Aug 2015 12:48:22 -0400 (EDT)
Received: by ykek5 with SMTP id k5so7310429yke.3
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 09:48:22 -0700 (PDT)
Received: from mail-yk0-x233.google.com (mail-yk0-x233.google.com. [2607:f8b0:4002:c07::233])
        by mx.google.com with ESMTPS id z188si4417397ykc.119.2015.08.28.09.48.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Aug 2015 09:48:21 -0700 (PDT)
Received: by ykek5 with SMTP id k5so7310061yke.3
        for <linux-mm@kvack.org>; Fri, 28 Aug 2015 09:48:21 -0700 (PDT)
Date: Fri, 28 Aug 2015 12:48:19 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150828164819.GL26785@mtj.duckdns.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-4-git-send-email-tj@kernel.org>
 <20150828163611.GI9610@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828163611.GI9610@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hello, Vladimir.

On Fri, Aug 28, 2015 at 07:36:11PM +0300, Vladimir Davydov wrote:
> > * try_charge() can be invoked from any in-kernel allocation site and
> >   reclaim path may use considerable amount of stack.  This can lead to
> >   stack overflows which are extremely difficult to reproduce.
> 
> IMO this paragraph does not justify this patch at all, because one will
> still invoke direct reclaim from try_charge() on hitting the hard limit.

Ah... right, and we can't defer direct reclaim for hard limit.

> > * If the allocation doesn't have __GFP_WAIT, direct reclaim is
> >   skipped.  If a process performs only speculative allocations, it can
> >   blow way past the high limit.  This is actually easily reproducible
> >   by simply doing "find /".  VFS tries speculative !__GFP_WAIT
> >   allocations first, so as long as there's memory which can be
> >   consumed without blocking, it can keep allocating memory regardless
> >   of the high limit.
> 
> I think there shouldn't normally occur a lot of !__GFP_WAIT allocations
> in a row - they should still alternate with normal __GFP_WAIT
> allocations. Yes, that means we can breach memory.high threshold for a
> short period of time, but it isn't a hard limit, so it looks perfectly
> fine to me.
> 
> I tried to run `find /` over ext4 in a cgroup with memory.high set to
> 32M and kmem accounting enabled. With such a setup memory.current never
> got higher than 33152K, which is only 384K greater than the memory.high.
> Which FS did you use?

ext4.  Here, it goes onto happily consuming hundreds of megabytes with
limit set at 32M.  We have quite a few places where !__GFP_WAIT
allocations are performed speculatively in hot paths with fallback
slow paths, so this is bound to happen somewhere.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
