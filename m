Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC9526B026D
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 12:08:28 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y7-v6so8531687plp.16
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 09:08:28 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j9-v6si5651380pll.407.2018.10.04.09.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 09:08:27 -0700 (PDT)
Received: from mail-wm1-f50.google.com (mail-wm1-f50.google.com [209.85.128.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1FDDC2098A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 16:08:27 +0000 (UTC)
Received: by mail-wm1-f50.google.com with SMTP id a8-v6so5588619wmf.1
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 09:08:27 -0700 (PDT)
MIME-Version: 1.0
References: <20180921150553.21016-1-yu-cheng.yu@intel.com> <20180921150553.21016-7-yu-cheng.yu@intel.com>
 <20181004132811.GJ32759@asgard.redhat.com> <3350f7b42b32f3f7a1963a9c9c526210c24f7b05.camel@intel.com>
In-Reply-To: <3350f7b42b32f3f7a1963a9c9c526210c24f7b05.camel@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 4 Oct 2018 09:08:12 -0700
Message-ID: <CALCETrWTu-zuSKn6e3=QkP4_ca8PJfuevMD8KJq0VX3nq7Hw8Q@mail.gmail.com>
Subject: Re: [RFC PATCH v4 6/9] x86/cet/ibt: Add arch_prctl functions for IBT
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Eugene Syromiatnikov <esyr@redhat.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

> On Oct 4, 2018, at 8:37 AM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
>> On Thu, 2018-10-04 at 15:28 +0200, Eugene Syromiatnikov wrote:
>>> On Fri, Sep 21, 2018 at 08:05:50AM -0700, Yu-cheng Yu wrote:
>>> Update ARCH_CET_STATUS and ARCH_CET_DISABLE to include Indirect
>>> Branch Tracking features.
>>>
>>> Introduce:
>>>
>>> arch_prctl(ARCH_CET_LEGACY_BITMAP, unsigned long *addr)
>>>    Enable the Indirect Branch Tracking legacy code bitmap.
>>>
>>>    The parameter 'addr' is a pointer to a user buffer.
>>>    On returning to the caller, the kernel fills the following:
>>>
>>>    *addr = IBT bitmap base address
>>>    *(addr + 1) = IBT bitmap size
>>
>> Again, some structure with a size field would be better from
>> UAPI/extensibility standpoint.
>>
>> One additional point: "size" in the structure from kernel should have
>> structure size expected by kernel, and at least providing there "0" from
>> user space shouldn't lead to failure (in fact, it is possible to provide
>> structure size back to userspace even if buffer is too small, along
>> with error).
>
> This has been in GLIBC v2.28.  We cannot change it anymore.

Sure you can. Just change ARCH_CET_LEGACY_BITMAP to a new number.  You
might need to change all the constants.  And if the ELF note by itself
causes a problem too, you may need to rename it.  And maybe ask glibc
to kindly not enable code that depends on non-upstreamed kernel
features.

There is not, and has never been, any ABI compatibility requirement
that says that, if glibc 2.28 "enables" a feature, that the kernel
will ever enable it in a way that makes glibc 2.28 actually support
it.  All the kernel needs to do is avoid making glibc 2.28 *crash*.
