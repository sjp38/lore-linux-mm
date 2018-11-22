Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id B64E56B2AEC
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:04:30 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id k192so11556198wmd.1
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:04:30 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id i127si3152046wmi.183.2018.11.22.02.04.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 02:04:29 -0800 (PST)
Date: Thu, 22 Nov 2018 11:04:28 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V11 14/19] block: handle non-cluster bio out of
 blk_bio_segment_split
Message-ID: <20181122100427.GA28871@lst.de>
References: <20181121032327.8434-1-ming.lei@redhat.com> <20181121032327.8434-15-ming.lei@redhat.com> <20181121143355.GB2594@lst.de> <20181121153726.GC19111@ming.t460p> <20181121174621.GA6961@lst.de> <20181122093259.GA27007@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122093259.GA27007@ming.t460p>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 22, 2018 at 05:33:00PM +0800, Ming Lei wrote:
> However, using virt boundary limit on non-cluster seems over-kill,
> because the bio will be over-split(each small bvec may be split as one bio)
> if it includes lots of small segment.

The combination of the virt boundary of PAGE_SIZE - 1 and a
max_segment_size of PAGE_SIZE will only split if the to me merged
segment is in a different page than the previous one, which is exactly
what we need here.  Multiple small bvec inside the same page (e.g.
512 byte buffer_heads) will still be merged.

> What we want to do is just to avoid to merge bvecs to segment, which
> should have been done by NO_SG_MERGE simply. However, after multi-page
> is enabled, two adjacent bvecs won't be merged any more, I just forget
> to remove the bvec merge code in V11.
> 
> So seems we can simply avoid to use virt boundary limit for non-cluster
> after multipage bvec is enabled?

No, we can't just remove it.  As explained in the patch there is one very
visible difference of setting the flag amd that is no segment will span a
page boundary, and at least the iSCSI code seems to rely on that.
