Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2376B029E
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 07:07:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w84so70021023wmg.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 04:07:55 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id r4si13601253wmd.5.2016.09.29.04.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 04:07:53 -0700 (PDT)
Date: Thu, 29 Sep 2016 12:07:14 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] mm/vmalloc: reduce the number of lazy_max_pages to
 reduce latency
Message-ID: <20160929110714.GF28107@nuc-i3427.alporthouse.com>
References: <20160929073411.3154-1-jszhang@marvell.com>
 <20160929081818.GE28107@nuc-i3427.alporthouse.com>
 <20160929162808.745c869b@xhacker>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160929162808.745c869b@xhacker>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jisheng Zhang <jszhang@marvell.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, rientjes@google.com, iamjoonsoo.kim@lge.com, agnel.joel@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Thu, Sep 29, 2016 at 04:28:08PM +0800, Jisheng Zhang wrote:
> On Thu, 29 Sep 2016 09:18:18 +0100 Chris Wilson wrote:
> 
> > On Thu, Sep 29, 2016 at 03:34:11PM +0800, Jisheng Zhang wrote:
> > > On Marvell berlin arm64 platforms, I see the preemptoff tracer report
> > > a max 26543 us latency at __purge_vmap_area_lazy, this latency is an
> > > awfully bad for STB. And the ftrace log also shows __free_vmap_area
> > > contributes most latency now. I noticed that Joel mentioned the same
> > > issue[1] on x86 platform and gave two solutions, but it seems no patch
> > > is sent out for this purpose.
> > > 
> > > This patch adopts Joel's first solution, but I use 16MB per core
> > > rather than 8MB per core for the number of lazy_max_pages. After this
> > > patch, the preemptoff tracer reports a max 6455us latency, reduced to
> > > 1/4 of original result.  
> > 
> > My understanding is that
> > 
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index 91f44e78c516..3f7c6d6969ac 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -626,7 +626,6 @@ void set_iounmap_nonlazy(void)
> >  static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
> >                                         int sync, int force_flush)
> >  {
> > -       static DEFINE_SPINLOCK(purge_lock);
> >         struct llist_node *valist;
> >         struct vmap_area *va;
> >         struct vmap_area *n_va;
> > @@ -637,12 +636,6 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
> >          * should not expect such behaviour. This just simplifies locking for
> >          * the case that isn't actually used at the moment anyway.
> >          */
> > -       if (!sync && !force_flush) {
> > -               if (!spin_trylock(&purge_lock))
> > -                       return;
> > -       } else
> > -               spin_lock(&purge_lock);
> > -
> >         if (sync)
> >                 purge_fragmented_blocks_allcpus();
> >  
> > @@ -667,7 +660,6 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
> >                         __free_vmap_area(va);
> >                 spin_unlock(&vmap_area_lock);
> 
> Hi Chris,
> 
> Per my test, the bottleneck now is __free_vmap_area() over the valist, the
> iteration is protected with spinlock vmap_area_lock. So the larger lazy max
> pages, the longer valist, the bigger the latency.
> 
> So besides above patch, we still need to remove vmap_are_lock or replace with
> mutex.

Or follow up with

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 3f7c6d6969ac..67b5475f0b0a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -656,8 +656,10 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
 
        if (nr) {
                spin_lock(&vmap_area_lock);
-               llist_for_each_entry_safe(va, n_va, valist, purge_list)
+               llist_for_each_entry_safe(va, n_va, valist, purge_list) {
                        __free_vmap_area(va);
+                       cond_resched_lock(&vmap_area_lock);
+               }
                spin_unlock(&vmap_area_lock);
        }
 }

?
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
