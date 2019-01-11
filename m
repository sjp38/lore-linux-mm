Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 887E68E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:03:44 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id v11so7368802ply.4
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:03:44 -0800 (PST)
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id z71si6272737pgd.490.2019.01.10.18.03.42
        for <linux-mm@kvack.org>;
        Thu, 10 Jan 2019 18:03:43 -0800 (PST)
Date: Fri, 11 Jan 2019 13:03:40 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190111020340.GM27534@dastard>
References: <20190109022430.GE27534@dastard>
 <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard>
 <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard>
 <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard>
 <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 10, 2019 at 02:11:01PM -0800, Linus Torvalds wrote:
> And we *can* do sane things about RWF_NOWAIT. For example, we could
> start async IO on RWF_NOWAIT, and suddenly it would go from "probe the
> page cache" to "probe and fill", and be much harder to use as an
> attack vector..

We can only do that if the application submits the read via AIO and
has an async IO completion reporting mechanism.  Otherwise we have
to wait for the IO to complete to copy the data into the user's
buffer. And given that the app is using RWF_NOWAIT to explicitly
avoid blocking on the IO....

Also, keep in mind that RWF_NOWAIT also prevents blocking on
filesystem locks and full request queues. One of the prime drivers
of RWF_NOWAIT was to prevent AIO submission from blocking on
filesystem locks - it allows userspace to submit other IO while it
can't get all the access it requires to a single file or a single
block device is congested.

Hence I don't think there's a such a simple answer here - blocking
for IO breaks RWF_NOWAIT.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
