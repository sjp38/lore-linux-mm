Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id C52496B0007
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 08:17:40 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id h3-v6so8555491otj.15
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 05:17:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i25-v6sor7388558otc.94.2018.06.08.05.17.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Jun 2018 05:17:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrWd+1iNmt36EFiLxMv8bQ-GodU=XygPRGb4h+xanhHHLQ@mail.gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-7-yu-cheng.yu@intel.com>
 <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com>
 <1528403417.5265.35.camel@2b52.sc.intel.com> <CALCETrXz3WWgZwUXJsDTWvmqKUArQFuMH1xJdSLVKFpTysNWxg@mail.gmail.com>
 <CAMe9rOr49V8rqRa_KVsw61PWd+crkQvPDgPKtvowazjmsfgWWQ@mail.gmail.com>
 <CAMe9rOphjpPd3HnKAdU-RmG0RGj6c2oAbnq+C2Jd1srsqTA7=w@mail.gmail.com> <CALCETrWd+1iNmt36EFiLxMv8bQ-GodU=XygPRGb4h+xanhHHLQ@mail.gmail.com>
From: "H.J. Lu" <hjl.tools@gmail.com>
Date: Fri, 8 Jun 2018 05:17:38 -0700
Message-ID: <CAMe9rOrrh70RKcpiOas9JVm0bc_xg+cTN+N9o4krOJxdXObpDw@mail.gmail.com>
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 9:35 PM, Andy Lutomirski <luto@kernel.org> wrote:
> On Thu, Jun 7, 2018 at 9:22 PM H.J. Lu <hjl.tools@gmail.com> wrote:
>>
>> On Thu, Jun 7, 2018 at 3:02 PM, H.J. Lu <hjl.tools@gmail.com> wrote:
>> > On Thu, Jun 7, 2018 at 2:01 PM, Andy Lutomirski <luto@kernel.org> wrote:
>> >> On Thu, Jun 7, 2018 at 1:33 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>> >>>
>> >>> On Thu, 2018-06-07 at 11:48 -0700, Andy Lutomirski wrote:
>> >>> > On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>> >>> > >
>> >>> > > The following operations are provided.
>> >>> > >
>> >>> > > ARCH_CET_STATUS:
>> >>> > >         return the current CET status
>> >>> > >
>> >>> > > ARCH_CET_DISABLE:
>> >>> > >         disable CET features
>> >>> > >
>> >>> > > ARCH_CET_LOCK:
>> >>> > >         lock out CET features
>> >>> > >
>> >>> > > ARCH_CET_EXEC:
>> >>> > >         set CET features for exec()
>> >>> > >
>> >>> > > ARCH_CET_ALLOC_SHSTK:
>> >>> > >         allocate a new shadow stack
>> >>> > >
>> >>> > > ARCH_CET_PUSH_SHSTK:
>> >>> > >         put a return address on shadow stack
>> >>> > >
>>
>> >> And why do we need ARCH_CET_EXEC?
>> >>
>> >> For background, I really really dislike adding new state that persists
>> >> across exec().  It's nice to get as close to a clean slate as possible
>> >> after exec() so that programs can run in a predictable environment.
>> >> exec() is also a security boundary, and anything a task can do to
>> >> affect itself after exec() needs to have its security implications
>> >> considered very carefully.  (As a trivial example, you should not be
>> >> able to use cetcmd ... sudo [malicious options here] to cause sudo to
>> >> run with CET off and then try to exploit it via the malicious options.
>> >>
>> >> If a shutoff is needed for testing, how about teaching ld.so to parse
>> >> LD_CET=no or similar and protect it the same way as LD_PRELOAD is
>> >> protected.  Or just do LD_PRELOAD=/lib/libdoesntsupportcet.so.
>> >>
>> >
>> > I will take a look.
>>
>> We can use LD_CET to turn off CET.   Since most of legacy binaries
>> are compatible with shadow stack,  ARCH_CET_EXEC can be used
>> to turn on shadow stack on legacy binaries:
>
> Is there any reason you can't use LD_CET=force to do it for
> dynamically linked binaries?

We need to enable shadow stack from the start.  Otherwise function
return will fail when returning from callee with shadow stack to caller
without shadow stack.

> I find it quite hard to believe that forcibly CET-ifying a legacy
> statically linked binary is a good idea.

We'd like to provide protection as much as we can.

-- 
H.J.
