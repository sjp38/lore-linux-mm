Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 186206B0006
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 16:57:18 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a13-v6so5030724pfo.22
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 13:57:18 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r10-v6si4575895pfe.121.2018.06.07.13.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 13:57:16 -0700 (PDT)
Received: from mail-wr0-f170.google.com (mail-wr0-f170.google.com [209.85.128.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5A6E6208AE
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 20:57:16 +0000 (UTC)
Received: by mail-wr0-f170.google.com with SMTP id w10-v6so11193465wrk.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 13:57:16 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-4-yu-cheng.yu@intel.com>
 <CALCETrWo77RS_wOzskw5OG-LdC1S-b_NY=uPWUmPbQEnNwANgQ@mail.gmail.com> <20180607200714.GA2525@uranus>
In-Reply-To: <20180607200714.GA2525@uranus>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 7 Jun 2018 13:57:03 -0700
Message-ID: <CALCETrXAoPsHK49c1Dpa8N0ccsxjwnVOTktKVaY++xjHxdmUzg@mail.gmail.com>
Subject: Re: [PATCH 03/10] x86/cet: Signal handling for shadow stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, Florian Weimer <fweimer@redhat.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 1:07 PM Cyrill Gorcunov <gorcunov@gmail.com> wrote:
>
> On Thu, Jun 07, 2018 at 11:30:34AM -0700, Andy Lutomirski wrote:
> > On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > >
> > > Set and restore shadow stack pointer for signals.
> >
> > How does this interact with siglongjmp()?
> >
> > This patch makes me extremely nervous due to the possibility of ABI
> > issues and CRIU breakage.
> >
> > > diff --git a/arch/x86/include/uapi/asm/sigcontext.h b/arch/x86/include/uapi/asm/sigcontext.h
> > > index 844d60eb1882..6c8997a0156a 100644
> > > --- a/arch/x86/include/uapi/asm/sigcontext.h
> > > +++ b/arch/x86/include/uapi/asm/sigcontext.h
> > > @@ -230,6 +230,7 @@ struct sigcontext_32 {
> > >         __u32                           fpstate; /* Zero when no FPU/extended context */
> > >         __u32                           oldmask;
> > >         __u32                           cr2;
> > > +       __u32                           ssp;
> > >  };
> > >
> > >  /*
> > > @@ -262,6 +263,7 @@ struct sigcontext_64 {
> > >         __u64                           trapno;
> > >         __u64                           oldmask;
> > >         __u64                           cr2;
> > > +       __u64                           ssp;
> > >
> > >         /*
> > >          * fpstate is really (struct _fpstate *) or (struct _xstate *)
> > > @@ -320,6 +322,7 @@ struct sigcontext {
> > >         struct _fpstate __user          *fpstate;
> > >         __u32                           oldmask;
> > >         __u32                           cr2;
> > > +       __u32                           ssp;
> >
> > Is it actually okay to modify these structures like this?  They're
> > part of the user ABI, and I don't know whether any user code relies on
> > the size being constant.
>
> For sure it might cause problems for CRIU since we have
> similar definitions for this structure inside our code.
> That said if kernel is about to modify the structures it
> should keep backward compatibility at least if a user
> passes previous version of a structure @ssp should be
> set to something safe by the kernel itself.
>
> I didn't read the whole series of patches in details
> yet, hopefully will be able tomorrow. Thanks Andy for
> CC'ing!

We have uc_flags.  It might be useful to carve out some of the flag
space (24 bits?) to indicate something like the *size* of sigcontext
and teach the kernel that new sigcontext fields should only be parsed
on sigreturn() if the size is large enough.
