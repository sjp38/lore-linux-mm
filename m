Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 128156B004F
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 07:31:38 -0400 (EDT)
Date: Wed, 10 Jun 2009 19:32:14 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-ID: <20090610113214.GA5657@localhost>
References: <20090609190128.GA1785@cmpxchg.org> <20090609193702.GA2017@cmpxchg.org> <20090610050342.GA8867@localhost> <20090610074508.GA1960@cmpxchg.org> <20090610081132.GA27519@localhost> <20090610173249.50e19966.kamezawa.hiroyu@jp.fujitsu.com> <20090610085638.GA32511@localhost> <1244626976.13761.11593.camel@twins> <20090610095950.GA514@localhost> <1244628314.13761.11617.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1244628314.13761.11617.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 10, 2009 at 06:05:14PM +0800, Peter Zijlstra wrote:
> On Wed, 2009-06-10 at 17:59 +0800, Wu Fengguang wrote:
> > On Wed, Jun 10, 2009 at 05:42:56PM +0800, Peter Zijlstra wrote:
> > > On Wed, 2009-06-10 at 16:56 +0800, Wu Fengguang wrote:
> > > > 
> > > > Yes it worked!  But then I run into page allocation failures:
> > > > 
> > > > [  340.639803] Xorg: page allocation failure. order:4, mode:0x40d0
> > > > [  340.645744] Pid: 3258, comm: Xorg Not tainted 2.6.30-rc8-mm1 #303
> > > > [  340.651839] Call Trace:
> > > > [  340.654289]  [<ffffffff810c8204>] __alloc_pages_nodemask+0x344/0x6c0
> > > > [  340.660645]  [<ffffffff810f7489>] __slab_alloc_page+0xb9/0x3b0
> > > > [  340.666472]  [<ffffffff810f8608>] __kmalloc+0x198/0x250
> > > > [  340.671786]  [<ffffffffa014bf9f>] ? i915_gem_execbuffer+0x17f/0x11e0 [i915]
> > > > [  340.678746]  [<ffffffffa014bf9f>] i915_gem_execbuffer+0x17f/0x11e0 [i915]
> > > 
> > > Jesse Barnes had a patch to add a vmalloc fallback to those largish kms
> > > allocs.
> > > 
> > > But order-4 allocs failing isn't really strange, but it might indicate
> > > this patch fragments stuff sooner, although I've seen these particular
> > > failues before.
> > 
> > Thanks for the tip. Where is it? I'd like to try it out :)
> 
> commit 8e7d2b2c6ecd3c21a54b877eae3d5be48292e6b5
> Author: Jesse Barnes <jbarnes@virtuousgeek.org>
> Date:   Fri May 8 16:13:25 2009 -0700
> 
>     drm/i915: allocate large pointer arrays with vmalloc

Thanks! It is already in the -mm tree, but it missed on conversion :)

I'll retry with this patch tomorrow.

Thanks,
Fengguang
---

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 39f5c65..7132dbe 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -3230,8 +3230,8 @@ i915_gem_execbuffer(struct drm_device *dev, void *data,
 	}
 
 	if (args->num_cliprects != 0) {
-		cliprects = drm_calloc(args->num_cliprects, sizeof(*cliprects),
-				       DRM_MEM_DRIVER);
+		cliprects = drm_calloc_large(args->num_cliprects,
+					     sizeof(*cliprects));
 		if (cliprects == NULL)
 			goto pre_mutex_err;
 
@@ -3474,8 +3474,7 @@ err:
 pre_mutex_err:
 	drm_free_large(object_list);
 	drm_free_large(exec_list);
-	drm_free(cliprects, sizeof(*cliprects) * args->num_cliprects,
-		 DRM_MEM_DRIVER);
+	drm_free_large(cliprects);
 
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
