Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 591E86B0538
	for <linux-mm@kvack.org>; Wed,  9 May 2018 13:01:44 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id h62-v6so15133639vke.1
        for <linux-mm@kvack.org>; Wed, 09 May 2018 10:01:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b18sor11692135uak.175.2018.05.09.10.01.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 10:01:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4baffc55-510e-96d3-3487-5ea09f993a0c@redhat.com>
References: <20180509004229.36341-1-keescook@chromium.org> <4baffc55-510e-96d3-3487-5ea09f993a0c@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 9 May 2018 10:01:41 -0700
Message-ID: <CAGXu5jKXq7--CYgp8Q+k00RjjGJY+o71RMr51NPuWS1eM0KX1w@mail.gmail.com>
Subject: Re: [RFC][PATCH 00/13] Provide saturating helpers for allocation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, May 9, 2018 at 9:08 AM, Laura Abbott <labbott@redhat.com> wrote:
> On 05/08/2018 05:42 PM, Kees Cook wrote:
>>
>> This is a stab at providing three new helpers for allocation size
>> calculation:
>>
>> struct_size(), array_size(), and array3_size().
>>
>> These are implemented on top of Rasmus's overflow checking functions,
>> and the last 8 patches are all treewide conversions of open-coded
>> multiplications into the various combinations of the helper functions.
>>
>> -Kees
>>
>>
> Obvious question (that might indicate this deserves documentation?)
>
> What's the difference between
>
> kmalloc_array(cnt, sizeof(struct blah), GFP_KERNEL);
>
> and
>
> kmalloc(array_size(cnt, struct blah), GFP_KERNEL);
>
>
> and when would you use one over the other?

If I'm understanding the intentions here, the next set of treewide
changes would be to remove *calloc() and *_array() in favor of using
the array_size() helper. (i.e. reducing proliferation of allocator
helpers in favor of using the *_size() helpers.

There are, however, some cases that don't map well to
{struct,array,array3}_size(), specifically cases of additions in
finding a count. For example, stuff like:

kmalloc(sizeof(header) + sizeof(trailing_array) * (count + SOMETHING), gfp...)

This gets currently mapped to:

kmalloc(struct_size(header, trailing_array, (count + SOMETHING), gfp...)

But we run the risk in some cases of having even the addition
overflow. I think we need to have a "saturating add" too. Something
like:

kmalloc(struct_size(header, trailing_array, sat_add(count, SOMETHING), gfp...)

It's a bit ugly, but it would cover nearly all the remaining cases...

-Kees

-- 
Kees Cook
Pixel Security
