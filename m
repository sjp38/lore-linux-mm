Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7245B6B0010
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 05:04:52 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id a206-v6so22230353oib.7
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 02:04:52 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l19si10550762otn.248.2018.10.19.02.04.51
        for <linux-mm@kvack.org>;
        Fri, 19 Oct 2018 02:04:51 -0700 (PDT)
Subject: Re: [PATCH v7 0/8] arm64: untag user pointers passed to the kernel
References: <cover.1538485901.git.andreyknvl@google.com>
 <be684ce5-92fd-e970-b002-83452cf50abd@arm.com>
 <CAAeHK+yEZTLjgSj8YUzeJec9Pp2TwuLT5nCa1OpfBLXJkx_hhg@mail.gmail.com>
 <CAFKCwrh4-BvFB_R1J0LWcbfeR=d02OazowFuMU+hmq8Y=Dx+4w@mail.gmail.com>
From: Vincenzo Frascino <vincenzo.frascino@arm.com>
Message-ID: <9bb7fefd-3f8f-266a-3cc9-cc64f8927206@arm.com>
Date: Fri, 19 Oct 2018 10:04:42 +0100
MIME-Version: 1.0
In-Reply-To: <CAFKCwrh4-BvFB_R1J0LWcbfeR=d02OazowFuMU+hmq8Y=Dx+4w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Evgenii Stepanov <eugenis@google.com>, Andrey Konovalov <andreyknvl@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Shuah Khan <shuah@kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, "open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>

On 10/17/18 9:25 PM, Evgenii Stepanov wrote:
> On Wed, Oct 17, 2018 at 7:20 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> On Wed, Oct 17, 2018 at 4:06 PM, Vincenzo Frascino
>> <vincenzo.frascino@arm.com> wrote:
>>> Hi Andrey,
>>> I have been thinking a bit lately on how to address the problem of user tagged pointers passed to the kernel through syscalls, and IMHO probably the best way we have to catch them all and make sure that the approach is maintainable in the long term is to introduce shims that tag/untag the pointers passed to the kernel.
>>>
>>> In details, what I am proposing can live either in userspace (preferred solution so that we do not have to relax the ABI) or in kernel space and can be summarized as follows:
>>>  - A shim is specific to a syscall and is called by the libc when it needs to invoke the respective syscall.
>>>  - It is required only if the syscall accepts pointers.
>>>  - It saves the tags of a pointers passed to the syscall in memory (same approach if the we are passing a struct that contains pointers to the kernel, with the difference that all the tags of the pointers in the struct need to be saved singularly)
>>>  - Untags the pointers
>>>  - Invokes the syscall
>>>  - Retags the pointers with the tags stored in memory
>>>  - Returns
>>>
>>> What do you think?
>>
>> Hi Vincenzo,
>>
>> If I correctly understand what you are proposing, I'm not sure if that
>> would work with the countless number of different ioctl calls. For
>> example when an ioctl accepts a struct with a bunch of pointer fields.
>> In this case a shim like the one you propose can't live in userspace,
>> since libc doesn't know about the interface of all ioctls, so it can't
>> know which fields to untag. The kernel knows about those interfaces
>> (since the kernel implements them), but then we would need a custom
>> shim for each ioctl variation, which doesn't seem practical.
> 
> The current patchset handles majority of pointers in a just a few
> common places, like copy_from_user. Userspace shims will need to untag
> & retag all pointer arguments - we are looking at hundreds if not
> thousands of shims. They will also be located in a different code base
> from the syscall / ioctl implementations, which would make them
> impossible to keep up to date.
> 

I agree with both of you, ioctl is the real show stopper for this approach. Thanks for pointing this out.

-- 
Regards,
Vincenzo
