Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 858068E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:18:38 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id z5-v6so3289799ljb.13
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:18:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z26sor19803458lfe.67.2019.01.10.18.18.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 18:18:36 -0800 (PST)
Received: from mail-lf1-f49.google.com (mail-lf1-f49.google.com. [209.85.167.49])
        by smtp.gmail.com with ESMTPSA id c2-v6sm15484755ljj.41.2019.01.10.18.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 18:18:33 -0800 (PST)
Received: by mail-lf1-f49.google.com with SMTP id y14so9711860lfg.13
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:18:33 -0800 (PST)
MIME-Version: 1.0
References: <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard>
In-Reply-To: <20190111020340.GM27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 10 Jan 2019 18:18:16 -0800
Message-ID: <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 10, 2019 at 6:03 PM Dave Chinner <david@fromorbit.com> wrote:
>
> On Thu, Jan 10, 2019 at 02:11:01PM -0800, Linus Torvalds wrote:
> > And we *can* do sane things about RWF_NOWAIT. For example, we could
> > start async IO on RWF_NOWAIT, and suddenly it would go from "probe the
> > page cache" to "probe and fill", and be much harder to use as an
> > attack vector..
>
> We can only do that if the application submits the read via AIO and
> has an async IO completion reporting mechanism.

Oh, no, you misunderstand.

RWF_NOWAIT has a lot of situations where it will potentially return
early (the DAX and direct IO ones have their own), but I was thinking
of the one in generic_file_buffered_read(), which triggers when you
don't find a page mapping. That looks like the obvious "probe page
cache" case.

But we could literally move that test down just a few lines. Let it
start read-ahead.

.. and then it will actually trigger on the *second* case instead, where we have

                if (!PageUptodate(page)) {
                        if (iocb->ki_flags & IOCB_NOWAIT) {
                                put_page(page);
                                goto would_block;
                        }

and that's where RWF_MNOWAIT would act.

It would still return EAGAIN.

But it would have started filling the page cache. So now the act of
probing would fill the page cache, and the attacker would be left high
and dry - the fact that the page cache now exists is because of the
attack, not because of whatever it was trying to measure.

See?

But obviously this kind of change only matters if we also have
mincore() not returning the probe data. mincore() obviously can't do
the same kind of read-ahead to defeat things.

              Linus
