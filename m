Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0CDD6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:43:51 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id a25-v6so16676886otf.2
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 04:43:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t46-v6sor266560oti.289.2018.06.12.04.43.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Jun 2018 04:43:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1806121155450.2157@nanos.tec.linutronix.de>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-7-yu-cheng.yu@intel.com>
 <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com>
 <1528403417.5265.35.camel@2b52.sc.intel.com> <CALCETrXz3WWgZwUXJsDTWvmqKUArQFuMH1xJdSLVKFpTysNWxg@mail.gmail.com>
 <CAMe9rOr49V8rqRa_KVsw61PWd+crkQvPDgPKtvowazjmsfgWWQ@mail.gmail.com> <alpine.DEB.2.21.1806121155450.2157@nanos.tec.linutronix.de>
From: "H.J. Lu" <hjl.tools@gmail.com>
Date: Tue, 12 Jun 2018 04:43:49 -0700
Message-ID: <CAMe9rOoCiXQ4iVD3j_AHGrvEXtoaVVZVs7H7fCuqNEuuR5j+2Q@mail.gmail.com>
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Tue, Jun 12, 2018 at 3:03 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Thu, 7 Jun 2018, H.J. Lu wrote:
>> On Thu, Jun 7, 2018 at 2:01 PM, Andy Lutomirski <luto@kernel.org> wrote:
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
> That works for stuff which loads all libraries at start time, but what
> happens if the program uses dlopen() later on? If CET is force locked and
> the library is not CET enabled, it will fail.

That is to prevent disabling CET by dlopening a legacy shared library.

> I don't see the point of trying to support CET by magic. It adds complexity
> and you'll never be able to handle all corner cases correctly. dlopen() is
> not even a corner case.

That is a price we pay for security.  To enable CET, especially shadow
shack, the program and all of shared libraries it uses should be CET
enabled.  Most of programs can be enabled with CET by compiling them
with -fcf-protection.

> Occasionally stuff needs to be recompiled to utilize new mechanisms, see
> retpoline ...
>
> Thanks,
>
>         tglx
>



-- 
H.J.
