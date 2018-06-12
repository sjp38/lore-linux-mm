Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2CD846B000C
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 12:02:05 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r8-v6so7241681pgq.2
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 09:02:05 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h8-v6si444643pls.69.2018.06.12.09.02.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 09:02:03 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1F53A208CB
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 16:02:03 +0000 (UTC)
Received: by mail-wm0-f47.google.com with SMTP id v16-v6so21575501wmh.5
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 09:02:03 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-7-yu-cheng.yu@intel.com>
 <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com>
 <1528403417.5265.35.camel@2b52.sc.intel.com> <CALCETrXz3WWgZwUXJsDTWvmqKUArQFuMH1xJdSLVKFpTysNWxg@mail.gmail.com>
 <CAMe9rOr49V8rqRa_KVsw61PWd+crkQvPDgPKtvowazjmsfgWWQ@mail.gmail.com>
 <alpine.DEB.2.21.1806121155450.2157@nanos.tec.linutronix.de> <CAMe9rOoCiXQ4iVD3j_AHGrvEXtoaVVZVs7H7fCuqNEuuR5j+2Q@mail.gmail.com>
In-Reply-To: <CAMe9rOoCiXQ4iVD3j_AHGrvEXtoaVVZVs7H7fCuqNEuuR5j+2Q@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 12 Jun 2018 09:01:48 -0700
Message-ID: <CALCETrXO8R+RQPhJFk4oiA4PF77OgSS2Yro_POXQj1zvdLo61A@mail.gmail.com>
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. J. Lu" <hjl.tools@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Andrew Lutomirski <luto@kernel.org>, Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Tue, Jun 12, 2018 at 4:43 AM H.J. Lu <hjl.tools@gmail.com> wrote:
>
> On Tue, Jun 12, 2018 at 3:03 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Thu, 7 Jun 2018, H.J. Lu wrote:
> >> On Thu, Jun 7, 2018 at 2:01 PM, Andy Lutomirski <luto@kernel.org> wrote:
> >> > Why is the lockout necessary?  If user code enables CET and tries to
> >> > run code that doesn't support CET, it will crash.  I don't see why we
> >> > need special code in the kernel to prevent a user program from calling
> >> > arch_prctl() and crashing itself.  There are already plenty of ways to
> >> > do that :)
> >>
> >> On CET enabled machine, not all programs nor shared libraries are
> >> CET enabled.  But since ld.so is CET enabled, all programs start
> >> as CET enabled.  ld.so will disable CET if a program or any of its shared
> >> libraries aren't CET enabled.  ld.so will lock up CET once it is done CET
> >> checking so that CET can't no longer be disabled afterwards.
> >
> > That works for stuff which loads all libraries at start time, but what
> > happens if the program uses dlopen() later on? If CET is force locked and
> > the library is not CET enabled, it will fail.
>
> That is to prevent disabling CET by dlopening a legacy shared library.
>
> > I don't see the point of trying to support CET by magic. It adds complexity
> > and you'll never be able to handle all corner cases correctly. dlopen() is
> > not even a corner case.
>
> That is a price we pay for security.  To enable CET, especially shadow
> shack, the program and all of shared libraries it uses should be CET
> enabled.  Most of programs can be enabled with CET by compiling them
> with -fcf-protection.

If you charge too high a price for security, people may turn it off.
I think we're going to need a mode where a program says "I want to use
the CET, but turn it off if I dlopen an unsupported library".  There
are programs that load binary-only plugins.
