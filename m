Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id AD71C6B0005
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 16:35:57 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id y9so21705532qgd.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 13:35:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o40si7293026qkh.49.2016.02.03.13.35.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 13:35:56 -0800 (PST)
Subject: Re: [RFC][PATCH 0/3] Speed up SLUB poisoning + disable checks
References: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org>
 <20160126070320.GB28254@js1304-P5Q-DELUXE> <56B24B01.30306@redhat.com>
 <CAGXu5jJK1UhNX7h2YmxxTrCABr8oS=Y2OBLMr4KTxk7LctRaiQ@mail.gmail.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56B272B8.2050808@redhat.com>
Date: Wed, 3 Feb 2016 13:35:52 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJK1UhNX7h2YmxxTrCABr8oS=Y2OBLMr4KTxk7LctRaiQ@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@fedoraproject.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 02/03/2016 01:06 PM, Kees Cook wrote:
> On Wed, Feb 3, 2016 at 10:46 AM, Laura Abbott <labbott@redhat.com> wrote:
>> On 01/25/2016 11:03 PM, Joonsoo Kim wrote:
>>>
>>> On Mon, Jan 25, 2016 at 05:15:10PM -0800, Laura Abbott wrote:
>>>>
>>>> Hi,
>>>>
>>>> Based on the discussion from the series to add slab sanitization
>>>> (lkml.kernel.org/g/<1450755641-7856-1-git-send-email-laura@labbott.name>)
>>>> the existing SLAB_POISON mechanism already covers similar behavior.
>>>> The performance of SLAB_POISON isn't very good. With hackbench -g 20 -l
>>>> 1000
>>>> on QEMU with one cpu:
>>>
>>>
>>> I doesn't follow up that discussion, but, I think that reusing
>>> SLAB_POISON for slab sanitization needs more changes. I assume that
>>> completeness and performance is matter for slab sanitization.
>>>
>>> 1) SLAB_POISON isn't applied to specific kmem_cache which has
>>> constructor or SLAB_DESTROY_BY_RCU flag. For debug, it's not necessary
>>> to be applied, but, for slab sanitization, it is better to apply it to
>>> all caches.
>>
>>
>> The grsecurity patches get around this by calling the constructor again
>> after poisoning. It could be worth investigating doing that as well
>> although my focus was on the cases without the constructor.
>>>
>>>
>>> 2) SLAB_POISON makes object size bigger so natural alignment will be
>>> broken. For example, kmalloc(256) cache's size is 256 in normal
>>> case but it would be 264 when SLAB_POISON is enabled. This causes
>>> memory waste.
>>
>>
>> The grsecurity patches also bump the size up to put the free pointer
>> outside the object. For sanitization purposes it is cleaner to have
>> no pointers in the object after free
>>
>>>
>>> In fact, I'd prefer not reusing SLAB_POISON. It would make thing
>>> simpler. But, it's up to Christoph.
>>>
>>> Thanks.
>>>
>>
>> It basically looks like trying to poison on the fast path at all
>> will have a negative impact even with the feature is turned off.
>> Christoph has indicated this is not acceptable so we are forced
>> to limit it to the slow path only if we want runtime enablement.
>
> Is it possible to have both? i.e fast path via CONFIG, and slow path
> via runtime options?
>

That's what this patch series had. A Kconfig to turn the fast path
debugging on and off. When the Kconfig is off it reverts back to the
existing behavior and there is no fastpath penalty.
  
>> If we're limited to the slow path only, we might as well work
>> with SLAB_POISON to make it faster. We can reevaluate if it turns
>> out the poisoning isn't fast enough to be useful.
>
> And since I'm new to this area, I know of fast/slow path in the
> syscall sense. What happens in the allocation/free fast/slow path that
> makes it fast or slow?

The fast path uses the per cpu caches. No locks are taken and there
is no IRQ disabling. For concurrency protection this comment
explains it best:

/*
  * The cmpxchg will only match if there was no additional
  * operation and if we are on the right processor.
  *
  * The cmpxchg does the following atomically (without lock
  * semantics!)
  * 1. Relocate first pointer to the current per cpu area.
  * 2. Verify that tid and freelist have not been changed
  * 3. If they were not changed replace tid and freelist
  *
  * Since this is without lock semantics the protection is only
  * against code executing on this cpu *not* from access by
  * other cpus.
  */

in the slow path, IRQs and locks have to be taken at the minimum.
The debug options disable ever loading the per CPU caches so it
always falls back to the slow path.

>
> -Kees
>

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
