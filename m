Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD1A76B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 15:47:53 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id a63so19116351wrc.1
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:47:53 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g202si11728617wmg.206.2017.11.27.12.47.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 12:47:52 -0800 (PST)
Date: Mon, 27 Nov 2017 21:47:21 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch V2 5/5] x86/kaiser: Add boottime disable switch
In-Reply-To: <20171127191840.xv34rffmfb6oombh@treble>
Message-ID: <alpine.DEB.2.20.1711272146320.2333@nanos>
References: <20171126231403.657575796@linutronix.de> <20171126232414.645128754@linutronix.de> <24359653-5b93-7146-8f65-ac38c3af0069@linux.intel.com> <alpine.DEB.2.20.1711271958450.2333@nanos> <20171127191840.xv34rffmfb6oombh@treble>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, 27 Nov 2017, Josh Poimboeuf wrote:

> On Mon, Nov 27, 2017 at 08:00:19PM +0100, Thomas Gleixner wrote:
> > On Mon, 27 Nov 2017, Dave Hansen wrote:
> > 
> > > On 11/26/2017 03:14 PM, Thomas Gleixner wrote:
> > > > --- a/security/Kconfig
> > > > +++ b/security/Kconfig
> > > > @@ -56,7 +56,7 @@ config SECURITY_NETWORK
> > > >  
> > > >  config KAISER
> > > >  	bool "Remove the kernel mapping in user mode"
> > > > -	depends on X86_64 && SMP && !PARAVIRT
> > > > +	depends on X86_64 && SMP && !PARAVIRT && JUMP_LABEL
> > > >  	help
> > > >  	  This feature reduces the number of hardware side channels by
> > > >  	  ensuring that the majority of kernel addresses are not mapped
> > > 
> > > One of the reasons for doing the runtime-disable was to get rid of the
> > > !PARAVIRT dependency.  I can add a follow-on here that will act as if we
> > > did "nokaiser" whenever Xen is in play so we can remove this dependency.
> > > 
> > > I just hope Xen is detectable early enough to do the static patching.
> > 
> > Yes, it is. I'm currently trying to figure out why it fails on a KVM guest.
> > 
> > If I boot with 'nokaiser' on the command line it works. If kaiser is
> > runtime enabled then some early klibc user space in the ramdisk
> > explodes. Not sure yet whats going on.
> 
> I'm also seeing weirdness with PARAVIRT+KAISER on kvm.  The symptoms
> aren't consistent.  Sometimes it boots, sometimes it hangs before the
> login prompt, sometimes there are user space seg faults.
> 
> It almost seems like the interrupt handler is corrupting user space
> state somehow.
> 
> This is with tip/WIP.x86/mm plus a patch to remove the KAISER dependency
> on !PARAVIRT.

See the patches I posted. Its the PV patching of flush_tlb_single() ...

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
