Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id D25B98E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 00:34:22 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id v74-v6so1299496lje.6
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:34:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e11-v6sor3836703ljg.24.2019.01.15.21.34.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 21:34:20 -0800 (PST)
Received: from mail-lj1-f174.google.com (mail-lj1-f174.google.com. [209.85.208.174])
        by smtp.gmail.com with ESMTPSA id o25sm959180lfd.29.2019.01.15.21.34.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 21:34:18 -0800 (PST)
Received: by mail-lj1-f174.google.com with SMTP id v15-v6so4317153ljh.13
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:34:18 -0800 (PST)
MIME-Version: 1.0
References: <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net>
In-Reply-To: <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 16 Jan 2019 17:34:01 +1200
Message-ID: <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Josh Snyder <joshs@netflix.com>, Dominique Martinet <asmadeus@codewreck.org>, Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 16, 2019 at 5:25 PM Andy Lutomirski <luto@amacapital.net> wrote:
>
> Something like CAP_DAC_READ_SEARCH might not be crazy.

I agree that it would work. In fact' it's what Jiri's patch basically
did. Except Jiri used CAP_SYS_ADMIN instead.

But that then basically limits it to root (or root-like with
capability masks), which is quite likely to not work in practice all
that well. That's why I wanted to find alternatives.

*Very* few people want to run their databases as root.

Jiri's original patch kind of acknowledged that by making the new test
be conditional, and off by default. So then it's a "only do this for
lockdown mode, because normal people won't find it acceptable".

And I'm not a huge fan of that approach. If you don't protect normal
people, then what's the point, really?

              Linus
