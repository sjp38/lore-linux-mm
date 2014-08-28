Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 685006B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 20:16:25 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id ey11so130470pad.35
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 17:16:25 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id bp16si3538170pdb.34.2014.08.27.17.16.22
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 17:16:24 -0700 (PDT)
Date: Thu, 28 Aug 2014 09:17:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: compaction of zspages
Message-ID: <20140828001719.GA14679@bbox>
References: <CAA25o9T+byVZjO5U8krW-hQAnx3jNrvARANtur82b2KFzYpELQ@mail.gmail.com>
 <20140827220955.GA26902@cerebellum.variantweb.net>
 <CAA25o9RVZGqZTBM6+sPXBfMB_b5ZHCjPWwdWVy_cB0_whiiQrw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAA25o9RVZGqZTBM6+sPXBfMB_b5ZHCjPWwdWVy_cB0_whiiQrw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, Slava Malyugin <slavamn@google.com>, Sonny Rao <sonnyrao@google.com>

Hey Luigi,

On Wed, Aug 27, 2014 at 04:25:52PM -0700, Luigi Semenzato wrote:
> Thank you Seth!
> 
> On Wed, Aug 27, 2014 at 3:09 PM, Seth Jennings <sjennings@variantweb.net> wrote:
> > On Wed, Aug 27, 2014 at 02:42:52PM -0700, Luigi Semenzato wrote:
> >> Hello Minchan and others,
> >>
> >> I just noticed that the data structures used by zsmalloc have the
> >> potential to tie up memory unnecessarily.  I don't call it "leaking"
> >> because that memory can be reused, but it's not necessarily returned
> >> to the system upon freeing.
> >
> > Yes, this is a known condition in zsmalloc.

Yeb, I discussed it with Seth and Dan two years ago but I didn't have
a number how it's significat problem for real practice and no time to
look at it.

> >
> > Compaction is not a simple as it seems because zsmalloc returns a handle
> > to the user that encodes the pfn.  In order the implement a compaction
> > system, there would need to be some notification method to the alert the
> > user that their allocation has moved and provide a new handle so the
> > user can update its structures.  This is very non-trivial and I'm not
> > sure that it can be done safely (i.e.  without races).
> 
> Since the handles are opaque, we can add a level of indirection
> without affecting users.  Assuming that the overhead is tolerable, or
> anyway less than what we're wasting now.  (For some definition of
> "less".)

Yeb, my idea was same.
We could add indirection layer and it wouldn't be hard to implement.
It would add a bit overhead for memory footprint and performance
but I think it's is worth to try and see the result.
I hope I'd really like to implement it.

> 
> I agree that notification + update would be a huge pain, not really acceptable.
> 
> >
> > I looked at it a while back and it would be a significant effort.
> >
> > And yes, if you could do such a thing, you would not want the compaction
> > triggered by the shrinkers as the users of zsmalloc are only active
> > under memory pressure.  Something like a periodic compaction kthread
> > would be the best way (after two minutes of thinking about it).
> >
> > Seth
> >
> >
> >>
> >> I have no idea if this has any impact in practice, but I plan to run a
> >> test in the near future.  Also, I am not sure that doing compaction in
> >> the shrinkers (as planned according to a comment) is the best
> >> approach, because the shrinkers won't be called unless there is
> >> considerable pressure, but the compaction would be more effective when
> >> there is less pressure.

If we add the feature, basically, I'd like to open the interface(ex, zs_compact)
to user because when we need to compact depends on user's usecase and then
we could add up more smart things (ex, zs_set_auto_compaction(frag_ratio))
based on it.

> >>
> >> Some more detail here:
> >>
> >> https://code.google.com/p/chromium/issues/detail?id=408221
> >>
> >> Should I open a bug on some other tracker?

I don't think it's a bug, every allocator have a same problem(fragmentation).

Thanks for the report!

> >>
> >> Thank you very much!
> >> Luigi
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
