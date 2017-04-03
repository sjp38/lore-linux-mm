Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CEFAB6B0038
	for <linux-mm@kvack.org>; Sun,  2 Apr 2017 23:40:52 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u195so66798336pgb.1
        for <linux-mm@kvack.org>; Sun, 02 Apr 2017 20:40:52 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id v21si12811021pgi.239.2017.04.02.20.40.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 02 Apr 2017 20:40:51 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] mm: Add additional consistency check
In-Reply-To: <CAGXu5jK8RrHwa1Uv464=5+T5iBnhhx796CdLcJMAA88wi8bzaA@mail.gmail.com>
References: <20170331164028.GA118828@beast> <20170331143317.3865149a6b6112f0d1a63499@linux-foundation.org> <CAGXu5jK8RrHwa1Uv464=5+T5iBnhhx796CdLcJMAA88wi8bzaA@mail.gmail.com>
Date: Mon, 03 Apr 2017 13:40:47 +1000
Message-ID: <874ly6gnuo.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Kees Cook <keescook@chromium.org> writes:

> On Fri, Mar 31, 2017 at 2:33 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Fri, 31 Mar 2017 09:40:28 -0700 Kees Cook <keescook@chromium.org> wrote:
>>
>>> As found in PaX, this adds a cheap check on heap consistency, just to
>>> notice if things have gotten corrupted in the page lookup.
>>
>> "As found in PaX" isn't a very illuminating justification for such a
>> change.  Was there a real kernel bug which this would have exposed, or
>> what?
>
> I don't know off the top of my head, but given the kinds of heap
> attacks I've been seeing, I think this added consistency check is
> worth it given how inexpensive it is. When heap metadata gets
> corrupted, we can get into nasty side-effects that can be
> attacker-controlled, so better to catch obviously bad states as early
> as possible.

There's your changelog :)

>>> --- a/mm/slab.h
>>> +++ b/mm/slab.h
>>> @@ -384,6 +384,7 @@ static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
>>>               return s;
>>>
>>>       page = virt_to_head_page(x);
>>> +     BUG_ON(!PageSlab(page));
>>>       cachep = page->slab_cache;
>>>       if (slab_equal_or_root(cachep, s))
>>>               return cachep;
>>
>> BUG_ON might be too severe.  I expect the kindest VM_WARN_ON_ONCE()
>> would suffice here, but without more details it is hard to say.
>
> So, WARN isn't enough to protect the kernel (execution continues and
> the memory is still dereferenced for malicious purposes, etc).

You could do:

	if (WARN_ON(!PageSlab(page)))
        	return NULL.

Though I see at least two callers that don't check for a NULL return.

Looking at the context, the tail of the function already contains:

	pr_err("%s: Wrong slab cache. %s but object is from %s\n",
	       __func__, s->name, cachep->name);
	WARN_ON_ONCE(1);
	return s;
}

At least in slab.c it seems that would allow you to "free" an object
from one kmem_cache onto the array_cache of another kmem_cache, which
seems fishy. But maybe there's a check somewhere I'm missing?

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
