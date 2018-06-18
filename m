Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 239736B0007
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 17:44:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u16-v6so9190448pfm.15
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 14:44:50 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m62-v6si16576239pfb.127.2018.06.18.14.44.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 14:44:47 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 95CD3208A6
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 21:44:46 +0000 (UTC)
Received: by mail-wm0-f49.google.com with SMTP id v16-v6so16502975wmh.5
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 14:44:46 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <bbfde1b3-5e1b-80e3-30e8-fd1e46a2ceb1@gmail.com>
 <1528815820.8271.16.camel@2b52.sc.intel.com> <814fc15e80908d8630ff665be690ccbe6e69be88.camel@gmail.com>
 <1528988176.13101.15.camel@2b52.sc.intel.com> <2b77abb17dfaf58b7c23fac9d8603482e1887337.camel@gmail.com>
In-Reply-To: <2b77abb17dfaf58b7c23fac9d8603482e1887337.camel@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 18 Jun 2018 14:44:33 -0700
Message-ID: <CALCETrWCEjuM56J8dqXPR==MevJTYKan5dnAMFJaXzFMYr8Q_A@mail.gmail.com>
Subject: Re: [PATCH 00/10] Control Flow Enforcement - Part (3)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Sat, Jun 16, 2018 at 8:16 PM Balbir Singh <bsingharora@gmail.com> wrote:
>
> On Thu, 2018-06-14 at 07:56 -0700, Yu-cheng Yu wrote:
> > On Thu, 2018-06-14 at 11:07 +1000, Balbir Singh wrote:
> > > On Tue, 2018-06-12 at 08:03 -0700, Yu-cheng Yu wrote:
> > > > On Tue, 2018-06-12 at 20:56 +1000, Balbir Singh wrote:
> > > > >
> > > > > On 08/06/18 00:37, Yu-cheng Yu wrote:
> > > > > > This series introduces CET - Shadow stack
> > > > > >
> > > > > > At the high level, shadow stack is:
> > > > > >
> > > > > >       Allocated from a task's address space with vm_flags VM_SHSTK;
> > > > > >       Its PTEs must be read-only and dirty;
> > > > > >       Fixed sized, but the default size can be changed by sys admin.
> > > > > >
> > > > > > For a forked child, the shadow stack is duplicated when the next
> > > > > > shadow stack access takes place.
> > > > > >
> > > > > > For a pthread child, a new shadow stack is allocated.
> > > > > >
> > > > > > The signal handler uses the same shadow stack as the main program.
> > > > > >
> > > > >
> > > > > Even with sigaltstack()?
> > > > >
> > > >
> > > > Yes.
> > >
> > > I am not convinced that it would work, as we switch stacks, oveflow might
> > > be an issue. I also forgot to bring up setcontext(2), I presume those
> > > will get new shadow stacks
> >
> > Do you mean signal stack/sigaltstack overflow or swapcontext in a signal
> > handler?
> >
>
> I meant any combination of that. If there is a user space threads implementation that uses sigaltstack for switching threads
>

Anyone who does that is nuts.  The whole point of user space threads
is speed, and signals are very slow.  For userspace threads to work,
we need an API to allocate new shadow stacks, and we need to use the
extremely awkwardly defined RSTORSSP stuff to switch.  (I assume this
is possible on an ISA level.  The docs are bad, and the mnemonics for
the relevant instructions are nonsensical.)
