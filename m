Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D76F68E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:08:41 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id y2so7507004plr.8
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 20:08:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k63sor1555950pfc.66.2019.01.10.20.08.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 20:08:40 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <20190111040434.GN27534@dastard>
Date: Thu, 10 Jan 2019 20:08:37 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <6955E7C1-A61C-49F3-8BB6-0624D5A70BD6@amacapital.net>
References: <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com> <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com> <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com> <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com> <20190111020340.GM27534@dastard> <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com> <20190111040434.GN27534@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>



> On Jan 10, 2019, at 8:04 PM, Dave Chinner <david@fromorbit.com> wrote:
>=20
>> On Thu, Jan 10, 2019 at 06:18:16PM -0800, Linus Torvalds wrote:
>>> On Thu, Jan 10, 2019 at 6:03 PM Dave Chinner <david@fromorbit.com> wrote=
:
>>>=20
>>>> On Thu, Jan 10, 2019 at 02:11:01PM -0800, Linus Torvalds wrote:
>>>> And we *can* do sane things about RWF_NOWAIT. For example, we could
>>>> start async IO on RWF_NOWAIT, and suddenly it would go from "probe the
>>>> page cache" to "probe and fill", and be much harder to use as an
>>>> attack vector..
>>>=20
>>> We can only do that if the application submits the read via AIO and
>>> has an async IO completion reporting mechanism.
>>=20
>> Oh, no, you misunderstand.
>>=20
>> RWF_NOWAIT has a lot of situations where it will potentially return
>> early (the DAX and direct IO ones have their own), but I was thinking
>> of the one in generic_file_buffered_read(), which triggers when you
>> don't find a page mapping. That looks like the obvious "probe page
>> cache" case.
>>=20
>> But we could literally move that test down just a few lines. Let it
>> start read-ahead.
>>=20
>> .. and then it will actually trigger on the *second* case instead, where w=
e have
>>=20
>>                if (!PageUptodate(page)) {
>>                        if (iocb->ki_flags & IOCB_NOWAIT) {
>>                                put_page(page);
>>                                goto would_block;
>>                        }
>>=20
>> and that's where RWF_MNOWAIT would act.
>>=20
>> It would still return EAGAIN.
>>=20
>> But it would have started filling the page cache. So now the act of
>> probing would fill the page cache, and the attacker would be left high
>> and dry - the fact that the page cache now exists is because of the
>> attack, not because of whatever it was trying to measure.
>>=20
>> See?
>=20
> Except for fadvise(POSIX_FADV_RANDOM) which triggers this code in
> page_cache_sync_readahead():
>=20
>        /* be dumb */
>        if (filp && (filp->f_mode & FMODE_RANDOM)) {
>                force_page_cache_readahead(mapping, filp, offset, req_size)=
;
>                return;
>        }
>=20
> So it will only read the single page we tried to access and won't
> perturb the rest of the message encoded into subsequent pages in
> file.
>=20

There are two types of attacks.  One is an intentional side channel where tw=
o cooperating processes communicate. This is, under some circumstances, a pr=
oblem, but it=E2=80=99s not one we=E2=80=99re about to solve in general. The=
 other is an attacker monitoring an unwilling process. I think we care a lot=
 more about that, and Linus=E2=80=99 idea will help.=
