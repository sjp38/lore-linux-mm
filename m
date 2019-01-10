Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5077B8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 09:47:19 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id t26so6412274pgu.18
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 06:47:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r27si70130964pgl.494.2019.01.10.06.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 Jan 2019 06:47:18 -0800 (PST)
Date: Thu, 10 Jan 2019 06:47:11 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190110144711.GV6310@bombadil.infradead.org>
References: <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard>
 <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard>
 <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard>
 <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard>
 <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <CALCETrWxwaBUYMg=aLySJByMgXzuzV4gHS0n6O6Oet2Jm6SAbw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWxwaBUYMg=aLySJByMgXzuzV4gHS0n6O6Oet2Jm6SAbw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 09, 2019 at 09:26:41PM -0800, Andy Lutomirski wrote:
> Since direct IO has been brought up, I have a question.  I've wondered
> for years why direct IO works the way it does.  If I were implementing
> it from scratch, my first inclination would be to use the page cache
> instead of fighting it.  To do a single-page direct read, I would look
> that page up in the page cache (i.e. i_pages these days).  If the page
> is there, I would do a normal buffered read.  If the page is not
> there, I would insert a record into i_pages indicating that direct IO
> is in progress and then I would do the IO into the destination page.
> If any other read, direct or otherwise, sees a record saying "under
> direct IO", it would wait.

OK, you're in the same ballpark I am ;-)  Kent Overstreet pointed out
that what you want to do here is great for the mixed case, but it's
pretty inefficient for IOs to files which are wholly uncached.

So what I'm currently thinking about is an rwsem which works like this:

O_DIRECT task:
if i_pages is empty, take rwsem for read, recheck i_pages is empty, do IO,
drop rwsem.
if i_pages is not empty, insert XA_LOCK_ENTRY, when IO complete, wake waitqueue for that (mapping, index).

buffered IO:
if i_pages is empty, take rwsem for write, allocate page, insert page, drop rwsem.
if i_pages is not empty, look up index, if entry is XA_LOCK_ENTRY sleep on
waitqueue. otherwise proceed as now.
