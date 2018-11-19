Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD5046B197A
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 03:09:25 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id j125so1143065qke.12
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 00:09:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n127si6546243qkf.230.2018.11.19.00.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 00:09:25 -0800 (PST)
Date: Mon, 19 Nov 2018 16:09:00 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V10 07/19] btrfs: use bvec_last_segment to get bio's last
 page
Message-ID: <20181119080854.GD16519@ming.t460p>
References: <20181115085306.9910-1-ming.lei@redhat.com>
 <20181115085306.9910-8-ming.lei@redhat.com>
 <20181116133710.GF3165@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116133710.GF3165@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <dchinner@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, linux-erofs@lists.ozlabs.org, David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org, Boaz Harrosh <ooo@electrozaur.com>, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com

On Fri, Nov 16, 2018 at 02:37:10PM +0100, Christoph Hellwig wrote:
> On Thu, Nov 15, 2018 at 04:52:54PM +0800, Ming Lei wrote:
> > index 2955a4ea2fa8..161e14b8b180 100644
> > --- a/fs/btrfs/compression.c
> > +++ b/fs/btrfs/compression.c
> > @@ -400,8 +400,11 @@ blk_status_t btrfs_submit_compressed_write(struct inode *inode, u64 start,
> >  static u64 bio_end_offset(struct bio *bio)
> >  {
> >  	struct bio_vec *last = bio_last_bvec_all(bio);
> > +	struct bio_vec bv;
> >  
> > -	return page_offset(last->bv_page) + last->bv_len + last->bv_offset;
> > +	bvec_last_segment(last, &bv);
> > +
> > +	return page_offset(bv.bv_page) + bv.bv_len + bv.bv_offset;
> 
> I don't think we need this.  If last is a multi-page bvec bv_offset
> will already contain the correct offset from the first page.

Yeah, it is true for this specific case, looks we can drop this patch.


thanks,
Ming
