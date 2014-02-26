Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0576B6B00B9
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 20:34:31 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so247313pbc.27
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 17:34:31 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:5])
        by mx.google.com with ESMTP id ic5si5392270pbb.258.2014.02.25.17.34.30
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 17:34:31 -0800 (PST)
Date: Wed, 26 Feb 2014 12:34:26 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v5 0/10] fs: Introduce new flag(FALLOC_FL_COLLAPSE_RANGE)
 for fallocate
Message-ID: <20140226013426.GM13647@dastard>
References: <1392741436-19995-1-git-send-email-linkinjeon@gmail.com>
 <20140224005710.GH4317@dastard>
 <20140225141601.358f6e3df2660d4af44da876@canb.auug.org.au>
 <20140225041346.GA29907@dastard>
 <alpine.LSU.2.11.1402251217030.2380@eggly.anvils>
 <20140225154128.947a2de83a2d0dc21763ccf9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140225154128.947a2de83a2d0dc21763ccf9@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Namjae Jeon <linkinjeon@gmail.com>, Matthew Wilcox <matthew@wil.cx>, Theodore Ts'o <tytso@mit.edu>, Stephen Rothwell <sfr@canb.auug.org.au>, viro@zeniv.linux.org.uk, bpm@sgi.com, adilger.kernel@dilger.ca, jack@suse.cz, mtk.manpages@gmail.com, lczerner@redhat.com, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Namjae Jeon <namjae.jeon@samsung.com>

On Tue, Feb 25, 2014 at 03:41:28PM -0800, Andrew Morton wrote:
> On Tue, 25 Feb 2014 15:23:35 -0800 (PST) Hugh Dickins <hughd@google.com> wrote:
> > On Tue, 25 Feb 2014, Dave Chinner wrote:
> > > On Tue, Feb 25, 2014 at 02:16:01PM +1100, Stephen Rothwell wrote:
> > > > On Mon, 24 Feb 2014 11:57:10 +1100 Dave Chinner <david@fromorbit.com> wrote:
> > FALLOC_FL_COLLAPSE_RANGE: I'm a little sad at the name COLLAPSE,
> > but probably seven months too late to object.  It surprises me that
> > you're doing all this work to deflate a part of the file, without
> > the obvious complementary work to inflate it - presumably all those
> > advertisers whose ads you're cutting out, will come back to us soon
> > to ask for inflation, so that they have somewhere to reinsert them ;)
> 
> Yes, I was wondering that.  Why not simply "move these blocks from here
> to there".

And open a completely unnecessary can of worms to do with
behavioural and implementation corner cases?

Do you allow it to destroy data by default? Or only allow moves into
holes?

What do you do with range the data is moved out of? Does it just
become a hole? What happens if the range overlaps EOF - does that
change the file size?

What if you want to move the range beyond EOF?

What if the source and destination ranges overlap?

What happens when you move the block at EOF into the middle of a
file - do you end up with zeros padding the block and the file size
having to be adjusted accordingly? Or do we have to *copy* all the
data in high blocks down to fill the hole in the block?

What behaviour should we expect if the filesystem can't implement
the entire move atomically and we crash in the middle of the move?

I can keep going, but I'll stop here - you get the idea.

In comparison, collapse range as a file data manipulation has very
specific requirements and from that we can define a simple, specific
API that allows filesystems to accelerate that operation by extent
manipulation rather than read/memcpy/write that the applications are
currently doing for this operation....  IOWs, collapse range is a
simple operation, "move arbitrary blocks from here to there" is a
nightmare both from the specification and the implementation points
of view.

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
