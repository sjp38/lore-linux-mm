Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6750A6B2B5D
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 06:03:17 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id f3-v6so8645829wme.9
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 03:03:17 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 89si3100557wrk.98.2018.11.22.03.03.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 03:03:16 -0800 (PST)
Date: Thu, 22 Nov 2018 12:03:15 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH V11 12/19] block: allow bio_for_each_segment_all() to
 iterate over multi-page bvec
Message-ID: <20181122110315.GA30369@lst.de>
References: <20181121032327.8434-1-ming.lei@redhat.com> <20181121032327.8434-13-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181121032327.8434-13-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

> +/* used for chunk_for_each_segment */
> +static inline void bvec_next_segment(const struct bio_vec *bvec,
> +				     struct bvec_iter_all *iter_all)

FYI, chunk_for_each_segment doesn't exist anymore, this is
bvec_for_each_segment now.  Not sure the comment helps much, though.

> +{
> +	struct bio_vec *bv = &iter_all->bv;
> +
> +	if (bv->bv_page) {
> +		bv->bv_page += 1;

I think this needs to use nth_page() given that with discontigmem
page structures might not be allocated contigously.
