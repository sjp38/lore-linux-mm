Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5345F6B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 13:42:34 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y84so21321980lfc.3
        for <linux-mm@kvack.org>; Tue, 03 May 2016 10:42:34 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id q3si231373wmg.48.2016.05.03.10.42.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 May 2016 10:42:32 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id g17so52496291wme.1
        for <linux-mm@kvack.org>; Tue, 03 May 2016 10:42:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20E775CA4D599049A25800DE5799F6DD1F61F1B2@G9W0752.americas.hpqcorp.net>
References: <20160502094920.GA3005@cherokee.in.rdlabs.hpecorp.net>
 <CACT4Y+YV4A_YbDq5asowLJPUODottNHAKScWoRdUx6uy+TN-Uw@mail.gmail.com>
 <CACT4Y+Z_+crRUm0U89YwW3x99dtx9cfPoO+L6mD-uyzfZAMkKw@mail.gmail.com> <20E775CA4D599049A25800DE5799F6DD1F61F1B2@G9W0752.americas.hpqcorp.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 3 May 2016 19:42:12 +0200
Message-ID: <CACT4Y+azLKpGXSqs2=7PKZLNHd61LN7FiAQeWLhw3yApVHadXQ@mail.gmail.com>
Subject: Re: [PATCH] kasan: improve double-free detection
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luruo, Kuthonuzo" <kuthonuzo.luruo@hpe.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, May 3, 2016 at 9:53 AM, Luruo, Kuthonuzo
<kuthonuzo.luruo@hpe.com> wrote:
>> I missed that Alexander already landed patches that reduce header size
>> to 16 bytes.
>> It is not OK to increase them again. Please leave state as bitfield
>> and update it with CAS (if we introduce helper functions for state
>> manipulation, they will hide the CAS loop, which is nice).
>>
>
> Available CAS primitives/compiler do not support CAS with bitfield. I propose
> to change kasan_alloc_meta to:
>
> struct kasan_alloc_meta {
>         struct kasan_track track;
>         u16 size_delta;         /* object_size - alloc size */
>         u8 state;                    /* enum kasan_state */
>         u8 reserved1;
>         u32 reserved2;
> }
>
> This shrinks _used_ meta object by 1 byte wrt the original. (btw, patch v1 does
> not increase overall alloc meta object size). "Alloc size", where needed, is
> easily calculated as a delta from cache->object_size.


What is the maximum size that slab can allocate?
I remember seeing slabs as large as 4MB some time ago (or did I
confuse it with something else?). If there are such large objects,
that 2 bytes won't be able to hold even delta.
However, now on my desktop I don't see slabs larger than 16KB in /proc/slabinfo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
