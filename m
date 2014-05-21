Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id C5B2A6B0037
	for <linux-mm@kvack.org>; Wed, 21 May 2014 11:04:21 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id b8so1684563lan.9
        for <linux-mm@kvack.org>; Wed, 21 May 2014 08:04:20 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id zn10si6973891lbb.51.2014.05.21.08.04.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 May 2014 08:04:19 -0700 (PDT)
Date: Wed, 21 May 2014 19:04:10 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 3/3] slub: reparent memcg caches' slabs on memcg
 offline
Message-ID: <20140521150408.GB23193@esperanza>
References: <6eafe1e95d9a934228e9af785f5b5de38955aa6a.1399982635.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1405141119320.16512@gentwo.org>
 <20140515071650.GB32113@esperanza>
 <alpine.DEB.2.10.1405151015330.24665@gentwo.org>
 <20140516132234.GF32113@esperanza>
 <alpine.DEB.2.10.1405160957100.32249@gentwo.org>
 <20140519152437.GB25889@esperanza>
 <alpine.DEB.2.10.1405191056580.22956@gentwo.org>
 <537A4D27.1050909@parallels.com>
 <alpine.DEB.2.10.1405210937440.8038@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405210937440.8038@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 21, 2014 at 09:41:03AM -0500, Christoph Lameter wrote:
> On Mon, 19 May 2014, Vladimir Davydov wrote:
> 
> > 3) Per cpu partial slabs. We can disable this feature for dead caches by
> > adding appropriate check to kmem_cache_has_cpu_partial.
> 
> There is already a s->cpu_partial number in kmem_cache. If that is zero
> then no partial cpu slabs should be kept.
> 
> > So far, everything looks very simple - it seems we don't have to modify
> > __slab_free at all if we follow the instruction above.
> >
> > However, there is one thing regarding preemptable kernels. The problem
> > is after forbidding the cache store free slabs in per-cpu/node partial
> > lists by setting min_partial=0 and kmem_cache_has_cpu_partial=false
> > (i.e. marking the cache as dead), we have to make sure that all frees
> > that saw the cache as alive are over, otherwise they can occasionally
> > add a free slab to a per-cpu/node partial list *after* the cache was
> > marked dead. For instance,
> 
> Ok then lets switch off preeempt there? Preemption is not supported by
> most distribution and so will have the least impact.

Do I understand you correctly that the following change looks OK to you?

diff --git a/mm/slub.c b/mm/slub.c
index fdf0fe4da9a9..dc3582c2b5bb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2676,31 +2676,31 @@ static __always_inline void slab_free(struct kmem_cache *s,
 redo:
 	/*
 	 * Determine the currently cpus per cpu slab.
 	 * The cpu may change afterward. However that does not matter since
 	 * data is retrieved via this pointer. If we are on the same cpu
 	 * during the cmpxchg then the free will succedd.
 	 */
 	preempt_disable();
 	c = this_cpu_ptr(s->cpu_slab);
 
 	tid = c->tid;
-	preempt_enable();
 
 	if (likely(page == c->page)) {
 		set_freepointer(s, object, c->freelist);
 
 		if (unlikely(!this_cpu_cmpxchg_double(
 				s->cpu_slab->freelist, s->cpu_slab->tid,
 				c->freelist, tid,
 				object, next_tid(tid)))) {
 
 			note_cmpxchg_failure("slab_free", s, tid);
 			goto redo;
 		}
 		stat(s, FREE_FASTPATH);
 	} else
 		__slab_free(s, page, x, addr);
 
+	preempt_enable();
 }
 
 void kmem_cache_free(struct kmem_cache *s, void *x)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
