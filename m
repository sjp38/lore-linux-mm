Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 07A5B6B027D
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 13:02:39 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id u1-v6so2128534pls.16
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 10:02:39 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0134.outbound.protection.outlook.com. [104.47.2.134])
        by mx.google.com with ESMTPS id m77si3113631pfk.56.2018.03.28.10.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 28 Mar 2018 10:02:37 -0700 (PDT)
Subject: Re: [PATCH] slab, slub: skip unnecessary kasan_cache_shutdown()
References: <20180327230603.54721-1-shakeelb@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <3d48de97-0e5f-eba4-0d66-32eb300b79c3@virtuozzo.com>
Date: Wed, 28 Mar 2018 20:03:20 +0300
MIME-Version: 1.0
In-Reply-To: <20180327230603.54721-1-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Alexander Potapenko <glider@google.com>, Greg Thelen <gthelen@google.com>, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 03/28/2018 02:06 AM, Shakeel Butt wrote:
> The kasan quarantine is designed to delay freeing slab objects to catch
> use-after-free. The quarantine can be large (several percent of machine
> memory size). When kmem_caches are deleted related objects are flushed
> from the quarantine but this requires scanning the entire quarantine
> which can be very slow. We have seen the kernel busily working on this
> while holding slab_mutex and badly affecting cache_reaper, slabinfo
> readers and memcg kmem cache creations.
> 
> It can easily reproduced by following script:
> 
> 	yes . | head -1000000 | xargs stat > /dev/null
> 	for i in `seq 1 10`; do
> 		seq 500 | (cd /cg/memory && xargs mkdir)
> 		seq 500 | xargs -I{} sh -c 'echo $BASHPID > \
> 			/cg/memory/{}/tasks && exec stat .' > /dev/null
> 		seq 500 | (cd /cg/memory && xargs rmdir)
> 	done
> 
> The busy stack:
>     kasan_cache_shutdown
>     shutdown_cache
>     memcg_destroy_kmem_caches
>     mem_cgroup_css_free
>     css_free_rwork_fn
>     process_one_work
>     worker_thread
>     kthread
>     ret_from_fork
> 
> This patch is based on the observation that if the kmem_cache to be
> destroyed is empty then there should not be any objects of this cache in
> the quarantine.
> 
> Without the patch the script got stuck for couple of hours. With the
> patch the script completed within a second.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> 

Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
