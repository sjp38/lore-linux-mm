Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id F14AB8E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 11:45:33 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id m13-v6so2635714ioq.9
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:45:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v7-v6sor6026499itv.63.2018.09.18.08.45.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 08:45:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAeHK+w+Znw-t_wd29PO5B+pNegS3wqzS1mUVCmfrgdCXpavWw@mail.gmail.com>
References: <cover.1535462971.git.andreyknvl@google.com> <6cd298a90d02068969713f2fd440eae21227467b.1535462971.git.andreyknvl@google.com>
 <CACT4Y+adO3n4Nb4XOPyXdt43DbYjb=Kz6__tPTmb1CX=00qNSQ@mail.gmail.com> <CAAeHK+w+Znw-t_wd29PO5B+pNegS3wqzS1mUVCmfrgdCXpavWw@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 18 Sep 2018 17:45:11 +0200
Message-ID: <CACT4Y+a=tctG9PXkQmaeLtU3cGbBCSA==uwHasX+XzNVB66kcA@mail.gmail.com>
Subject: Re: [PATCH v6 07/18] khwasan: add tag related helper functions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Mon, Sep 17, 2018 at 8:59 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> On Wed, Sep 12, 2018 at 6:21 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Wed, Aug 29, 2018 at 1:35 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>
>>> +void *khwasan_preset_slub_tag(struct kmem_cache *cache, const void *addr)
>>
>> Can't we do this in the existing kasan_init_slab_obj() hook? It looks
>> like it should do exactly this -- allow any one-time initialization
>> for objects. We could extend it to accept index and return a new
>> pointer.
>> If that does not work for some reason, I would try to at least unify
>> the hook for slab/slub, e.g. pass idx=-1 from slub and then use
>> random_tag().
>> It also seems that we do preset tag for slab multiple times (from
>> slab_get_obj()). Using kasan_init_slab_obj() should resolve this too
>> (hopefully we don't call it multiple times).
>
> The issue is that SLAB stores freelist as an array of indexes instead
> of using an actual linked list like SLUB. So you can't store the tag
> in the pointer while the object is in the freelist, since there's no
> pointer. And, technically, we don't preset tags for SLAB, we just use
> the id as the tag every time a pointer is used, so perhaps we should
> rename the callback. As to unifying the callbacks, sure, we can do
> that.

As per offline discussion: potentially we can use
kasan_init_slab_obj() if we add tag in kmalloc hook by using
obj_to_idx().
