Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C6F108E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 00:25:42 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id v11so3145466ply.4
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:25:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u8sor8015594pgn.54.2019.01.15.21.25.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 21:25:41 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
Date: Tue, 15 Jan 2019 21:25:38 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net>
References: <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com> <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm> <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com> <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com> <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com> <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com> <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Josh Snyder <joshs@netflix.com>, Dominique Martinet <asmadeus@codewreck.org>, Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>



> On Jan 15, 2019, at 9:00 PM, Linus Torvalds <torvalds@linux-foundation.org=
> wrote:
>=20
>> On Wed, Jan 16, 2019 at 12:42 PM Josh Snyder <joshs@netflix.com> wrote:
>>=20
>> For Netflix, losing accurate information from the mincore syscall would
>> lengthen database cluster maintenance operations from days to months.  We=

>> rely on cross-process mincore to migrate the contents of a page cache fro=
m
>> machine to machine, and across reboots.
>=20
> Ok, this is the kind of feedback we need, and means I guess we can't
> just use the mapping existence for mincore.
>=20
> The two other ways that we considered were:
>=20
> (a) owner of the file gets to know cache information for that file.
>=20
> (b) having the fd opened *writably* gets you cache residency information.
>=20
> Sadly, taking a look at happycache, you open the file read-only, so
> (b) doesn't work.
>=20
> Judging just from the source code, I can't tell how the user ownership
> works. Any input on that?
>=20
> And if you're not the owner of the file, do you have another
> suggestion for that "Yes, I have the right to see what's in-core for
> this file". Because the problem is literally that if it's some random
> read-only system file, the kernel shouldn't leak access patterns to
> it..
>=20
>=20


Something like CAP_DAC_READ_SEARCH might not be crazy.=
