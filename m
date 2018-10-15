Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 476D86B000A
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 08:55:00 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id d76-v6so12213241ywb.7
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 05:55:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9-v6sor3555443ybm.52.2018.10.15.05.54.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 05:54:59 -0700 (PDT)
MIME-Version: 1.0
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938919123.8361.13059492965161549195.stgit@magnolia> <20181014171927.GD30673@infradead.org>
 <CAOQ4uxiReFJRxKJbsoUgWWNP75_Qsoh1fWC_dLYV_zBU_jaGbA@mail.gmail.com> <20181015124719.GA15379@infradead.org>
In-Reply-To: <20181015124719.GA15379@infradead.org>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 15 Oct 2018 15:54:47 +0300
Message-ID: <CAOQ4uxi7AuNHapyfkLYDSjkZAiDsZFUiPDDWTgGJJSEcOOtaPg@mail.gmail.com>
Subject: Re: [PATCH 07/25] vfs: combine the clone and dedupe into a single remap_file_range
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Mon, Oct 15, 2018 at 3:47 PM Christoph Hellwig <hch@infradead.org> wrote:
>
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
>
> RFR_CAN_SHORTEN is advisory as no one has to shorten, but that can
> easily be solved by including it everywhere.
>
> RFR_SHORT_DEDUPE is as far as I can tell entirely superflous to
> start with, as RFR_CAN_SHORTEN can be used instead.
>
> So something like this in fs.h:
>
> #define REMAP_FILE_ADVISORY_FLAGS       REMAP_FILE_CAN_SHORTEN
>
> And then in the file system:
>
>         if (flags & ~REMAP_FILE_ADVISORY_FLAGS)
>                 -EINVAL;
>
> or
>
>         if (flags & ~(REMAP_FILE_ADVISORY_FLAGS | REMAP_FILE_DEDUP))
>                 -EINVAL;
>
> should be all that is needed.

Yeh, I suppose that makes sense.

Thanks,
Amir.
