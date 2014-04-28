Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 514D46B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 18:14:53 -0400 (EDT)
Received: by mail-ob0-f174.google.com with SMTP id gq1so7998993obb.19
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 15:14:52 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id k2si14722627oel.137.2014.04.28.15.14.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 15:14:52 -0700 (PDT)
Message-ID: <1398723290.25549.20.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 28 Apr 2014 15:14:50 -0700
In-Reply-To: <alpine.LSU.2.11.1404281500180.2861@eggly.anvils>
References: <535EA976.1080402@linux.vnet.ibm.com>
	 <CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com>
	 <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com>
	 <alpine.LSU.2.11.1404281500180.2861@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Mon, 2014-04-28 at 15:05 -0700, Hugh Dickins wrote:
> On Mon, 28 Apr 2014, Linus Torvalds wrote:
> > On Mon, Apr 28, 2014 at 2:20 PM, Linus Torvalds
> > <torvalds@linux-foundation.org> wrote:
> > >
> > > That said, the bug does seem to be that some path doesn't invalidate
> > > the vmacache sufficiently, or something inserts a vmacache entry into
> > > the current process when looking up a remote process or whatever.
> > > Davidlohr, ideas?
> > 
> > Maybe we missed some use_mm() call. That will change the current mm
> > without flushing the vma cache. The code considers kernel threads to
> > be bad targets for vma caching for this reason (and perhaps others),
> > but maybe we missed something.
> > 
> > I wonder if we should just invalidate the vma cache in use_mm(), and
> > remote the "kernel tasks are special" check.
> > 
> > Srivatsa, are you doing something peculiar on that system that would
> > trigger this? I see some kdump failures in the log, anything else?
> 
> I doubt that the vmacache has anything to do with the real problem
> (though it *might* suggest that vmacache is less robust than what
> it replaced - maybe).  The log is so full of userspace SIGSEGVs
> and General Protection faults, it looks like userspace was utterly
> broken by some kernel bug messing up the address space.

I think that returning some stale/bogus vma is causing those segfaults
in udev. It shouldn't occur in a normal scenario. What puzzles me is
that it's not always reproducible. This makes me wonder what else is
going on...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
