Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8606B2AC9
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 04:33:38 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id k90so5774643qte.0
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 01:33:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f10si2908016qvm.149.2018.11.22.01.33.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 01:33:37 -0800 (PST)
Date: Thu, 22 Nov 2018 17:33:00 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V11 14/19] block: handle non-cluster bio out of
 blk_bio_segment_split
Message-ID: <20181122093259.GA27007@ming.t460p>
References: <20181121032327.8434-1-ming.lei@redhat.com>
 <20181121032327.8434-15-ming.lei@redhat.com>
 <20181121143355.GB2594@lst.de>
 <20181121153726.GC19111@ming.t460p>
 <20181121174621.GA6961@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121174621.GA6961@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Wed, Nov 21, 2018 at 06:46:21PM +0100, Christoph Hellwig wrote:
> Actually..
> 
> I think we can kill this code entirely.  If we look at what the
> clustering setting is really about it is to avoid ever merging a
> segement that spans a page boundary.  And we should be able to do
> that with something like this before your series:
> 
> ---
> From 0d46fa76c376493a74ea0dbe77305bd5fa2cf011 Mon Sep 17 00:00:00 2001
> From: Christoph Hellwig <hch@lst.de>
> Date: Wed, 21 Nov 2018 18:39:47 +0100
> Subject: block: remove the "cluster" flag
> 
> The cluster flag implements some very old SCSI behavior.  As far as I
> can tell the original intent was to enable or disable any kind of
> segment merging.  But the actually visible effect to the LLDD is that
> it limits each segments to be inside a single page, which we can
> also affect by setting the maximum segment size and the virt
> boundary.

This approach is pretty good given we can do post-split during mapping
sg.

However, using virt boundary limit on non-cluster seems over-kill,
because the bio will be over-split(each small bvec may be split as one bio)
if it includes lots of small segment.

What we want to do is just to avoid to merge bvecs to segment, which
should have been done by NO_SG_MERGE simply. However, after multi-page
is enabled, two adjacent bvecs won't be merged any more, I just forget
to remove the bvec merge code in V11.

So seems we can simply avoid to use virt boundary limit for non-cluster
after multipage bvec is enabled?


thanks,
Ming
