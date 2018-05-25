Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D17EB6B000D
	for <linux-mm@kvack.org>; Fri, 25 May 2018 04:11:58 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id t15-v6so3578227wrm.3
        for <linux-mm@kvack.org>; Fri, 25 May 2018 01:11:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5-v6si1917153edx.293.2018.05.25.01.11.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 May 2018 01:11:57 -0700 (PDT)
Date: Fri, 25 May 2018 10:11:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] doc: document scope NOFS, NOIO APIs
Message-ID: <20180525081155.GG11881@dhcp22.suse.cz>
References: <20180424183536.GF30619@thunk.org>
 <20180524114341.1101-1-mhocko@kernel.org>
 <20180524145202.7d5a55c3@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180524145202.7d5a55c3@lwn.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, "Darrick J. Wong" <darrick.wong@oracle.com>, David Sterba <dsterba@suse.cz>

On Thu 24-05-18 14:52:02, Jonathan Corbet wrote:
> On Thu, 24 May 2018 13:43:41 +0200
> Michal Hocko <mhocko@kernel.org> wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Although the api is documented in the source code Ted has pointed out
> > that there is no mention in the core-api Documentation and there are
> > people looking there to find answers how to use a specific API.
> > 
> > Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
> > Cc: David Sterba <dsterba@suse.cz>
> > Requested-by: "Theodore Y. Ts'o" <tytso@mit.edu>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> > 
> > Hi Johnatan,
> > Ted has proposed this at LSFMM and then we discussed that briefly on the
> > mailing list [1]. I received some useful feedback from Darrick and Dave
> > which has been (hopefully) integrated. Then the thing fall off my radar
> > rediscovering it now when doing some cleanup. Could you take the patch
> > please?
> > 
> > [1] http://lkml.kernel.org/r/20180424183536.GF30619@thunk.org
> >  .../core-api/gfp_mask-from-fs-io.rst          | 55 +++++++++++++++++++
> >  1 file changed, 55 insertions(+)
> >  create mode 100644 Documentation/core-api/gfp_mask-from-fs-io.rst
> 
> So you create the rst file, but don't add it in index.rst; that means it
> won't be a part of the docs build and Sphinx will complain.

I am not really familiar with how the whole rst thing works.

diff --git a/Documentation/core-api/index.rst b/Documentation/core-api/index.rst
index c670a8031786..8a5f48ef16f2 100644
--- a/Documentation/core-api/index.rst
+++ b/Documentation/core-api/index.rst
@@ -25,6 +25,7 @@ Core utilities
    genalloc
    errseq
    printk-formats
+   gfp_mask-from-fs-io
 
 Interfaces for kernel debugging
 ===============================

This?

> 
> > diff --git a/Documentation/core-api/gfp_mask-from-fs-io.rst b/Documentation/core-api/gfp_mask-from-fs-io.rst
> > new file mode 100644
> > index 000000000000..e8b2678e959b
> > --- /dev/null
> > +++ b/Documentation/core-api/gfp_mask-from-fs-io.rst
> > @@ -0,0 +1,55 @@
> > +=================================
> > +GFP masks used from FS/IO context
> > +=================================
> > +
> > +:Date: Mapy, 2018
> 
> Ah...the wonderful month of Mapy....:)

fixed

> > +:Author: Michal Hocko <mhocko@kernel.org>
> > +
> > +Introduction
> > +============
> > +
> > +Code paths in the filesystem and IO stacks must be careful when
> > +allocating memory to prevent recursion deadlocks caused by direct
> > +memory reclaim calling back into the FS or IO paths and blocking on
> > +already held resources (e.g. locks - most commonly those used for the
> > +transaction context).
> > +
> > +The traditional way to avoid this deadlock problem is to clear __GFP_FS
> > +resp. __GFP_IO (note the later implies clearing the first as well) in
> 
> "resp." is indeed a bit terse.  Even spelled out as "respectively", though,

OK s@resp\.@respectively@g

> I'm not sure what the word is intended to mean here.  Did you mean "or"?

Basically yes. There are two cases here. NOFS and NOIO. The later being
a subset of the first. I didn't really want to repeat the whole thing
for NOIO.

> 
> > +the gfp mask when calling an allocator. GFP_NOFS resp. GFP_NOIO can be
> 
> Here too.
> 
> > +used as shortcut. It turned out though that above approach has led to
> > +abuses when the restricted gfp mask is used "just in case" without a
> > +deeper consideration which leads to problems because an excessive use
> > +of GFP_NOFS/GFP_NOIO can lead to memory over-reclaim or other memory
> > +reclaim issues.
> > +
> > +New API
> > +========
> > +
> > +Since 4.12 we do have a generic scope API for both NOFS and NOIO context
> > +``memalloc_nofs_save``, ``memalloc_nofs_restore`` resp. ``memalloc_noio_save``,
> > +``memalloc_noio_restore`` which allow to mark a scope to be a critical
> > +section from the memory reclaim recursion into FS/IO POV. Any allocation
> 
> "from a filesystem or I/O point of view" ?

OK

> > +from that scope will inherently drop __GFP_FS resp. __GFP_IO from the given
> > +mask so no memory allocation can recurse back in the FS/IO.
> 
> Wouldn't it be nice if those functions had kerneldoc comments that could be
> pulled in here! :)

Most probably yes ;) I thought I've done that but that was probably in a
different universe. This probably?

diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
index e1f8411e6b80..f49ece8ee37a 100644
--- a/include/linux/sched/mm.h
+++ b/include/linux/sched/mm.h
@@ -166,6 +166,17 @@ static inline void fs_reclaim_acquire(gfp_t gfp_mask) { }
 static inline void fs_reclaim_release(gfp_t gfp_mask) { }
 #endif
 
+/**
+ * memalloc_noio_save - Marks implicit GFP_NOIO allocation scope.
+ *
+ * This functions marks the beginning of the GFP_NOIO allocation scope.
+ * All further allocations will implicitly drop __GFP_IO flag and so
+ * they are safe for the IO critical section from the allocation recursion
+ * point of view. Use memalloc_noio_restore to end the scope with flags
+ * returned by this function.
+ *
+ * This function is safe to be used from any context.
+ */
 static inline unsigned int memalloc_noio_save(void)
 {
 	unsigned int flags = current->flags & PF_MEMALLOC_NOIO;
@@ -173,11 +184,30 @@ static inline unsigned int memalloc_noio_save(void)
 	return flags;
 }
 
+/**
+ * memalloc_noio_restore - Ends the implicit GFP_NOIO scope.
+ * @flags: Flags to restore.
+ *
+ * Ends the implicit GFP_NOIO scope started by memalloc_noio_save function.
+ * Always make sure that that the given flags is the return value from the
+ * pairing memalloc_noio_save call.
+ */ 
 static inline void memalloc_noio_restore(unsigned int flags)
 {
 	current->flags = (current->flags & ~PF_MEMALLOC_NOIO) | flags;
 }
 
+/**
+ * memalloc_nofs_save - Marks implicit GFP_NOFS allocation scope.
+ *
+ * This functions marks the beginning of the GFP_NOFS allocation scope.
+ * All further allocations will implicitly drop __GFP_FS flag and so
+ * they are safe for the FS critical section from the allocation recursion
+ * point of view. Use memalloc_nofs_restore to end the scope with flags
+ * returned by this function.
+ *
+ * This function is safe to be used from any context.
+ */
 static inline unsigned int memalloc_nofs_save(void)
 {
 	unsigned int flags = current->flags & PF_MEMALLOC_NOFS;
@@ -185,6 +215,14 @@ static inline unsigned int memalloc_nofs_save(void)
 	return flags;
 }
 
+/**
+ * memalloc_nofs_restore - Ends the implicit GFP_NOFS scope.
+ * @flags: Flags to restore.
+ *
+ * Ends the implicit GFP_NOFS scope started by memalloc_nofs_save function.
+ * Always make sure that that the given flags is the return value from the
+ * pairing memalloc_nofs_save call.
+ */ 
 static inline void memalloc_nofs_restore(unsigned int flags)
 {
 	current->flags = (current->flags & ~PF_MEMALLOC_NOFS) | flags;

> > +FS/IO code then simply calls the appropriate save function right at the
> > +layer where a lock taken from the reclaim context (e.g. shrinker) and
> 
> where a lock *is* taken ?

fixed
 
-- 
Michal Hocko
SUSE Labs
