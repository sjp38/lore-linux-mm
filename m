Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id D41A88E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 00:58:55 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id v24-v6so1310762ljj.10
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:58:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1-v6sor4017832ljg.10.2019.01.15.21.58.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 21:58:54 -0800 (PST)
Received: from mail-lf1-f45.google.com (mail-lf1-f45.google.com. [209.85.167.45])
        by smtp.gmail.com with ESMTPSA id b21sm986000lfi.7.2019.01.15.21.58.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 21:58:51 -0800 (PST)
Received: by mail-lf1-f45.google.com with SMTP id u18so3895757lff.10
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:58:50 -0800 (PST)
MIME-Version: 1.0
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica>
In-Reply-To: <20190116054613.GA11670@nautica>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 16 Jan 2019 17:58:32 +1200
Message-ID: <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominique Martinet <asmadeus@codewreck.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 16, 2019 at 5:46 PM Dominique Martinet
<asmadeus@codewreck.org> wrote:
>
> "Being owner or has cap" (whichever cap) is probably OK.
> On the other hand, writeability check makes more sense in general -
> could we somehow check if the user has write access to the file instead
> of checking if it currently is opened read-write?

That's likely the best option. We could say "is it open for write, or
_could_ we open it for writing?"

It's a slightly annoying special case, and I'd have preferred to avoid
it, but it doesn't sound *compilcated*.

I'm on the road, but I did send out this:

    https://lore.kernel.org/lkml/CAHk-=wif_9nvNHJiyxHzJ80_WUb0P7CXNBvXkjZz-r1u0ozp7g@mail.gmail.com/

originally. The "let's try to only do the mmap residency" was the
optimistic "maybe we can just get rid of this complexity entirely"
version..

Anybody willing to test the above patch instead? And replace the

   || capable(CAP_SYS_ADMIN)

check with something like

   || inode_permission(inode, MAY_WRITE) == 0

instead?

(This is obviously after you've reverted the "only check mmap
residency" patch..)

            Linus
