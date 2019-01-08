Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3655E8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 12:58:12 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id y24so369457lfh.4
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 09:58:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y24-v6sor39689068ljy.1.2019.01.08.09.58.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 09:58:10 -0800 (PST)
Received: from mail-lf1-f53.google.com (mail-lf1-f53.google.com. [209.85.167.53])
        by smtp.gmail.com with ESMTPSA id u65sm14080720lff.54.2019.01.08.09.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 09:58:07 -0800 (PST)
Received: by mail-lf1-f53.google.com with SMTP id u18so3579379lff.10
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 09:58:06 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
 <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com>
 <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
 <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com>
 <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com> <20190108044336.GB27534@dastard>
In-Reply-To: <20190108044336.GB27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 8 Jan 2019 09:57:49 -0800
Message-ID: <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Mon, Jan 7, 2019 at 8:43 PM Dave Chinner <david@fromorbit.com> wrote:
>
> So, I read the paper and before I was half way through it I figured
> there are a bunch of other similar page cache invalidation attacks
> we can perform without needing mincore. i.e. Focussing on mmap() and
> mincore() misses the wider issues we have with global shared caches.

Oh, agreed, and that was discussed in the original report too.

The thing is, you can also depend on our pre-faulting of pages in the
page fault handler, and use that to get the cached status of nearby
pages. So do something like "fault one page, then do mincore() to see
how many pages near it were mapped". See our "do_fault_around()"
logic.

But mincore is certainly the easiest interface, and the one that
doesn't require much effort or setup. It's also the one where our old
behavior was actually arguably simply stupid and actively wrong (ie
"in caches" isn't even strictly speaking a valid question, since the
caches in question may be invalid). So let's try to see if giving
mincore() slightly more well-defined semantics actually causes any
pain.

I do think that the RWF_NOWAIT case might also be interesting to look at.

                 Linus
