Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 042028E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 08:25:02 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id z20-v6so14598281ioh.2
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 05:25:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y127-v6sor13998098iod.36.2018.09.21.05.25.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 05:25:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aoFSySFTd9FzA0xzRYQXSbs-wzX7B67hD3jTGAQEXBOA@mail.gmail.com>
References: <cover.1537383101.git.andreyknvl@google.com> <d74e710797323db0e43f047ea698fbc85060fc57.1537383101.git.andreyknvl@google.com>
 <CACT4Y+aoFSySFTd9FzA0xzRYQXSbs-wzX7B67hD3jTGAQEXBOA@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 21 Sep 2018 14:24:59 +0200
Message-ID: <CAAeHK+zBh0BiYq65QDxD-nxkHHF0QL6UQx8fs40K39R6XJJfzA@mail.gmail.com>
Subject: Re: [PATCH v8 09/20] kasan: preassign tags to objects with ctors or SLAB_TYPESAFE_BY_RCU
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Fri, Sep 21, 2018 at 1:25 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Sep 19, 2018 at 8:54 PM, Andrey Konovalov <andreyknvl@google.com> wrote:

>>         if (!shuffle) {
>>                 for_each_object_idx(p, idx, s, start, page->objects) {
>> -                       setup_object(s, page, p);
>> -                       if (likely(idx < page->objects))
>> -                               set_freepointer(s, p, p + s->size);
>> -                       else
>> +                       if (likely(idx < page->objects)) {
>> +                               next = p + s->size;
>> +                               next = setup_object(s, page, next);
>> +                               set_freepointer(s, p, next);
>> +                       } else
>>                                 set_freepointer(s, p, NULL);
>>                 }
>> -               page->freelist = fixup_red_left(s, start);
>> +               start = fixup_red_left(s, start);
>> +               start = setup_object(s, page, start);
>> +               page->freelist = start;
>>         }
>
> Just want to double-check that this is correct.
> We now do an additional setup_object call after the loop, but we do 1
> less in the loop. So total number of calls should be the same, right?
> However, after the loop we call setup_object for the first object (?),
> but inside of the loop we skip the call for the last object (?). Am I
> missing something, or we call ctor twice for the last object and don't
> call it for the first one?

Inside the loop we call setup_object for the "next" object. So we
start iterating on the first one, but call setup_object for the
second. Then the loop moves on to the second one and calls
setup_object for the third. And so on. So the loop calls setup_object
for every object (including the last one) except for the first one.

The idea is that we want the freelist pointer that is stored in the
current object to have a tagged pointer to the next one, so we need to
assign a tag to the next object before storing the pointer in the
current one.
