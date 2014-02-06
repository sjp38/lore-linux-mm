Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id EFE1A6B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:22:05 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id n15so2084651lbi.11
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:22:05 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id b8si633685lah.158.2014.02.06.06.15.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Feb 2014 06:16:23 -0800 (PST)
Message-ID: <52F39916.2040603@parallels.com>
Date: Thu, 6 Feb 2014 18:15:50 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/8] memcg, slab: never try to merge memcg caches
References: <cover.1391356789.git.vdavydov@parallels.com> <27c4e7d7fb6b788b66995d2523225ef2dcbc6431.1391356789.git.vdavydov@parallels.com> <20140204145210.GH4890@dhcp22.suse.cz> <52F1004B.90307@parallels.com> <20140204151145.GI4890@dhcp22.suse.cz> <52F106D7.3060802@parallels.com> <20140206140707.GF20269@dhcp22.suse.cz>
In-Reply-To: <20140206140707.GF20269@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On 02/06/2014 06:07 PM, Michal Hocko wrote:
> On Tue 04-02-14 19:27:19, Vladimir Davydov wrote:
> [...]
>> What does this patch change? Actually, it introduces no functional
>> changes - it only remove the code trying to find an alias for a memcg
>> cache, because it will fail anyway. So this is rather a cleanup.
> But this also means that two different memcgs might share the same cache
> and so the pages for that cache, no?

No, because in this patch I explicitly forbid to merge memcg caches by
this hunk:

@@ -200,9 +200,11 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg,
const char *name, size_t size,
      */
     flags &= CACHE_CREATE_MASK;
 
-    s = __kmem_cache_alias(memcg, name, size, align, flags, ctor);
-    if (s)
-        goto out_unlock;
+    if (!memcg) {
+        s = __kmem_cache_alias(name, size, align, flags, ctor);
+        if (s)
+            goto out_unlock;
+    }

Thanks.

> Actually it would depend on timing
> because a new page would be chaged for the current allocator.
>
> cachep->memcg_params->memcg == memcg would prevent from such a merge
> previously AFAICS, or am I still confused?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
