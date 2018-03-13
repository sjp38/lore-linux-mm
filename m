Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C44B06B000D
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 13:36:55 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id d12so353942wri.4
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 10:36:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9sor375103wrh.54.2018.03.13.10.36.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Mar 2018 10:36:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1803131217200.9367@nuc-kabylake>
References: <20180313165428.58699-1-shakeelb@google.com> <alpine.DEB.2.20.1803131217200.9367@nuc-kabylake>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 13 Mar 2018 10:36:52 -0700
Message-ID: <CALvZod4qa39QJqCr3n6UqzdD6pfLAQ3Rix6zm9_1pQkfQCDa7Q@mail.gmail.com>
Subject: Re: [PATCH] slab, slub: remove size disparity on debug kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Mar 13, 2018 at 10:19 AM, Christopher Lameter <cl@linux.com> wrote:
> On Tue, 13 Mar 2018, Shakeel Butt wrote:
>
>> However for SLUB in debug kernel, the sizes were same. On further
>> inspection it is found that SLUB always use kmem_cache.object_size to
>> measure the kmem_cache.size while SLAB use the given kmem_cache.size. In
>> the debug kernel the slab's size can be larger than its object_size.
>> Thus in the creation of non-root slab, the SLAB uses the root's size as
>> base to calculate the non-root slab's size and thus non-root slab's size
>> can be larger than the root slab's size. For SLUB, the non-root slab's
>> size is measured based on the root's object_size and thus the size will
>> remain same for root and non-root slab.
>
> Note that the object_size and size may differ for SLUB based on kernel
> parameters and slab configuration. For SLAB these are compilation options.
>

Thanks for the explanation.

>> @@ -379,7 +379,7 @@ struct kmem_cache *find_mergeable(unsigned int size, unsigned int align,
>>  }
>>
>>  static struct kmem_cache *create_cache(const char *name,
>> -             unsigned int object_size, unsigned int size, unsigned int align,
>> +             unsigned int object_size, unsigned int align,
>>               slab_flags_t flags, unsigned int useroffset,
>
> Why was both the size and object_size passed during cache creation in the
> first place? From the flags etc the slab logic should be able to compute
> the actual bytes required for each object and its metadata.
>

+Vladimir

I think it was introduced by 794b1248be4e7 ("memcg, slab: separate
memcg vs root cache creation paths") but I could not find out the
reason.
