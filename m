Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7743C6B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 17:17:37 -0400 (EDT)
Received: by qgt47 with SMTP id 47so53635228qgt.2
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 14:17:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o84si30139583qkh.77.2015.10.08.14.17.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 14:17:36 -0700 (PDT)
Date: Thu, 8 Oct 2015 14:17:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] slab_common: clear pointers to per memcg caches on
 destroy
Message-Id: <20151008141735.d545d3fa1ab0244f69c41cdf@linux-foundation.org>
In-Reply-To: <833ae913932949814d1063e11248e6747d0c3a2b.1444319304.git.vdavydov@virtuozzo.com>
References: <6a18aab2f1c3088377d7fd2207b4cc1a1a743468.1444319304.git.vdavydov@virtuozzo.com>
	<833ae913932949814d1063e11248e6747d0c3a2b.1444319304.git.vdavydov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 8 Oct 2015 19:02:40 +0300 Vladimir Davydov <vdavydov@virtuozzo.com> wrote:

> Currently, we do not clear pointers to per memcg caches in the
> memcg_params.memcg_caches array when a global cache is destroyed with
> kmem_cache_destroy. It is fine if the global cache does get destroyed.
> However, a cache can be left on the list if it still has active objects
> when kmem_cache_destroy is called (due to a memory leak). If this
> happens, the entries in the array will point to already freed areas,
> which is likely to result in data corruption when the cache is reused
> (via slab merging).

It's important that we report these leaks so the kernel bug can get
fixed.  The patch doesn't add such detection and reporting, but it
could do so?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
