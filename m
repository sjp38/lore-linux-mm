Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 087386B0073
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 18:49:02 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so1614101pdi.7
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 15:49:02 -0800 (PST)
Received: from mail-pb0-x229.google.com (mail-pb0-x229.google.com [2607:f8b0:400e:c01::229])
        by mx.google.com with ESMTPS id yo5si2518911pab.34.2014.02.26.15.49.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Feb 2014 15:49:01 -0800 (PST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so1696918pbb.14
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 15:49:01 -0800 (PST)
Date: Wed, 26 Feb 2014 15:48:07 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v5 1/10] fs: Add new flag(FALLOC_FL_COLLAPSE_RANGE) for
 fallocate
In-Reply-To: <20140226100439.GV13647@dastard>
Message-ID: <alpine.LSU.2.11.1402261511270.2880@eggly.anvils>
References: <1392741464-20029-1-git-send-email-linkinjeon@gmail.com> <20140222140625.GD26637@thunk.org> <20140223213606.GE4317@dastard> <alpine.LSU.2.11.1402251525370.2380@eggly.anvils> <20140226015747.GN13647@dastard> <alpine.LSU.2.11.1402252049250.1586@eggly.anvils>
 <20140226100439.GV13647@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Namjae Jeon <linkinjeon@gmail.com>, viro@zeniv.linux.org.uk, bpm@sgi.com, adilger.kernel@dilger.ca, jack@suse.cz, mtk.manpages@gmail.com, lczerner@redhat.com, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Namjae Jeon <namjae.jeon@samsung.com>, Ashish Sangwan <a.sangwan@samsung.com>

On Wed, 26 Feb 2014, Dave Chinner wrote:
> On Tue, Feb 25, 2014 at 09:25:40PM -0800, Hugh Dickins wrote:
> 
> > But I wasn't really thinking of the offset > i_size case, just the
> > offset + len >= i_size case: which would end with i_size at offset,
> > and the areas you're worried about still beyond EOF - or am I confused?
> 
> Right, offset beyond EOF is just plain daft. But you're not thinking
> of the entire picture. What happens when a system crashes half way
> through a collapse operation? On tmpfs you don't care - everything
> is lost, but on real filesystems we have to care about. 
> 
> offset + len beyond EOF is just truncate(offset).
> 
> From the point of view of an application offloading a data movement
> operation via collapse range, any range that overlaps EOF is wrong -
> data beyond EOF is not accessible and is not available for the
> application to move. Hence EINVAL - it's an invalid set of
> parameters.
> 
> If we do allow it and implement it by block shifting (which,
> technically, is the correct interpretation of the collapse range
> behaviour because it preserves preallocation beyond
> the collapsed region beyond EOF), then we have
> thr problem of moving data blocks below EOF by extent shifting
> before we change the EOF. That exposes blocks of undefined content
> to the user if we crash and recover up to that point of the
> operation. It's just plain dangerous, and if we allow this
> possibility via the API, someone is going to make that mistake in a
> filesystem because it's difficult to test and hard to get right.

Again, I would have thought that this is a problem you are already
having to solve in the case when offset + len is below EOF, with
blocks of undefined content preallocated beyond EOF.

But I don't know xfs, you do: so I accept there may be subtle reasons
why the offset + len below EOF case is easier for you to handle - and
please don't spend your time trying to hammer those into my head!

I think I've been somewhat unreasonable: I insisted in the other
thread that "Collapse is significantly more challenging than either
hole-punch or truncation", so I should give you a break, not demand
that you provide a perfect smooth implementation in all circumstances.

None of our filesystems were designed with this operation in mind,
each may have its own sound reasons to reject those peculiare cases
which would pose more trouble and risk than they are worth.

Whether that should be enforced at the VFS level is anther matter:
if it turns out that the xfs and ext4 limitations match up, okay.

I think we have different preferences, for whether to return error
or success, when there is nothing to be done; but I notice now that
fallocate fails on len 0, so you are being consistent with that.

Reject "offset + len >= i_size" or "offset + len > i_size"?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
