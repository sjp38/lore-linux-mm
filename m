Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 845C06B0006
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 08:24:24 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q129-v6so7856196oic.9
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 05:24:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t129-v6sor1006687oib.281.2018.06.08.05.24.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Jun 2018 05:24:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrWhMmqGWKx-yw55YKHMJwGyLZio5f8Pskh8X69zfQMy7A@mail.gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-7-yu-cheng.yu@intel.com>
 <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com>
 <1528403417.5265.35.camel@2b52.sc.intel.com> <CALCETrXz3WWgZwUXJsDTWvmqKUArQFuMH1xJdSLVKFpTysNWxg@mail.gmail.com>
 <CAMe9rOr49V8rqRa_KVsw61PWd+crkQvPDgPKtvowazjmsfgWWQ@mail.gmail.com>
 <CALCETrV1GG5rq_kwxkS-o3x8Ldr72ThdYgkJKQ9cx9Q63SxgTQ@mail.gmail.com>
 <CAMe9rOpeDrkwi-AG0vsiZy4NwkmavhB5Empv58FSHxtr3rpapw@mail.gmail.com> <CALCETrWhMmqGWKx-yw55YKHMJwGyLZio5f8Pskh8X69zfQMy7A@mail.gmail.com>
From: "H.J. Lu" <hjl.tools@gmail.com>
Date: Fri, 8 Jun 2018 05:24:22 -0700
Message-ID: <CAMe9rOpLDzWk=xdZqN1QJVnP-c_dti5Fy=C_GqbeQpS_a=0ewA@mail.gmail.com>
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 9:38 PM, Andy Lutomirski <luto@kernel.org> wrote:
> On Thu, Jun 7, 2018 at 9:10 PM H.J. Lu <hjl.tools@gmail.com> wrote:
>>
>> On Thu, Jun 7, 2018 at 4:01 PM, Andy Lutomirski <luto@kernel.org> wrote:
>> > On Thu, Jun 7, 2018 at 3:02 PM H.J. Lu <hjl.tools@gmail.com> wrote:
>> >>
>> >> On Thu, Jun 7, 2018 at 2:01 PM, Andy Lutomirski <luto@kernel.org> wrote:
>> >> > On Thu, Jun 7, 2018 at 1:33 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>> >> >>
>> >> >> On Thu, 2018-06-07 at 11:48 -0700, Andy Lutomirski wrote:
>> >> >> > On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>> >> >> > >
>> >> >> > > The following operations are provided.
>> >> >> > >
>> >> >> > > ARCH_CET_STATUS:
>> >> >> > >         return the current CET status
>> >> >> > >
>> >> >> > > ARCH_CET_DISABLE:
>> >> >> > >         disable CET features
>> >> >> > >
>> >> >> > > ARCH_CET_LOCK:
>> >> >> > >         lock out CET features
>> >> >> > >
>> >> >> > > ARCH_CET_EXEC:
>> >> >> > >         set CET features for exec()
>> >> >> > >
>> >> >> > > ARCH_CET_ALLOC_SHSTK:
>> >> >> > >         allocate a new shadow stack
>> >> >> > >
>> >> >> > > ARCH_CET_PUSH_SHSTK:
>> >> >> > >         put a return address on shadow stack
>> >> >> > >
>> >> >> > > ARCH_CET_ALLOC_SHSTK and ARCH_CET_PUSH_SHSTK are intended only for
>> >> >> > > the implementation of GLIBC ucontext related APIs.
>> >> >> >
>> >> >> > Please document exactly what these all do and why.  I don't understand
>> >> >> > what purpose ARCH_CET_LOCK and ARCH_CET_EXEC serve.  CET is opt in for
>> >> >> > each ELF program, so I think there should be no need for a magic
>> >> >> > override.
>> >> >>
>> >> >> CET is initially enabled if the loader has CET capability.  Then the
>> >> >> loader decides if the application can run with CET.  If the application
>> >> >> cannot run with CET (e.g. a dependent library does not have CET), then
>> >> >> the loader turns off CET before passing to the application.  When the
>> >> >> loader is done, it locks out CET and the feature cannot be turned off
>> >> >> anymore until the next exec() call.
>> >> >
>> >> > Why is the lockout necessary?  If user code enables CET and tries to
>> >> > run code that doesn't support CET, it will crash.  I don't see why we
>> >> > need special code in the kernel to prevent a user program from calling
>> >> > arch_prctl() and crashing itself.  There are already plenty of ways to
>> >> > do that :)
>> >>
>> >> On CET enabled machine, not all programs nor shared libraries are
>> >> CET enabled.  But since ld.so is CET enabled, all programs start
>> >> as CET enabled.  ld.so will disable CET if a program or any of its shared
>> >> libraries aren't CET enabled.  ld.so will lock up CET once it is done CET
>> >> checking so that CET can't no longer be disabled afterwards.
>> >
>> > Yeah, I got that.  No one has explained *why*.
>>
>> It is to prevent malicious code from disabling CET.
>>
>
> By the time malicious code issue its own syscalls, you've already lost
> the battle.  I could probably be convinced that a lock-CET-on feature
> that applies *only* to the calling thread and is not inherited by
> clone() is a decent idea, but I'd want to see someone who understands
> the state of the art in exploit design justify it.  You're also going
> to need to figure out how to make CRIU work if you allow locking CET
> on.
>
> A priori, I think we should just not provide a lock mechanism.

We need a door for CET.  But it is a very bad idea to leave it open
all the time.  I don't know much about CRIU,  If it is Checkpoint/Restore
In Userspace.  Can you free any application with AVX512 on AVX512
machine and restore it on non-AVX512 machine?

>> > (Also, shouldn't the vDSO itself be marked as supporting CET?)
>>
>> No. vDSO is loaded by kernel.  vDSO in CET kernel is CET
>> compatible.
>>
>
> I think the vDSO should do its best to act like a real DSO.  That
> means that, if the vDSO supports CET, it should advertise support for
> CET using the Linux ABI.  Since you're going to require GCC 8 anyway,
> this should be a single line of code in the Makefile.

Sure.  A couple lines.

-- 
H.J.
