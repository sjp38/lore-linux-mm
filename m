Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1F16B055A
	for <linux-mm@kvack.org>; Wed,  9 May 2018 13:59:01 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id c8so12014395uae.5
        for <linux-mm@kvack.org>; Wed, 09 May 2018 10:59:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a187-v6sor10838244vkc.227.2018.05.09.10.58.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 10:58:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180509113446.GA18549@bombadil.infradead.org>
References: <20180509004229.36341-1-keescook@chromium.org> <20180509004229.36341-5-keescook@chromium.org>
 <20180509113446.GA18549@bombadil.infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 9 May 2018 10:58:57 -0700
Message-ID: <CAGXu5j+PT2O6RTnUJvV-m1PKT6RebY2s-0V=19V3tt+VGJrKvQ@mail.gmail.com>
Subject: Re: [PATCH 04/13] mm: Use array_size() helpers for kmalloc()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, May 9, 2018 at 4:34 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Tue, May 08, 2018 at 05:42:20PM -0700, Kees Cook wrote:
>> @@ -499,6 +500,8 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
>>   */
>>  static __always_inline void *kmalloc(size_t size, gfp_t flags)
>>  {
>> +     if (size == SIZE_MAX)
>> +             return NULL;
>>       if (__builtin_constant_p(size)) {
>>               if (size > KMALLOC_MAX_CACHE_SIZE)
>>                       return kmalloc_large(size, flags);
>
> I don't like the add-checking-to-every-call-site part of this patch.
> Fine, the compiler will optimise it away if it can calculate it at compile
> time, but there are a lot of situations where it can't.  You aren't
> adding any safety by doing this; trying to allocate SIZE_MAX bytes is
> guaranteed to fail, and it doesn't need to fail quickly.

Fun bit of paranoia: I added early checks to devm_kmalloc() too in
another patch after 0-day started yelling about other things, and this
morning while removing the SIZE_MAX checks based on your feedback, I
discovered:

void * devm_kmalloc(struct device *dev, size_t size, gfp_t gfp)
{
        struct devres *dr;

        /* use raw alloc_dr for kmalloc caller tracing */
        dr = alloc_dr(devm_kmalloc_release, size, gfp, dev_to_node(dev));
...

static __always_inline struct devres * alloc_dr(dr_release_t release,
                                               size_t size, gfp_t gfp, int nid)
{
       size_t tot_size = sizeof(struct devres) + size;
        struct devres *dr;

        dr = kmalloc_node_track_caller(tot_size, gfp, nid);
...

which is exactly the pattern I was worried about: SIZE_MAX plus some
small number would overflow. :(

So, I've added an explicit overflow check in devm_kmalloc() now.

Thoughts: making {struct,array,array3}_size() return "SIZE_MAX -
something" could help for generic cases (like above), but it might
still be possible in a buggy situation for an attacker to choose
factors that do NOT overflow, but reach something like "SIZE_MAX - 1"
and then the later addition will wrap it around. I'm leaning towards
doing it anyway, though, since not all factors in a given bug may have
very high granularity, giving us better protection than SIZE_MAX.

However, since now we're separating overflow checking from saturation
(i.e. we could calculate a non-overflowing value that lands in the
saturation zone), we can't sanely to the check_*_overflow() cases,
since the "saturated" results from array_size() aren't SIZE_MAX any
more...

I can't decide which is a safer failure case...

> Hmm.  I wonder why we have the kmalloc/__kmalloc "optimisation"
> in kmalloc_array, but not kcalloc.  Bet we don't really need it in
> kmalloc_array.  I'll do some testing.

Not sure; my new patches drop it entirely since they're redefining
*calloc() and *_array*() with the helpers now...

I'll send a v2 shortly (without the treewide changes, since those are
huge and only changed slightly with some 0-day noticed glitches).

-Kees

-- 
Kees Cook
Pixel Security
