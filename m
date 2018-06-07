Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id CE4586B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 16:07:18 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x90-v6so2979529lfi.17
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 13:07:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y11-v6sor419697ljc.29.2018.06.07.13.07.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 13:07:16 -0700 (PDT)
Date: Thu, 7 Jun 2018 23:07:14 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 03/10] x86/cet: Signal handling for shadow stack
Message-ID: <20180607200714.GA2525@uranus>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
 <20180607143807.3611-4-yu-cheng.yu@intel.com>
 <CALCETrWo77RS_wOzskw5OG-LdC1S-b_NY=uPWUmPbQEnNwANgQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWo77RS_wOzskw5OG-LdC1S-b_NY=uPWUmPbQEnNwANgQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, Florian Weimer <fweimer@redhat.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 07, 2018 at 11:30:34AM -0700, Andy Lutomirski wrote:
> On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> >
> > Set and restore shadow stack pointer for signals.
> 
> How does this interact with siglongjmp()?
> 
> This patch makes me extremely nervous due to the possibility of ABI
> issues and CRIU breakage.
> 
> > diff --git a/arch/x86/include/uapi/asm/sigcontext.h b/arch/x86/include/uapi/asm/sigcontext.h
> > index 844d60eb1882..6c8997a0156a 100644
> > --- a/arch/x86/include/uapi/asm/sigcontext.h
> > +++ b/arch/x86/include/uapi/asm/sigcontext.h
> > @@ -230,6 +230,7 @@ struct sigcontext_32 {
> >         __u32                           fpstate; /* Zero when no FPU/extended context */
> >         __u32                           oldmask;
> >         __u32                           cr2;
> > +       __u32                           ssp;
> >  };
> >
> >  /*
> > @@ -262,6 +263,7 @@ struct sigcontext_64 {
> >         __u64                           trapno;
> >         __u64                           oldmask;
> >         __u64                           cr2;
> > +       __u64                           ssp;
> >
> >         /*
> >          * fpstate is really (struct _fpstate *) or (struct _xstate *)
> > @@ -320,6 +322,7 @@ struct sigcontext {
> >         struct _fpstate __user          *fpstate;
> >         __u32                           oldmask;
> >         __u32                           cr2;
> > +       __u32                           ssp;
> 
> Is it actually okay to modify these structures like this?  They're
> part of the user ABI, and I don't know whether any user code relies on
> the size being constant.

For sure it might cause problems for CRIU since we have
similar definitions for this structure inside our code.
That said if kernel is about to modify the structures it
should keep backward compatibility at least if a user
passes previous version of a structure @ssp should be
set to something safe by the kernel itself.

I didn't read the whole series of patches in details
yet, hopefully will be able tomorrow. Thanks Andy for
CC'ing!
