Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9266828026B
	for <linux-mm@kvack.org>; Sun, 25 Sep 2016 19:28:31 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id r126so466382381oib.2
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 16:28:31 -0700 (PDT)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id p204si1804316oia.9.2016.09.25.16.28.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Sep 2016 16:28:30 -0700 (PDT)
Received: by mail-oi0-x22b.google.com with SMTP id t83so189898772oie.3
        for <linux-mm@kvack.org>; Sun, 25 Sep 2016 16:28:30 -0700 (PDT)
Date: Sun, 25 Sep 2016 16:28:22 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: check VMA flags to avoid invalid PROT_NONE NUMA
 balancing
In-Reply-To: <CA+55aFyL+qFsJpxQufgRKgWeB6Yj0e1oapdu5mdU9_t+zwtBjg@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1609251618180.1695@eggly.anvils>
References: <20160911225425.10388-1-lstoakes@gmail.com> <20160925184731.GA20480@lucifer> <CA+55aFwtHAT_ukyE=+s=3twW8v8QExLxpVcfEDyLihf+pn9qeA@mail.gmail.com> <1474842875.17726.38.camel@redhat.com>
 <CA+55aFyL+qFsJpxQufgRKgWeB6Yj0e1oapdu5mdU9_t+zwtBjg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, tbsaunde@tbsaunde.org, robert@ocallahan.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, 25 Sep 2016, Linus Torvalds wrote:
> On Sun, Sep 25, 2016 at 3:34 PM, Rik van Riel <riel@redhat.com> wrote:
> >
> > The patch looks good to me, too.
> >
> > Acked-by: Rik van Riel <riel@redhat.com>
> 
> Thanks, amended the commit since I hadn't pushed out yet.
> 
> Btw, the only reason this bug could happen is that we do that
> "force=1" for remote vm accesses, which turns into FOLL_FORCE, which
> in turn will turn into us allowing an access even when we technically
> shouldn't.
> 
> I'd really like to re-open the "drop FOLL_FORCE entirely" discussion,
> because the thing really is disgusting.
> 
> I realize that debuggers etc sometimes would want to punch through
> PROT_NONE protections, and I also realize that right now we only have
> a read/write flag, and we have that whole issue with "what if it's
> executable but not readable", which currently FOLL_FORCE makes a
> non-issue.
> 
> But at the same time, FOLL_FORCE really is a major nasty thing. It
> shouldn't be a security issue (we still do check VM_MAY_READ/WRITE etc
> to verify that even if something isn't readable or writable we *could*
> have had permissions to do this), but this bug is a prime example of
> how it violates our deeply held beliefs of how VM permissions *should*
> work, and it screwed up the numa case as a result.
> 
> So how about we consider getting rid of FOLL_FORCE? Addign Hugh
> Dickins to the cc, because I think he argued for that many moons ago..

No.  You do remember half-right, because there was a bizarre aspect
of write,force that Nick and I campaigned to remove, which in the end
cda540ace6a1 ("mm: get_user_pages(write,force) refuse to COW in shared areas")
got rid of - see that commit for details.

I don't have any objections to force now, though I haven't been reading
this thread to see if it would change my mind (and now I must dash out).
But someone else who had concerns about it, I forget whether resolved
or not by cda5, was Konstantin - baton passed.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
