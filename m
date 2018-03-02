Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1033D6B0003
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 07:09:51 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u65so5215584pfd.7
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 04:09:51 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0118.outbound.protection.outlook.com. [104.47.1.118])
        by mx.google.com with ESMTPS id c8-v6si2542039pli.418.2018.03.02.04.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 02 Mar 2018 04:09:49 -0800 (PST)
Subject: Re: [PATCH] kasan, slub: fix handling of kasan_slab_free hook
References: <083f58501e54731203801d899632d76175868e97.1519400992.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <26dd94c5-19ca-dca6-07b8-7103f53c0130@virtuozzo.com>
Date: Fri, 2 Mar 2018 15:10:21 +0300
MIME-Version: 1.0
In-Reply-To: <083f58501e54731203801d899632d76175868e97.1519400992.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com
Cc: Kostya Serebryany <kcc@google.com>

On 02/23/2018 06:53 PM, Andrey Konovalov wrote:
> The kasan_slab_free hook's return value denotes whether the reuse of a
> slab object must be delayed (e.g. when the object is put into memory
> qurantine).
> 
> The current way SLUB handles this hook is by ignoring its return value
> and hardcoding checks similar (but not exactly the same) to the ones
> performed in kasan_slab_free, which is prone to making mistakes.
> 

What are those differences exactly? And what problems do they cause?
Answers to these questions should be in the changelog.


> This patch changes the way SLUB handles this by:
> 1. taking into account the return value of kasan_slab_free for each of
>    the objects, that are being freed;
> 2. reconstructing the freelist of objects to exclude the ones, whose
>    reuse must be delayed.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---




>  
> @@ -2965,14 +2974,13 @@ static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
>  				      void *head, void *tail, int cnt,
>  				      unsigned long addr)
>  {
> -	slab_free_freelist_hook(s, head, tail);
>  	/*
> -	 * slab_free_freelist_hook() could have put the items into quarantine.
> -	 * If so, no need to free them.
> +	 * With KASAN enabled slab_free_freelist_hook modifies the freelist
> +	 * to remove objects, whose reuse must be delayed.
>  	 */
> -	if (s->flags & SLAB_KASAN && !(s->flags & SLAB_TYPESAFE_BY_RCU))
> -		return;
> -	do_slab_free(s, page, head, tail, cnt, addr);
> +	slab_free_freelist_hook(s, &head, &tail);
> +	if (head != NULL)

That's an additional branch in non-debug fast-path. Find a way to avoid this.


> +		do_slab_free(s, page, head, tail, cnt, addr);
>  }
>  
>  #ifdef CONFIG_KASAN
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
