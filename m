Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC96F6B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 20:20:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a7so15061535pfj.3
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 17:20:59 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id c30si1534504pgn.815.2017.10.02.17.20.57
        for <linux-mm@kvack.org>;
        Mon, 02 Oct 2017 17:20:58 -0700 (PDT)
Date: Tue, 3 Oct 2017 11:08:49 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH RFC] mm: implement write-behind policy for sequential
 file writes
Message-ID: <20171003000849.GK15067@dastard>
References: <150693809463.587641.5712378065494786263.stgit@buzz>
 <CA+55aFyXrxN8Dqw9QK9NPWk+ZD52fT=q2y7ByPt9pooOrio3Nw@mail.gmail.com>
 <20171002224520.GJ15067@dastard>
 <CA+55aFx5t5YifPXhL2KdTZRFOwLgXLqrpXjdAJHygKhxmMyqNg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx5t5YifPXhL2KdTZRFOwLgXLqrpXjdAJHygKhxmMyqNg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Oct 02, 2017 at 04:08:46PM -0700, Linus Torvalds wrote:
> On Mon, Oct 2, 2017 at 3:45 PM, Dave Chinner <david@fromorbit.com> wrote:
> >
> > Yup, it's a good idea. Needs some tweaking, though.
> 
> Probably a lot. 256kB seems very eager.
> 
> > If we block on close, it becomes:
> 
> I'm not at all suggesting blocking at cl;ose, just doing that final
> async writebehind (assuming we started any earlier write-behind) so
> that the writeour ends up seeing the whole file, rather than
> "everything but the very end"

That's fine by me - we already do that in certain cases - but
AFAICT that's not the way the writebehind code presented
works. If the file is larger than the async write behind size then
it will also block waiting for previous writebehind to complete.

I think all we'd need is a call is filemap_fdatawrite()....

> > Perhaps we need to think about a small per-backing dev threshold
> > where the behaviour is the current writeback behaviour, but once
> > it's exceeded we then switch to write-behind so that the amount of
> > dirty data doesn't exceed that threshold.
> 
> Yes, that sounds like a really good idea, and as a way to avoid
> starting too early.
> 
> However, part of the problem there is that we don't have that
> historical "what is dirty", because it would often be in previous
> files. Konstantin's patch is simple partly because it has only that
> single-file history to worry about.
>
> You could obviously keep that simplicity, and just accept the fact
> that the early dirty data ends up being kept dirty, and consider it
> just the startup cost and not even try to do the write-behind on that
> oldest data.

I'm not sure we need to care about that - the bdi knows how much
dirty data there is on the device, and so we can switch from
device-based writeback to per-file writeback at that point. If we
we trigger a background flush of all the existing dirty
data when we switch modes then we wouldn't leave any of it hanging
around for ages while other file data gets written...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
