Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id E55B06B0073
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 07:53:23 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id h11so32732642wiw.3
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 04:53:23 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id jk6si1367648wid.50.2015.02.17.04.53.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Feb 2015 04:53:22 -0800 (PST)
Date: Tue, 17 Feb 2015 07:53:15 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150217125315.GA14287@phnom.home.cmpxchg.org>
References: <20141230112158.GA15546@dhcp22.suse.cz>
 <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
 <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.cz, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

On Tue, Feb 17, 2015 at 09:23:26PM +0900, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > Johannes Weiner wrote:
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 8e20f9c2fa5a..f77c58ebbcfa 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -2382,8 +2382,15 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> > >  		if (high_zoneidx < ZONE_NORMAL)
> > >  			goto out;
> > >  		/* The OOM killer does not compensate for light reclaim */
> > > -		if (!(gfp_mask & __GFP_FS))
> > > +		if (!(gfp_mask & __GFP_FS)) {
> > > +			/*
> > > +			 * XXX: Page reclaim didn't yield anything,
> > > +			 * and the OOM killer can't be invoked, but
> > > +			 * keep looping as per should_alloc_retry().
> > > +			 */
> > > +			*did_some_progress = 1;
> > >  			goto out;
> > > +		}
> > 
> > Why do you omit out_of_memory() call for GFP_NOIO / GFP_NOFS allocations?
> 
> I can see "possible memory allocation deadlock in %s (mode:0x%x)" warnings
> at kmem_alloc() in fs/xfs/kmem.c . I think commit 9879de7373fcfb46 "mm:
> page_alloc: embed OOM killing naturally into allocation slowpath" introduced
> a regression and below one is the fix.
> 
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2381,9 +2381,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>                 /* The OOM killer does not needlessly kill tasks for lowmem */
>                 if (high_zoneidx < ZONE_NORMAL)
>                         goto out;
> -               /* The OOM killer does not compensate for light reclaim */
> -               if (!(gfp_mask & __GFP_FS))
> -                       goto out;
>                 /*
>                  * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
>                  * Sanity check for bare calls of __GFP_THISNODE, not real OOM.

Again, we don't want to OOM kill on behalf of allocations that can't
initiate IO, or even actively prevent others from doing it.  Not per
default anyway, because most callers can deal with the failure without
having to resort to killing tasks, and NOFS reclaim *can* easily fail.
It's the exceptions that should be annotated instead:

void *
kmem_alloc(size_t size, xfs_km_flags_t flags)
{
	int	retries = 0;
	gfp_t	lflags = kmem_flags_convert(flags);
	void	*ptr;

	do {
		ptr = kmalloc(size, lflags);
		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
			return ptr;
		if (!(++retries % 100))
			xfs_err(NULL,
		"possible memory allocation deadlock in %s (mode:0x%x)",
					__func__, lflags);
		congestion_wait(BLK_RW_ASYNC, HZ/50);
	} while (1);
}

This should use __GFP_NOFAIL, which is not only designed to annotate
broken code like this, but also recognizes that endless looping on a
GFP_NOFS allocation needs the OOM killer after all to make progress.

diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index a7a3a63bb360..17ced1805d3a 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -45,20 +45,12 @@ kmem_zalloc_greedy(size_t *size, size_t minsize, size_t maxsize)
 void *
 kmem_alloc(size_t size, xfs_km_flags_t flags)
 {
-	int	retries = 0;
 	gfp_t	lflags = kmem_flags_convert(flags);
-	void	*ptr;
 
-	do {
-		ptr = kmalloc(size, lflags);
-		if (ptr || (flags & (KM_MAYFAIL|KM_NOSLEEP)))
-			return ptr;
-		if (!(++retries % 100))
-			xfs_err(NULL,
-		"possible memory allocation deadlock in %s (mode:0x%x)",
-					__func__, lflags);
-		congestion_wait(BLK_RW_ASYNC, HZ/50);
-	} while (1);
+	if (!(flags & (KM_MAYFAIL | KM_NOSLEEP)))
+		lflags |= __GFP_NOFAIL;
+
+	return kmalloc(size, lflags);
 }
 
 void *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
