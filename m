Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 49E926B0038
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 11:34:17 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w11so59481406oia.6
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 08:34:17 -0700 (PDT)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id i56si15949500ote.232.2016.10.07.08.34.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Oct 2016 08:34:16 -0700 (PDT)
Received: by mail-oi0-x22b.google.com with SMTP id m72so60922722oik.3
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 08:34:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161007100720.GA14859@lucifer>
References: <20160911225425.10388-1-lstoakes@gmail.com> <20160925184731.GA20480@lucifer>
 <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com>
 <1474842875.17726.38.camel@redhat.com> <CA+55aFyL+qFsJpxQufgRKgWeB6Yj0e1oapdu5mdU9_t+zwtBjg@mail.gmail.com>
 <20161007100720.GA14859@lucifer>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 7 Oct 2016 08:34:15 -0700
Message-ID: <CA+55aFzOYk_1Jcr8CSKyqfkXaOApZvCkX0_27mZk7PvGSE4xSw@mail.gmail.com>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA balancing
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, tbsaunde@tbsaunde.org, robert@ocallahan.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 7, 2016 at 3:07 AM, Lorenzo Stoakes <lstoakes@gmail.com> wrote:
>
> So I've experimented with this a little locally, removing FOLL_FORCE altogether
> and tracking places where it is used (it seems to be a fair few places
> actually.)

I'm actually a bit worried that it is used too much simply because
it's so easy to use.

In paticular, there's a class of functions that (for legacy reasons)
get the "int force" and "int write" arguments, and they both tend to
just use a very non-descript 0/1 in the callers. Then at some point
you have code like

    if (write)
        flags |= FOLL_WRITE;
    if (force)
        flags |= FOLL_FORCE;

(I'm paraphrasing from memory), and then subsequent calls use that FOLL_FORCE.

And the problem with that it's that it's *really* hard to see where
people actually use FOLL_FORCE, and it's also really easy to use it
without thinking (because it doesn't say "FOLL_FORCE", it just
randomly says "1" in some random argument list).

So the *first* step I'd do is to actually get rid of all the "write"
and "force" arguments, and just pass in "flags" instead, and use
FOLL_FORCE and FOLL_WRITE explicitly in the caller. That way it
suddenly becomes *much* easier to grep for FOLL_FORCE and see who it
is that actually really wants it.

(In fact, I think some functions get *both* "flags" and the separate
write/force argument).

Would you be willing to look at doing that kind of purely syntactic,
non-semantic cleanup first?

> I've rather naively replaced the FOLL_FORCE check in check_vma_flags() with a
> check against 'tsk && tsk->ptrace && tsk->parent == current', I'm not sure how
> valid or sane this is, however, but a quick check against gdb proves that it is
> able to do its thing in this configuration. Is this a viable path, or is this
> way off the mark here?

I think that if we end up having the FOLL_FORCE semantics, we're
actually better off having an explicit FOLL_FORCE flag, and *not* do
some kind of implicit "under these magical circumstances we'll force
it anyway". The implicit thing is what we used to do long long ago, we
definitely don't want to.

So I'd rather see all the callers that actually use FOLL_FORCE, and
then we can start looking at whether it's really a requirement. Some
of them may not strictly *need* it in actual use, they just have it
because of historical reasons (ie exactly those implicit users that
just got mindlessly converted to maintain same semantics).

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
