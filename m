Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7C486B0007
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 10:09:27 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id n132-v6so5627558itn.2
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 07:09:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11-v6sor8515138iop.37.2018.10.10.07.09.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 07:09:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181003173256.GG12998@arrakis.emea.arm.com>
References: <cover.1538485901.git.andreyknvl@google.com> <47a464307d4df3c0cb65f88d1fe83f9a741dd74b.1538485901.git.andreyknvl@google.com>
 <20181003173256.GG12998@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 10 Oct 2018 16:09:25 +0200
Message-ID: <CAAeHK+yPCRNAOSi6OpYC_Tdbo9SoXRVRbx8pjXNq96v8csO-Wg@mail.gmail.com>
Subject: Re: [PATCH v7 7/8] arm64: update Documentation/arm64/tagged-pointers.txt
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Evgeniy Stepanov <eugenis@google.com>

On Wed, Oct 3, 2018 at 7:32 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On Tue, Oct 02, 2018 at 03:12:42PM +0200, Andrey Konovalov wrote:
>> diff --git a/Documentation/arm64/tagged-pointers.txt b/Documentation/arm64/tagged-pointers.txt
>> index a25a99e82bb1..ae877d185fdb 100644
>> --- a/Documentation/arm64/tagged-pointers.txt
>> +++ b/Documentation/arm64/tagged-pointers.txt
>> @@ -17,13 +17,21 @@ this byte for application use.
>>  Passing tagged addresses to the kernel
>>  --------------------------------------
>>
>> -All interpretation of userspace memory addresses by the kernel assumes
>> -an address tag of 0x00.
>> +Some initial work for supporting non-zero address tags passed to the
>> +kernel has been done. As of now, the kernel supports tags in:
>
> With my maintainer hat on, the above statement leads me to think this
> new ABI is work in progress, so not yet suitable for upstream.

OK, I think we can just say "The kernel supports tags in:" here. Will do in v8.

>
> Also, how is user space supposed to know that it can now pass tagged
> pointers into the kernel? An ABI change (or relaxation), needs to be
> advertised by the kernel, usually via a new HWCAP bit (e.g. HWCAP_TBI).
> Once we have a HWCAP bit in place, we need to be pretty clear about
> which syscalls can and cannot cope with tagged pointers. The "as of now"
> implies potential further relaxation which, again, would need to be
> advertised to user in some (additional) way.

How exactly should I do that? Something like this [1]? Or is it only
for hardware specific things and for this patchset I need to do
something else?

[1] https://github.com/torvalds/linux/commit/7206dc93a58fb76421c4411eefa3c003337bcb2d

>
>> -This includes, but is not limited to, addresses found in:
>> +  - user fault addresses
>
> While the kernel currently supports this in some way (by clearing the
> tag exception entry, el0_da), the above implies (at least to me) that
> sigcontext.fault_address would contain the tagged address. That's not
> the case (unless I missed it in your patches).

I'll update the doc to reflect this in v8.

>
>> - - pointer arguments to system calls, including pointers in structures
>> -   passed to system calls,
>> +  - pointer arguments (including pointers in structures), which don't
>> +    describe virtual memory ranges, passed to system calls
>
> I think we need to be more precise here...

In what way?

>
>> +All other interpretations of userspace memory addresses by the kernel
>> +assume an address tag of 0x00. This includes, but is not limited to,
>> +addresses found in:
>> +
>> + - pointer arguments (including pointers in structures), which describe
>> +   virtual memory ranges, passed to memory system calls (mmap, mprotect,
>> +   etc.)
>
> ...and probably a full list here.

Will add a full list in v8.
