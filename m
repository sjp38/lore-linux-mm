Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC056B0037
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 04:11:38 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id k14so336532wgh.24
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 01:11:37 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id g2si5933604wjx.123.2014.09.12.01.11.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 01:11:36 -0700 (PDT)
Date: Fri, 12 Sep 2014 10:11:21 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
In-Reply-To: <541239F1.2000508@intel.com>
Message-ID: <alpine.DEB.2.10.1409120950260.4178@nanos>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120020060.4178@nanos> <541239F1.2000508@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 11 Sep 2014, Dave Hansen wrote:
> On 09/11/2014 04:28 PM, Thomas Gleixner wrote:
> > On Thu, 11 Sep 2014, Qiaowei Ren wrote:
> >> This patch adds the PR_MPX_REGISTER and PR_MPX_UNREGISTER prctl()
> >> commands. These commands can be used to register and unregister MPX
> >> related resource on the x86 platform.
> > 
> > I cant see anything which is registered/unregistered.
> 
> This registers the location of the bounds directory with the kernel.
> 
> >From the app's perspective, it says "I'm using MPX, and here is where I
> put the root data structure".
> 
> Without this, the kernel would have to do an (expensive) xsave operation
> every time it wanted to see if MPX was in use.  This also makes the
> user/kernel interaction more explicit.  We would be in a world of hurt
> if userspace was allowed to move the bounds directory around.  With this
> interface, it's a bit more obvious that userspace can't just move it
> around willy-nilly.

And what prevents it to do so? Just the fact that you have a prctl
does not make userspace better.

> >> The base of the bounds directory is set into mm_struct during
> >> PR_MPX_REGISTER command execution. This member can be used to
> >> check whether one application is mpx enabled.
> > 
> > This changelog is completely useless.
> 
> Yeah, it's pretty bare-bones.  Let me know if the explanation above
> makes sense, and we'll get it updated.

Well, it at least explains what its supposed to do. Whether that
itself makes sense is a completely different question.
 
> >> + */
> >> +static __user void *task_get_bounds_dir(struct task_struct *tsk)
> >> +{
> >> +	struct xsave_struct *xsave_buf;
> >> +
> >> +	fpu_xsave(&tsk->thread.fpu);
> >> +	xsave_buf = &(tsk->thread.fpu.state->xsave);
> >> +	if (!(xsave_buf->bndcsr.cfg_reg_u & MPX_BNDCFG_ENABLE_FLAG))
> >> +		return NULL;
> > 
> > Now this might be understandable with a proper comment. Right now it's
> > a magic check for something uncomprehensible.
> 
> It's a bit ugly to access, but it seems pretty blatantly obvious that
> this is a check for "Is the enable flag in a hardware register set?"
> 
> Yes, the registers have names only a mother could love.  But that is
> what they're really called.
> 
> I guess we could add some comments about why we need to do the xsave.

Exactly.
 
> > So we use that information to check, whether we need to tear down a
> > VM_MPX flagged region with mpx_unmap(), right?
> 
> Well, we use it to figure out whether we _potentially_ need to tear down
> an VM_MPX-flagged area.  There's no guarantee that there will be one.

So what you are saying is, that if user space sets the pointer to NULL
via the unregister prctl, kernel can safely ignore vmas which have the
VM_MPX flag set. I really can't follow that logic.
 
	mmap_mpx();
	prctl(enable mpx);
	do lots of crap which uses mpx;
	prctl(disable mpx);

So after that point the previous use of MPX is irrelevant, just
because we set a pointer to NULL? Does it just look like crap because
I do not get the big picture how all of this is supposed to work?

> Yes.  The only other way the kernel can possibly know that it needs to
> go tearing things down is with a potentially frequent and expensive xsave.
> 
> Either we change mmap to say "this mmap() is for a bounds directory", or
> we have some other interface that says "the mmap() for the bounds
> directory is at $foo".  We could also record the bounds directory the
> first time that we catch userspace using it.  I'd rather have an
> explicit interface than an implicit one like that, though I don't feel
> that strongly about it.

I really have to disagree here. If I follow your logic then we would
have a prctl for using floating point as well instead of catching the
use and handle it from there. Just get it, if you make it simple for
user space to do stupid things, they will happen in all provided ways
and some more.

> > The design to support this feature makes no sense at all to me. We
> > have a special mmap interface, some magic kernel side mapping
> > functionality and then on top of it a prctl telling the kernel to
> > ignore/respect it.
> 
> That's a good point.  We don't seem to have anything in the
> allocate_bt() side of things to tell the kernel to refuse to create
> things if the prctl() hasn't been called.  That needs to get added.

And then you need another bunch of logic in the prctl(disable mpx)
path to cleanup the mess instead of just setting a random pointer to
NULL.

> If you don't want to share them in public, I'm happy to take this
> off-list, but please do share.

I'll let you know once I verified that it might work.

Thanks,

	tglx
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
