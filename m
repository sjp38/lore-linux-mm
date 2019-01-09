Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 229F48E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 21:31:38 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id e29so2363427ede.19
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 18:31:38 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25si300508edr.258.2019.01.08.18.31.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 18:31:36 -0800 (PST)
Date: Wed, 9 Jan 2019 03:31:35 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <20190109022430.GE27534@dastard>
Message-ID: <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
References: <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com> <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com> <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com> <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com>
 <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com> <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com> <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com> <20190109022430.GE27534@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, 9 Jan 2019, Dave Chinner wrote:

> > But mincore is certainly the easiest interface, and the one that
> > doesn't require much effort or setup.
> 
> Off the top of my head, here's a few vectors for reading the page
> cache residency state without perturbing the page cache residency
> pattern:
> 	- mincore
> 	- preadv2(RWF_NOWAIT)
> 	- fadvise(POSIX_FADV_RANDOM); timed read(2) syscalls
> 	- madvise(MADV_RANDOM); timed read of first byte in each page

While I obviously agree that all those are creating pagecache sidechannel 
in principle, I think we really should mostly focus on the first two (with 
mincore() already having been covered).

Rationale has been provided by Daniel Gruss in this thread -- if the 
attacker is left with cache timing as the only available vector, he's 
going to be much more successful with mounting hardware cache timing 
attack anyway.

Thanks,

-- 
Jiri Kosina
SUSE Labs
