Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D9D0F8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 11:12:30 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id q62so4157761pgq.9
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:12:30 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j5si6859986pfg.254.2019.01.16.08.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 08:12:28 -0800 (PST)
Date: Wed, 16 Jan 2019 17:12:24 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
Message-ID: <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm>
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com> <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com> <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com> <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com> <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net>
 <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com> <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, 16 Jan 2019, Linus Torvalds wrote:

> > "Being owner or has cap" (whichever cap) is probably OK. On the other 
> > hand, writeability check makes more sense in general - could we 
> > somehow check if the user has write access to the file instead of 
> > checking if it currently is opened read-write?
> 
> That's likely the best option. We could say "is it open for write, or
> _could_ we open it for writing?"
> 
> It's a slightly annoying special case, and I'd have preferred to avoid
> it, but it doesn't sound *compilcated*.
> 
> I'm on the road, but I did send out this:
> 
>     https://lore.kernel.org/lkml/CAHk-=wif_9nvNHJiyxHzJ80_WUb0P7CXNBvXkjZz-r1u0ozp7g@mail.gmail.com/
> 
> originally. The "let's try to only do the mmap residency" was the
> optimistic "maybe we can just get rid of this complexity entirely"
> version..
> 
> Anybody willing to test the above patch instead? And replace the
> 
>    || capable(CAP_SYS_ADMIN)
> 
> check with something like
> 
>    || inode_permission(inode, MAY_WRITE) == 0
> 
> instead?
> 
> (This is obviously after you've reverted the "only check mmap
> residency" patch..)

So that seems to deal with mincore() in a reasonable way indeed.

It doesn't unfortunately really solve the preadv2(RWF_NOWAIT), nor does it 
provide any good answer what to do about it, does it?

Thanks,

-- 
Jiri Kosina
SUSE Labs
