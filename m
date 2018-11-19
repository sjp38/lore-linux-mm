Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9196D6B19CA
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 04:00:52 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id z68so43589575qkb.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 01:00:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p2si2290298qtq.4.2018.11.19.01.00.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 01:00:51 -0800 (PST)
Date: Mon, 19 Nov 2018 17:00:22 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 14/19] block: enable multipage bvecs
Message-ID: <20181119090021.GL16736@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-15-ming.lei@redhat.com>
 <20181116135308.GK3165@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116135308.GK3165@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Fri, Nov 16, 2018 at 02:53:08PM +0100, Christoph Hellwig wrote:
> > -
> > -		if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len) {
> > -			bv->bv_len += len;
> > -			bio->bi_iter.bi_size += len;
> > -			return true;
> > -		}
> > +		struct request_queue *q = NULL;
> > +
> > +		if (page == bv->bv_page && off == (bv->bv_offset + bv->bv_len)
> > +				&& (off + len) <= PAGE_SIZE)
> 
> How could the page struct be the same, but the range beyond PAGE_SIZE
> (at least with the existing callers)?
> 
> Also no need for the inner btraces, and the && always goes on the
> first line.

OK.

> 
> > +		if (bio->bi_disk)
> > +			q = bio->bi_disk->queue;
> > +
> > +		/* disable multi-page bvec too if cluster isn't enabled */
> > +		if (!q || !blk_queue_cluster(q) ||
> > +		    ((page_to_phys(bv->bv_page) + bv->bv_offset + bv->bv_len) !=
> > +		     (page_to_phys(page) + off)))
> > +			return false;
> > + merge:
> > +		bv->bv_len += len;
> > +		bio->bi_iter.bi_size += len;
> > +		return true;
> 
> Ok, this is scary, as it will give differen results depending on when
> bi_disk is assigned.

It is just merge or not, both can be handled well now.

> But then again we shouldn't really do the cluster
> check here, but rather when splitting the bio for the actual low-level
> driver.

Yeah, I thought of this way too, but it may cause tons of bio split for
no-clustering, and there are quite a few scsi devices which require
to disable clustering.

[linux]$ git grep -n DISABLE_CLUSTERING ./drivers/scsi/ | wc -l
     28

Or we may introduce bio_split_to_single_page_bvec() to allocate &
convert to single-page bvec table for non-clustering, will try this
approach in next version.

> 
> (and eventually we should kill this clustering setting off in favor
> of our normal segment limits).

Yeah, it has been in my post-multi-page todo list already, :-)

thanks,
Ming
