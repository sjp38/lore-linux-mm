Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 483086B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 13:27:50 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e39-v6so7099052plb.10
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:27:50 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id y2-v6si491412pgr.677.2018.06.12.10.27.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 10:27:48 -0700 (PDT)
Message-ID: <1528824280.9447.30.camel@2b52.sc.intel.com>
Subject: Re: [PATCH 00/10] Control Flow Enforcement - Part (3)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 12 Jun 2018 10:24:40 -0700
In-Reply-To: <CALCETrVOyZz72RuoRB=z_EjFTqqctSLfX30GM+MSEVtbcd=PeQ@mail.gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
	 <bbfde1b3-5e1b-80e3-30e8-fd1e46a2ceb1@gmail.com>
	 <1528815820.8271.16.camel@2b52.sc.intel.com>
	 <CALCETrXK6hypCb5sXwxWRKr=J6_7XtS6s5GB1WPBiqi79q8-8g@mail.gmail.com>
	 <1528820489.9324.14.camel@2b52.sc.intel.com>
	 <CALCETrVOyZz72RuoRB=z_EjFTqqctSLfX30GM+MSEVtbcd=PeQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: bsingharora@gmail.com, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Tue, 2018-06-12 at 09:31 -0700, Andy Lutomirski wrote:
> On Tue, Jun 12, 2018 at 9:24 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> >
> > On Tue, 2018-06-12 at 09:00 -0700, Andy Lutomirski wrote:
> > > On Tue, Jun 12, 2018 at 8:06 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > > >
> > > > On Tue, 2018-06-12 at 20:56 +1000, Balbir Singh wrote:
> > > > >
> > > > > On 08/06/18 00:37, Yu-cheng Yu wrote:
> > > > > > This series introduces CET - Shadow stack
> > > > > >
> > > > > > At the high level, shadow stack is:
> > > > > >
> > > > > >     Allocated from a task's address space with vm_flags VM_SHSTK;
> > > > > >     Its PTEs must be read-only and dirty;
> > > > > >     Fixed sized, but the default size can be changed by sys admin.
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
> > > > >
> > > > > Balbir Singh.
> > > >
> > > > Yes.
> > > >
> > >
> > > I think we're going to need some provision to add an alternate signal
> > > stack to handle the case where the shadow stack overflows.
> >
> > The shadow stack stores only return addresses; its consumption will not
> > exceed a percentage of (program stack size + sigaltstack size) before
> > those overflow.  When that happens, there is usually very little we can
> > do.  So we set a default shadow stack size that supports certain nested
> > calls and allow sys admin to adjust it.
> >
> 
> Of course there's something you can do: add a sigaltstack-like stack
> switching mechanism.  Have a reserve shadow stack and, when a signal
> is delivered (possibly guarded by other conditions like "did the
> shadow stack overflow"), switch to a new shadow stack and maybe write
> a special token to the new shadow stack that says "signal delivery
> jumped here and will restore to the previous shadow stack and
> such-and-such address on return".

If (shstk size == (stack size + sigaltstack size)), then shstk will not
overflow before program stack overflows and sigaltstack also overflows.

Let me think about this.

> Also, I have a couple of other questions after reading the
> documentation some more:
> 
> 1. Why on Earth does INCSSP only take an 8-bit number of frames to
> skip?  It seems to me that code that calls setjmp() and then calls
> longjmp() while nested more than 256 function call levels will crash.

GLIBC takes care of more than 256 functions calls.

> 2. The mnemonic RSTORSSP makes no sense to me.  RSTORSSP is a stack
> *switch* operation not a stack *restore* operation, unless I'm
> seriously misunderstanding.

The intention is to switch shadow stacks with tokens.  RSTORSSP restores
to a previous shadow stack address from a restore token.

> 3. Is there anything resembling clear documentation of the format of
> the shadow stack?  That is, what types of values might be found on the
> shadow stack and what do they all mean?

Only return addresses and restore tokens can be on a user-mode shadow
stack.  The restore token has the incoming shadow stack address plus one
bit indicating 64/32-bit mode.

I will put this into Documentation/x86/intel_cet.txt.

> 
> 4. Usually Intel doesn't submit upstream Linux patches for ISA
> extensions until the ISA is documented for real.  CET does not appear
> to be documented for real.  Could Intel kindly release something that
> at least claims to be authoritative documentation?
> 
> --Andy
