Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F08796B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 12:08:11 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id w7so6160662pfd.4
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 09:08:11 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m8sor1166495plt.148.2017.12.07.09.08.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 09:08:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171206050547.GA5260@X58A-UD3R>
References: <94eb2c0d010a4e7897055f70535b@google.com> <20171204083339.GF8365@quack2.suse.cz>
 <80ba65b6-d0c2-2d3a-779b-a134af8a9054@lge.com> <CACT4Y+arqmp6RW4mt3EyaPqxqxPyY31kjDLftnof5DkwfyoyRQ@mail.gmail.com>
 <20171206050547.GA5260@X58A-UD3R>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 7 Dec 2017 18:07:48 +0100
Message-ID: <CACT4Y+ZXMU3-zhoCo2SPOt+NJYJG8JARDKXFE=A4XMDUni8W-w@mail.gmail.com>
Subject: Re: possible deadlock in generic_file_write_iter (2)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Jan Kara <jack@suse.cz>, syzbot <bot+045a1f65bdea780940bf0f795a292f4cd0b773d1@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, Peter Zijlstra <peterz@infradead.org>, kernel-team@lge.com

On Wed, Dec 6, 2017 at 6:05 AM, Byungchul Park <byungchul.park@lge.com> wrote:
>> > On 12/4/2017 5:33 PM, Jan Kara wrote:
>> >>
>> >> Hello,
>> >>
>> >> adding Peter and Byungchul to CC since the lockdep report just looks
>> >> strange and cross-release seems to be involved. Guys, how did #5 get into
>> >> the lock chain and what does put_ucounts() have to do with sb_writers
>> >> there? Thanks!
>> >
>> >
>> > Hello Jan,
>> >
>> > In order to get full stack of #5, we have to pass a boot param,
>> > "crossrelease_fullstack", to the kernel. Now that it only informs
>> > put_ucounts() in the call trace, it's hard to find out what exactly
>> > happened at that time, but I can tell #5 shows:
>> >
>> > When acquire(sb_writers) in put_ucounts(), it was on the way to
>> > complete((completion)&req.done) of wait_for_completion() in
>> > devtmpfs_create_node().
>> >
>> > If acquire(sb_writers) in put_ucounts() is stuck, then
>> > wait_for_completion() in devtmpfs_create_node() would be also
>> > stuck, since complete() being in the context of acquire(sb_writers)
>> > cannot be called.
>> >
>> > This is why cross-release added the lock chain.
>>
>> Hi,
>>
>> What is cross-release? Is it something new? Should we always enable
>> crossrelease_fullstack during testing?
>
> Hello Dmitry,
>
> Yes, it's new one making lockdep track wait_for_completion() as well.
>
> And we should enable crossrelease_fullstack if you don't care system
> slowdown but testing.

I've enabled CONFIG_BOOTPARAM_LOCKDEP_CROSSRELEASE_FULLSTACK. It
should have the same effect, right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
