Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id C14B1828F6
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 16:06:36 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id hb3so21253618igb.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 13:06:36 -0800 (PST)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id k2si33216765igx.32.2016.02.03.13.06.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 13:06:36 -0800 (PST)
Received: by mail-ig0-x22b.google.com with SMTP id xg9so11906035igb.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 13:06:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56B24B01.30306@redhat.com>
References: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org>
	<20160126070320.GB28254@js1304-P5Q-DELUXE>
	<56B24B01.30306@redhat.com>
Date: Wed, 3 Feb 2016 13:06:35 -0800
Message-ID: <CAGXu5jJK1UhNX7h2YmxxTrCABr8oS=Y2OBLMr4KTxk7LctRaiQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/3] Speed up SLUB poisoning + disable checks
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@fedoraproject.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Wed, Feb 3, 2016 at 10:46 AM, Laura Abbott <labbott@redhat.com> wrote:
> On 01/25/2016 11:03 PM, Joonsoo Kim wrote:
>>
>> On Mon, Jan 25, 2016 at 05:15:10PM -0800, Laura Abbott wrote:
>>>
>>> Hi,
>>>
>>> Based on the discussion from the series to add slab sanitization
>>> (lkml.kernel.org/g/<1450755641-7856-1-git-send-email-laura@labbott.name>)
>>> the existing SLAB_POISON mechanism already covers similar behavior.
>>> The performance of SLAB_POISON isn't very good. With hackbench -g 20 -l
>>> 1000
>>> on QEMU with one cpu:
>>
>>
>> I doesn't follow up that discussion, but, I think that reusing
>> SLAB_POISON for slab sanitization needs more changes. I assume that
>> completeness and performance is matter for slab sanitization.
>>
>> 1) SLAB_POISON isn't applied to specific kmem_cache which has
>> constructor or SLAB_DESTROY_BY_RCU flag. For debug, it's not necessary
>> to be applied, but, for slab sanitization, it is better to apply it to
>> all caches.
>
>
> The grsecurity patches get around this by calling the constructor again
> after poisoning. It could be worth investigating doing that as well
> although my focus was on the cases without the constructor.
>>
>>
>> 2) SLAB_POISON makes object size bigger so natural alignment will be
>> broken. For example, kmalloc(256) cache's size is 256 in normal
>> case but it would be 264 when SLAB_POISON is enabled. This causes
>> memory waste.
>
>
> The grsecurity patches also bump the size up to put the free pointer
> outside the object. For sanitization purposes it is cleaner to have
> no pointers in the object after free
>
>>
>> In fact, I'd prefer not reusing SLAB_POISON. It would make thing
>> simpler. But, it's up to Christoph.
>>
>> Thanks.
>>
>
> It basically looks like trying to poison on the fast path at all
> will have a negative impact even with the feature is turned off.
> Christoph has indicated this is not acceptable so we are forced
> to limit it to the slow path only if we want runtime enablement.

Is it possible to have both? i.e fast path via CONFIG, and slow path
via runtime options?

> If we're limited to the slow path only, we might as well work
> with SLAB_POISON to make it faster. We can reevaluate if it turns
> out the poisoning isn't fast enough to be useful.

And since I'm new to this area, I know of fast/slow path in the
syscall sense. What happens in the allocation/free fast/slow path that
makes it fast or slow?

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
