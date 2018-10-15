Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 832336B0006
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 13:13:38 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f4-v6so20899041pff.2
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 10:13:38 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o5-v6si11329557pgk.300.2018.10.15.10.13.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 10:13:37 -0700 (PDT)
Date: Mon, 15 Oct 2018 10:13:17 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 07/25] vfs: combine the clone and dedupe into a single
 remap_file_range
Message-ID: <20181015171317.GM28243@magnolia>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938919123.8361.13059492965161549195.stgit@magnolia>
 <20181014171927.GD30673@infradead.org>
 <CAOQ4uxiReFJRxKJbsoUgWWNP75_Qsoh1fWC_dLYV_zBU_jaGbA@mail.gmail.com>
 <20181015124719.GA15379@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181015124719.GA15379@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Amir Goldstein <amir73il@gmail.com>, Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Mon, Oct 15, 2018 at 05:47:19AM -0700, Christoph Hellwig wrote:
> On Mon, Oct 15, 2018 at 09:04:13AM +0300, Amir Goldstein wrote:
> > I supposed you figured out the reason already.
> 
> No, I hadn't.
> 
> > It makes it appearance in patch 16/25 as RFR_VFS_FLAGS.
> > All those "advisory" flags, we want to pass them in to filesystem as FYI,
> > but we don't want to explicitly add support for e.g. RFR_CAN_SHORTEN
> > to every filesystem, when vfs has already taken care of the advice.
> 
> I don't think this model makes sense.  If they really are purely
> handled in the VFS we can mask them before passing them to the file
> system, if not we need to check them, or the they are avisory and
> we can have a simple #define instead of the helper.
> 
> RFR_TO_SRC_EOF is checked in generic_remap_file_range_prep,
> so the file system should know about it  Also looking at it again now
> it seems entirely superflous - we can just pass down then len == we
> use in higher level code instead of having a flag and will side step
> the issue here.

I'm not a fan of hidden behaviors like that, particularly when we
already have a flags field where callers can explicitly ask for the
to-eof behavior.

> RFR_CAN_SHORTEN is advisory as no one has to shorten, but that can
> easily be solved by including it everywhere.

CAN_SHORTEN isn't included everywhere -- FICLONE{,RANGE} don't enable it
because they have no way to communicate the number of bytes cloned back
to userspace.  Either we can clone every byte the user asked for, or we
send back -EINVAL.  (Maybe I'm misinterpreting what you meant by 'solved
by including it everywhere'?)

> RFR_SHORT_DEDUPE is as far as I can tell entirely superflous to
> start with, as RFR_CAN_SHORTEN can be used instead.

For now it's superfluous.  At first I was thinking that we could return
a short bytes_deduped if, say, the first part of the range actually did
match, but it became pretty obvious via shared/010 that duperemove can't
handle that, so we really must stick to the existing btrfs behavior.

The existing btrfs behavior is that we can round the length down to
avoid deduping partial EOF blocks, but we return the original length
(i.e. lie) in bytes_deduped when we do that.

I sort of thought about introducing a new copy_file_range flag that
would just do deduplication and allow for opportunistic "dedup as much
as you can" but ... meh.  Maybe I'll just drop the patch instead; we can
revisit that when anyone wants a better dedupe interface.

> So something like this in fs.h:
> 
> #define REMAP_FILE_ADVISORY_FLAGS	REMAP_FILE_CAN_SHORTEN
> 
> And then in the file system:
> 
> 	if (flags & ~REMAP_FILE_ADVISORY_FLAGS)
> 		-EINVAL;
> 
> or
> 
> 	if (flags & ~(REMAP_FILE_ADVISORY_FLAGS | REMAP_FILE_DEDUP))
> 		-EINVAL;
> 
> should be all that is needed.

Sounds good to me.

--D
