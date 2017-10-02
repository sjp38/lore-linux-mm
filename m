Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id F08AD6B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 19:08:48 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id e9so6651804iod.4
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 16:08:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h135sor5062355ioe.13.2017.10.02.16.08.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Oct 2017 16:08:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171002224520.GJ15067@dastard>
References: <150693809463.587641.5712378065494786263.stgit@buzz>
 <CA+55aFyXrxN8Dqw9QK9NPWk+ZD52fT=q2y7ByPt9pooOrio3Nw@mail.gmail.com> <20171002224520.GJ15067@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 2 Oct 2017 16:08:46 -0700
Message-ID: <CA+55aFx5t5YifPXhL2KdTZRFOwLgXLqrpXjdAJHygKhxmMyqNg@mail.gmail.com>
Subject: Re: [PATCH RFC] mm: implement write-behind policy for sequential file writes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Oct 2, 2017 at 3:45 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> Yup, it's a good idea. Needs some tweaking, though.

Probably a lot. 256kB seems very eager.

> If we block on close, it becomes:

I'm not at all suggesting blocking at cl;ose, just doing that final
async writebehind (assuming we started any earlier write-behind) so
that the writeour ends up seeing the whole file, rather than
"everything but the very end"

> Perhaps we need to think about a small per-backing dev threshold
> where the behaviour is the current writeback behaviour, but once
> it's exceeded we then switch to write-behind so that the amount of
> dirty data doesn't exceed that threshold.

Yes, that sounds like a really good idea, and as a way to avoid
starting too early.

However, part of the problem there is that we don't have that
historical "what is dirty", because it would often be in previous
files. Konstantin's patch is simple partly because it has only that
single-file history to worry about.

You could obviously keep that simplicity, and just accept the fact
that the early dirty data ends up being kept dirty, and consider it
just the startup cost and not even try to do the write-behind on that
oldest data.

But I do agree that 256kB is a very early threshold, and likely too
small for many cases.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
