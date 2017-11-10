Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 18B09440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 21:26:03 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id s2so7452669pge.19
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 18:26:03 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w1si7570788pgp.781.2017.11.09.18.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 18:26:01 -0800 (PST)
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3A4D921993
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 02:26:01 +0000 (UTC)
Received: by mail-io0-f170.google.com with SMTP id 97so12002375iok.7
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 18:26:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4c8c441e-d65c-fcec-7718-6997bd010971@linux.intel.com>
References: <20171108194646.907A1942@viggo.jf.intel.com> <20171108194731.AB5BDA01@viggo.jf.intel.com>
 <CALCETrUs-6yWK9uYLFmVNhYz9e1NAUbT6BPJKHge8Zkwghsesg@mail.gmail.com>
 <6871f284-b7e9-f843-608f-5345f9d03396@linux.intel.com> <CALCETrVFDtj5m2eA_fq9n_s4+E2u6GDA-xEfNYPkJceicT4taQ@mail.gmail.com>
 <27b55108-1e72-cb3d-d5d8-ffe0238245aa@linux.intel.com> <CALCETrXy-K5fKzvjF-Dr6gVpJ+ui4c-GjrT6Oruh5ePvPudPpg@mail.gmail.com>
 <4c8c441e-d65c-fcec-7718-6997bd010971@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 9 Nov 2017 18:25:39 -0800
Message-ID: <CALCETrXzmtoS-vHF3AHVZtuf0LsDsFLDUMSk0TjT0eOfGHjHkQ@mail.gmail.com>
Subject: Re: [PATCH 24/30] x86, kaiser: disable native VSYSCALL
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Thu, Nov 9, 2017 at 5:22 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
> On 11/09/2017 05:04 PM, Andy Lutomirski wrote:
>> On Thu, Nov 9, 2017 at 4:57 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
>>> On 11/09/2017 04:53 PM, Andy Lutomirski wrote:
>>>>> The KAISER code attempts to "poison" the user portion of the kernel page
>>>>> tables.  It detects the entries pages that it wants that it wants to
>>>>> poison in two ways:
>>>>>  * Looking for addresses >= PAGE_OFFSET
>>>>>  * Looking for entries without _PAGE_USER set
>>>> What do you mean "poison"?
>>>
>>> I meant the _PAGE_NX magic that we do in here:
>>>
>>> https://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-kaiser.git/commit/?h=kaiser-414rc7-20171108&id=c4f7d0819170761f092fcf2327b85b082368e73a
>>>
>>> to ensure that userspace is unable to run on the kernel PGD.
>>
>> Aha, I get it.  Why not just drop the _PAGE_USER check?  You could
>> instead warn if you see a _PAGE_USER page that doesn't have the
>> correct address for the vsyscall.
>
> The _PAGE_USER check helps us with kernel things that want to create
> mappings below PAGE_OFFSET.  The EFI code was the prime user for this.
> Without this, we poison the EFI mappings and the EFI calls die.

OK, let's see if I understand.  EFI and maybe some other stuff creates
low mappings with _PAGE_USER clear that are intended to be executed in
kernel mode, and, if you just set NX on all low mappings in kernel
mode, then it doesn't work.

Here are two proposals to address this without breaking vsyscalls.

1. Set NX on low mappings that are _PAGE_USER.  Don't set NX on high
mappings but, optionally, warn if you see _PAGE_USER on any address
that isn't the vsyscall page.

2. Ignore _PAGE_USER entirely and just mark the EFI mm as special so
KAISER doesn't muck with it.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
