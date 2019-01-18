Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 43C418E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 23:55:15 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id k16-v6so2924265lji.5
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 20:55:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p4sor1131078lfc.35.2019.01.17.20.55.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 20:55:13 -0800 (PST)
Received: from mail-lf1-f52.google.com (mail-lf1-f52.google.com. [209.85.167.52])
        by smtp.gmail.com with ESMTPSA id x24-v6sm590976ljc.54.2019.01.17.20.55.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 20:55:12 -0800 (PST)
Received: by mail-lf1-f52.google.com with SMTP id z13so9518708lfe.11
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 20:55:12 -0800 (PST)
MIME-Version: 1.0
References: <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm> <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com>
 <nycvar.YFH.7.76.1901162120000.6626@cbobk.fhfr.pm> <20190116213708.GN6310@bombadil.infradead.org>
 <CAHk-=wjciBwJo5JHcvUO+JAC13TUME1PH=ftsaNt+0RC-3PCSw@mail.gmail.com>
In-Reply-To: <CAHk-=wjciBwJo5JHcvUO+JAC13TUME1PH=ftsaNt+0RC-3PCSw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 18 Jan 2019 16:54:54 +1200
Message-ID: <CAHk-=wg_MZgBvbH3cC9DT5MD694=SYO3+ns_2VnaiyV93vDMRQ@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jiri Kosina <jikos@kernel.org>, Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 17, 2019 at 4:51 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Thu, Jan 17, 2019 at 9:37 AM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > Your patch 3/3 just removes the test.  Am I right in thinking that it
> > doesn't need to be *moved* because the existing test after !PageUptodate
> > catches it?
>
> That's the _hope_.
>
> That's the simplest patch I can come up with as a potential solution.
> But it's possible that there's some nasty performance regression
> because somebody really relies on not even triggering read-ahead, and
> we might need to do some totally different thing.

Oh, and somebody should probably check that there isn't some simple
way to just avoid that readahead code entirely.

In particular, right now we skip readahead for at least these cases:

        /* no read-ahead */
        if (!ra->ra_pages)
                return;

        if (blk_cgroup_congested())
                return;

and I don't think we need to worry about the cgroup congestion case -
if the attack has to also congest its cgroup with IO, I think they
have bigger problems.

And I think 'ra_pages' can be zero only in the presence of IO errors,
but I might be wrong. It would be good if somebody double-checks that.

               Linus
