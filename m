Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id E3D726B005D
	for <linux-mm@kvack.org>; Tue, 29 May 2012 13:36:08 -0400 (EDT)
Received: by wefh52 with SMTP id h52so4017583wef.14
        for <linux-mm@kvack.org>; Tue, 29 May 2012 10:36:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120529155759.GA11326@localhost>
References: <20120528114124.GA6813@localhost> <CA+55aFxHt8q8+jQDuoaK=hObX+73iSBTa4bBWodCX3s-y4Q1GQ@mail.gmail.com>
 <20120529155759.GA11326@localhost>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 29 May 2012 10:35:46 -0700
Message-ID: <CA+55aFykFaBhzzEyRYWRS9Qoy_q_R65Cuth7=XvfOZEMqjn6=w@mail.gmail.com>
Subject: Re: write-behind on streaming writes
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue, May 29, 2012 at 8:57 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
>
> Actually O_SYNC is pretty close to the below code for the purpose of
> limiting the dirty and writeback pages, except that it's not on by
> default, hence means nothing for normal users.

Absolutely not.

O_SYNC syncs the *current* write, syncs your metadata, and just
generally makes your writer synchronous. It's just a f*cking moronic
idea. Nobody sane ever uses it, since you are much better off just
using fsync() if you want that kind of behavior. That's one of those
"stupid legacy flags" things that have no sane use.

The whole point is that doing that is never the right thing to do. You
want to sync *past* writes, and you never ever want to wait on them
unless you just sent more (newer) writes to the disk that you are
*not* waiting on - so that you always have more IO pending.

O_SYNC is the absolutely anti-thesis of that kind of "multiple levels
of overlapping IO". Because it requires that the IO is _done_ by the
time you start more, which is against the whole point.

> It seems to me all about optimizing the 1-dd case for desktop users,
> and the most beautiful thing about per-file write behind is, it keeps
> both the number of dirty and writeback pages low in the system when
> there are only one or two sequential dirtier tasks. Which is good for
> responsiveness.

Yes, but I don't think it's about a single-dd case - it's about just
trying to handle one common case (streaming writes) efficiently and
naturally. Try to get those out of the system so that you can then
worry about the *other* cases knowing that they don't have that kind
of big streaming behavior.

For example, right now our main top-level writeback logic is *not*
about streaming writes (just dirty counts), but then we try to "find"
the locality by making the lower-level writeback do the whole "write
back by chunking inodes" without really having any higher-level
information.

I just suspect that we'd be better off teaching upper levels about the
streaming. I know for a fact that if I do it by hand, system
responsiveness was *much* better, and IO throughput didn't go down at
all.

> Note that the above user space code won't work well when there are 10+
> dirtier tasks. It effectively creates 10+ IO submitters on different
> regions of the disk and thus create lots of seeks.

Not really much more than our current writeback code does. It
*schedules* data for writing, but doesn't wait for it until much
later.

You seem to think it was synchronous. It's not. Look at the second
sync_file_range() thing, and the important part is the "index-1". The
fact that you confused this with O_SYNC seems to be the same thing.
This has absolutely *nothing* to do with O_SYNC.

The other important part is that the chunk size is fairly large. We do
read-ahead in 64k kind of things, to make sense the write-behind
chunking needs to be in "multiple megabytes".  8MB is probably the
minimum size it makes sense.

The write-behind would be for things like people writing disk images
and video files. Not for random IO in smaller chunks.

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
