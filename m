Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 984EDC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 14:59:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3578E2075E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 14:59:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3578E2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88C516B0003; Thu, 28 Mar 2019 10:59:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 839F26B0006; Thu, 28 Mar 2019 10:59:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DB206B0008; Thu, 28 Mar 2019 10:59:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0DA6B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 10:59:25 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n12so8246124edo.5
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 07:59:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Ba9d6EtHWkFGUjKOk6FlkN9WpPcplVvzWgnJ9rYRuwQ=;
        b=paXqK6xySxkTHFBr+mvTG2ucxlt+iC7ufeaHiD12l4RIei35cjZrj5PwcAKhy7A+yB
         Cm/PsVZAD6gtPxmnQmZ7ttZljK2W4zqp2pFo+RgKRA8j1YOoENzUWfe9C5KcFMLXvHlv
         hP8vZ0qCSjTSlOF+CdrNow/jTUzvEjZVp+/NC3WChVievTb0+6z5zcuoYn2umo3wxYFr
         TyyiH0Q6NxM9GwHI8vf2f6qqcykgvZEy7QsKIy6W+ny9Jx07PoDUrCxzLDhx9M/vDq7Q
         8u5UWHYg4vZFA9VQNAQnfftZ/iS07LYgnWI+PVyfjyo9tFlfLP6HOZOsFoeNnJxFRakx
         Dkww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVUTo9hgV4OFjFUEIMK13mUeeO5fPBmabuJWfVkNsCbqnkiVhjx
	wavgBEKBNVZyqsAIrgaxGFG0qjb3s7aEY1JpF02hJelEf4fn+7SWbv7sfblds2+xdoEGSLRyoeL
	pescXjLN3rpMNOf+UlR1yEJ1S5yz17QYbFYwGle0NENlTs9SaVFb4fkHjM0G26755PA==
X-Received: by 2002:a50:c982:: with SMTP id w2mr9315006edh.47.1553785164647;
        Thu, 28 Mar 2019 07:59:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPaalXePIX6B5JMuL8fkRkcUdzu4S2FmfGcDPOknL653A6rvXbJaX9znD+9iXNt5stL9OQ
X-Received: by 2002:a50:c982:: with SMTP id w2mr9314941edh.47.1553785163398;
        Thu, 28 Mar 2019 07:59:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553785163; cv=none;
        d=google.com; s=arc-20160816;
        b=w00IMO8OxvrwXU4Jq0MfTaucLvLvut0drhxZ0+z5J+ZQWXsCbHxcA24OPQPpotbhdf
         MRgoiibHNpDV0GJjVzhIbSGjOG2Tqh9SNJoYSZH9WklLeIasEKhXNVPPwX89BKv+gzku
         H80yvQ5alJVABFvcxOSqqiblLApfY6Ov+19piJkg7SfKiGy7ojBcfAteJV49WPvIylMH
         uO8O7g1GFPCn2ETtRADfOvBVcE3wgbOgrXFFa9L0C46yTXZAwj/9zfSw5p2c82OBBsGM
         hjOOpJxQZHivRGBckr/iq7ssY8jImI9omNU5UEAhgAPhNORPjMMoc3MQbLoLQkLeJwcE
         6z4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Ba9d6EtHWkFGUjKOk6FlkN9WpPcplVvzWgnJ9rYRuwQ=;
        b=SqRmY7HAlLlWeDEZos0Pxr2gxyFo9e6gsb3pjLMIIuPDkIivYtnvNoruC+ll6zuw4o
         c08s75z5mGYlzy7T9DAznmlXrtMETzPMo1iXNo60w2x2Er1r6uCxVNLToUc0sAjUR9Y6
         tpvHdxZKcB0Knv0rJlEMC+nK8astT/HigI6LbJESWWywxFtJRTd+cTp8CLy6VnTG61Pa
         10S+4KB9rbna0f4v55hPYK9ug63c1+0GYUbJrJ37O5dK5+Rd1XG6vo65/nkEdJjT4Z82
         tobDThexZPKEDWRGLEhG2Lq+n8GKaT8Y+Uzlwod5lbYTl7sRRkQUWSxhzoMwI4pMtONP
         55/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e17si8406382edj.59.2019.03.28.07.59.22
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 07:59:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F158F15AB;
	Thu, 28 Mar 2019 07:59:21 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 069113F575;
	Thu, 28 Mar 2019 07:59:19 -0700 (PDT)
Date: Thu, 28 Mar 2019 14:59:17 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Qian Cai <cai@lca.pw>,
	akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org,
	rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] kmemleak: survive in a low-memory situation
Message-ID: <20190328145917.GC10283@arrakis.emea.arm.com>
References: <20190327005948.24263-1-cai@lca.pw>
 <20190327084432.GA11927@dhcp22.suse.cz>
 <20190327172955.GB17247@arrakis.emea.arm.com>
 <20190327182158.GS10344@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190327182158.GS10344@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 27, 2019 at 11:21:58AM -0700, Matthew Wilcox wrote:
> On Wed, Mar 27, 2019 at 05:29:57PM +0000, Catalin Marinas wrote:
> > On Wed, Mar 27, 2019 at 09:44:32AM +0100, Michal Hocko wrote:
> > > As long as there is an implicit __GFP_NOFAIL then kmemleak is simply
> > > broken no matter what other gfp flags you play with. Has anybody looked
> > > at some sort of preallocation where gfpflags_allow_blocking context
> > > allocate objects into a pool that non-sleeping allocations can eat from?
> > 
> > Quick attempt below and it needs some more testing (pretty random pick
> > of the EMERGENCY_POOL_SIZE value). Also, with __GFP_NOFAIL removed, are
> > the other flags safe or we should trim them further?
> 
> Why not use mempool?

I had the wrong impression that it could sleep but it's only if
__GFP_DIRECT_RECLAIM is passed. See below for an updated patch.

> >  #define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
> >  				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
> > -				 __GFP_NOWARN | __GFP_NOFAIL)
> > +				 __GFP_NOWARN)
> 
> Why GFP_NORETRY?  And if I have specified one of the other retry policies
> in my gfp flags, you should presumably clear that off before setting
> GFP_NORETRY.

It only preserves GFP_KERNEL|GFP_ATOMIC from the original flags
while setting the NOWARN|NORETRY|NOMEMALLOC (the same flags seem to be
set by mempool_alloc()). Anyway, with the changes below, I'll let
mempool add the relevant flags while kmemleak only passes
GFP_KERNEL|GFP_ATOMIC from the original caller.

-----------------------8<------------------------------------------
From 09eba8f0235eb16409931e6aad77a45a12bedc82 Mon Sep 17 00:00:00 2001
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Thu, 28 Mar 2019 13:26:07 +0000
Subject: [PATCH] mm: kmemleak: Use mempool allocations for kmemleak objects

This patch adds mempool allocations for struct kmemleak_object and
kmemleak_scan_area as slightly more resilient than kmem_cache_alloc()
under memory pressure. The patch also masks out all the gfp flags passed
to kmemleak other than GFP_KERNEL|GFP_ATOMIC.

Suggested-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
---
 mm/kmemleak.c | 34 +++++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 9 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 6c318f5ac234..9755678e83b9 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -82,6 +82,7 @@
 #include <linux/kthread.h>
 #include <linux/rbtree.h>
 #include <linux/fs.h>
+#include <linux/mempool.h>
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
 #include <linux/cpumask.h>
@@ -125,9 +126,7 @@
 #define BYTES_PER_POINTER	sizeof(void *)
 
 /* GFP bitmask for kmemleak internal allocations */
-#define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
-				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
-				 __GFP_NOWARN | __GFP_NOFAIL)
+#define gfp_kmemleak_mask(gfp)	((gfp) & (GFP_KERNEL | GFP_ATOMIC))
 
 /* scanning area inside a memory block */
 struct kmemleak_scan_area {
@@ -191,6 +190,9 @@ struct kmemleak_object {
 #define HEX_ASCII		1
 /* max number of lines to be printed */
 #define HEX_MAX_LINES		2
+/* minimum memory pool sizes */
+#define MIN_OBJECT_POOL		(NR_CPUS * 4)
+#define MIN_SCAN_AREA_POOL	(NR_CPUS * 1)
 
 /* the list of all allocated objects */
 static LIST_HEAD(object_list);
@@ -203,7 +205,9 @@ static DEFINE_RWLOCK(kmemleak_lock);
 
 /* allocation caches for kmemleak internal data */
 static struct kmem_cache *object_cache;
+static mempool_t *object_mempool;
 static struct kmem_cache *scan_area_cache;
+static mempool_t *scan_area_mempool;
 
 /* set if tracing memory operations is enabled */
 static int kmemleak_enabled;
@@ -483,9 +487,9 @@ static void free_object_rcu(struct rcu_head *rcu)
 	 */
 	hlist_for_each_entry_safe(area, tmp, &object->area_list, node) {
 		hlist_del(&area->node);
-		kmem_cache_free(scan_area_cache, area);
+		mempool_free(area, scan_area_mempool);
 	}
-	kmem_cache_free(object_cache, object);
+	mempool_free(object, object_mempool);
 }
 
 /*
@@ -576,7 +580,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	struct rb_node **link, *rb_parent;
 	unsigned long untagged_ptr;
 
-	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
+	object = mempool_alloc(object_mempool, gfp_kmemleak_mask(gfp));
 	if (!object) {
 		pr_warn("Cannot allocate a kmemleak_object structure\n");
 		kmemleak_disable();
@@ -640,7 +644,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 			 * be freed while the kmemleak_lock is held.
 			 */
 			dump_object_info(parent);
-			kmem_cache_free(object_cache, object);
+			mempool_free(object, object_mempool);
 			object = NULL;
 			goto out;
 		}
@@ -798,7 +802,7 @@ static void add_scan_area(unsigned long ptr, size_t size, gfp_t gfp)
 		return;
 	}
 
-	area = kmem_cache_alloc(scan_area_cache, gfp_kmemleak_mask(gfp));
+	area = mempool_alloc(scan_area_mempool, gfp_kmemleak_mask(gfp));
 	if (!area) {
 		pr_warn("Cannot allocate a scan area\n");
 		goto out;
@@ -810,7 +814,7 @@ static void add_scan_area(unsigned long ptr, size_t size, gfp_t gfp)
 	} else if (ptr + size > object->pointer + object->size) {
 		kmemleak_warn("Scan area larger than object 0x%08lx\n", ptr);
 		dump_object_info(object);
-		kmem_cache_free(scan_area_cache, area);
+		mempool_free(area, scan_area_mempool);
 		goto out_unlock;
 	}
 
@@ -2049,6 +2053,18 @@ void __init kmemleak_init(void)
 
 	object_cache = KMEM_CACHE(kmemleak_object, SLAB_NOLEAKTRACE);
 	scan_area_cache = KMEM_CACHE(kmemleak_scan_area, SLAB_NOLEAKTRACE);
+	if (!object_cache || !scan_area_cache) {
+		kmemleak_disable();
+		return;
+	}
+	object_mempool = mempool_create_slab_pool(MIN_OBJECT_POOL,
+						  object_cache);
+	scan_area_mempool = mempool_create_slab_pool(MIN_SCAN_AREA_POOL,
+						     scan_area_cache);
+	if (!object_mempool || !scan_area_mempool) {
+		kmemleak_disable();
+		return;
+	}
 
 	if (crt_early_log > ARRAY_SIZE(early_log))
 		pr_warn("Early log buffer exceeded (%d), please increase DEBUG_KMEMLEAK_EARLY_LOG_SIZE\n",

