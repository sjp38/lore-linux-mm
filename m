Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 297486B0069
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:18:47 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id i17so16403628otb.2
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 11:18:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a194si1038788oii.524.2017.11.27.11.18.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 11:18:46 -0800 (PST)
Date: Mon, 27 Nov 2017 13:18:40 -0600
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [patch V2 5/5] x86/kaiser: Add boottime disable switch
Message-ID: <20171127191840.xv34rffmfb6oombh@treble>
References: <20171126231403.657575796@linutronix.de>
 <20171126232414.645128754@linutronix.de>
 <24359653-5b93-7146-8f65-ac38c3af0069@linux.intel.com>
 <alpine.DEB.2.20.1711271958450.2333@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1711271958450.2333@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Mon, Nov 27, 2017 at 08:00:19PM +0100, Thomas Gleixner wrote:
> On Mon, 27 Nov 2017, Dave Hansen wrote:
> 
> > On 11/26/2017 03:14 PM, Thomas Gleixner wrote:
> > > --- a/security/Kconfig
> > > +++ b/security/Kconfig
> > > @@ -56,7 +56,7 @@ config SECURITY_NETWORK
> > >  
> > >  config KAISER
> > >  	bool "Remove the kernel mapping in user mode"
> > > -	depends on X86_64 && SMP && !PARAVIRT
> > > +	depends on X86_64 && SMP && !PARAVIRT && JUMP_LABEL
> > >  	help
> > >  	  This feature reduces the number of hardware side channels by
> > >  	  ensuring that the majority of kernel addresses are not mapped
> > 
> > One of the reasons for doing the runtime-disable was to get rid of the
> > !PARAVIRT dependency.  I can add a follow-on here that will act as if we
> > did "nokaiser" whenever Xen is in play so we can remove this dependency.
> > 
> > I just hope Xen is detectable early enough to do the static patching.
> 
> Yes, it is. I'm currently trying to figure out why it fails on a KVM guest.
> 
> If I boot with 'nokaiser' on the command line it works. If kaiser is
> runtime enabled then some early klibc user space in the ramdisk
> explodes. Not sure yet whats going on.

I'm also seeing weirdness with PARAVIRT+KAISER on kvm.  The symptoms
aren't consistent.  Sometimes it boots, sometimes it hangs before the
login prompt, sometimes there are user space seg faults.

It almost seems like the interrupt handler is corrupting user space
state somehow.

This is with tip/WIP.x86/mm plus a patch to remove the KAISER dependency
on !PARAVIRT.

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
