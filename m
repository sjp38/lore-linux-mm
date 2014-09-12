Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 019476B0039
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 13:42:34 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id ex7so1064308wid.1
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 10:42:34 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id b15si3977800wiv.86.2014.09.12.10.42.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 10:42:31 -0700 (PDT)
Date: Fri, 12 Sep 2014 19:42:17 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
In-Reply-To: <54130F9A.3000406@intel.com>
Message-ID: <alpine.DEB.2.10.1409121934520.4178@nanos>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120020060.4178@nanos> <541239F1.2000508@intel.com> <alpine.DEB.2.10.1409120950260.4178@nanos>
 <54130F9A.3000406@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 12 Sep 2014, Dave Hansen wrote:
> On 09/12/2014 01:11 AM, Thomas Gleixner wrote:
> > So what you are saying is, that if user space sets the pointer to NULL
> > via the unregister prctl, kernel can safely ignore vmas which have the
> > VM_MPX flag set. I really can't follow that logic.
> >  
> > 	mmap_mpx();
> > 	prctl(enable mpx);
> > 	do lots of crap which uses mpx;
> > 	prctl(disable mpx);
> > 
> > So after that point the previous use of MPX is irrelevant, just
> > because we set a pointer to NULL? Does it just look like crap because
> > I do not get the big picture how all of this is supposed to work?
> 
> The prctl(register) is meant to be a signal from userspace to the kernel
> to say, "I would like your help in managing these bounds tables".
> prctl(unregister) is the opposite, meaning "I don't want your help any
> more".

Fine, but that's a totally different story. I can see the usefulness
of this, but then it's a complete misnomer. It should be:

   prctl(EN/DISABLE_MPX_BT_MANAGEMENT)

So this wants to be a boolean value and not some random user space
address collected at some random point and then ignored until you do
the magic cleanup. See the other reply.

> If userspace uses MPX, it does not necessarily want the kernel to do
> bounds table management all the time (or ever in some cases).  Without
> the prctl(), the kernel has no way of distinguishing what userspace wants.

Fine with me, but it needs to be done proper. And proper means: ON/OFF

The kernel has to handle the information for which context it
allocated stuff and then tear it down when the context goes
away. Relying on a user space address sampled at some random prctl
point is just stupid.

> > And then you need another bunch of logic in the prctl(disable mpx)
> > path to cleanup the mess instead of just setting a random pointer to
> > NULL.
> 
> The bounds tables potentially represent a *lot* of state.  If userspace
> wants to temporarily turn off the kernel's MPX bounds table management,
> it does not necessarily want that state destroyed.  On the other hand,
> if userspace feels the need to go destroying all the state, it is free
> to do so and does not need any help to do so from the kernel.

Fine with me, but the above still stands.

Thanks,

	tglx

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
