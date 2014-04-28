Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f43.google.com (mail-oa0-f43.google.com [209.85.219.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8926B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 18:39:17 -0400 (EDT)
Received: by mail-oa0-f43.google.com with SMTP id eb12so8040175oac.2
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 15:39:17 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id rk8si14737282oeb.201.2014.04.28.15.39.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 15:39:16 -0700 (PDT)
Message-ID: <1398724754.25549.35.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 28 Apr 2014 15:39:14 -0700
In-Reply-To: <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com>
References: <535EA976.1080402@linux.vnet.ibm.com>
	 <CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com>
	 <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>

Adding Oleg.

On Mon, 2014-04-28 at 14:55 -0700, Linus Torvalds wrote:
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

Is this perhaps a KVM guest? fwiw I see CONFIG_KVM_ASYNC_PF=y which is a
user of use_mm().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
