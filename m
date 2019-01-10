Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6ACC08E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 09:50:26 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f125so6440949pgc.20
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 06:50:26 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d19si7432534pgg.314.2019.01.10.06.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 10 Jan 2019 06:50:25 -0800 (PST)
Date: Thu, 10 Jan 2019 06:50:20 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190110145020.GW6310@bombadil.infradead.org>
References: <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard>
 <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard>
 <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard>
 <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190110004424.GH27534@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jikos@kernel.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 10, 2019 at 11:44:24AM +1100, Dave Chinner wrote:
> And, really, this would be just another band-aid over a symptom of
> the information leak - it doesn't prevent users from being able to
> control page cache invalidation. It just removes one method, just
> like hacking mincore only removes one method of observing the page
> cache.  And, like mincore(), there's every chance it impacts on
> userspace in a negative manner and so we need to be very careful
> here.

Putting the mincore() / cache timing information leak aside though,
the current behaviour of XFS means that an attacker can screw up the
performance of random applications just by repeatedly doing O_DIRECT
reads of libc.so.

Maybe O_DIRECT reads should be forbidden from files on XFS unless you
also have write access to them?  (eg owner).
