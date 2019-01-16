Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5410A8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:48:58 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id 18-v6so1697780ljn.8
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:48:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k14-v6sor5268841lji.4.2019.01.16.09.48.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 09:48:56 -0800 (PST)
Received: from mail-lf1-f51.google.com (mail-lf1-f51.google.com. [209.85.167.51])
        by smtp.gmail.com with ESMTPSA id d24-v6sm1126543ljg.2.2019.01.16.09.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 09:48:52 -0800 (PST)
Received: by mail-lf1-f51.google.com with SMTP id n18so5590665lfh.6
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:48:51 -0800 (PST)
MIME-Version: 1.0
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Jan 2019 05:48:33 +1200
Message-ID: <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 17, 2019 at 4:12 AM Jiri Kosina <jikos@kernel.org> wrote:
>
> So that seems to deal with mincore() in a reasonable way indeed.
>
> It doesn't unfortunately really solve the preadv2(RWF_NOWAIT), nor does it
> provide any good answer what to do about it, does it?

As I suggested earlier in the thread, the fix for RWF_NOWAIT might be
to just move the test down to after readahead.

We could/should be smarter than this,but it *might* be as simple as just

diff --git a/mm/filemap.c b/mm/filemap.c
index 9f5e323e883e..7bcdd36e629d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2075,8 +2075,6 @@ static ssize_t generic_file_buffered_read(

                page = find_get_page(mapping, index);
                if (!page) {
-                       if (iocb->ki_flags & IOCB_NOWAIT)
-                               goto would_block;
                        page_cache_sync_readahead(mapping,
                                        ra, filp,
                                        index, last_index - index);

which starts readahead even if IOCB_NOWAIT is set and will then test
IOCB_NOWAIT _later_ and not actually wait for it.

            Linus
