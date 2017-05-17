Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 72B746B02EE
	for <linux-mm@kvack.org>; Wed, 17 May 2017 03:44:57 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id r58so1583433qtb.0
        for <linux-mm@kvack.org>; Wed, 17 May 2017 00:44:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w52si1340216qth.166.2017.05.17.00.44.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 00:44:56 -0700 (PDT)
Date: Wed, 17 May 2017 09:44:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] drm: use kvmalloc_array for drm_malloc*
Message-ID: <20170517074453.GC18247@dhcp22.suse.cz>
References: <20170516090606.5891-1-mhocko@kernel.org>
 <20170516093119.GW19912@nuc-i3427.alporthouse.com>
 <20170516105352.GH2481@dhcp22.suse.cz>
 <20170516110908.GE26693@nuc-i3427.alporthouse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170516110908.GE26693@nuc-i3427.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, Sean Paul <seanpaul@chromium.org>, David Airlie <airlied@linux.ie>

On Tue 16-05-17 12:09:08, Chris Wilson wrote:
> On Tue, May 16, 2017 at 12:53:52PM +0200, Michal Hocko wrote:
> > On Tue 16-05-17 10:31:19, Chris Wilson wrote:
> > > On Tue, May 16, 2017 at 11:06:06AM +0200, Michal Hocko wrote:
> > > > From: Michal Hocko <mhocko@suse.com>
> > > > 
> > > > drm_malloc* has grown their own kmalloc with vmalloc fallback
> > > > implementations. MM has grown kvmalloc* helpers in the meantime. Let's
> > > > use those because it a) reduces the code and b) MM has a better idea
> > > > how to implement fallbacks (e.g. do not vmalloc before kmalloc is tried
> > > > with __GFP_NORETRY).
> > > 
> > > Better? The same idea. The only difference I was reluctant to hand out
> > > large pages for long lived objects. If that's the wisdom of the core mm,
> > > so be it.
> > 
> > vmalloc tends to fragment physical memory more os it is preferable to
> > try the physically contiguous request first and only fall back to
> > vmalloc if the first attempt would be too costly or it fails.
> 
> Not relevant for the changelog in this patch, but it would be nice to
> have that written in kvmalloc() as to why the scatterring of 4k vmapped
> pages prevents defragmentation when compared to allocating large pages.

Well, it is not as much about defragmentation because both vmapped and
kmalloc allocations are very likely to be unmovable (at least
currently). Theoretically there shouldn't be a problem to make vmapped
pages movable as the ptes can be modified but this is not implemented...
The problem is that vmapped pages are more likely to break up more
larger order blocks. kmalloc will naturally break a single larger block.

> I have vague recollections of seeing the conversation, but a summary as
> to the reason why kvmalloc prefers large pages will be good for future
> reference.

Does the following sound better to you?

diff --git a/mm/util.c b/mm/util.c
index 464df3489903..87499f8119f2 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -357,7 +357,10 @@ void *kvmalloc_node(size_t size, gfp_t flags, int node)
 	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
 
 	/*
-	 * Make sure that larger requests are not too disruptive - no OOM
+	 * We want to attempt a large physically contiguous block first because
+	 * it is less likely to fragment multiple larger blocks and therefore
+	 * contribute to a long term fragmentation less than vmalloc fallback.
+	 * However make sure that larger requests are not too disruptive - no OOM
 	 * killer and no allocation failure warnings as we have a fallback
 	 */
 	if (size > PAGE_SIZE) {

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
