Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 955806B2B30
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:32:47 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 92so8955785qkx.19
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:32:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c29si1377459qte.8.2018.11.22.02.32.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 02:32:46 -0800 (PST)
Date: Thu, 22 Nov 2018 18:32:09 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V11 14/19] block: handle non-cluster bio out of
 blk_bio_segment_split
Message-ID: <20181122103208.GD27273@ming.t460p>
References: <20181121032327.8434-1-ming.lei@redhat.com>
 <20181121032327.8434-15-ming.lei@redhat.com>
 <20181121143355.GB2594@lst.de>
 <20181121153726.GC19111@ming.t460p>
 <20181121174621.GA6961@lst.de>
 <20181122093259.GA27007@ming.t460p>
 <20181122100427.GA28871@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122100427.GA28871@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 22, 2018 at 11:04:28AM +0100, Christoph Hellwig wrote:
> On Thu, Nov 22, 2018 at 05:33:00PM +0800, Ming Lei wrote:
> > However, using virt boundary limit on non-cluster seems over-kill,
> > because the bio will be over-split(each small bvec may be split as one bio)
> > if it includes lots of small segment.
> 
> The combination of the virt boundary of PAGE_SIZE - 1 and a
> max_segment_size of PAGE_SIZE will only split if the to me merged
> segment is in a different page than the previous one, which is exactly
> what we need here.  Multiple small bvec inside the same page (e.g.
> 512 byte buffer_heads) will still be merged.
> 
> > What we want to do is just to avoid to merge bvecs to segment, which
> > should have been done by NO_SG_MERGE simply. However, after multi-page
> > is enabled, two adjacent bvecs won't be merged any more, I just forget
> > to remove the bvec merge code in V11.
> > 
> > So seems we can simply avoid to use virt boundary limit for non-cluster
> > after multipage bvec is enabled?
> 
> No, we can't just remove it.  As explained in the patch there is one very
> visible difference of setting the flag amd that is no segment will span a
> page boundary, and at least the iSCSI code seems to rely on that.

IMO, we should use queue_segment_boundary() to enhance the rule during splitting
segment after multi-page bvec is enabled.

Seems we miss the segment boundary limit in bvec_split_segs().

Thanks,
Ming
