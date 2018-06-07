Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4446B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 16:15:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e7-v6so4978969pfi.8
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 13:15:43 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id v38-v6si56085430plg.283.2018.06.07.13.15.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 13:15:42 -0700 (PDT)
Message-ID: <1528402350.5265.21.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 03/10] x86/cet: Signal handling for shadow stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 07 Jun 2018 13:12:30 -0700
In-Reply-To: <CALCETrWo77RS_wOzskw5OG-LdC1S-b_NY=uPWUmPbQEnNwANgQ@mail.gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <20180607143807.3611-4-yu-cheng.yu@intel.com>
	 <CALCETrWo77RS_wOzskw5OG-LdC1S-b_NY=uPWUmPbQEnNwANgQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Florian Weimer <fweimer@redhat.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, Cyrill Gorcunov <gorcunov@openvz.org>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, 2018-06-07 at 11:30 -0700, Andy Lutomirski wrote:
> On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> >
> > Set and restore shadow stack pointer for signals.
> 
> How does this interact with siglongjmp()?
> 
> This patch makes me extremely nervous due to the possibility of ABI
> issues and CRIU breakage.

Longjmp/Siglongjmp is handled in GLIBC and basically the shadow stack
pointer is unwound.  There could be some unexpected conditions.
However, we run all GLIBC tests.

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
> 
> > +int cet_push_shstk(int ia32, unsigned long ssp, unsigned long val)
> > +{
> > +       if (val >= TASK_SIZE)
> > +               return -EINVAL;
> 
> TASK_SIZE_MAX.  But I'm a bit unsure why you need this check at all.

If an invalid address is put on the shadow stack, the task will get a
control protection fault.  I will change it to TASK_SIZE_MAX.

> 
> > +int cet_restore_signal(unsigned long ssp)
> > +{
> > +       if (!current->thread.cet.shstk_enabled)
> > +               return 0;
> > +       return cet_set_shstk_ptr(ssp);
> > +}
> 
> This will blow up if the shadow stack enabled state changes in a
> signal handler.  Maybe we don't care.

Yes, the task will get a control protection fault.
