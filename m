Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B38236B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 00:35:32 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v133-v6so4323484pgb.10
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 21:35:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a34-v6si5643926pla.522.2018.06.07.21.35.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 21:35:31 -0700 (PDT)
Received: from mail-wr0-f172.google.com (mail-wr0-f172.google.com [209.85.128.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 966152089E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 04:35:30 +0000 (UTC)
Received: by mail-wr0-f172.google.com with SMTP id w7-v6so11919558wrn.6
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 21:35:30 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-7-yu-cheng.yu@intel.com>
 <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com>
 <1528403417.5265.35.camel@2b52.sc.intel.com> <CALCETrXz3WWgZwUXJsDTWvmqKUArQFuMH1xJdSLVKFpTysNWxg@mail.gmail.com>
 <CAMe9rOr49V8rqRa_KVsw61PWd+crkQvPDgPKtvowazjmsfgWWQ@mail.gmail.com> <CAMe9rOphjpPd3HnKAdU-RmG0RGj6c2oAbnq+C2Jd1srsqTA7=w@mail.gmail.com>
In-Reply-To: <CAMe9rOphjpPd3HnKAdU-RmG0RGj6c2oAbnq+C2Jd1srsqTA7=w@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 7 Jun 2018 21:35:17 -0700
Message-ID: <CALCETrWd+1iNmt36EFiLxMv8bQ-GodU=XygPRGb4h+xanhHHLQ@mail.gmail.com>
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. J. Lu" <hjl.tools@gmail.com>
Cc: Andrew Lutomirski <luto@kernel.org>, Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 9:22 PM H.J. Lu <hjl.tools@gmail.com> wrote:
>
> On Thu, Jun 7, 2018 at 3:02 PM, H.J. Lu <hjl.tools@gmail.com> wrote:
> > On Thu, Jun 7, 2018 at 2:01 PM, Andy Lutomirski <luto@kernel.org> wrote:
> >> On Thu, Jun 7, 2018 at 1:33 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> >>>
> >>> On Thu, 2018-06-07 at 11:48 -0700, Andy Lutomirski wrote:
> >>> > On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> >>> > >
> >>> > > The following operations are provided.
> >>> > >
> >>> > > ARCH_CET_STATUS:
> >>> > >         return the current CET status
> >>> > >
> >>> > > ARCH_CET_DISABLE:
> >>> > >         disable CET features
> >>> > >
> >>> > > ARCH_CET_LOCK:
> >>> > >         lock out CET features
> >>> > >
> >>> > > ARCH_CET_EXEC:
> >>> > >         set CET features for exec()
> >>> > >
> >>> > > ARCH_CET_ALLOC_SHSTK:
> >>> > >         allocate a new shadow stack
> >>> > >
> >>> > > ARCH_CET_PUSH_SHSTK:
> >>> > >         put a return address on shadow stack
> >>> > >
>
> >> And why do we need ARCH_CET_EXEC?
> >>
> >> For background, I really really dislike adding new state that persists
> >> across exec().  It's nice to get as close to a clean slate as possible
> >> after exec() so that programs can run in a predictable environment.
> >> exec() is also a security boundary, and anything a task can do to
> >> affect itself after exec() needs to have its security implications
> >> considered very carefully.  (As a trivial example, you should not be
> >> able to use cetcmd ... sudo [malicious options here] to cause sudo to
> >> run with CET off and then try to exploit it via the malicious options.
> >>
> >> If a shutoff is needed for testing, how about teaching ld.so to parse
> >> LD_CET=no or similar and protect it the same way as LD_PRELOAD is
> >> protected.  Or just do LD_PRELOAD=/lib/libdoesntsupportcet.so.
> >>
> >
> > I will take a look.
>
> We can use LD_CET to turn off CET.   Since most of legacy binaries
> are compatible with shadow stack,  ARCH_CET_EXEC can be used
> to turn on shadow stack on legacy binaries:

Is there any reason you can't use LD_CET=force to do it for
dynamically linked binaries?

I find it quite hard to believe that forcibly CET-ifying a legacy
statically linked binary is a good idea.
