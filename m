Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62CAA6B09D5
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:53:10 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id t130-v6so24618517wmt.3
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:53:10 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id z11si6513840wrw.97.2018.11.16.05.53.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 05:53:09 -0800 (PST)
Date: Fri, 16 Nov 2018 14:53:08 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V10 14/19] block: enable multipage bvecs
Message-ID: <20181116135308.GK3165@lst.de>
References: <20181115085306.9910-1-ming.lei@redhat.com> <20181115085306.9910-15-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-15-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

> -
> -		if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len) {
> -			bv->bv_len += len;
> -			bio->bi_iter.bi_size += len;
> -			return true;
> -		}
> +		struct request_queue *q = NULL;
> +
> +		if (page == bv->bv_page && off == (bv->bv_offset + bv->bv_len)
> +				&& (off + len) <= PAGE_SIZE)

How could the page struct be the same, but the range beyond PAGE_SIZE
(at least with the existing callers)?

Also no need for the inner btraces, and the && always goes on the
first line.

> +		if (bio->bi_disk)
> +			q = bio->bi_disk->queue;
> +
> +		/* disable multi-page bvec too if cluster isn't enabled */
> +		if (!q || !blk_queue_cluster(q) ||
> +		    ((page_to_phys(bv->bv_page) + bv->bv_offset + bv->bv_len) !=
> +		     (page_to_phys(page) + off)))
> +			return false;
> + merge:
> +		bv->bv_len += len;
> +		bio->bi_iter.bi_size += len;
> +		return true;

Ok, this is scary, as it will give differen results depending on when
bi_disk is assigned.  But then again we shouldn't really do the cluster
check here, but rather when splitting the bio for the actual low-level
driver.

(and eventually we should kill this clustering setting off in favor
of our normal segment limits).
