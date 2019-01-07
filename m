Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF05E8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 06:08:45 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id f5-v6so11296100ljj.17
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 03:08:45 -0800 (PST)
Received: from nautica.notk.org (ipv6.notk.org. [2001:41d0:1:7a93::1])
        by mx.google.com with ESMTPS id 17-v6si1461100ljn.9.2019.01.07.03.08.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 03:08:43 -0800 (PST)
Date: Mon, 7 Jan 2019 12:08:27 +0100
From: Dominique Martinet <asmadeus@codewreck.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190107110827.GA15249@nautica>
References: <20190107043227.GA3325@nautica>
 <151b4ac8-5cfc-ed30-db30-e4d67a324c4b@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <151b4ac8-5cfc-ed30-db30-e4d67a324c4b@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, daniel@gruss.cc

Vlastimil Babka wrote on Mon, Jan 07, 2019:
> On 1/7/19 5:32 AM, Dominique Martinet wrote:
> > Linus Torvalds wrote on Sat, Jan 05, 2019:
> >> But I think my patch to just rip out all that page lookup, and just
> >> base it on the page table state has the fundamental advantage that it
> >> gets rid of code. Maybe I should jst commit it, and see if anything
> >> breaks? We do have options in case things break, and then we'd at
> >> least know who cares (and perhaps a lot more information of _why_ they
> >> care).
> > 
> > There actually are many tools like fincore which depend on mincore to
> > try to tell whether a file is "loaded in cache" or not (I personally use
> > vmtouch[1], but I know of at least nocache[2] uses it as well to only
> > try to evict used pages)
> 
> nocache could probably do fine without mincore. IIUC the point is to not
> evict anything that was already resident prior to running some command
> wrapped in nocache. Without the mincore checks,
> posix_fadvise(POSIX_FADV_DONTNEED) will still not drop anything that
> others have mapped. That means without mincore() it will drop data
> that's in cache but not currently in use by anybody, which shouldn't
> cause large performance regressions?

Yes, I sent them a patch to allow this behaviour (which got merged ages
ago); but the default nocache usage will try to preserve pages that were
mapped before even if the user mapped it themselves so it's a little bit
more robust that just trusting linux to do the right thing. I did
various tests with fadvise dontneed and honestly the way it works is far
from obvious when operating as a single user at least; I didn't test
multi-users as that didn't really concern me.

With the current mincore change, it will think everything was "in core"
and not flush anything unless my option to just fadvise dontneed
everything is passed though ; so even if we can make it work it is a
change of behaviour that is breaking an existing application, and it has
no way of telling it didn't work.


Honestly though, as I said, mincore() is much more useful for debugging
for me ; the application can be changed if required. I just pointed it
out as it'll need changing, and it has no obvious way of testing at
runtime if the syscall works (except dumb kernel version check, but that
won't work with stable backports); so it's not that obvious.

> > FWIW I personally don't care much about "only for owner" or depending on
> > mmap options; I don't understand much of the security implications
> > honestly so I'm not sure how these limitations actually help.
> > On the other hand, a simple CAP_SYS_ADMIN check making the call take
> > either behaviour should be safe and would cover what I described above.
> 
> So without CAP_SYS_ADMIN, mincore() would return mapping status, and
> with CAP_SYS_ADMIN, it would return cache residency status? Very clumsy
> :( Maybe if we introduced mincore2() with flags similar to BSD mentioned
> earlier in the thread, and the cache residency flag would require
> CAP_SYS_ADMIN or something similar.

I agree, that's rather clumsy... Or rather might lead to some unexpected
behaviours. I'm open to other ideas.
I'm not sure how the BSD flags help though?

> > (by the way, while we are discussing permissions, a regular user can use
> > fadvise dontneed on files it doesn't own as well as long as it can open
> > them for reading; I'm not sure if that would need restricting as well in
> > the context of the security issue.
> 
> Probably not, as I've mentioned it won't evict what's mapped by somebody
> else. And eviction is also possible via controlling LRU, which is what
> the paper [1] does anyway (and also mentions that DONTNEED doesn't
> work). Being able to evict somebody's page is AFAIU not sufficient for
> attack, the side channel is about knowing that somebody brought that
> page back to RAM by touching it.

Thanks for the link to the paper, I hadn't taken the time to extract it
from the news article but it's much more interesting indeed.
Some of what's been said here makes more sense to me now (checking
about ownership and similar might indeed be good enough).

For evicting page I agree most targets would be different users so I
guess that makes sense as well; there seem to be other ways of
efficiently evicting a page from cache anyway.

(BTW, this was brought up earlier, the paper also mentions
/proc/self/pagemap as not being useful.)


> > Frankly even with mincore someone
> > could likely tell the difference through timing, if they just do it a
> > few times. Do magic, probe, flush out, repeat until satisfied.)

(I meant "without mincore", obviously, as you understood properly)

> That's my bigger concern here. In [1] there's described a remote attack
> (on webserver) using the page fault timing differences for present/not
> present page cache pages. Noisy but works, and I expect locally it to be
> much less noisy. Yet the countermeasures section only mentions
> restricting mincore() as if it was sufficient (and also how to make
> evictions harder, but that's secondary IMHO).

I'd suggest making clock rougher for non-root users but javascript tried
that and it wasn't enough... :)
Honestly won't be of much help there, good luck?

Thanks,
-- 
Dominique
