Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7046B009B
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 18:42:08 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fa1so132200pad.13
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:42:07 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id iy3si5085378pbb.334.2014.02.25.15.42.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 15:42:07 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so129420pad.22
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:42:06 -0800 (PST)
Date: Tue, 25 Feb 2014 15:41:20 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v5 1/10] fs: Add new flag(FALLOC_FL_COLLAPSE_RANGE) for
 fallocate
In-Reply-To: <20140223213606.GE4317@dastard>
Message-ID: <alpine.LSU.2.11.1402251525370.2380@eggly.anvils>
References: <1392741464-20029-1-git-send-email-linkinjeon@gmail.com> <20140222140625.GD26637@thunk.org> <20140223213606.GE4317@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Namjae Jeon <linkinjeon@gmail.com>, viro@zeniv.linux.org.uk, bpm@sgi.com, adilger.kernel@dilger.ca, jack@suse.cz, mtk.manpages@gmail.com, lczerner@redhat.com, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Namjae Jeon <namjae.jeon@samsung.com>, Ashish Sangwan <a.sangwan@samsung.com>

On Mon, 24 Feb 2014, Dave Chinner wrote:
> On Sat, Feb 22, 2014 at 09:06:25AM -0500, Theodore Ts'o wrote:
> > On Wed, Feb 19, 2014 at 01:37:43AM +0900, Namjae Jeon wrote:
> > > +	/*
> > > +	 * There is no need to overlap collapse range with EOF, in which case
> > > +	 * it is effectively a truncate operation
> > > +	 */
> > > +	if ((mode & FALLOC_FL_COLLAPSE_RANGE) &&
> > > +	    (offset + len >= i_size_read(inode)))
> > > +		return -EINVAL;
> > > +
> > 
> > I wonder if we should just translate a collapse range that is
> > equivalent to a truncate operation to, in fact, be a truncate
> > operation?
> 
> Trying to collapse a range that extends beyond EOF, IMO, is likely
> to only happen if the DVR/NLE application is buggy. Hence I think
> that telling the application it is doing something that is likely to
> be wrong is better than silently truncating the file....

I do agree with Ted on this point.  This is not an xfs ioctl added
for one DVR/NLE application, it's a mode of a Linux system call.

We do not usually reject with an error when one system call happens
to ask for something which can already be accomplished another way;
nor nanny our callers.

It seems natural to me that COLLAPSE_RANGE should support beyond EOF;
unless that adds significantly to implementation difficulties?

Actually, is it even correct to fail at EOF?  What if fallocation
with FALLOC_FL_KEEP_SIZE was used earlier, to allocate beyond EOF:
shouldn't it be possible to shift that allocation down, along with
the EOF, rather than leave it behind as a stranded island?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
