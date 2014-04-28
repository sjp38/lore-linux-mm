Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f170.google.com (mail-ve0-f170.google.com [209.85.128.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8E46B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 18:58:03 -0400 (EDT)
Received: by mail-ve0-f170.google.com with SMTP id sa20so334707veb.29
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 15:58:03 -0700 (PDT)
Received: from mail-vc0-x229.google.com (mail-vc0-x229.google.com [2607:f8b0:400c:c03::229])
        by mx.google.com with ESMTPS id ie18si4045255vec.175.2014.04.28.15.58.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 15:58:03 -0700 (PDT)
Received: by mail-vc0-f169.google.com with SMTP id im17so8955927vcb.14
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 15:58:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1398724754.25549.35.camel@buesod1.americas.hpqcorp.net>
References: <535EA976.1080402@linux.vnet.ibm.com>
	<CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com>
	<CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com>
	<1398724754.25549.35.camel@buesod1.americas.hpqcorp.net>
Date: Mon, 28 Apr 2014 15:58:02 -0700
Message-ID: <CA+55aFz0jrk-O9gq9VQrFBeWTpLt_5zPt9RsJO9htrqh+nKTfA@mail.gmail.com>
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>

On Mon, Apr 28, 2014 at 3:39 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>
> Is this perhaps a KVM guest? fwiw I see CONFIG_KVM_ASYNC_PF=y which is a
> user of use_mm().

So I tried to look through these guys, and that was one of the ones I looked at.

It's using use_mm(), but it's only called through schedule_work().
Which *should* mean that it's in a kernel thread and
vmacache_valid_mm() will not be true.

HOWEVER.

The whole "we don't use the vma cache on kernel threads" does seem to
be a pretty fragile approach to the whole workqueue etc issue. I think
we always use a kernel thread for workqueue entries, but at the same
time I'm not 100% convinced that we should *rely* on that kind of
behavior. I don't think that it's necessarily fundamentally guaranteed
conceptually - I could see, for example, some user of "flush_work()"
deciding to run the work *synchronously* within the context of the
process that does the flushing.

Now, I don't think we actually do that, but my point is that I think
it's a bit dangerous to just say "only kernel threads do use_mm(), and
work entries are always done by kernel threads, so let's disable vma
caching for kernel threads". It may be *true*, but it's a very
indirect kind of true.

That's why I think we might be better off saying "let's just
invalidate the vmacache in use_mm(), and not care about who does it".
No subtle indirect logic about why the caching is safe in one context
but not another.

But quite frankly, I grepped for things that set "tsk->mm", and apart
from clearing it on exit, the only uses I found was copy_mm() (which
does that vmacache_flush()) and use_mm(). And all the use_mm() cases
_seem_ to be in kernel threads, and that first BUG_ON() didn't have a
very complex call chain at all, just a regular page fault from udevd.

So it might just be some really nasty corruption totally unrelated to
the vmacache, and those preceding odd udevd-work and kdump faults
could be related.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
