Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6CF28E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 02:20:44 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a18so7925857pga.16
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:20:44 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id t20si6319587plj.94.2019.01.10.23.20.42
        for <linux-mm@kvack.org>;
        Thu, 10 Jan 2019 23:20:43 -0800 (PST)
Date: Fri, 11 Jan 2019 18:20:39 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190111072039.GO27534@dastard>
References: <20190110004424.GH27534@dastard>
 <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard>
 <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard>
 <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
 <20190111040434.GN27534@dastard>
 <6955E7C1-A61C-49F3-8BB6-0624D5A70BD6@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <6955E7C1-A61C-49F3-8BB6-0624D5A70BD6@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 10, 2019 at 08:08:37PM -0800, Andy Lutomirski wrote:
> > On Jan 10, 2019, at 8:04 PM, Dave Chinner <david@fromorbit.com>
> > wrote:
> > 
> >> On Thu, Jan 10, 2019 at 06:18:16PM -0800, Linus Torvalds
> >> wrote:
> >>> On Thu, Jan 10, 2019 at 6:03 PM Dave Chinner
> >>> <david@fromorbit.com> wrote:
> >>> 
> >>>> On Thu, Jan 10, 2019 at 02:11:01PM -0800, Linus Torvalds
> >>>> wrote: And we *can* do sane things about RWF_NOWAIT. For
> >>>> example, we could start async IO on RWF_NOWAIT, and suddenly
> >>>> it would go from "probe the page cache" to "probe and fill",
> >>>> and be much harder to use as an attack vector..
> >>> 
> >>> We can only do that if the application submits the read via
> >>> AIO and has an async IO completion reporting mechanism.
> >> 
> >> Oh, no, you misunderstand.
> >> 
> >> RWF_NOWAIT has a lot of situations where it will potentially
> >> return early (the DAX and direct IO ones have their own), but I
> >> was thinking of the one in generic_file_buffered_read(), which
> >> triggers when you don't find a page mapping. That looks like
> >> the obvious "probe page cache" case.
> >> 
> >> But we could literally move that test down just a few lines.
> >> Let it start read-ahead.
> >> 
> >> .. and then it will actually trigger on the *second* case
> >> instead, where we have
> >> 
> >>                if (!PageUptodate(page)) { if (iocb->ki_flags &
> >>                IOCB_NOWAIT) { put_page(page); goto would_block;
> >>                }
> >> 
> >> and that's where RWF_MNOWAIT would act.
> >> 
> >> It would still return EAGAIN.
> >> 
> >> But it would have started filling the page cache. So now the
> >> act of probing would fill the page cache, and the attacker
> >> would be left high and dry - the fact that the page cache now
> >> exists is because of the attack, not because of whatever it was
> >> trying to measure.
> >> 
> >> See?
> > 
> > Except for fadvise(POSIX_FADV_RANDOM) which triggers this code
> > in page_cache_sync_readahead():
> > 
> >        /* be dumb */ if (filp && (filp->f_mode & FMODE_RANDOM))
> >        { force_page_cache_readahead(mapping, filp, offset,
> >        req_size); return; }
> > 
> > So it will only read the single page we tried to access and
> > won't perturb the rest of the message encoded into subsequent
> > pages in file.
> 
> There are two types of attacks.  One is an intentional side
> channel where two cooperating processes communicate.  This is,
> under some circumstances, a problem,

Yes, that's the covert communication channel that can cross container
and machine boundaries without any required privileges.

> but it’s not one
> we’re about to solve in general. The other is an attacker
> monitoring an unwilling process.

Which uses exactly the same mechanisms as the first case. i.e.
controlled invalidation and page cache residency monitoring.If we
aren't going to solve the first problem case, the we aren't going to
solve the second because they are one and the same problem...

However, I suspect you have misunderstood the monitoring mechanism
here - dispatch IO for this page doesn't prevent the information
leak about that page. It's when we return EAGAIN that we leak
information about page cache residency.

What Linus is attempting to do is perturb the nearby state of the
page cache by triggering async readahead in the EAGAIN case.  Async
readahead will fill all the holes in readahead window and hence
destroy the information about where the page fault landed and
instantiated the page cache. That would prevent the attacker from
determining what code the executable is running as they would only
be able to check a single page in an executable at a time and that
makes the attack highly impractical.

But if the attacker uses FADV_RANDOM, readahead is only triggered
for the page the attacker is trying to read. Hence it does not
disturb the nearby page cache residency pattern the executable's
page faults left behind and so doesn't destroy the information that
they are trying to extract from the unwilling process.

Sure, Linus's change makes monitoring the executable file after
FADV_RANDOM a "read-once" mechanism. However, detection of what code
is executing is a repeated invalidate-and-sweep exercise to begin
with, so it basically doesn't change the information or the rate at
which the monitoring process can extract information from the file.

/me hasn't thought about this sort of stuff since he was running
page cache invalidation attacks on Irix system libraries way back in
2002 when he found a libc bug that killed the init process and
paniced the kernel.

This isn't my first rodeo - it's been well known for a long, long
time that the system page cache can be exploited to monitor
executing code...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
