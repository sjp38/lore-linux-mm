Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 053FB6B0005
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 08:47:24 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id t28-v6so6179546pfk.21
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 05:47:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m29-v6si10577696pgd.361.2018.10.15.05.47.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 15 Oct 2018 05:47:22 -0700 (PDT)
Date: Mon, 15 Oct 2018 05:47:19 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 07/25] vfs: combine the clone and dedupe into a single
 remap_file_range
Message-ID: <20181015124719.GA15379@infradead.org>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938919123.8361.13059492965161549195.stgit@magnolia>
 <20181014171927.GD30673@infradead.org>
 <CAOQ4uxiReFJRxKJbsoUgWWNP75_Qsoh1fWC_dLYV_zBU_jaGbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxiReFJRxKJbsoUgWWNP75_Qsoh1fWC_dLYV_zBU_jaGbA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Mon, Oct 15, 2018 at 09:04:13AM +0300, Amir Goldstein wrote:
> I supposed you figured out the reason already.

No, I hadn't.

> It makes it appearance in patch 16/25 as RFR_VFS_FLAGS.
> All those "advisory" flags, we want to pass them in to filesystem as FYI,
> but we don't want to explicitly add support for e.g. RFR_CAN_SHORTEN
> to every filesystem, when vfs has already taken care of the advice.

I don't think this model makes sense.  If they really are purely
handled in the VFS we can mask them before passing them to the file
system, if not we need to check them, or the they are avisory and
we can have a simple #define instead of the helper.

RFR_TO_SRC_EOF is checked in generic_remap_file_range_prep,
so the file system should know about it  Also looking at it again now
it seems entirely superflous - we can just pass down then len == we
use in higher level code instead of having a flag and will side step
the issue here.

RFR_CAN_SHORTEN is advisory as no one has to shorten, but that can
easily be solved by including it everywhere.

RFR_SHORT_DEDUPE is as far as I can tell entirely superflous to
start with, as RFR_CAN_SHORTEN can be used instead.

So something like this in fs.h:

#define REMAP_FILE_ADVISORY_FLAGS	REMAP_FILE_CAN_SHORTEN

And then in the file system:

	if (flags & ~REMAP_FILE_ADVISORY_FLAGS)
		-EINVAL;

or

	if (flags & ~(REMAP_FILE_ADVISORY_FLAGS | REMAP_FILE_DEDUP))
		-EINVAL;

should be all that is needed.
