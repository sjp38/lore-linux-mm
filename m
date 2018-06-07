Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF5A76B0006
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 17:01:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a13-v6so5037650pfo.22
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 14:01:33 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i33-v6si53514444pld.546.2018.06.07.14.01.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 14:01:32 -0700 (PDT)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 439CF2088F
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 21:01:32 +0000 (UTC)
Received: by mail-wm0-f48.google.com with SMTP id v16-v6so20429435wmh.5
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 14:01:32 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-7-yu-cheng.yu@intel.com>
 <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com> <1528403417.5265.35.camel@2b52.sc.intel.com>
In-Reply-To: <1528403417.5265.35.camel@2b52.sc.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 7 Jun 2018 14:01:18 -0700
Message-ID: <CALCETrXz3WWgZwUXJsDTWvmqKUArQFuMH1xJdSLVKFpTysNWxg@mail.gmail.com>
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Andrew Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 1:33 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>
> On Thu, 2018-06-07 at 11:48 -0700, Andy Lutomirski wrote:
> > On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > >
> > > The following operations are provided.
> > >
> > > ARCH_CET_STATUS:
> > >         return the current CET status
> > >
> > > ARCH_CET_DISABLE:
> > >         disable CET features
> > >
> > > ARCH_CET_LOCK:
> > >         lock out CET features
> > >
> > > ARCH_CET_EXEC:
> > >         set CET features for exec()
> > >
> > > ARCH_CET_ALLOC_SHSTK:
> > >         allocate a new shadow stack
> > >
> > > ARCH_CET_PUSH_SHSTK:
> > >         put a return address on shadow stack
> > >
> > > ARCH_CET_ALLOC_SHSTK and ARCH_CET_PUSH_SHSTK are intended only for
> > > the implementation of GLIBC ucontext related APIs.
> >
> > Please document exactly what these all do and why.  I don't understand
> > what purpose ARCH_CET_LOCK and ARCH_CET_EXEC serve.  CET is opt in for
> > each ELF program, so I think there should be no need for a magic
> > override.
>
> CET is initially enabled if the loader has CET capability.  Then the
> loader decides if the application can run with CET.  If the application
> cannot run with CET (e.g. a dependent library does not have CET), then
> the loader turns off CET before passing to the application.  When the
> loader is done, it locks out CET and the feature cannot be turned off
> anymore until the next exec() call.

Why is the lockout necessary?  If user code enables CET and tries to
run code that doesn't support CET, it will crash.  I don't see why we
need special code in the kernel to prevent a user program from calling
arch_prctl() and crashing itself.  There are already plenty of ways to
do that :)

> When the next exec() is called, CET
> feature is turned on/off based on the values set by ARCH_CET_EXEC.

And why do we need ARCH_CET_EXEC?

For background, I really really dislike adding new state that persists
across exec().  It's nice to get as close to a clean slate as possible
after exec() so that programs can run in a predictable environment.
exec() is also a security boundary, and anything a task can do to
affect itself after exec() needs to have its security implications
considered very carefully.  (As a trivial example, you should not be
able to use cetcmd ... sudo [malicious options here] to cause sudo to
run with CET off and then try to exploit it via the malicious options.

If a shutoff is needed for testing, how about teaching ld.so to parse
LD_CET=no or similar and protect it the same way as LD_PRELOAD is
protected.  Or just do LD_PRELOAD=/lib/libdoesntsupportcet.so.

--Andy
