Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E24346B070E
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 21:18:14 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id d11-v6so15818720plo.17
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 18:18:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v191sor32992612pgb.53.2018.11.15.18.18.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Nov 2018 18:18:14 -0800 (PST)
Date: Thu, 15 Nov 2018 18:18:11 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH V10 18/19] block: kill QUEUE_FLAG_NO_SG_MERGE
Message-ID: <20181116021811.GM23828@vader>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-19-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-19-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:53:05PM +0800, Ming Lei wrote:
> Since bdced438acd83ad83a6c ("block: setup bi_phys_segments after splitting"),
> physical segment number is mainly figured out in blk_queue_split() for
> fast path, and the flag of BIO_SEG_VALID is set there too.
> 
> Now only blk_recount_segments() and blk_recalc_rq_segments() use this
> flag.
> 
> Basically blk_recount_segments() is bypassed in fast path given BIO_SEG_VALID
> is set in blk_queue_split().
> 
> For another user of blk_recalc_rq_segments():
> 
> - run in partial completion branch of blk_update_request, which is an unusual case
> 
> - run in blk_cloned_rq_check_limits(), still not a big problem if the flag is killed
> since dm-rq is the only user.
> 
> Multi-page bvec is enabled now, QUEUE_FLAG_NO_SG_MERGE doesn't make sense any more.

This commit message wasn't very clear. Is it the case that
QUEUE_FLAG_NO_SG_MERGE is no longer set by any drivers?
