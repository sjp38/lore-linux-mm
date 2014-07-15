Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id D12DD6B0037
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 19:55:07 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id hz20so91680lab.22
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 16:55:07 -0700 (PDT)
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
        by mx.google.com with ESMTPS id p10si16101284lah.63.2014.07.15.16.55.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 16:55:06 -0700 (PDT)
Received: by mail-lb0-f174.google.com with SMTP id c11so92197lbj.33
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 16:55:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53C5BD3E.2010600@zytor.com>
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
 <1405452884-25688-4-git-send-email-toshi.kani@hp.com> <CALCETrUPpP1Lo1gB_eTm6V3pJ3Fam-1gPZGKfksOXXGgtNGsEQ@mail.gmail.com>
 <1405465801.28702.34.camel@misato.fc.hp.com> <CALCETrUx+HkzBmTZo-BtOcOz7rs=oNcavJ9Go536Fcn2ugdobg@mail.gmail.com>
 <53C5BD3E.2010600@zytor.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 15 Jul 2014 16:54:45 -0700
Message-ID: <CALCETrUV2NseM8u6YqQ3trqLy+10_A6sd7nmfkgO3Rnw3GSxiQ@mail.gmail.com>
Subject: Re: [RFC PATCH 3/11] x86, mm, pat: Change reserve_memtype() to handle
 WT type
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Dave Airlie <airlied@gmail.com>, Borislav Petkov <bp@alien8.de>

On Tue, Jul 15, 2014 at 4:46 PM, H. Peter Anvin <hpa@zytor.com> wrote:
> On 07/15/2014 04:36 PM, Andy Lutomirski wrote:
>> On Tue, Jul 15, 2014 at 4:10 PM, Toshi Kani <toshi.kani@hp.com> wrote:
>>> On Tue, 2014-07-15 at 12:56 -0700, Andy Lutomirski wrote:
>>>> On Tue, Jul 15, 2014 at 12:34 PM, Toshi Kani <toshi.kani@hp.com> wrote:
>>>>> This patch changes reserve_memtype() to handle the new WT type.
>>>>> When (!pat_enabled && new_type), it continues to set either WB
>>>>> or UC- to *new_type.  When pat_enabled, it can reserve a given
>>>>> non-RAM range for WT.  At this point, it may not reserve a RAM
>>>>> range for WT since reserve_ram_pages_type() uses the page flags
>>>>> limited to three memory types, WB, WC and UC.
>>>>
>>>> FWIW, last time I looked at this, it seemed like all the fancy
>>>> reserve_ram_pages stuff was unnecessary: shouldn't the RAM type be
>>>> easy to track in the direct map page tables?
>>>
>>> Are you referring the direct map page tables as the kernel page
>>> directory tables (pgd/pud/..)?
>>>
>>> I think it needs to be able to keep track of the memory type per a
>>> physical memory range, not per a translation, in order to prevent
>>> aliasing of the memory type.
>>
>> Actual RAM (the lowmem kind, which is all of it on x86_64) is mapped
>> linearly somewhere in kernel address space.  The pagetables for that
>> mapping could be used as the canonical source of the memory type for
>> the ram range in question.
>>
>> This only works for lowmem, so maybe it's not a good idea to rely on it.
>>
>
> We could do that, but would it be better?

>From vague memory, the current mechanism for tracking RAM memtypes (as
opposed to memtypes for everything that isn't RAM) is limited to a
very small number of types, leading to oddities like not being able to
create WT ram with this patchset.

Using the pagetables directly would be simpler (no extra data
structure) and would automatically exactly track the set of memtypes
that can fit in the pagetable structures.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
