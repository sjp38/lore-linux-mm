Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2419A8E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 19:21:01 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id l16so301914lfc.8
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 16:21:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m10-v6sor3283651lje.8.2019.01.23.16.20.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 16:20:59 -0800 (PST)
Received: from mail-lf1-f47.google.com (mail-lf1-f47.google.com. [209.85.167.47])
        by smtp.gmail.com with ESMTPSA id u79-v6sm816187lje.36.2019.01.23.16.20.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 16:20:55 -0800 (PST)
Received: by mail-lf1-f47.google.com with SMTP id f5so2955099lfc.13
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 16:20:54 -0800 (PST)
MIME-Version: 1.0
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm> <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com>
 <nycvar.YFH.7.76.1901162120000.6626@cbobk.fhfr.pm> <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com>
 <CAHk-=wgy+1YT-Rhj5qWb_aCuBADhcq42GDKHB74sqrnOVPKzPg@mail.gmail.com> <nycvar.YFH.7.76.1901240009560.6626@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1901240009560.6626@cbobk.fhfr.pm>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 24 Jan 2019 13:20:37 +1300
Message-ID: <CAHk-=whVyE2TL4NpEgsSnx=w0Pf-vNBidJY9HEeOVLO-m=Mx+g@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 24, 2019 at 12:12 PM Jiri Kosina <jikos@kernel.org> wrote:
>
> >
> > I think the "test vm_file" thing may be unnecessary, because a
> > non-anonymous mapping should always have a file pointer and an inode.
> > But I could  imagine some odd case (vdso mapping, anyone?) that
> > doesn't have a vm_file, but also isn't anonymous.
>
> Hmm, good point.
>
> So dropping the 'vma->vm_file' test and checking whether given vma is
> special mapping should hopefully provide the desired semantics, shouldn't
> it?

Maybe. But on the whole I think it would  be simpler and more
straightforward to just instead add a vm_file test for the
inode_permission() case. That way you at least know that you aren't
following a NULL pointer.

If the file then turns out to be some special thing, it doesn't really
_matter_, I think. It won't have anything in the page cache etc, but
the code should "work".

             Linus
