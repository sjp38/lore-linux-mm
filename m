Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 62E936B7983
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 12:00:59 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j15-v6so6007979pff.12
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 09:00:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id bj7-v6si4925003plb.320.2018.09.06.09.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Sep 2018 09:00:57 -0700 (PDT)
Date: Thu, 6 Sep 2018 09:00:51 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: linux-next test error
Message-ID: <20180906160051.GB29639@bombadil.infradead.org>
References: <0000000000004f6b5805751a8189@google.com>
 <20180905085545.GD24902@quack2.suse.cz>
 <CAFqt6zZtjPFdfAGxp43oqN3=z9+vAGzdOvDcgFaU+05ffCGu7A@mail.gmail.com>
 <20180905133459.GF23909@thunk.org>
 <CAFqt6za5OvHgONOgpmhxS+YsYZyiXUhzpmOgZYyHWPHEO34QwQ@mail.gmail.com>
 <20180906083800.GC19319@quack2.suse.cz>
 <CAFqt6zZ=uaArS0hrbgZGLe38HgSPhZBHzsGEJOZiQGm4Y2N0yw@mail.gmail.com>
 <20180906131212.GG2331@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180906131212.GG2331@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Souptick Joarder <jrdr.linux@gmail.com>, Jan Kara <jack@suse.cz>, syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com, ak@linux.intel.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, zwisler@kernel.org

On Thu, Sep 06, 2018 at 09:12:12AM -0400, Theodore Y. Ts'o wrote:
> So I don't see the point of changing return value block_page_mkwrite()
> (although to be honest I haven't see the value of the vm_fault_t
> change at all in the first place, at least not compared to the pain it
> has caused) but no, I don't think it's worth it.

You have a sampling bias though; you've only seen the filesystem patches.
Filesystem fault handlers are generally more complex and written by
people who have more Linux expertise.  For the device drivers, it's
been far more useful; bugs have been fixed and a lot of cargo-culted
code has been deleted.

> So what we do for functions that need to either return an error or a
> pointer is to call encode the error as a "pointer" by using ERR_PTR(),
> and the caller can determine whether or not it is a valid pointer or
> an error code by using IS_ERR_VALUE() and turning it back into an
> error by using PTR_ERR().   See include/linux/err.h.

That's _usually_ the convention when a function might return a pointer
or an error.  Sometimes we return NULL to mean "an error happened".
Sometimes that NULL means -ENOMEM.  Sometimes we return ZERO_SIZE_PTR
instead of -EINVAL.  Sometimes we return a POISON value.  It's all pretty
ad-hoc, which wouldn't be as bad if it were better documented.

> Similarly, all valid vm_fault_t's composed of VM_FAULT_xxx are
> positive integers, and all errors are passed using the kernel's
> convention of using a negative error code.  So going through lots of
> machinations to return both an error code and a vm_fault_t *really*
> wasn't necessary.

Not necessary from the point of view that there are enough bits to be able
to distinguish the two, I agree.  But from the mm point of view, it rather
does matter that you can distinguish between SIGBUS, SIGSEGV, HWPOISON
and OOM (although -ENOMEM and VM_FAULT_OOM do have the same meaning).

> The issue, as near as I can understand things, for why we're going
> through all of this churn, was there was a concern that in the mm
> code, that all of the places which received a vm_fault_t would
> sometimes see a negative error code.  The proposal here is to just
> *accept* that this will happen, and just simply have them *check* to
> see if it's a negative error code, and convert it to the appropriate
> vm_fault_t in that case.  It puts the onus of the change on the mm
> layer, where as the "blast radius" of the vm_fault_t "cleanup" is
> spread out across a large number of subsystems.
> 
> Which I wouldn't mind, if it wasn't causing pain.  But it *is* causing
> pain.

As I said earlier, your sample bias shows only pain, but there are
genuine improvements in the patches you haven't seen and don't care about.

> And it's common kernel convention to overload an error and a pointer
> using the exact same trick.  We do it *all* over the place, and quite
> frankly, it's less error prone than changing functions to return a
> pointer and an error.  No one has said, "let's do to the ERR_PTR
> convention what we've done to the vm_fault_t -- it's too confusing
> that a pointer might be an error, since people might forget to check
> for it."  If they did that, it would be NACK'ed right, left and
> center.  But yet it's a good idea for vm_fault_t?

I actually think it would be a good idea to mark functions which return
either-an-errno-or-a-pointer as returning an errptr_t.  The downside is
that we'd lose the type information (we'd only know that it's a void *
or an errno, not that it's a struct ext4_foo * or an errno).  Just like
we gradually introduced 'bool' instead of 'int' for functions which only
returned true/false.
