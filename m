Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 372816B026D
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 04:19:30 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id m9so15844850pff.0
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 01:19:30 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j25sor3606067pgn.17.2017.12.05.01.19.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Dec 2017 01:19:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <80ba65b6-d0c2-2d3a-779b-a134af8a9054@lge.com>
References: <94eb2c0d010a4e7897055f70535b@google.com> <20171204083339.GF8365@quack2.suse.cz>
 <80ba65b6-d0c2-2d3a-779b-a134af8a9054@lge.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 5 Dec 2017 10:19:07 +0100
Message-ID: <CACT4Y+arqmp6RW4mt3EyaPqxqxPyY31kjDLftnof5DkwfyoyRQ@mail.gmail.com>
Subject: Re: possible deadlock in generic_file_write_iter (2)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Jan Kara <jack@suse.cz>, syzbot <bot+045a1f65bdea780940bf0f795a292f4cd0b773d1@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, Peter Zijlstra <peterz@infradead.org>, kernel-team@lge.com

On Tue, Dec 5, 2017 at 5:58 AM, Byungchul Park <byungchul.park@lge.com> wrote:
> On 12/4/2017 5:33 PM, Jan Kara wrote:
>>
>> Hello,
>>
>> adding Peter and Byungchul to CC since the lockdep report just looks
>> strange and cross-release seems to be involved. Guys, how did #5 get into
>> the lock chain and what does put_ucounts() have to do with sb_writers
>> there? Thanks!
>
>
> Hello Jan,
>
> In order to get full stack of #5, we have to pass a boot param,
> "crossrelease_fullstack", to the kernel. Now that it only informs
> put_ucounts() in the call trace, it's hard to find out what exactly
> happened at that time, but I can tell #5 shows:
>
> When acquire(sb_writers) in put_ucounts(), it was on the way to
> complete((completion)&req.done) of wait_for_completion() in
> devtmpfs_create_node().
>
> If acquire(sb_writers) in put_ucounts() is stuck, then
> wait_for_completion() in devtmpfs_create_node() would be also
> stuck, since complete() being in the context of acquire(sb_writers)
> cannot be called.
>
> This is why cross-release added the lock chain.

Hi,

What is cross-release? Is it something new? Should we always enable
crossrelease_fullstack during testing?

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
