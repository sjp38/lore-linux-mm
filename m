Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id C13C1800C7
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 19:17:53 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id ik10so22423194igb.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 16:17:53 -0800 (PST)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id 143si37485068ion.76.2016.01.05.16.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 16:17:53 -0800 (PST)
Received: by mail-ig0-x22b.google.com with SMTP id ik10so22423129igb.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 16:17:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5679B701.9040802@suse.cz>
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
	<1450755641-7856-2-git-send-email-laura@labbott.name>
	<5679B701.9040802@suse.cz>
Date: Tue, 5 Jan 2016 16:17:53 -0800
Message-ID: <CAGXu5jLvS0jzi07QegCHoBoCc3wFhbcMOjCpmbe3KC2oJO9jPQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/7] mm/slab_common.c: Add common support for slab saniziation
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Laura Abbott <laura@labbott.name>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Mathias Krause <minipli@googlemail.com>

On Tue, Dec 22, 2015 at 12:48 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 22.12.2015 4:40, Laura Abbott wrote:
>> Each of the different allocators (SLAB/SLUB/SLOB) handles
>> clearing of objects differently depending on configuration.
>> Add common infrastructure for selecting sanitization levels
>> (off, slow path only, partial, full) and marking caches as
>> appropriate.
>>
>> All credit for the original work should be given to Brad Spengler and
>> the PaX Team.
>>
>> Signed-off-by: Laura Abbott <laura@labbott.name>
>>
>> +#ifdef CONFIG_SLAB_MEMORY_SANITIZE
>> +#ifdef CONFIG_X86_64
>> +#define SLAB_MEMORY_SANITIZE_VALUE       '\xfe'
>> +#else
>> +#define SLAB_MEMORY_SANITIZE_VALUE       '\xff'
>> +#endif
>> +enum slab_sanitize_mode {
>> +     /* No sanitization */
>> +     SLAB_SANITIZE_OFF = 0,
>> +
>> +     /* Partial sanitization happens only on the slow path */
>> +     SLAB_SANITIZE_PARTIAL_SLOWPATH = 1,
>
> Can you explain more about this variant? I wonder who might find it useful
> except someone getting a false sense of security, but cheaper.
> It sounds like wanting the cake and eat it too :)
> I would be surprised if such IMHO half-solution existed in the original
> PAX_MEMORY_SANITIZE too?
>
> Or is there something that guarantees that the objects freed on hotpath won't
> stay there for long so the danger of leak is low? (And what about
> use-after-free?) It depends on further slab activity, no? (I'm not that familiar
> with SLUB, but I would expect the hotpath there being similar to SLAB freeing
> the object on per-cpu array_cache. But, it seems the PARTIAL_SLOWPATH is not
> implemented for SLAB, so there might be some fundamental difference I'm missing.)

Perhaps the partial sanitize could be a separate patch so it's
features were more logically separated?

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
