Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DDE16B24F1
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 02:45:32 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d17-v6so2609944edv.4
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 23:45:32 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y1-v6si5436220ejh.51.2018.11.20.23.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 23:45:30 -0800 (PST)
Subject: Re: [PATCH V11 17/19] block: document usage of bio iterator helpers
References: <20181121032327.8434-1-ming.lei@redhat.com>
 <20181121032327.8434-18-ming.lei@redhat.com>
From: Nikolay Borisov <nborisov@suse.com>
Message-ID: <1f93e845-09e8-2c6c-3643-654b8c490597@suse.com>
Date: Wed, 21 Nov 2018 09:45:25 +0200
MIME-Version: 1.0
In-Reply-To: <20181121032327.8434-18-ming.lei@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>, Sagi Grimberg <sagi@grimberg.me>, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com



On 21.11.18 D3. 5:23 N?., Ming Lei wrote:
> Now multi-page bvec is supported, some helpers may return page by
> page, meantime some may return segment by segment, this patch
> documents the usage.
> 
> Signed-off-by: Ming Lei <ming.lei@redhat.com>
> ---
>  Documentation/block/biovecs.txt | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
> 
> diff --git a/Documentation/block/biovecs.txt b/Documentation/block/biovecs.txt
> index 25689584e6e0..bb008f7afb05 100644
> --- a/Documentation/block/biovecs.txt
> +++ b/Documentation/block/biovecs.txt
> @@ -117,3 +117,27 @@ Other implications:
>     size limitations and the limitations of the underlying devices. Thus
>     there's no need to define ->merge_bvec_fn() callbacks for individual block
>     drivers.
> +
> +Usage of helpers:
> +=================
> +
> +* The following helpers whose names have the suffix of "_all" can only be used
> +on non-BIO_CLONED bio. They are usually used by filesystem code. Drivers
> +shouldn't use them because the bio may have been split before it reached the
> +driver.
> +
> +	bio_for_each_segment_all()
> +	bio_first_bvec_all()
> +	bio_first_page_all()
> +	bio_last_bvec_all()
> +
> +* The following helpers iterate over single-page bvecs. The passed 'struct
> +bio_vec' will contain a single-page IO vector during the iteration
> +
> +	bio_for_each_segment()
> +	bio_for_each_segment_all()
> +
> +* The following helpers iterate over single-page bvecs. The passed 'struct
> +bio_vec' will contain a single-page IO vector during the iteration
> +
> +	bio_for_each_bvec()

Just put this helper right below the above 2, no need to repeat the
explanation. Also I'd suggest introducing another catch-all sentence
"All other helpers are assumed to iterate multipage bio vecs" and
perhaps give an example with 1-2 helpers.

> 
