Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A585C6B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 18:07:01 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id rd3so6284818pab.23
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 15:07:01 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id qf5si11312608pac.170.2014.04.28.15.06.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 15:06:59 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so5879956pdj.18
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 15:06:59 -0700 (PDT)
Date: Mon, 28 Apr 2014 15:05:43 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
In-Reply-To: <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1404281500180.2861@eggly.anvils>
References: <535EA976.1080402@linux.vnet.ibm.com> <CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com> <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Davidlohr Bueso <davidlohr@hp.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Mon, 28 Apr 2014, Linus Torvalds wrote:
> On Mon, Apr 28, 2014 at 2:20 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > That said, the bug does seem to be that some path doesn't invalidate
> > the vmacache sufficiently, or something inserts a vmacache entry into
> > the current process when looking up a remote process or whatever.
> > Davidlohr, ideas?
> 
> Maybe we missed some use_mm() call. That will change the current mm
> without flushing the vma cache. The code considers kernel threads to
> be bad targets for vma caching for this reason (and perhaps others),
> but maybe we missed something.
> 
> I wonder if we should just invalidate the vma cache in use_mm(), and
> remote the "kernel tasks are special" check.
> 
> Srivatsa, are you doing something peculiar on that system that would
> trigger this? I see some kdump failures in the log, anything else?

I doubt that the vmacache has anything to do with the real problem
(though it *might* suggest that vmacache is less robust than what
it replaced - maybe).  The log is so full of userspace SIGSEGVs
and General Protection faults, it looks like userspace was utterly
broken by some kernel bug messing up the address space.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
