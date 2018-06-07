Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4F86B0003
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 15:54:14 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id x2-v6so5955592plv.0
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 12:54:14 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p2-v6si40004414pgn.187.2018.06.07.12.54.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 12:54:12 -0700 (PDT)
Message-ID: <1528401060.5265.4.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 03/10] x86/cet: Signal handling for shadow stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 07 Jun 2018 12:51:00 -0700
In-Reply-To: <2b920019-cf03-334c-3b6a-b2c6b7f4dfa3@redhat.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <20180607143807.3611-4-yu-cheng.yu@intel.com>
	 <CALCETrWo77RS_wOzskw5OG-LdC1S-b_NY=uPWUmPbQEnNwANgQ@mail.gmail.com>
	 <2b920019-cf03-334c-3b6a-b2c6b7f4dfa3@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Dmitry Safonov <dsafonov@virtuozzo.com>, Cyrill Gorcunov <gorcunov@openvz.org>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, 2018-06-07 at 20:58 +0200, Florian Weimer wrote:
> On 06/07/2018 08:30 PM, Andy Lutomirski wrote:
> > On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> >>
> >> Set and restore shadow stack pointer for signals.
> > 
> > How does this interact with siglongjmp()?
> 
> We plan to use some unused signal mask bits in the jump buffer (we have 
> a lot of those in glibc for some reason) to store the shadow stack pointer.
> 
> > This patch makes me extremely nervous due to the possibility of ABI
> > issues and CRIU breakage.
> > 
> >> diff --git a/arch/x86/include/uapi/asm/sigcontext.h b/arch/x86/include/uapi/asm/sigcontext.h
> >> index 844d60eb1882..6c8997a0156a 100644
> >> --- a/arch/x86/include/uapi/asm/sigcontext.h
> >> +++ b/arch/x86/include/uapi/asm/sigcontext.h
> >> @@ -230,6 +230,7 @@ struct sigcontext_32 {
> >>          __u32                           fpstate; /* Zero when no FPU/extended context */
> >>          __u32                           oldmask;
> >>          __u32                           cr2;
> >> +       __u32                           ssp;
> >>   };
> >>
> >>   /*
> >> @@ -262,6 +263,7 @@ struct sigcontext_64 {
> >>          __u64                           trapno;
> >>          __u64                           oldmask;
> >>          __u64                           cr2;
> >> +       __u64                           ssp;
> >>
> >>          /*
> >>           * fpstate is really (struct _fpstate *) or (struct _xstate *)
> >> @@ -320,6 +322,7 @@ struct sigcontext {
> >>          struct _fpstate __user          *fpstate;
> >>          __u32                           oldmask;
> >>          __u32                           cr2;
> >> +       __u32                           ssp;
> > 
> > Is it actually okay to modify these structures like this?  They're
> > part of the user ABI, and I don't know whether any user code relies on
> > the size being constant.
> 
> Probably not.  Historically, these things have been tacked at the end of 
> the floating point state, see struct _xstate:
> 
>          /* New processor state extensions go here: */
> 
> However, I'm not sure if this is really ideal because I doubt that 
> everyone who needs the shadow stack pointer also wants to sacrifice 
> space for the AVX-512 save area (which is already a backwards 
> compatibility hazard).  Other architectures have variable offsets and 
> some TLV-style setup here.
> 
> Thanks,
> Florian

I will move 'ssp' to _xstate for now, and look for other ways.
