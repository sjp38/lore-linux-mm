Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BDBC6B2897
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 20:17:32 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w19so5009039qto.13
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 17:17:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j25si12667822qtp.145.2018.11.21.17.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 17:17:31 -0800 (PST)
Date: Thu, 22 Nov 2018 09:17:06 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V11 03/19] block: introduce bio_for_each_bvec()
Message-ID: <20181122011705.GC20814@ming.t460p>
References: <20181121032327.8434-1-ming.lei@redhat.com>
 <20181121032327.8434-4-ming.lei@redhat.com>
 <20181121133244.GB1640@lst.de>
 <20181121153135.GB19111@ming.t460p>
 <20181121161025.GB4977@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121161025.GB4977@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Wed, Nov 21, 2018 at 05:10:25PM +0100, Christoph Hellwig wrote:
> On Wed, Nov 21, 2018 at 11:31:36PM +0800, Ming Lei wrote:
> > > But while looking over this I wonder why we even need the max_seg_len
> > > here.  The only thing __bvec_iter_advance does it to move bi_bvec_done
> > > and bi_idx forward, with corresponding decrements of bi_size.  As far
> > > as I can tell the only thing that max_seg_len does is that we need
> > > to more iterations of the while loop to archive the same thing.
> > > 
> > > And actual bvec used by the caller will be obtained using
> > > bvec_iter_bvec or segment_iter_bvec depending on if they want multi-page
> > > or single-page variants.
> > 
> > Right, we let __bvec_iter_advance() serve for both multi-page and single-page
> > case, then we have to tell it via one way or another, now we use the constant
> > of 'max_seg_len'.
> > 
> > Or you suggest to implement two versions of __bvec_iter_advance()?
> 
> No - I think we can always use the code without any segment in
> bvec_iter_advance.  Because bvec_iter_advance only operates on the
> iteractor, the generation of an actual single-page or multi-page
> bvec is left to the caller using the bvec_iter_bvec or segment_iter_bvec
> helpers.  The only difference is how many bytes you can move the
> iterator forward in a single loop iteration - so if you pass in
> PAGE_SIZE as the max_seg_len you just will have to loop more often
> for a large enough bytes, but not actually do anything different.

Yeah, I see that.

The difference is made by bio_iter_iovec()/bio_iter_mp_iovec() in
__bio_for_each_segment()/__bio_for_each_bvec().


Thanks,
Ming
