Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 851716B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 08:36:51 -0400 (EDT)
Received: by igkz10 with SMTP id z10so62928igk.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 05:36:51 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id h7si2370762ioi.142.2015.10.09.05.36.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 05:36:47 -0700 (PDT)
Received: by igkz10 with SMTP id z10so61763igk.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 05:36:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150926100401.96a36c7cd3c913b063887466@gmail.com>
References: <20150926100401.96a36c7cd3c913b063887466@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 9 Oct 2015 08:36:08 -0400
Message-ID: <CALZtONAbX4dzGnhcO6s7aMP9VU8+FeQqYS33u+XdUv2noAvePA@mail.gmail.com>
Subject: Re: [PATCHv2 0/3] align zpool/zbud/zsmalloc on the api
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Sat, Sep 26, 2015 at 4:04 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
> Here comes the second iteration over zpool/zbud/zsmalloc API alignment.
> This time I divide it into three patches: for zpool, for zbud and for zsmalloc :)
> Patches are non-intrusive and do not change any existing functionality. They only
> add up stuff for the alignment purposes.

While I agree with what the patches do - simply change zram to use
zpool so zbud is an option - I also understand (I think) Minchan's
reluctance to ack them.  From his point of view, with zram, there is
no upside to using zpool; zsmalloc has better storage density than
zbud.  And without compaction, zbud and zsmalloc should be
*approximately* as deterministic, at least theoretically.  So changing
zram to use zpool only introduces a layer between zram and zsmalloc,
creating more work for him to update both zram and zsmalloc in the
future; adding a new feature/interface to zsmalloc will mean he also
has to update zpool and get additional ack's; he can add new features
to zram/zsmalloc now relatively uncontested.  I'm not trying to say
that's a bad thing, just that I can understand reluctance to add
complexity and additional future work, when in doubt of the benefit.
So I suspect you aren't going to get an ack from him until you show
him the specific benefit of using zbud, using hard data, and we all
figure out exactly why zbud is better in some situations.  And without
his ack, you're almost certainly not going to get zram or zsmalloc
patches in.

One thing I will say in general, and Seth has said this before too, is
that zbud is supposed to be the simple, reliable, consistent driver;
it won't get you the best storage efficiency, but it should be very
consistent in doing what it does, and it shouldn't change (much) from
one kernel version to another.  Opposed to that is zsmalloc, which is
supposed to get the best storage density, and is updated rather often
to get closer to that goal.  It has more knobs (at least internally),
and its code can change significantly from one kernel to another,
resulting in different (usually better) storage efficiency, but
possibly also resulting in less deterministic behavior, and more
processing overhead.  So I think even without hard numbers to compare
zbud and zsmalloc under zram, your general argument that some people
want stability over efficiency is not something to be dismissed; zbud
and zsmalloc clearly have different goals, and zsmalloc can't simply
be patched to be as consistent as zbud across kernel versions.  That's
not its goal; its goal is to achieve maximum storage efficiency.

Specifically regarding the determinism of each; obviously compaction
will have an impact, since it takes cpu cycles to do the compaction.
I don't know how much impact, but I think at minimum it would make
sense to add a module param to zsmalloc to allow disabling compaction.
But even without compaction, there is an important difference between
zbud and zsmalloc; zbud will never alloc more than 1 page when it
needs more storage, while zsmalloc will alloc between 1 and
ZS_MAX_PAGES_PER_ZSPAGE (currently 4) pages when it needs more
storage.  So in the worst case (if memory is tight and alloc_page()
takes a while), zsmalloc could take up to 4 times as long as zbud to
store a page.  Now, that should average out, where zsmalloc doesn't
need to alloc as many times as zbud (since it allocs more at once),
but on the small scale there will be less consistency of page storage
times with zsmalloc than zbud; at least, theoretically ;-)

I suggest you work with Minchan to find out what comparison data he
wants to see, to prove zbud is more stable/consistent under a certain
workload (and/or across kernel versions).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
