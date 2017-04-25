Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 41CD06B02F2
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 15:01:25 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id k77so106242661oih.11
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:01:25 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id 126si13212114oig.267.2017.04.25.12.01.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 12:01:23 -0700 (PDT)
Received: by mail-oi0-x236.google.com with SMTP id y11so151100050oie.0
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:01:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170425185333.3ecz46gn5ufy4bwi@gmail.com>
References: <20170425092557.21852-1-kirill.shutemov@linux.intel.com>
 <CAPcyv4j6woeE7QfTVXEohh-kCbcFFJQmciMmgf5RDDWntM+P5w@mail.gmail.com> <20170425185333.3ecz46gn5ufy4bwi@gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 25 Apr 2017 12:01:22 -0700
Message-ID: <CAPcyv4gxbD2CNEfwacO=c1P9qJnRX3mo3=07HzV45Lpqem-=ag@mail.gmail.com>
Subject: Re: [PATCH] x86/mm/64: Fix crash in remove_pagetable()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Apr 25, 2017 at 11:53 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Dan Williams <dan.j.williams@intel.com> wrote:
>
>> On Tue, Apr 25, 2017 at 2:25 AM, Kirill A. Shutemov
>> <kirill.shutemov@linux.intel.com> wrote:
>> > remove_pagetable() does page walk using p*d_page_vaddr() plus cast.
>> > It's not canonical approach -- we usually use p*d_offset() for that.
>> >
>> > It works fine as long as all page table levels are present. We broke the
>> > invariant by introducing folded p4d page table level.
>> >
>> > As result, remove_pagetable() interprets PMD as PUD and it leads to
>> > crash:
>> >
>> >         BUG: unable to handle kernel paging request at ffff880300000000
>> >         IP: memchr_inv+0x60/0x110
>> >         PGD 317d067
>> >         P4D 317d067
>> >         PUD 3180067
>> >         PMD 33f102067
>> >         PTE 8000000300000060
>> >
>> > Let's fix this by using p*d_offset() instead of p*d_page_vaddr() for
>> > page walk.
>> >
>> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> > Reported-by: Dan Williams <dan.j.williams@intel.com>
>> > Fixes: f2a6a7050109 ("x86: Convert the rest of the code to support p4d_t")
>>
>> Thanks! This patch on top of tip/master passes a full run of the
>> nvdimm regression suite.
>>
>> Tested-by: Dan Williams <dan.j.williams@intel.com>
>
> Does a re-application of:
>
>   "x86/mm/gup: Switch GUP to the generic get_user_page_fast() implementation"
>
> still work (which you can achive via 'git revert 6dd29b3df975'), or is that
> another breakage?

That's another breakage. We're discussing how to resolve it in this thread:

    http://www.spinics.net/lists/linux-mm/msg126056.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
