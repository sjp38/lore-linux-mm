Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 17F566B0390
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 20:04:02 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 68so31687437ioh.4
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 17:04:02 -0700 (PDT)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id 134si7989628ion.113.2017.03.31.17.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 17:04:01 -0700 (PDT)
Received: by mail-io0-x22a.google.com with SMTP id f84so48874768ioj.0
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 17:04:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170331143317.3865149a6b6112f0d1a63499@linux-foundation.org>
References: <20170331164028.GA118828@beast> <20170331143317.3865149a6b6112f0d1a63499@linux-foundation.org>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 31 Mar 2017 17:04:00 -0700
Message-ID: <CAGXu5jK8RrHwa1Uv464=5+T5iBnhhx796CdLcJMAA88wi8bzaA@mail.gmail.com>
Subject: Re: [PATCH] mm: Add additional consistency check
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 31, 2017 at 2:33 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 31 Mar 2017 09:40:28 -0700 Kees Cook <keescook@chromium.org> wrote:
>
>> As found in PaX, this adds a cheap check on heap consistency, just to
>> notice if things have gotten corrupted in the page lookup.
>
> "As found in PaX" isn't a very illuminating justification for such a
> change.  Was there a real kernel bug which this would have exposed, or
> what?

I don't know off the top of my head, but given the kinds of heap
attacks I've been seeing, I think this added consistency check is
worth it given how inexpensive it is. When heap metadata gets
corrupted, we can get into nasty side-effects that can be
attacker-controlled, so better to catch obviously bad states as early
as possible.

>> --- a/mm/slab.h
>> +++ b/mm/slab.h
>> @@ -384,6 +384,7 @@ static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
>>               return s;
>>
>>       page = virt_to_head_page(x);
>> +     BUG_ON(!PageSlab(page));
>>       cachep = page->slab_cache;
>>       if (slab_equal_or_root(cachep, s))
>>               return cachep;
>
> BUG_ON might be too severe.  I expect the kindest VM_WARN_ON_ONCE()
> would suffice here, but without more details it is hard to say.

So, WARN isn't enough to protect the kernel (execution continues and
the memory is still dereferenced for malicious purposes, etc). Perhaps
use CHECK_DATA_CORRUPTION() here, which can either WARN and take a
"safe" path, or BUG (depending on config paranoia of the builder).
I've got a series adding it in a number of other places, so I could
add this patch to that series?

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
