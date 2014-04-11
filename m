Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 378BE6B0038
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 13:33:22 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id e16so3728847lan.2
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 10:33:20 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id h8si6012699lam.53.2014.04.11.10.33.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Apr 2014 10:33:19 -0700 (PDT)
Message-ID: <53482754.1090102@parallels.com>
Date: Fri, 11 Apr 2014 21:33:08 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2.2] mm: get rid of __GFP_KMEMCG
References: <1396419365-351-1-git-send-email-vdavydov@parallels.com> <1396537559-17453-1-git-send-email-vdavydov@parallels.com> <alpine.DEB.2.10.1404111104550.13278@nuc>
In-Reply-To: <alpine.DEB.2.10.1404111104550.13278@nuc>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@gmail.com>, Pekka Enberg <penberg@kernel.org>

On 04/11/2014 08:07 PM, Christoph Lameter wrote:
> On Thu, 3 Apr 2014, Vladimir Davydov wrote:
>
>> --- a/include/linux/slab.h
>> +++ b/include/linux/slab.h
>> @@ -358,16 +358,7 @@ kmem_cache_alloc_node_trace(struct kmem_cache *s,
>>  #include <linux/slub_def.h>
>>  #endif
>>
>> -static __always_inline void *
>> -kmalloc_order(size_t size, gfp_t flags, unsigned int order)
>> -{
>> -	void *ret;
>> -
>> -	flags |= (__GFP_COMP | __GFP_KMEMCG);
>> -	ret = (void *) __get_free_pages(flags, order);
>> -	kmemleak_alloc(ret, size, 1, flags);
>> -	return ret;
>> -}
>> +extern void *kmalloc_order(size_t size, gfp_t flags, unsigned int order);
>
> Hmmm... This was intentional inlined to allow inline expansion for calls
> to kmalloc with large constants. The inline expansion directly converts
> these calls to page allocator calls avoiding slab overhead.

I moved kmalloc_order() to slab_common.c, because I can't call
alloc_kmem_pages() directly from the header (we don't have
page_address() defined there, and including mm.h to slab.h wouldn't be
good I think), and I don't want to introduce __get_free_kmem_pages().
Sorry that I didn't state this explicitly in the comment to the patch.

However, would it be any better if I introduced __get_free_kmem_pages()
and called it from kmalloc_order(), which could be inlined then? I don't
think so, because I would have to place __get_free_kmem_pages() in
page_alloc.c just like __get_free_pages() (again, because including mm.h
to gfp.h for page_address() isn't an option), and we would get exactly
the same number of function calls.

I admit that this patch adds one extra function call to large kmallocs:

 - before: __get_free_pages -> alloc_pages
 - after: kmalloc_order -> alloc_kmem_pages -> alloc_pages

but that's not because I move kmalloc_order from the header, but rather
because I introduce alloc_kmem_pages, which is not inline.

What can we do to eliminate it? We could place alloc_kmem_pages()
definition to a header file, but since it needs memcontrol.h for kmemcg
charging functions, that would lead to slab.h depending on memcontrol.h
eventually, which is not good IMO.

Alternatively, we could

#ifndef MEMCG_KMEM
# define alloc_kmem_pages alloc_pages
#endif

so that we would avoid any additional overhead if kmemcg is compiled out.

However, do we need to bother about one function call at all? My point
is that one function call can be neglected in case of large kmem
allocations, which are rather rare.

Any thoughts/objections?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
