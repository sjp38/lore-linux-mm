Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA396B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 04:08:52 -0400 (EDT)
Received: by lbbwt4 with SMTP id wt4so72366470lbb.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 01:08:51 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id uk5si288056lbb.90.2015.10.09.01.08.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 01:08:51 -0700 (PDT)
Date: Fri, 9 Oct 2015 11:08:36 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 2/3] slab_common: clear pointers to per memcg caches on
 destroy
Message-ID: <20151009080835.GC2302@esperanza>
References: <6a18aab2f1c3088377d7fd2207b4cc1a1a743468.1444319304.git.vdavydov@virtuozzo.com>
 <833ae913932949814d1063e11248e6747d0c3a2b.1444319304.git.vdavydov@virtuozzo.com>
 <20151008141735.d545d3fa1ab0244f69c41cdf@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151008141735.d545d3fa1ab0244f69c41cdf@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 08, 2015 at 02:17:35PM -0700, Andrew Morton wrote:
> On Thu, 8 Oct 2015 19:02:40 +0300 Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> 
> > Currently, we do not clear pointers to per memcg caches in the
> > memcg_params.memcg_caches array when a global cache is destroyed with
> > kmem_cache_destroy. It is fine if the global cache does get destroyed.
> > However, a cache can be left on the list if it still has active objects
> > when kmem_cache_destroy is called (due to a memory leak). If this
> > happens, the entries in the array will point to already freed areas,
> > which is likely to result in data corruption when the cache is reused
> > (via slab merging).
> 
> It's important that we report these leaks so the kernel bug can get
> fixed.  The patch doesn't add such detection and reporting, but it
> could do so?

Reporting individual leaks is up to the slab implementation, we simply
can't do it from the generic code, so we just warn that there is a leak
there. SLUB already dumps addresses of all leaked objects to the log
(see kmem_cache_close -> free_partial -> list_slab_objects).

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
