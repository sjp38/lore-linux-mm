Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85DC88E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:04:47 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id a10so7511930plp.14
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 20:04:47 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id t3si20081384ply.126.2019.01.10.20.04.45
        for <linux-mm@kvack.org>;
        Thu, 10 Jan 2019 20:04:46 -0800 (PST)
Date: Fri, 11 Jan 2019 15:04:35 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190111040434.GN27534@dastard>
References: <20190109043906.GF27534@dastard>
 <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard>
 <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard>
 <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard>
 <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 10, 2019 at 06:18:16PM -0800, Linus Torvalds wrote:
> On Thu, Jan 10, 2019 at 6:03 PM Dave Chinner <david@fromorbit.com> wrote:
> >
> > On Thu, Jan 10, 2019 at 02:11:01PM -0800, Linus Torvalds wrote:
> > > And we *can* do sane things about RWF_NOWAIT. For example, we could
> > > start async IO on RWF_NOWAIT, and suddenly it would go from "probe the
> > > page cache" to "probe and fill", and be much harder to use as an
> > > attack vector..
> >
> > We can only do that if the application submits the read via AIO and
> > has an async IO completion reporting mechanism.
> 
> Oh, no, you misunderstand.
> 
> RWF_NOWAIT has a lot of situations where it will potentially return
> early (the DAX and direct IO ones have their own), but I was thinking
> of the one in generic_file_buffered_read(), which triggers when you
> don't find a page mapping. That looks like the obvious "probe page
> cache" case.
> 
> But we could literally move that test down just a few lines. Let it
> start read-ahead.
> 
> .. and then it will actually trigger on the *second* case instead, where we have
> 
>                 if (!PageUptodate(page)) {
>                         if (iocb->ki_flags & IOCB_NOWAIT) {
>                                 put_page(page);
>                                 goto would_block;
>                         }
> 
> and that's where RWF_MNOWAIT would act.
> 
> It would still return EAGAIN.
> 
> But it would have started filling the page cache. So now the act of
> probing would fill the page cache, and the attacker would be left high
> and dry - the fact that the page cache now exists is because of the
> attack, not because of whatever it was trying to measure.
> 
> See?

Except for fadvise(POSIX_FADV_RANDOM) which triggers this code in
page_cache_sync_readahead():

        /* be dumb */
        if (filp && (filp->f_mode & FMODE_RANDOM)) {
                force_page_cache_readahead(mapping, filp, offset, req_size);
                return;
        }

So it will only read the single page we tried to access and won't
perturb the rest of the message encoded into subsequent pages in
file.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
