Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2CFB56B0039
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 20:32:51 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so214761pde.34
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 17:32:50 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id qs6si13023246pbc.21.2014.07.15.17.32.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jul 2014 17:32:50 -0700 (PDT)
In-Reply-To: <CALCETrXMYmVkcpzwGEo=aUia6S9aOaODFR__Z54YUQAZ4rRhRA@mail.gmail.com>
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com> <1405452884-25688-4-git-send-email-toshi.kani@hp.com> <CALCETrUPpP1Lo1gB_eTm6V3pJ3Fam-1gPZGKfksOXXGgtNGsEQ@mail.gmail.com> <1405465801.28702.34.camel@misato.fc.hp.com> <CALCETrUx+HkzBmTZo-BtOcOz7rs=oNcavJ9Go536Fcn2ugdobg@mail.gmail.com> <1405468387.28702.53.camel@misato.fc.hp.com> <CALCETrXMYmVkcpzwGEo=aUia6S9aOaODFR__Z54YUQAZ4rRhRA@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [RFC PATCH 3/11] x86, mm, pat: Change reserve_memtype() to handle WT type
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 15 Jul 2014 17:31:43 -0700
Message-ID: <788fbcdc-4f69-4970-aaf4-00aae6c57fed@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Toshi Kani <toshi.kani@hp.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Dave Airlie <airlied@gmail.com>, Borislav Petkov <bp@alien8.de>

It already happened...

On July 15, 2014 5:28:40 PM PDT, Andy Lutomirski <luto@amacapital.net> wrote:
>On Tue, Jul 15, 2014 at 4:53 PM, Toshi Kani <toshi.kani@hp.com> wrote:
>> On Tue, 2014-07-15 at 16:36 -0700, Andy Lutomirski wrote:
>>> On Tue, Jul 15, 2014 at 4:10 PM, Toshi Kani <toshi.kani@hp.com>
>wrote:
>>> > On Tue, 2014-07-15 at 12:56 -0700, Andy Lutomirski wrote:
>>> >> On Tue, Jul 15, 2014 at 12:34 PM, Toshi Kani <toshi.kani@hp.com>
>wrote:
>>> >> > This patch changes reserve_memtype() to handle the new WT type.
>>> >> > When (!pat_enabled && new_type), it continues to set either WB
>>> >> > or UC- to *new_type.  When pat_enabled, it can reserve a given
>>> >> > non-RAM range for WT.  At this point, it may not reserve a RAM
>>> >> > range for WT since reserve_ram_pages_type() uses the page flags
>>> >> > limited to three memory types, WB, WC and UC.
>>> >>
>>> >> FWIW, last time I looked at this, it seemed like all the fancy
>>> >> reserve_ram_pages stuff was unnecessary: shouldn't the RAM type
>be
>>> >> easy to track in the direct map page tables?
>>> >
>>> > Are you referring the direct map page tables as the kernel page
>>> > directory tables (pgd/pud/..)?
>>> >
>>> > I think it needs to be able to keep track of the memory type per a
>>> > physical memory range, not per a translation, in order to prevent
>>> > aliasing of the memory type.
>>>
>>> Actual RAM (the lowmem kind, which is all of it on x86_64) is mapped
>>> linearly somewhere in kernel address space.  The pagetables for that
>>> mapping could be used as the canonical source of the memory type for
>>> the ram range in question.
>>>
>>> This only works for lowmem, so maybe it's not a good idea to rely on
>it.
>>
>> Right.
>>
>> I think using struct page table for the RAM ranges is a good way for
>> saving memory, but I wonder how often the RAM ranges are mapped other
>> than WB...  If not often, reserve_memtype() could simply call
>> rbt_memtype_check_insert() for all ranges, including RAM.
>>
>> In this patch, I left using reserve_ram_pages_type() since I do not
>see
>> much reason to use WT for RAM, either.
>
>I hereby predict that someone, some day, will build a system with
>nonvolatile "RAM", and someone will want this feature.  Just saying :)
>
>More realistically, someone might want to write a silly driver that
>lets programs mmap some WT memory for testing.
>
>--Andy

-- 
Sent from my mobile phone.  Please pardon brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
