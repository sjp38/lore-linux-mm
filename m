Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id B9FAD6B19E2
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 04:18:19 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id f22so66982033qkm.11
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 01:18:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l91si1470667qtd.76.2018.11.19.01.18.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 01:18:18 -0800 (PST)
Date: Mon, 19 Nov 2018 17:17:46 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 18/19] block: kill QUEUE_FLAG_NO_SG_MERGE
Message-ID: <20181119091746.GO16736@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-19-ming.lei@redhat.com>
 <20181116021811.GM23828@vader>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116021811.GM23828@vader>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 06:18:11PM -0800, Omar Sandoval wrote:
> On Thu, Nov 15, 2018 at 04:53:05PM +0800, Ming Lei wrote:
> > Since bdced438acd83ad83a6c ("block: setup bi_phys_segments after splitting"),
> > physical segment number is mainly figured out in blk_queue_split() for
> > fast path, and the flag of BIO_SEG_VALID is set there too.
> > 
> > Now only blk_recount_segments() and blk_recalc_rq_segments() use this
> > flag.
> > 
> > Basically blk_recount_segments() is bypassed in fast path given BIO_SEG_VALID
> > is set in blk_queue_split().
> > 
> > For another user of blk_recalc_rq_segments():
> > 
> > - run in partial completion branch of blk_update_request, which is an unusual case
> > 
> > - run in blk_cloned_rq_check_limits(), still not a big problem if the flag is killed
> > since dm-rq is the only user.
> > 
> > Multi-page bvec is enabled now, QUEUE_FLAG_NO_SG_MERGE doesn't make sense any more.
> 
> This commit message wasn't very clear. Is it the case that
> QUEUE_FLAG_NO_SG_MERGE is no longer set by any drivers?

OK, I will add the explanation to commit log in next version.

05f1dd53152173 (block: add queue flag for disabling SG merging) introduces this
flag for NVMe performance purpose only, so that merging to segment can
be bypassed for NVMe.

Actually this optimization was bypassed by 54efd50bfd873e2d (block: make
generic_make_request handle arbitrarily sized bios) and bdced438acd83ad83a6c
("block: setup bi_phys_segments after splitting").

Now segment computation can be very quick, given most of times one bvec
can be thought as one segment, so we can remove the flag.

thanks, 
Ming
