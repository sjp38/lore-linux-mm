Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id A09256B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 04:10:05 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id r20so1473394wiv.2
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 01:10:05 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w8si45548121wjw.51.2015.02.20.01.10.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Feb 2015 01:10:03 -0800 (PST)
Date: Fri, 20 Feb 2015 10:10:01 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150220091001.GC21248@dhcp22.suse.cz>
References: <20150218082502.GA4478@dhcp22.suse.cz>
 <20150218104859.GM12722@dastard>
 <20150218121602.GC4478@dhcp22.suse.cz>
 <20150219110124.GC15569@phnom.home.cmpxchg.org>
 <20150219122914.GH28427@dhcp22.suse.cz>
 <201502192229.FCJ73987.MFQLOHSJFFtOOV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502192229.FCJ73987.MFQLOHSJFFtOOV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, fernando_b1@lab.ntt.co.jp

On Thu 19-02-15 22:29:37, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 19-02-15 06:01:24, Johannes Weiner wrote:
> > [...]
> > > Preferrably, we'd get rid of all nofail allocations and replace them
> > > with preallocated reserves.  But this is not going to happen anytime
> > > soon, so what other option do we have than resolving this on the OOM
> > > killer side?
> > 
> > As I've mentioned in other email, we might give GFP_NOFAIL allocator
> > access to memory reserves (by giving it __GFP_HIGH). This is still not a
> > 100% solution because reserves could get depleted but this risk is there
> > even with multiple oom victims. I would still argue that this would be a
> > better approach because selecting more victims might hit pathological
> > case more easily (other victims might be blocked on the very same lock
> > e.g.).
> > 
> Does "multiple OOM victims" mean "select next if first does not die"?
> Then, I think my timeout patch http://marc.info/?l=linux-mm&m=142002495532320&w=2
> does not deplete memory reserves. ;-)

It doesn't because
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2603,9 +2603,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 		else if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
-		else if (!in_interrupt() &&
-				((current->flags & PF_MEMALLOC) ||
-				 unlikely(test_thread_flag(TIF_MEMDIE))))
+		else if (!in_interrupt() && (current->flags & PF_MEMALLOC))
 			alloc_flags |= ALLOC_NO_WATERMARKS;

you disabled the TIF_MEMDIE heuristic and use it only for OOM exclusion
and break out from the allocator. Exiting task might need a memory to do
so and you make all those allocations fail basically. How do you know
this is not going to blow up?

> If we change to permit invocation of the OOM killer for GFP_NOFS / GFP_NOIO,
> those who do not want to fail (e.g. journal transaction) will start passing
> __GFP_NOFAIL?
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
