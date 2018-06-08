Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 749FB6B0007
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 00:10:00 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id r58-v6so7875822otr.0
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 21:10:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i25-v6sor7071722otc.94.2018.06.07.21.09.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 21:09:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrV1GG5rq_kwxkS-o3x8Ldr72ThdYgkJKQ9cx9Q63SxgTQ@mail.gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-7-yu-cheng.yu@intel.com>
 <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com>
 <1528403417.5265.35.camel@2b52.sc.intel.com> <CALCETrXz3WWgZwUXJsDTWvmqKUArQFuMH1xJdSLVKFpTysNWxg@mail.gmail.com>
 <CAMe9rOr49V8rqRa_KVsw61PWd+crkQvPDgPKtvowazjmsfgWWQ@mail.gmail.com> <CALCETrV1GG5rq_kwxkS-o3x8Ldr72ThdYgkJKQ9cx9Q63SxgTQ@mail.gmail.com>
From: "H.J. Lu" <hjl.tools@gmail.com>
Date: Thu, 7 Jun 2018 21:09:58 -0700
Message-ID: <CAMe9rOpeDrkwi-AG0vsiZy4NwkmavhB5Empv58FSHxtr3rpapw@mail.gmail.com>
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 4:01 PM, Andy Lutomirski <luto@kernel.org> wrote:
> On Thu, Jun 7, 2018 at 3:02 PM H.J. Lu <hjl.tools@gmail.com> wrote:
>>
>> On Thu, Jun 7, 2018 at 2:01 PM, Andy Lutomirski <luto@kernel.org> wrote:
>> > On Thu, Jun 7, 2018 at 1:33 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>> >>
>> >> On Thu, 2018-06-07 at 11:48 -0700, Andy Lutomirski wrote:
>> >> > On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>> >> > >
>> >> > > The following operations are provided.
>> >> > >
>> >> > > ARCH_CET_STATUS:
>> >> > >         return the current CET status
>> >> > >
>> >> > > ARCH_CET_DISABLE:
>> >> > >         disable CET features
>> >> > >
>> >> > > ARCH_CET_LOCK:
>> >> > >         lock out CET features
>> >> > >
>> >> > > ARCH_CET_EXEC:
>> >> > >         set CET features for exec()
>> >> > >
>> >> > > ARCH_CET_ALLOC_SHSTK:
>> >> > >         allocate a new shadow stack
>> >> > >
>> >> > > ARCH_CET_PUSH_SHSTK:
>> >> > >         put a return address on shadow stack
>> >> > >
>> >> > > ARCH_CET_ALLOC_SHSTK and ARCH_CET_PUSH_SHSTK are intended only for
>> >> > > the implementation of GLIBC ucontext related APIs.
>> >> >
>> >> > Please document exactly what these all do and why.  I don't understand
>> >> > what purpose ARCH_CET_LOCK and ARCH_CET_EXEC serve.  CET is opt in for
>> >> > each ELF program, so I think there should be no need for a magic
>> >> > override.
>> >>
>> >> CET is initially enabled if the loader has CET capability.  Then the
>> >> loader decides if the application can run with CET.  If the application
>> >> cannot run with CET (e.g. a dependent library does not have CET), then
>> >> the loader turns off CET before passing to the application.  When the
>> >> loader is done, it locks out CET and the feature cannot be turned off
>> >> anymore until the next exec() call.
>> >
>> > Why is the lockout necessary?  If user code enables CET and tries to
>> > run code that doesn't support CET, it will crash.  I don't see why we
>> > need special code in the kernel to prevent a user program from calling
>> > arch_prctl() and crashing itself.  There are already plenty of ways to
>> > do that :)
>>
>> On CET enabled machine, not all programs nor shared libraries are
>> CET enabled.  But since ld.so is CET enabled, all programs start
>> as CET enabled.  ld.so will disable CET if a program or any of its shared
>> libraries aren't CET enabled.  ld.so will lock up CET once it is done CET
>> checking so that CET can't no longer be disabled afterwards.
>
> Yeah, I got that.  No one has explained *why*.

It is to prevent malicious code from disabling CET.

> (Also, shouldn't the vDSO itself be marked as supporting CET?)

No. vDSO is loaded by kernel.  vDSO in CET kernel is CET
compatible.

-- 
H.J.
