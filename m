Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 597986B000C
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 14:32:08 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a72-v6so5324721pfj.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 11:32:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a3-v6si10905491plp.199.2018.10.15.11.32.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 15 Oct 2018 11:32:07 -0700 (PDT)
Date: Mon, 15 Oct 2018 11:32:04 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 07/25] vfs: combine the clone and dedupe into a single
 remap_file_range
Message-ID: <20181015183204.GB20655@infradead.org>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938919123.8361.13059492965161549195.stgit@magnolia>
 <20181014171927.GD30673@infradead.org>
 <CAOQ4uxiReFJRxKJbsoUgWWNP75_Qsoh1fWC_dLYV_zBU_jaGbA@mail.gmail.com>
 <20181015124719.GA15379@infradead.org>
 <20181015171317.GM28243@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181015171317.GM28243@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Amir Goldstein <amir73il@gmail.com>, Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, linux-cifs@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Btrfs <linux-btrfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, ocfs2-devel@oss.oracle.com

On Mon, Oct 15, 2018 at 10:13:17AM -0700, Darrick J. Wong wrote:
> > RFR_TO_SRC_EOF is checked in generic_remap_file_range_prep,
> > so the file system should know about it  Also looking at it again now
> > it seems entirely superflous - we can just pass down then len == we
> > use in higher level code instead of having a flag and will side step
> > the issue here.
> 
> I'm not a fan of hidden behaviors like that, particularly when we
> already have a flags field where callers can explicitly ask for the
> to-eof behavior.

This just means we have a flag to mean ken is 0 and needs to be filled,
rather than encoding that in the field itself.  If you fell better we
can replace 0 with 0xffffffff and still encode it in the field.

> > RFR_CAN_SHORTEN is advisory as no one has to shorten, but that can
> > easily be solved by including it everywhere.
> 
> CAN_SHORTEN isn't included everywhere

Include it everywhere as in allow it in ever ->remap_file instance.

> I sort of thought about introducing a new copy_file_range flag that
> would just do deduplication and allow for opportunistic "dedup as much
> as you can" but ... meh.  Maybe I'll just drop the patch instead; we can
> revisit that when anyone wants a better dedupe interface.

Sounds fine to me.  The btrfs ioctl is really ugly, but then again
there is no pressing need for something better.
