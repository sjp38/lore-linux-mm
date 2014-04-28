Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 443626B0037
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 19:11:23 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id rd3so6368922pab.37
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 16:11:22 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id nl9si3554376pbc.352.2014.04.28.16.11.21
        for <linux-mm@kvack.org>;
        Mon, 28 Apr 2014 16:11:22 -0700 (PDT)
Date: Mon, 28 Apr 2014 16:11:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
Message-Id: <20140428161120.4cad719dc321e3c837db3fd6@linux-foundation.org>
In-Reply-To: <CA+55aFz0jrk-O9gq9VQrFBeWTpLt_5zPt9RsJO9htrqh+nKTfA@mail.gmail.com>
References: <535EA976.1080402@linux.vnet.ibm.com>
	<CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com>
	<CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com>
	<1398724754.25549.35.camel@buesod1.americas.hpqcorp.net>
	<CA+55aFz0jrk-O9gq9VQrFBeWTpLt_5zPt9RsJO9htrqh+nKTfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

On Mon, 28 Apr 2014 15:58:02 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, Apr 28, 2014 at 3:39 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> >
> > Is this perhaps a KVM guest? fwiw I see CONFIG_KVM_ASYNC_PF=y which is a
> > user of use_mm().
> 
> So I tried to look through these guys, and that was one of the ones I looked at.
> 
> It's using use_mm(), but it's only called through schedule_work().
> Which *should* mean that it's in a kernel thread and
> vmacache_valid_mm() will not be true.
> 
> HOWEVER.
> 
> The whole "we don't use the vma cache on kernel threads" does seem to
> be a pretty fragile approach to the whole workqueue etc issue. I think
> we always use a kernel thread for workqueue entries, but at the same
> time I'm not 100% convinced that we should *rely* on that kind of
> behavior. I don't think that it's necessarily fundamentally guaranteed
> conceptually - I could see, for example, some user of "flush_work()"
> deciding to run the work *synchronously* within the context of the
> process that does the flushing.

Very good point.

> Now, I don't think we actually do that, but my point is that I think
> it's a bit dangerous to just say "only kernel threads do use_mm(), and
> work entries are always done by kernel threads, so let's disable vma
> caching for kernel threads". It may be *true*, but it's a very
> indirect kind of true.
> 
> That's why I think we might be better off saying "let's just
> invalidate the vmacache in use_mm(), and not care about who does it".
> No subtle indirect logic about why the caching is safe in one context
> but not another.
> 
> But quite frankly, I grepped for things that set "tsk->mm", and apart
> from clearing it on exit, the only uses I found was copy_mm() (which
> does that vmacache_flush()) and use_mm(). And all the use_mm() cases
> _seem_ to be in kernel threads, and that first BUG_ON() didn't have a
> very complex call chain at all, just a regular page fault from udevd.

unuse_mm() leaves current->mm at NULL so we'd hear about it pretty
quickly if a user task was running use_mm/unuse_mm.  Perhaps it's
possible to do

	use_mm(new_mm);
	...
	use_mm(old_mm);

but nothing does that.

> So it might just be some really nasty corruption totally unrelated to
> the vmacache, and those preceding odd udevd-work and kdump faults
> could be related.

I think so.  Maybe it's time to cook up a debug patch for Srivatsa to
use?  Dump the vma cache when the bug hits, or wire up some trace
points.  Or perhaps plain old printks - it seems to be happening pretty
early in boot.

Are there additional sanity checks we can perform at cache addition
time?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
