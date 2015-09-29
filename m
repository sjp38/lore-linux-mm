Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 24CFF6B0255
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 13:20:23 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so11407612pab.3
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 10:20:22 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id ny9si38896585pbb.9.2015.09.29.10.20.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 10:20:22 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so11649351pad.1
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 10:20:22 -0700 (PDT)
Subject: Re: [MM PATCH V4 5/6] slub: support for bulk free with SLUB freelists
References: <20150929154605.14465.98995.stgit@canyon>
 <20150929154807.14465.76422.stgit@canyon> <560ABE86.9050508@gmail.com>
 <20150929190029.01ca01f2@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Message-ID: <560AC854.6040601@gmail.com>
Date: Tue, 29 Sep 2015 10:20:20 -0700
MIME-Version: 1.0
In-Reply-To: <20150929190029.01ca01f2@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, netdev@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 09/29/2015 10:00 AM, Jesper Dangaard Brouer wrote:
> On Tue, 29 Sep 2015 09:38:30 -0700
> Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> On 09/29/2015 08:48 AM, Jesper Dangaard Brouer wrote:
>>> +#if defined(CONFIG_KMEMCHECK) ||		\
>>> +	defined(CONFIG_LOCKDEP)	||		\
>>> +	defined(CONFIG_DEBUG_KMEMLEAK) ||	\
>>> +	defined(CONFIG_DEBUG_OBJECTS_FREE) ||	\
>>> +	defined(CONFIG_KASAN)
>>> +static inline void slab_free_freelist_hook(struct kmem_cache *s,
>>> +					   void *head, void *tail)
>>> +{
>>> +	void *object = head;
>>> +	void *tail_obj = tail ? : head;
>>> +
>>> +	do {
>>> +		slab_free_hook(s, object);
>>> +	} while ((object != tail_obj) &&
>>> +		 (object = get_freepointer(s, object)));
>>> +}
>>> +#else
>>> +static inline void slab_free_freelist_hook(struct kmem_cache *s, void *obj_tail,
>>> +					   void *freelist_head) {}
>>> +#endif
>>> +
>> Instead of messing around with an #else you might just wrap the contents
>> of slab_free_freelist_hook in the #if/#endif instead of the entire
>> function declaration.
> I had it that way in an earlier version of the patch, but I liked
> better this way.

It would be nice if the argument names were the same for both cases.  
Having the names differ will make it more difficult to maintain when 
changes need to be made to the function.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
