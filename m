Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f173.google.com (mail-vc0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 202EC6B0144
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 22:24:14 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id il7so8480460vcb.32
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 19:24:13 -0700 (PDT)
Received: from mail-ve0-x22f.google.com (mail-ve0-x22f.google.com [2607:f8b0:400c:c01::22f])
        by mx.google.com with ESMTPS id i3si7187520vcp.52.2014.03.18.19.24.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 19:24:13 -0700 (PDT)
Received: by mail-ve0-f175.google.com with SMTP id oz11so8056105veb.20
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 19:24:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1403181848380.3318@eggly.anvils>
References: <20140311045109.GB12551@redhat.com>
	<20140310220158.7e8b7f2a.akpm@linux-foundation.org>
	<20140311053017.GB14329@redhat.com>
	<20140311132024.GC32390@moon>
	<531F0E39.9020100@oracle.com>
	<20140311134158.GD32390@moon>
	<20140311142817.GA26517@redhat.com>
	<20140311143750.GE32390@moon>
	<20140311171045.GA4693@redhat.com>
	<20140311173603.GG32390@moon>
	<20140311173917.GB4693@redhat.com>
	<alpine.LSU.2.11.1403181703470.7055@eggly.anvils>
	<CA+55aFx0ZyCVrkosgTongBrNX6mJM4B8+QZQE1p0okk8ubbv7g@mail.gmail.com>
	<alpine.LSU.2.11.1403181848380.3318@eggly.anvils>
Date: Tue, 18 Mar 2014 19:24:13 -0700
Message-ID: <CA+55aFxVG7HLmsvCzoiA7PBRPvX3utRfyVGrBs6gVLZ-fUCuPQ@mail.gmail.com>
Subject: Re: bad rss-counter message in 3.14rc5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue, Mar 18, 2014 at 7:06 PM, Hugh Dickins <hughd@google.com> wrote:
>
> I'd love that, if we can get away with it now: depends very
> much on whether we then turn out to break userspace or not.

Right. I suspect we can, though, but it's one of those "we can try it
and see". Remind me early in the 3.15 merge window, and we can just
turn the "force" case into an error case and see if anybody hollers.

> If I remember correctly, it's been that way since early days,
> in case ptrace were used to put a breakpoint into a MAP_SHARED
> mapping of an executable: to prevent that modification from
> reaching the file, if the file happened to be opened O_RDWR.
> Usually it's not open for writing, and mapped MAP_PRIVATE anyway.

Yes, it's been that way since the very beginning, I think it goes back
pretty much as far as MAP_SHARED does.

We used to play lots of games wrt MAP_SHARED - in fact I think we used
to silently turn a MAP_SHARED RO mapping into MAP_PRIVATE because for
the longest time there was no "true" writable MAP_SHARED at all, but
we did have a coherent MAP_PRIVATE and something like the indexer for
nntpd wanted a read-only shared mapping of the nntp spool or something
like that. I forget the details, it's a _loong_ time ago.

So the whole "force turns a MAP_SHARED page into MAP_PRIVATE" all used
to make a lot more sense in that kind of situation, when MAP_SHARED vs
MAP_PRIVATE was much less of a black-and-white thing.

I really suspect nobody cares wrt ptrace, especially since presumably
other systems haven't had those kinds of games (although who knows -
HP-UX in particular had some of the shittiest mmap() implementations
on the planet - it made even the original Linux mmap hacks look like a
thing of pure beauty in comparison).

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
