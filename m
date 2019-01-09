Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 972DE8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 13:26:04 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id 2-v6so2042533ljs.15
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 10:26:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a22-v6sor42303303ljd.6.2019.01.09.10.26.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 10:26:02 -0800 (PST)
Received: from mail-lf1-f54.google.com (mail-lf1-f54.google.com. [209.85.167.54])
        by smtp.gmail.com with ESMTPSA id 11sm13967940lfq.89.2019.01.09.10.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 10:26:00 -0800 (PST)
Received: by mail-lf1-f54.google.com with SMTP id i26so6404529lfc.0
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 10:26:00 -0800 (PST)
MIME-Version: 1.0
References: <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
 <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com>
 <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard>
In-Reply-To: <20190109043906.GF27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 9 Jan 2019 10:25:43 -0800
Message-ID: <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue, Jan 8, 2019 at 8:39 PM Dave Chinner <david@fromorbit.com> wrote:
>
> FWIW, I just realised that the easiest, most reliable way to
> invalidate the page cache over a file range is simply to do a
> O_DIRECT read on it.

If that's the case, that's actually an O_DIRECT bug.

It should only invalidate the caches on write.

On reads, it wants to either _flush_ any direct caches before the
read, or just take the data from the caches. At no point is
"invalidate" a valid model.

Of course, I'm not in the least bit shocked if O_DIRECT is buggy like
this. But looking at least at the ext4 routine, the read just does

        ret = filemap_write_and_wait_range(mapping, iocb->ki_pos,

and I don't see any invalidation.

Having read access to a file absolutely should *not* mean that you can
flush caches on it. That's a write op.

Any filesystem that invalidates the caches on read is utterly buggy.

Can you actually point to such a thing? Let's get that fixed, because
it's completely wrong regardless of this whole mincore issue.

               Linus
