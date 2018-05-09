Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C30E6B055D
	for <linux-mm@kvack.org>; Wed,  9 May 2018 14:07:22 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id a5so18487330uaf.1
        for <linux-mm@kvack.org>; Wed, 09 May 2018 11:07:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p15sor12692766uag.270.2018.05.09.11.07.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 11:07:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <fea0a346-6f36-ff8c-f036-13f22dfb9bfe@rasmusvillemoes.dk>
References: <20180509004229.36341-1-keescook@chromium.org> <20180509004229.36341-5-keescook@chromium.org>
 <20180509113446.GA18549@bombadil.infradead.org> <fea0a346-6f36-ff8c-f036-13f22dfb9bfe@rasmusvillemoes.dk>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 9 May 2018 11:07:20 -0700
Message-ID: <CAGXu5j+ds=4tKM=GwzgfpA0YheUSX30pTbQqXg0gKUniOeDzww@mail.gmail.com>
Subject: Re: [PATCH 04/13] mm: Use array_size() helpers for kmalloc()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Matthew Wilcox <willy@infradead.org>, Matthew Wilcox <mawilcox@microsoft.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, May 9, 2018 at 11:00 AM, Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
> On 2018-05-09 13:34, Matthew Wilcox wrote:
>> On Tue, May 08, 2018 at 05:42:20PM -0700, Kees Cook wrote:
>>> @@ -499,6 +500,8 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
>>>   */
>>>  static __always_inline void *kmalloc(size_t size, gfp_t flags)
>>>  {
>>> +    if (size == SIZE_MAX)
>>> +            return NULL;
>>>      if (__builtin_constant_p(size)) {
>>>              if (size > KMALLOC_MAX_CACHE_SIZE)
>>>                      return kmalloc_large(size, flags);
>>
>> I don't like the add-checking-to-every-call-site part of this patch.
>> Fine, the compiler will optimise it away if it can calculate it at compile
>> time, but there are a lot of situations where it can't.  You aren't
>> adding any safety by doing this; trying to allocate SIZE_MAX bytes is
>> guaranteed to fail, and it doesn't need to fail quickly.
>
> Yeah, agree that we don't want to add a size check to all callers,
> including those where the size doesn't even come from one of the new
> *_size helpers; that just adds bloat. It's true that the overflow case
> does not have to fail quickly, but I was worried that the saturating
> helpers would end up making gcc emit a cmov instruction, thus stalling
> the regular path. But it seems that it actually ends up doing a forward
> jump, sets %rdi to SIZE_MAX, then jumps back to the call of __kmalloc,
> so it should be ok.

Okay, consensus is to remove new SIZE_MAX checks, then?

> With __builtin_constant_p(size) && size == SIZE_MAX, gcc could be smart
> enough to elide those two instructions and have the jo go directly to
> the caller's error handling, but at least gcc 5.4 doesn't seem to be
> that smart. So let's just omit that part for now.
>
> But in case of the kmalloc_array functions, with a direct call of
> __builtin_mul_overflow(), gcc does combine the "return NULL" with the
> callers error handling, thus avoiding the six byte "%rdi = -1; jmp
> back;" thunk. That, along with the churn factor, might be an argument
> for leaving the current callers of *_array alone. But if we are going to
> keep those longer-term, we might as well convert kmalloc(a, b) into
> kmalloc_array(a, b) instead of kmalloc(array_size(a, b)). In any case, I
> do see the usefulness of the struct_size helper, and agree that we
> definitely should not introduce a new *_struct variant that needs to be
> implemented in all families.

I'd like to drop *calloc() and *_array() to simplify APIs (and improve
developer sanity). Are you suggesting we should not use the overflow
helpers in kmalloc_array(), instead leaving the existing open-coded
overflow check?

-Kees

-- 
Kees Cook
Pixel Security
