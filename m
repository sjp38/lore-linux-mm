Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 662118E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 00:50:08 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id z5-v6so1310159ljb.13
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:50:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n10sor1790435lfe.49.2019.01.15.21.50.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 21:50:06 -0800 (PST)
Received: from mail-lf1-f45.google.com (mail-lf1-f45.google.com. [209.85.167.45])
        by smtp.gmail.com with ESMTPSA id r69sm1014983lfi.15.2019.01.15.21.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 21:50:04 -0800 (PST)
Received: by mail-lf1-f45.google.com with SMTP id z13so3889877lfe.11
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:50:03 -0800 (PST)
MIME-Version: 1.0
References: <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard> <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
 <20190111040434.GN27534@dastard> <CAHk-=wh-kegfnPC_dmw0A72Sdk4B9tvce-cOR=jEfHDU1-4Eew@mail.gmail.com>
 <20190111073606.GP27534@dastard> <CAHk-=wj+xyz_GKjgKpU6SF3qeqouGmRoR8uFxzg_c1VpeGEJMw@mail.gmail.com>
 <20190115234510.GA6173@dastard> <CAHk-=wjc2inOae8+9-DK4jFK78-7ZpNR=TEyZg0Dj57SYwP-ng@mail.gmail.com>
In-Reply-To: <CAHk-=wjc2inOae8+9-DK4jFK78-7ZpNR=TEyZg0Dj57SYwP-ng@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 16 Jan 2019 17:49:46 +1200
Message-ID: <CAHk-=wje=2Pndo+xZ5fLJ9VCoo6NYLV_a9D8mxpuSTFdz3eGMg@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 16, 2019 at 4:54 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Wed, Jan 16, 2019 at 11:45 AM Dave Chinner <david@fromorbit.com> wrote:
> >
> > I'm assuming that you can invalidate the page cache reliably by a
> > means that does not repeated require probing to detect invalidation
> > has occurred. I've mentioned one method in this discussion
> > already...
>
> Yes. And it was made clear to you that it was a bug in xfs dio and
> what the right thing to do was.

Side note: I actually think we *do* the right thing. Even for xfs. I
couldn't find the alleged place that invalidates the page cache on dio
reads.

The *generic* dio code only does it for writes (which is correct and
fine). And maybe xfs has some extra invalidation, but I don't see it.

So I actually hope your "you can use direct-io read to do directed
invalidating of the page cache" isn't true. I admittedly did *not* try
to delve very deeply into it, but the invalidates I found looked
correct. The generic code does it for writes, and at least ext4 does
the "writeback and wait" for reads.

There *does* seem to be a 'invalidate_inode_pages2_range()' call in
iomap_dio_rw(). That has a *comment* that says it only is for writes,
but it looks to me like it would trigger for reads too.

Just a plain bug/oversight? Or me misreading things.

So yes, maybe xfs does that "invalidate on read", but it really seems
to be just a bug. If the xfs people insist on keeping the bug, fine
(looks like gfs2 and xfs are the only users), but it seems kind of
sad.

             Linus
