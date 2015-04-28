Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id D71D36B006C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 12:02:00 -0400 (EDT)
Received: by iejt8 with SMTP id t8so21721501iej.2
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:02:00 -0700 (PDT)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com. [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id ci8si8783868igc.44.2015.04.28.09.02.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 09:02:00 -0700 (PDT)
Received: by iedfl3 with SMTP id fl3so24382961ied.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:02:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1430223111-14817-1-git-send-email-mhocko@suse.cz>
References: <20150114095019.GC4706@dhcp22.suse.cz>
	<1430223111-14817-1-git-send-email-mhocko@suse.cz>
Date: Tue, 28 Apr 2015 09:01:59 -0700
Message-ID: <CA+55aFxzLXx=cC309h_tEc-Gkn_zH4ipR7PsefVcE-97Uj066g@mail.gmail.com>
Subject: Re: Should mmap MAP_LOCKED fail if mm_poppulate fails?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, Cyril Hrubis <chrubis@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue, Apr 28, 2015 at 5:11 AM, Michal Hocko <mhocko@suse.cz> wrote:
>
> The first patch is dumb and straightforward. It should be safe as is and
> also good without the follow up 2 patches which try to handle potential
> allocation failures in the do_munmap path more gracefully. As we still
> do not fail small allocations even the first patch could be simplified
> a bit and the retry loop replaced by a BUG_ON right away.

I think the BUG_ON() is a bad idea in the first place, and is in fact
a good reason to ignore the patch series entirely.

What is the point of that BUG_ON()?

Hell, people add too many of those things. There is *no* excuse for
killing the kernel for things like this (and in certain setups,
BUG_ON() *will* cause the machine to be rebooted). None. It's
completely inexcusable.

Thinking like this must go. BUG_ON() is for things where our internal
data structures are so corrupted that we don't know what to do, and
there's no way to continue. Not for "I want to sprinkle these things
around and this should not happen".

I also think that the whole complex "do_munmap_nofail()" is broken to
begin with, along with the crazy "!fatal_signal_pending()" thing.
There is absolutely no excuse for any of this.

Your code is also fundamentally buggy in that it tries to do unmap()
after it has dropped all locks, and things went wrong. So you may nto
be unmapping some other threads data.

There is no way in hell any of these patches can ever be applied.

There's a reason we don't handle populate failures - it's exactly
because we've dropped the locks etc. After dropping the locks, we
*cannot* clean up any more, because there's no way to know whather
we're cleaning up the right thing.  You'd have to hold the write lock
over the whole populate, which has serious problems of its own.

So NAK on this series. I think just documenting the man-page might be
better. I don't think MAP_LOCKED is sanely fixable.

We might improve on MAP_LOCKED by having a heuristic up-front
(*before* actually doing any mmap) to verify that it's *likely* that
it will work. So we could return ENOMEM early if it looks like the
user would hit the resource limits, for example. That wouldn't be any
guarantee (another process might eat up the resource limit anyway),
and in fact it might be overly eager to fail (maybe the
mmap(MAP_LOCKED ends up unmapping an older locked mapping and we deny
it too eagerly), but it would probably work well enough in practice.

That, together with a warning in the man-page about mmap(MAP_LOCKED)
not being able to return "I only locked part of the mapping", if you
want full error handling you need to do mmap()+mlock() and check the
two errors separately.

Hmm? But I really dislike your patch-series as-is.

                       Linus

                      Linus

                           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
