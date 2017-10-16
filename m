Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1CB6B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 17:38:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v2so14100412pfa.10
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 14:38:39 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id b34si3487039pld.702.2017.10.16.14.38.37
        for <linux-mm@kvack.org>;
        Mon, 16 Oct 2017 14:38:38 -0700 (PDT)
Date: Tue, 17 Oct 2017 08:38:11 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: kernel BUG at fs/xfs/xfs_aops.c:853! in kernel 4.13 rc6
Message-ID: <20171016213811.GH15067@dastard>
References: <CABXGCsMorRzy-dJrjTO6sP80BSb0RAeMhF3QGwSkk50m7VYzOA@mail.gmail.com>
 <CABXGCsOeex62Y4qQJwvMJ+fJ+MnKyKGDj9eRbKemeMVWo5huKw@mail.gmail.com>
 <20171009000529.GY3666@dastard>
 <20171009183129.GE11645@wotan.suse.de>
 <87wp442lgm.fsf@xmission.com>
 <8729041d-05e5-6bea-98db-7f265edde193@suse.de>
 <20171015130625.o5k6tk5uflm3rx65@thunk.org>
 <87efq4qcry.fsf@xmission.com>
 <20171015232246.GI3666@dastard>
 <877evvng1q.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <877evvng1q.fsf@xmission.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Aleksa Sarai <asarai@suse.de>, "Luis R. Rodriguez" <mcgrof@kernel.org>, =?utf-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>, Christoph Hellwig <hch@infradead.org>, Jan Blunck <jblunck@infradead.org>, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>, Jan Kara <jack@suse.cz>, Hannes Reinecke <hare@suse.de>, linux-xfs@vger.kernel.org

On Mon, Oct 16, 2017 at 12:44:33PM -0500, Eric W. Biederman wrote:
> Dave Chinner <david@fromorbit.com> writes:
> > On Sun, Oct 15, 2017 at 05:14:41PM -0500, Eric W. Biederman wrote:
> >> So my suggestions for this case are two fold.
> >> 
> >> - Tweak Docker and friends to not be sloppy and hold onto extra
> >>   resources that they don't need.  That is just bad form.
> >> 
> >> - Generalize what ext4, f2fs, xfs and possibly the network filesystems
> >>   with umount_begin are doing into a general disconnect this filesystem
> >>   from it's backing store operation.
> >> 
> >>   That operation should be enough to drop the reference to the backing
> >>   device so that device mapper doesn't care.
> >
> > Define the semantics of a forced filesystem unmount are supposed to
> > be first, then decide whether an existing shutdown operation can be
> > used. It may be we just need a new flag to the existing API to
> > implement slightly different semantics (e.g to silence unnecessary
> > warnings), but at minimum I think we've need the ->unmount_begin op
> > name to change to indicate it's function, not document the calling
> > context...
> 
> Definite the expected semantics of a forced filesystem umount is the
> same process as defining the semantics of a forced filesytem shutdown.
> Look at the code and see what it does and document it.
> 
> That said, a quick skim through the umount_begin methods on network
> filesystems (the only filesystems that implement umount_begin) it
> appears they drop the network connection.  Which is pretty much the same
> as dropping the connection to the bdev.

Sure. But what do they do to incoming attempts to read from the
filesystem, or modify/write it in some way? That behaviour really
isn't defined in any way and what we need to do that so *all
filesystems behave the same way*.

As I've already pointed out, ext4 implements different shutdown
semantics to XFS even though it copied the user API to trigger
shutdowns. That's not an acceptible situation for a generic shutdown
operation....

> So I think there is good reason
> to believe these two cases can be unified.  They may not be exactly the
> same but they are close enough that the should be able to share common
> infrastructure.

You're making it sound so much simpler than it really is...

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
