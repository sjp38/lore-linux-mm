Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD276B033F
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 00:06:10 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id d4so1905106pgv.4
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 21:06:10 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id q3si1376236pfl.322.2017.12.05.21.06.08
        for <linux-mm@kvack.org>;
        Tue, 05 Dec 2017 21:06:09 -0800 (PST)
Date: Wed, 6 Dec 2017 14:05:47 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: possible deadlock in generic_file_write_iter (2)
Message-ID: <20171206050547.GA5260@X58A-UD3R>
References: <94eb2c0d010a4e7897055f70535b@google.com>
 <20171204083339.GF8365@quack2.suse.cz>
 <80ba65b6-d0c2-2d3a-779b-a134af8a9054@lge.com>
 <CACT4Y+arqmp6RW4mt3EyaPqxqxPyY31kjDLftnof5DkwfyoyRQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+arqmp6RW4mt3EyaPqxqxPyY31kjDLftnof5DkwfyoyRQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Jan Kara <jack@suse.cz>, syzbot <bot+045a1f65bdea780940bf0f795a292f4cd0b773d1@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, npiggin@gmail.com, rgoldwyn@suse.com, syzkaller-bugs@googlegroups.com, Peter Zijlstra <peterz@infradead.org>, kernel-team@lge.com

On Tue, Dec 05, 2017 at 10:19:07AM +0100, Dmitry Vyukov wrote:
> On Tue, Dec 5, 2017 at 5:58 AM, Byungchul Park <byungchul.park@lge.com> wrote:
> > On 12/4/2017 5:33 PM, Jan Kara wrote:
> >>
> >> Hello,
> >>
> >> adding Peter and Byungchul to CC since the lockdep report just looks
> >> strange and cross-release seems to be involved. Guys, how did #5 get into
> >> the lock chain and what does put_ucounts() have to do with sb_writers
> >> there? Thanks!
> >
> >
> > Hello Jan,
> >
> > In order to get full stack of #5, we have to pass a boot param,
> > "crossrelease_fullstack", to the kernel. Now that it only informs
> > put_ucounts() in the call trace, it's hard to find out what exactly
> > happened at that time, but I can tell #5 shows:
> >
> > When acquire(sb_writers) in put_ucounts(), it was on the way to
> > complete((completion)&req.done) of wait_for_completion() in
> > devtmpfs_create_node().
> >
> > If acquire(sb_writers) in put_ucounts() is stuck, then
> > wait_for_completion() in devtmpfs_create_node() would be also
> > stuck, since complete() being in the context of acquire(sb_writers)
> > cannot be called.
> >
> > This is why cross-release added the lock chain.
> 
> Hi,
> 
> What is cross-release? Is it something new? Should we always enable
> crossrelease_fullstack during testing?

Hello Dmitry,

Yes, it's new one making lockdep track wait_for_completion() as well.

And we should enable crossrelease_fullstack if you don't care system
slowdown but testing.

--
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
