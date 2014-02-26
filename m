Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id A46A46B00B6
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 22:42:37 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so364671pde.13
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 19:42:37 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id tm9si22430835pab.47.2014.02.25.19.42.34
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 19:42:35 -0800 (PST)
Date: Wed, 26 Feb 2014 14:42:30 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 0/10] fs: Introduce new flag(FALLOC_FL_COLLAPSE_RANGE)
 for fallocate
Message-ID: <20140226034230.GO13647@dastard>
References: <1392741436-19995-1-git-send-email-linkinjeon@gmail.com>
 <20140224005710.GH4317@dastard>
 <20140225141601.358f6e3df2660d4af44da876@canb.auug.org.au>
 <20140225041346.GA29907@dastard>
 <alpine.LSU.2.11.1402251217030.2380@eggly.anvils>
 <20140225154128.947a2de83a2d0dc21763ccf9@linux-foundation.org>
 <20140226013426.GM13647@dastard>
 <20140225175216.0f0c10f9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140225175216.0f0c10f9.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Namjae Jeon <linkinjeon@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Theodore Ts'o <tytso@mit.edu>, Stephen Rothwell <sfr@canb.auug.org.au>, viro@zeniv.linux.org.uk, bpm@sgi.com, adilger.kernel@dilger.ca, jack@suse.cz, mtk.manpages@gmail.com, lczerner@redhat.com, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Namjae Jeon <namjae.jeon@samsung.com>

On Tue, Feb 25, 2014 at 05:52:16PM -0800, Andrew Morton wrote:
> On Wed, 26 Feb 2014 12:34:26 +1100 Dave Chinner <david@fromorbit.com> wrote:
> 
> > On Tue, Feb 25, 2014 at 03:41:28PM -0800, Andrew Morton wrote:
> > > On Tue, 25 Feb 2014 15:23:35 -0800 (PST) Hugh Dickins <hughd@google.com> wrote:
> > > > On Tue, 25 Feb 2014, Dave Chinner wrote:
> > > > > On Tue, Feb 25, 2014 at 02:16:01PM +1100, Stephen Rothwell wrote:
> > > > > > On Mon, 24 Feb 2014 11:57:10 +1100 Dave Chinner <david@fromorbit.com> wrote:
> > > > FALLOC_FL_COLLAPSE_RANGE: I'm a little sad at the name COLLAPSE,
> > > > but probably seven months too late to object.  It surprises me that
> > > > you're doing all this work to deflate a part of the file, without
> > > > the obvious complementary work to inflate it - presumably all those
> > > > advertisers whose ads you're cutting out, will come back to us soon
> > > > to ask for inflation, so that they have somewhere to reinsert them ;)
> > > 
> > > Yes, I was wondering that.  Why not simply "move these blocks from here
> > > to there".
> > 
> > And open a completely unnecessary can of worms to do with
> > behavioural and implementation corner cases?
> 
> But it's general.

Exactly. And because it's general, you can't make arbitrary
decisions about the behaviour.

> > Do you allow it to destroy data by default? Or only allow moves into
> > holes?
> 
> Overwrite.

Application dev says: "I don't want it to overwrite data - I only
want to it succeed if it's moving into a hole that I've already
prepared".

> > What do you do with range the data is moved out of? Does it just
> > become a hole? What happens if the range overlaps EOF - does that
> > change the file size?
> 
> Truncate.

A.D. says: "But I need FALLOC_FL_KEEP_SIZE semantics"

> > What if you want to move the range beyond EOF?
> 
> Extend.

Filesystem developer says: "Ok, so what happens to the range between
the old EOF and destintation offset? What do you do with blocks
beyond EOF that fall within that range? punch, zero, preallocate the
entire range? Do users need to be able to specify this behaviour?
Hell, do we even know of an application that requires this
behaviour?"

> > What if the source and destination ranges overlap?
> 
> Don't screw it up.

Exactly my point - it's a complex behaviour that is difficult to
verify that it is correct.

> > What happens when you move the block at EOF into the middle of a
> > file - do you end up with zeros padding the block and the file size
> > having to be adjusted accordingly? Or do we have to *copy* all the
> > data in high blocks down to fill the hole in the block?
> 
> I don't understand that.  Move the block(s) and truncate to the new
> length.

So, you are saying this (move from s to d):

     +-----------------------------------------------------+
                                             +sssssssssssss+
              +ddddddddddddd+

should result in:

     +--------+ddddddddddddd+


A.D. says: "That's not what I asked for! What happened to all the
rest of my data in the file between d and s? I didn't ask for them
to be removed. And I want a hole where the source was!"

> > What behaviour should we expect if the filesystem can't implement
> > the entire move atomically and we crash in the middle of the move?
> 
> What does collapse_range do now?
> 
> If it's a journaled filesystem, it shouldn't screw up.  If it isn't, fsck.

Define "screw up". For journalled filesystems "don't screw up" means
the filesystem will be consistent after a crash, not that a change
made in a syscall is completed atomicly.

Indeed, collapse range isn't implemented atomically in XFS, and I
doubt it is in ext4. Why? Because the extent tree being manipulated
can be *much* larger than the journal and so the changes can't
easily be done atomically from a crash recovery perspective. The
result is that collapse range will end up with a hole somewhere in
the file the size of the range being collapsed. This was pointed out
during review some time in the past 6 months and, IIRC, the response
was "that's fine, just so long as the filesystem is not corrupted".
I have plans to fix this issue in XFS, but it isn't critical to the
correct functioning of devices using collapse range.

This just illustrates my point is that behaviour needs to be
specified so that we can get all filesystems with the same minimum
crash guarantees....

> > I can keep going, but I'll stop here - you get the idea.
> 
> None of this seems like rocket science.

It's not rocket science, but the devil is in the details. There's no
requirements or specification to work from, let alone an application
that needs such generic functionality. Until these exist and there's
someone willing to put the effort into specifying, implementing and
testing such an interface, it's just not going to happen.

> > In comparison, collapse range as a file data manipulation has very
> > specific requirements and from that we can define a simple, specific
> > API that allows filesystems to accelerate that operation by extent
> > manipulation rather than read/memcpy/write that the applications are
> > currently doing for this operation....  IOWs, collapse range is a
> > simple operation, "move arbitrary blocks from here to there" is a
> > nightmare both from the specification and the implementation points
> > of view.
> 
> collapse_range seems weird, arbitrary and half-assed.  "Why didn't they
> go all the way and do it properly".

Yup, I can apply exactly the same argument to FALLOC_FL_PREALLOC and
FALLOC_FL_PUNCH_HOLE. We should have done them as part of a generic
block movement API as they are simply degenerate cases of NULL
source/destination targets for the block movement API....

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
