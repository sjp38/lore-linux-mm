Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3EF6B0991
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 08:37:12 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id x13so45295wro.9
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:37:12 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id g5-v6si25187525wro.40.2018.11.16.05.37.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 05:37:11 -0800 (PST)
Date: Fri, 16 Nov 2018 14:37:10 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V10 07/19] btrfs: use bvec_last_segment to get bio's
 last page
Message-ID: <20181116133710.GF3165@lst.de>
References: <20181115085306.9910-1-ming.lei@redhat.com> <20181115085306.9910-8-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115085306.9910-8-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Thu, Nov 15, 2018 at 04:52:54PM +0800, Ming Lei wrote:
> index 2955a4ea2fa8..161e14b8b180 100644
> --- a/fs/btrfs/compression.c
> +++ b/fs/btrfs/compression.c
> @@ -400,8 +400,11 @@ blk_status_t btrfs_submit_compressed_write(struct inode *inode, u64 start,
>  static u64 bio_end_offset(struct bio *bio)
>  {
>  	struct bio_vec *last = bio_last_bvec_all(bio);
> +	struct bio_vec bv;
>  
> -	return page_offset(last->bv_page) + last->bv_len + last->bv_offset;
> +	bvec_last_segment(last, &bv);
> +
> +	return page_offset(bv.bv_page) + bv.bv_len + bv.bv_offset;

I don't think we need this.  If last is a multi-page bvec bv_offset
will already contain the correct offset from the first page.
