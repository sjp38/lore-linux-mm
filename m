Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 224F8C10F12
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 15:00:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8877B20880
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 15:00:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8877B20880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA92E6B0003; Mon, 15 Apr 2019 10:59:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E575E6B0006; Mon, 15 Apr 2019 10:59:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFAB86B0007; Mon, 15 Apr 2019 10:59:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 568F06B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 10:59:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o8so8502415edh.12
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 07:59:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=19wGmuSKrBtislisaDjfaBToWJ+W3BRVHB2FuaF+CkI=;
        b=gghE+eKYEei1Kw7DNNsh1IEYPZgvHntjRXWGoMmkNnSQGYt2HZrcALk2NgG4d0WmHe
         tpEOT2djg/eAZLz6UinNHfs8om5Q3F8k9RJ6EXovN3l/kz+LDigu/ajjbGTzX3UECz0Q
         9vNXWatSjTGTbqY9d5ebRNPlXEwGf29fVBT2spiGWgwCaGObESF4pXhzETDsrZ1+do2I
         0DKQopTVBDXPo3X6oy4rDQV+MltS6lqZAE/xRBzMpkUSVXed+u804It8kKlyJufLmwEO
         ozu/DIEIA4YTdJvUjmlMB7k7NcAUJAoCS7AoZK7ackwNoqgbTbSFfgjI9eHdXP4r9mYh
         a9Jg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAVQlspvAJYQkqppwfAbzDQ90DWB7yyFCFSIx00ufCkcENPuJboN
	H2shAVPVxqSG0nwzOIEzgGHCB0lyvdHXSpDc/Yc1NevfVIJo5S7IejMvlTYcuYjCp5YgM0NdNwG
	+81yo9r8Q2Fe/2TxaHentfu08HyPFWwtDsSwxFtjQFmkYN0G1YdjPwfKZwYLN2Qb2Tg==
X-Received: by 2002:a50:ad83:: with SMTP id a3mr46242073edd.21.1555340398648;
        Mon, 15 Apr 2019 07:59:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRvheokMcDB87VKXgeg68izlRjGElaP8h2j9rXFJzcTMaeAtX97wzsuDasrbtXy3YBOyWw
X-Received: by 2002:a50:ad83:: with SMTP id a3mr46241947edd.21.1555340396303;
        Mon, 15 Apr 2019 07:59:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555340396; cv=none;
        d=google.com; s=arc-20160816;
        b=BElTj7wwobhWJwq03q3RX1cR2DG8PIrNwBYTDITmhnUuxnIuSMnxF/mvjDmTVZ80U9
         jSu0C71x10c7gHBRkthpHvMyodzxjbVU45W2bdldSaHzwiH+g7CYQjb7/Xzrw3Pxg+wz
         F1ur4I1WdmGlzLxCvRnSbXUNpqG+xzhABRgXm4+jAY+ER6NsJwso09xPFaSRBonRGzc1
         lMCb9YU4NH3ICsM/6qMQDB3xPaKnEigtoimpD2VjlaVF9y1K8W7KYcWxFrObzE8MBfxL
         t5s59v/Lq1VujhHIM3r+mnqnepzknuhgJnVkqcBcZi5mNUvFfPi4ssRJ+o3w+lH8W0zE
         t0HA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=19wGmuSKrBtislisaDjfaBToWJ+W3BRVHB2FuaF+CkI=;
        b=fYkIYzElv85OCJwBwVBYHTOJFwfTSXI8cxm6o3DsDi1wdc+CIfnzJpDiqTp/wLOjML
         lwGxAivkBedrW0NCNxSMZP6poYLf6+FkT0IxPhGRkW1ErkbTDRFCC7R/mdqKUrZKYMC2
         szeZ2gPvZCERORvRoJjiulCEZZEFrxqtYANxk3GGUltPrD1Agr2ecYybFlzMFfY1Mn4f
         CJ3XkH45gWI9ClZtAk94hqLLwIs5x8BGixCOpa+OOt/T56RCT3kMT6KwmZkT1xqUbs5P
         G3TlW4lQmRp9CgAoEquwA5erB79ikIeqOGSBjpojYcumcCZMr9iiFEIIBxjPi8KYZBxA
         8Dmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si273532eds.357.2019.04.15.07.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 07:59:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4974AAEF9;
	Mon, 15 Apr 2019 14:59:55 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id AF7F01E09F9; Mon, 15 Apr 2019 16:59:52 +0200 (CEST)
Date: Mon, 15 Apr 2019 16:59:52 +0200
From: Jan Kara <jack@suse.cz>
To: jglisse@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-mm@kvack.org,
	John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1 10/15] block: add gup flag to
 bio_add_page()/bio_add_pc_page()/__bio_add_page()
Message-ID: <20190415145952.GE13684@quack2.suse.cz>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <20190411210834.4105-11-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190411210834.4105-11-jglisse@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jerome!

On Thu 11-04-19 17:08:29, jglisse@redhat.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> We want to keep track of how we got a reference on page added to bio_vec
> ie wether the page was reference through GUP (get_user_page*) or not. So
> add a flag to bio_add_page()/bio_add_pc_page()/__bio_add_page() to that
> effect.

Thanks for writing this patch set! Looking through patches like this one,
I'm a bit concerned. With so many bio_add_page() callers it's difficult to
get things right and not regress in the future. I'm wondering whether the
things won't be less error-prone if we required that all page reference
from bio are gup-like (not necessarily taken by GUP, if creator of the bio
gets to struct page he needs via some other means (e.g. page cache lookup),
he could just use get_gup_pin() helper we'd provide).  After all, a page
reference in bio means that the page is pinned for the duration of IO and
can be DMAed to/from so it even makes some sense to track the reference
like that. Then bio_put() would just unconditionally do put_user_page() and
we won't have to propagate the information in the bio.

Do you think this would be workable and easier?

								Honza

> 
> This is done using a coccinelle patch and running it with:
> 
> spatch --sp-file spfile --in-place --include-headers --dir .
> 
> with spfile:
> %<---------------------------------------------------------------------
> @@
> identifier I1, I2, I3, I4;
> @@
> void __bio_add_page(struct bio *I1, struct page *I2, unsigned I3,
> unsigned I4
> +, bool is_gup
>  ) {...}
> 
> @@
> identifier I1, I2, I3, I4;
> @@
> void __bio_add_page(struct bio *I1, struct page *I2, unsigned I3,
> unsigned I4
> +, bool is_gup
>  );
> 
> @@
> identifier I1, I2, I3, I4;
> @@
> int bio_add_page(struct bio *I1, struct page *I2, unsigned I3,
> unsigned I4
> +, bool is_gup
>  ) {...}
> 
> @@
> @@
> int bio_add_page(struct bio *, struct page *, unsigned, unsigned
> +, bool is_gup
>  );
> 
> @@
> identifier I1, I2, I3, I4, I5;
> @@
> int bio_add_pc_page(struct request_queue *I1, struct bio *I2,
> struct page *I3, unsigned I4, unsigned I5
> +, bool is_gup
>  ) {...}
> 
> @@
> @@
> int bio_add_pc_page(struct request_queue *, struct bio *,
> struct page *, unsigned, unsigned
> +, bool is_gup
>  );
> 
> @@
> expression E1, E2, E3, E4;
> @@
> __bio_add_page(E1, E2, E3, E4
> +, false
>  )
> 
> @@
> expression E1, E2, E3, E4;
> @@
> bio_add_page(E1, E2, E3, E4
> +, false
>  )
> 
> @@
> expression E1, E2, E3, E4, E5;
> @@
> bio_add_pc_page(E1, E2, E3, E4, E5
> +, false
>  )
> --------------------------------------------------------------------->%
> 
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Cc: linux-fsdevel@vger.kernel.org
> Cc: linux-block@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Johannes Thumshirn <jthumshirn@suse.de>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Ming Lei <ming.lei@redhat.com>
> Cc: Dave Chinner <david@fromorbit.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Matthew Wilcox <willy@infradead.org>
> ---
>  block/bio.c                         | 20 ++++++++++----------
>  block/blk-lib.c                     |  3 ++-
>  drivers/block/drbd/drbd_actlog.c    |  2 +-
>  drivers/block/drbd/drbd_bitmap.c    |  2 +-
>  drivers/block/drbd/drbd_receiver.c  |  2 +-
>  drivers/block/floppy.c              |  2 +-
>  drivers/block/pktcdvd.c             |  4 ++--
>  drivers/block/xen-blkback/blkback.c |  2 +-
>  drivers/block/zram/zram_drv.c       |  4 ++--
>  drivers/lightnvm/core.c             |  2 +-
>  drivers/lightnvm/pblk-core.c        |  5 +++--
>  drivers/lightnvm/pblk-rb.c          |  2 +-
>  drivers/md/dm-bufio.c               |  2 +-
>  drivers/md/dm-crypt.c               |  2 +-
>  drivers/md/dm-io.c                  |  5 +++--
>  drivers/md/dm-log-writes.c          |  8 ++++----
>  drivers/md/dm-writecache.c          |  3 ++-
>  drivers/md/dm-zoned-metadata.c      |  6 +++---
>  drivers/md/md.c                     |  4 ++--
>  drivers/md/raid1-10.c               |  2 +-
>  drivers/md/raid1.c                  |  4 ++--
>  drivers/md/raid10.c                 |  4 ++--
>  drivers/md/raid5-cache.c            |  7 ++++---
>  drivers/md/raid5-ppl.c              |  6 +++---
>  drivers/nvme/target/io-cmd-bdev.c   |  2 +-
>  drivers/staging/erofs/data.c        |  4 ++--
>  drivers/staging/erofs/unzip_vle.c   |  2 +-
>  drivers/target/target_core_iblock.c |  4 ++--
>  drivers/target/target_core_pscsi.c  |  2 +-
>  fs/btrfs/check-integrity.c          |  2 +-
>  fs/btrfs/compression.c              | 10 +++++-----
>  fs/btrfs/extent_io.c                |  8 ++++----
>  fs/btrfs/raid56.c                   |  4 ++--
>  fs/btrfs/scrub.c                    | 10 +++++-----
>  fs/buffer.c                         |  2 +-
>  fs/crypto/bio.c                     |  2 +-
>  fs/direct-io.c                      |  2 +-
>  fs/ext4/page-io.c                   |  2 +-
>  fs/ext4/readpage.c                  |  2 +-
>  fs/f2fs/data.c                      | 10 +++++-----
>  fs/gfs2/lops.c                      |  4 ++--
>  fs/gfs2/meta_io.c                   |  2 +-
>  fs/gfs2/ops_fstype.c                |  2 +-
>  fs/hfsplus/wrapper.c                |  3 ++-
>  fs/iomap.c                          |  6 +++---
>  fs/jfs/jfs_logmgr.c                 |  4 ++--
>  fs/jfs/jfs_metapage.c               |  6 +++---
>  fs/mpage.c                          |  4 ++--
>  fs/nfs/blocklayout/blocklayout.c    |  2 +-
>  fs/nilfs2/segbuf.c                  |  3 ++-
>  fs/ocfs2/cluster/heartbeat.c        |  2 +-
>  fs/xfs/xfs_aops.c                   |  2 +-
>  fs/xfs/xfs_buf.c                    |  2 +-
>  include/linux/bio.h                 |  7 ++++---
>  kernel/power/swap.c                 |  2 +-
>  mm/page_io.c                        |  2 +-
>  56 files changed, 116 insertions(+), 108 deletions(-)
> 
> diff --git a/block/bio.c b/block/bio.c
> index efd254c90974..73227ede9a0a 100644
> --- a/block/bio.c
> +++ b/block/bio.c
> @@ -663,7 +663,7 @@ EXPORT_SYMBOL(bio_clone_fast);
>   *	This should only be used by REQ_PC bios.
>   */
>  int bio_add_pc_page(struct request_queue *q, struct bio *bio, struct page
> -		    *page, unsigned int len, unsigned int offset)
> +		    *page, unsigned int len, unsigned int offset, bool is_gup)
>  {
>  	int retried_segments = 0;
>  	struct bio_vec *bvec;
> @@ -798,7 +798,7 @@ EXPORT_SYMBOL_GPL(__bio_try_merge_page);
>   * that @bio has space for another bvec.
>   */
>  void __bio_add_page(struct bio *bio, struct page *page,
> -		unsigned int len, unsigned int off)
> +		unsigned int len, unsigned int off, bool is_gup)
>  {
>  	struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt];
>  
> @@ -825,12 +825,12 @@ EXPORT_SYMBOL_GPL(__bio_add_page);
>   *	if either bio->bi_vcnt == bio->bi_max_vecs or it's a cloned bio.
>   */
>  int bio_add_page(struct bio *bio, struct page *page,
> -		 unsigned int len, unsigned int offset)
> +		 unsigned int len, unsigned int offset, bool is_gup)
>  {
>  	if (!__bio_try_merge_page(bio, page, len, offset, false)) {
>  		if (bio_full(bio))
>  			return 0;
> -		__bio_add_page(bio, page, len, offset);
> +		__bio_add_page(bio, page, len, offset, false);
>  	}
>  	return len;
>  }
> @@ -847,7 +847,7 @@ static int __bio_iov_bvec_add_pages(struct bio *bio, struct iov_iter *iter)
>  
>  	len = min_t(size_t, bv->bv_len - iter->iov_offset, iter->count);
>  	size = bio_add_page(bio, bvec_page(bv), len,
> -				bv->bv_offset + iter->iov_offset);
> +				bv->bv_offset + iter->iov_offset, false);
>  	if (size == len) {
>  		if (!bio_flagged(bio, BIO_NO_PAGE_REF)) {
>  			struct page *page;
> @@ -902,7 +902,7 @@ static int __bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter)
>  		struct page *page = pages[i];
>  
>  		len = min_t(size_t, PAGE_SIZE - offset, left);
> -		if (WARN_ON_ONCE(bio_add_page(bio, page, len, offset) != len))
> +		if (WARN_ON_ONCE(bio_add_page(bio, page, len, offset, false) != len))
>  			return -EINVAL;
>  		offset = 0;
>  	}
> @@ -1298,7 +1298,7 @@ struct bio *bio_copy_user_iov(struct request_queue *q,
>  			}
>  		}
>  
> -		if (bio_add_pc_page(q, bio, page, bytes, offset) < bytes) {
> +		if (bio_add_pc_page(q, bio, page, bytes, offset, false) < bytes) {
>  			if (!map_data)
>  				__free_page(page);
>  			break;
> @@ -1393,7 +1393,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
>  				if (n > bytes)
>  					n = bytes;
>  
> -				if (!bio_add_pc_page(q, bio, page, n, offs))
> +				if (!bio_add_pc_page(q, bio, page, n, offs, false))
>  					break;
>  
>  				/*
> @@ -1509,7 +1509,7 @@ struct bio *bio_map_kern(struct request_queue *q, void *data, unsigned int len,
>  			bytes = len;
>  
>  		if (bio_add_pc_page(q, bio, virt_to_page(data), bytes,
> -				    offset) < bytes) {
> +				    offset, false) < bytes) {
>  			/* we don't support partial mappings */
>  			bio_put(bio);
>  			return ERR_PTR(-EINVAL);
> @@ -1592,7 +1592,7 @@ struct bio *bio_copy_kern(struct request_queue *q, void *data, unsigned int len,
>  		if (!reading)
>  			memcpy(page_address(page), p, bytes);
>  
> -		if (bio_add_pc_page(q, bio, page, bytes, 0) < bytes)
> +		if (bio_add_pc_page(q, bio, page, bytes, 0, false) < bytes)
>  			break;
>  
>  		len -= bytes;
> diff --git a/block/blk-lib.c b/block/blk-lib.c
> index 02a0b398566d..0ccb8ea980f5 100644
> --- a/block/blk-lib.c
> +++ b/block/blk-lib.c
> @@ -289,7 +289,8 @@ static int __blkdev_issue_zero_pages(struct block_device *bdev,
>  
>  		while (nr_sects != 0) {
>  			sz = min((sector_t) PAGE_SIZE, nr_sects << 9);
> -			bi_size = bio_add_page(bio, ZERO_PAGE(0), sz, 0);
> +			bi_size = bio_add_page(bio, ZERO_PAGE(0), sz, 0,
> +					       false);
>  			nr_sects -= bi_size >> 9;
>  			sector += bi_size >> 9;
>  			if (bi_size < sz)
> diff --git a/drivers/block/drbd/drbd_actlog.c b/drivers/block/drbd/drbd_actlog.c
> index 5f0eaee8c8a7..532c783667c2 100644
> --- a/drivers/block/drbd/drbd_actlog.c
> +++ b/drivers/block/drbd/drbd_actlog.c
> @@ -154,7 +154,7 @@ static int _drbd_md_sync_page_io(struct drbd_device *device,
>  	bio_set_dev(bio, bdev->md_bdev);
>  	bio->bi_iter.bi_sector = sector;
>  	err = -EIO;
> -	if (bio_add_page(bio, device->md_io.page, size, 0) != size)
> +	if (bio_add_page(bio, device->md_io.page, size, 0, false) != size)
>  		goto out;
>  	bio->bi_private = device;
>  	bio->bi_end_io = drbd_md_endio;
> diff --git a/drivers/block/drbd/drbd_bitmap.c b/drivers/block/drbd/drbd_bitmap.c
> index e567bc234781..558c331342f1 100644
> --- a/drivers/block/drbd/drbd_bitmap.c
> +++ b/drivers/block/drbd/drbd_bitmap.c
> @@ -1024,7 +1024,7 @@ static void bm_page_io_async(struct drbd_bm_aio_ctx *ctx, int page_nr) __must_ho
>  	bio->bi_iter.bi_sector = on_disk_sector;
>  	/* bio_add_page of a single page to an empty bio will always succeed,
>  	 * according to api.  Do we want to assert that? */
> -	bio_add_page(bio, page, len, 0);
> +	bio_add_page(bio, page, len, 0, false);
>  	bio->bi_private = ctx;
>  	bio->bi_end_io = drbd_bm_endio;
>  	bio_set_op_attrs(bio, op, 0);
> diff --git a/drivers/block/drbd/drbd_receiver.c b/drivers/block/drbd/drbd_receiver.c
> index ee7c77445456..802565c28905 100644
> --- a/drivers/block/drbd/drbd_receiver.c
> +++ b/drivers/block/drbd/drbd_receiver.c
> @@ -1716,7 +1716,7 @@ int drbd_submit_peer_request(struct drbd_device *device,
>  
>  	page_chain_for_each(page) {
>  		unsigned len = min_t(unsigned, data_size, PAGE_SIZE);
> -		if (!bio_add_page(bio, page, len, 0))
> +		if (!bio_add_page(bio, page, len, 0, false))
>  			goto next_bio;
>  		data_size -= len;
>  		sector += len >> 9;
> diff --git a/drivers/block/floppy.c b/drivers/block/floppy.c
> index 6201106cb7e3..11e77f88ac39 100644
> --- a/drivers/block/floppy.c
> +++ b/drivers/block/floppy.c
> @@ -4131,7 +4131,7 @@ static int __floppy_read_block_0(struct block_device *bdev, int drive)
>  
>  	bio_init(&bio, &bio_vec, 1);
>  	bio_set_dev(&bio, bdev);
> -	bio_add_page(&bio, page, size, 0);
> +	bio_add_page(&bio, page, size, 0, false);
>  
>  	bio.bi_iter.bi_sector = 0;
>  	bio.bi_flags |= (1 << BIO_QUIET);
> diff --git a/drivers/block/pktcdvd.c b/drivers/block/pktcdvd.c
> index f5a71023f76c..cb5b9b4a7091 100644
> --- a/drivers/block/pktcdvd.c
> +++ b/drivers/block/pktcdvd.c
> @@ -1037,7 +1037,7 @@ static void pkt_gather_data(struct pktcdvd_device *pd, struct packet_data *pkt)
>  		offset = (f * CD_FRAMESIZE) % PAGE_SIZE;
>  		pkt_dbg(2, pd, "Adding frame %d, page:%p offs:%d\n",
>  			f, pkt->pages[p], offset);
> -		if (!bio_add_page(bio, pkt->pages[p], CD_FRAMESIZE, offset))
> +		if (!bio_add_page(bio, pkt->pages[p], CD_FRAMESIZE, offset, false))
>  			BUG();
>  
>  		atomic_inc(&pkt->io_wait);
> @@ -1277,7 +1277,7 @@ static void pkt_start_write(struct pktcdvd_device *pd, struct packet_data *pkt)
>  		struct page *page = pkt->pages[(f * CD_FRAMESIZE) / PAGE_SIZE];
>  		unsigned offset = (f * CD_FRAMESIZE) % PAGE_SIZE;
>  
> -		if (!bio_add_page(pkt->w_bio, page, CD_FRAMESIZE, offset))
> +		if (!bio_add_page(pkt->w_bio, page, CD_FRAMESIZE, offset, false))
>  			BUG();
>  	}
>  	pkt_dbg(2, pd, "vcnt=%d\n", pkt->w_bio->bi_vcnt);
> diff --git a/drivers/block/xen-blkback/blkback.c b/drivers/block/xen-blkback/blkback.c
> index fd1e19f1a49f..886e2e3202a7 100644
> --- a/drivers/block/xen-blkback/blkback.c
> +++ b/drivers/block/xen-blkback/blkback.c
> @@ -1362,7 +1362,7 @@ static int dispatch_rw_block_io(struct xen_blkif_ring *ring,
>  		       (bio_add_page(bio,
>  				     pages[i]->page,
>  				     seg[i].nsec << 9,
> -				     seg[i].offset) == 0)) {
> +				     seg[i].offset, false) == 0)) {
>  
>  			int nr_iovecs = min_t(int, (nseg-i), BIO_MAX_PAGES);
>  			bio = bio_alloc(GFP_KERNEL, nr_iovecs);
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 04fb864b16f5..a0734408db2f 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -596,7 +596,7 @@ static int read_from_bdev_async(struct zram *zram, struct bio_vec *bvec,
>  
>  	bio->bi_iter.bi_sector = entry * (PAGE_SIZE >> 9);
>  	bio_set_dev(bio, zram->bdev);
> -	if (!bio_add_page(bio, bvec_page(bvec), bvec->bv_len, bvec->bv_offset)) {
> +	if (!bio_add_page(bio, bvec_page(bvec), bvec->bv_len, bvec->bv_offset, false)) {
>  		bio_put(bio);
>  		return -EIO;
>  	}
> @@ -713,7 +713,7 @@ static ssize_t writeback_store(struct device *dev,
>  		bio.bi_opf = REQ_OP_WRITE | REQ_SYNC;
>  
>  		bio_add_page(&bio, bvec_page(&bvec), bvec.bv_len,
> -				bvec.bv_offset);
> +				bvec.bv_offset, false);
>  		/*
>  		 * XXX: A single page IO would be inefficient for write
>  		 * but it would be not bad as starter.
> diff --git a/drivers/lightnvm/core.c b/drivers/lightnvm/core.c
> index 5f82036fe322..cc08485dc36a 100644
> --- a/drivers/lightnvm/core.c
> +++ b/drivers/lightnvm/core.c
> @@ -807,7 +807,7 @@ static int nvm_bb_chunk_sense(struct nvm_dev *dev, struct ppa_addr ppa)
>  		return -ENOMEM;
>  
>  	bio_init(&bio, &bio_vec, 1);
> -	bio_add_page(&bio, page, PAGE_SIZE, 0);
> +	bio_add_page(&bio, page, PAGE_SIZE, 0, false);
>  	bio_set_op_attrs(&bio, REQ_OP_READ, 0);
>  
>  	rqd.bio = &bio;
> diff --git a/drivers/lightnvm/pblk-core.c b/drivers/lightnvm/pblk-core.c
> index 6ddb1e8a7223..2f374275b638 100644
> --- a/drivers/lightnvm/pblk-core.c
> +++ b/drivers/lightnvm/pblk-core.c
> @@ -344,7 +344,8 @@ int pblk_bio_add_pages(struct pblk *pblk, struct bio *bio, gfp_t flags,
>  	for (i = 0; i < nr_pages; i++) {
>  		page = mempool_alloc(&pblk->page_bio_pool, flags);
>  
> -		ret = bio_add_pc_page(q, bio, page, PBLK_EXPOSED_PAGE_SIZE, 0);
> +		ret = bio_add_pc_page(q, bio, page, PBLK_EXPOSED_PAGE_SIZE, 0,
> +				      false);
>  		if (ret != PBLK_EXPOSED_PAGE_SIZE) {
>  			pblk_err(pblk, "could not add page to bio\n");
>  			mempool_free(page, &pblk->page_bio_pool);
> @@ -605,7 +606,7 @@ struct bio *pblk_bio_map_addr(struct pblk *pblk, void *data,
>  			goto out;
>  		}
>  
> -		ret = bio_add_pc_page(dev->q, bio, page, PAGE_SIZE, 0);
> +		ret = bio_add_pc_page(dev->q, bio, page, PAGE_SIZE, 0, false);
>  		if (ret != PAGE_SIZE) {
>  			pblk_err(pblk, "could not add page to bio\n");
>  			bio_put(bio);
> diff --git a/drivers/lightnvm/pblk-rb.c b/drivers/lightnvm/pblk-rb.c
> index 03c241b340ea..986d9d308176 100644
> --- a/drivers/lightnvm/pblk-rb.c
> +++ b/drivers/lightnvm/pblk-rb.c
> @@ -596,7 +596,7 @@ unsigned int pblk_rb_read_to_bio(struct pblk_rb *rb, struct nvm_rq *rqd,
>  			return NVM_IO_ERR;
>  		}
>  
> -		if (bio_add_pc_page(q, bio, page, rb->seg_size, 0) !=
> +		if (bio_add_pc_page(q, bio, page, rb->seg_size, 0, false) !=
>  								rb->seg_size) {
>  			pblk_err(pblk, "could not add page to write bio\n");
>  			flags &= ~PBLK_WRITTEN_DATA;
> diff --git a/drivers/md/dm-bufio.c b/drivers/md/dm-bufio.c
> index 1ecef76225a1..4c77e2a7c2d8 100644
> --- a/drivers/md/dm-bufio.c
> +++ b/drivers/md/dm-bufio.c
> @@ -598,7 +598,7 @@ static void use_bio(struct dm_buffer *b, int rw, sector_t sector,
>  	do {
>  		unsigned this_step = min((unsigned)(PAGE_SIZE - offset_in_page(ptr)), len);
>  		if (!bio_add_page(bio, virt_to_page(ptr), this_step,
> -				  offset_in_page(ptr))) {
> +				  offset_in_page(ptr), false)) {
>  			bio_put(bio);
>  			goto dmio;
>  		}
> diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
> index ef7896c50814..29006bdc6753 100644
> --- a/drivers/md/dm-crypt.c
> +++ b/drivers/md/dm-crypt.c
> @@ -1429,7 +1429,7 @@ static struct bio *crypt_alloc_buffer(struct dm_crypt_io *io, unsigned size)
>  
>  		len = (remaining_size > PAGE_SIZE) ? PAGE_SIZE : remaining_size;
>  
> -		bio_add_page(clone, page, len, 0);
> +		bio_add_page(clone, page, len, 0, false);
>  
>  		remaining_size -= len;
>  	}
> diff --git a/drivers/md/dm-io.c b/drivers/md/dm-io.c
> index 81a346f9de17..1d47565b49c3 100644
> --- a/drivers/md/dm-io.c
> +++ b/drivers/md/dm-io.c
> @@ -361,7 +361,8 @@ static void do_region(int op, int op_flags, unsigned region,
>  			 * WRITE SAME only uses a single page.
>  			 */
>  			dp->get_page(dp, &page, &len, &offset);
> -			bio_add_page(bio, page, logical_block_size, offset);
> +			bio_add_page(bio, page, logical_block_size, offset,
> +				     false);
>  			num_sectors = min_t(sector_t, special_cmd_max_sectors, remaining);
>  			bio->bi_iter.bi_size = num_sectors << SECTOR_SHIFT;
>  
> @@ -374,7 +375,7 @@ static void do_region(int op, int op_flags, unsigned region,
>  			 */
>  			dp->get_page(dp, &page, &len, &offset);
>  			len = min(len, to_bytes(remaining));
> -			if (!bio_add_page(bio, page, len, offset))
> +			if (!bio_add_page(bio, page, len, offset, false))
>  				break;
>  
>  			offset = 0;
> diff --git a/drivers/md/dm-log-writes.c b/drivers/md/dm-log-writes.c
> index e403fcb5c30a..4d42de63c85e 100644
> --- a/drivers/md/dm-log-writes.c
> +++ b/drivers/md/dm-log-writes.c
> @@ -234,7 +234,7 @@ static int write_metadata(struct log_writes_c *lc, void *entry,
>  	       lc->sectorsize - entrylen - datalen);
>  	kunmap_atomic(ptr);
>  
> -	ret = bio_add_page(bio, page, lc->sectorsize, 0);
> +	ret = bio_add_page(bio, page, lc->sectorsize, 0, false);
>  	if (ret != lc->sectorsize) {
>  		DMERR("Couldn't add page to the log block");
>  		goto error_bio;
> @@ -294,7 +294,7 @@ static int write_inline_data(struct log_writes_c *lc, void *entry,
>  				memset(ptr + pg_datalen, 0, pg_sectorlen - pg_datalen);
>  			kunmap_atomic(ptr);
>  
> -			ret = bio_add_page(bio, page, pg_sectorlen, 0);
> +			ret = bio_add_page(bio, page, pg_sectorlen, 0, false);
>  			if (ret != pg_sectorlen) {
>  				DMERR("Couldn't add page of inline data");
>  				__free_page(page);
> @@ -371,7 +371,7 @@ static int log_one_block(struct log_writes_c *lc,
>  		 * for every bvec in the original bio for simplicity sake.
>  		 */
>  		ret = bio_add_page(bio, bvec_page(&block->vecs[i]),
> -				   block->vecs[i].bv_len, 0);
> +				   block->vecs[i].bv_len, 0, false);
>  		if (ret != block->vecs[i].bv_len) {
>  			atomic_inc(&lc->io_blocks);
>  			submit_bio(bio);
> @@ -388,7 +388,7 @@ static int log_one_block(struct log_writes_c *lc,
>  			bio_set_op_attrs(bio, REQ_OP_WRITE, 0);
>  
>  			ret = bio_add_page(bio, bvec_page(&block->vecs[i]),
> -					   block->vecs[i].bv_len, 0);
> +					   block->vecs[i].bv_len, 0, false);
>  			if (ret != block->vecs[i].bv_len) {
>  				DMERR("Couldn't add page on new bio?");
>  				bio_put(bio);
> diff --git a/drivers/md/dm-writecache.c b/drivers/md/dm-writecache.c
> index f7822875589e..2fff48b5479a 100644
> --- a/drivers/md/dm-writecache.c
> +++ b/drivers/md/dm-writecache.c
> @@ -1440,7 +1440,8 @@ static bool wc_add_block(struct writeback_struct *wb, struct wc_entry *e, gfp_t
>  
>  	persistent_memory_flush_cache(address, block_size);
>  	return bio_add_page(&wb->bio, persistent_memory_page(address),
> -			    block_size, persistent_memory_page_offset(address)) != 0;
> +			    block_size,
> +			    persistent_memory_page_offset(address), false) != 0;
>  }
>  
>  struct writeback_list {
> diff --git a/drivers/md/dm-zoned-metadata.c b/drivers/md/dm-zoned-metadata.c
> index fa68336560c3..70fbf77bc396 100644
> --- a/drivers/md/dm-zoned-metadata.c
> +++ b/drivers/md/dm-zoned-metadata.c
> @@ -438,7 +438,7 @@ static struct dmz_mblock *dmz_get_mblock_slow(struct dmz_metadata *zmd,
>  	bio->bi_private = mblk;
>  	bio->bi_end_io = dmz_mblock_bio_end_io;
>  	bio_set_op_attrs(bio, REQ_OP_READ, REQ_META | REQ_PRIO);
> -	bio_add_page(bio, mblk->page, DMZ_BLOCK_SIZE, 0);
> +	bio_add_page(bio, mblk->page, DMZ_BLOCK_SIZE, 0, false);
>  	submit_bio(bio);
>  
>  	return mblk;
> @@ -588,7 +588,7 @@ static void dmz_write_mblock(struct dmz_metadata *zmd, struct dmz_mblock *mblk,
>  	bio->bi_private = mblk;
>  	bio->bi_end_io = dmz_mblock_bio_end_io;
>  	bio_set_op_attrs(bio, REQ_OP_WRITE, REQ_META | REQ_PRIO);
> -	bio_add_page(bio, mblk->page, DMZ_BLOCK_SIZE, 0);
> +	bio_add_page(bio, mblk->page, DMZ_BLOCK_SIZE, 0, false);
>  	submit_bio(bio);
>  }
>  
> @@ -608,7 +608,7 @@ static int dmz_rdwr_block(struct dmz_metadata *zmd, int op, sector_t block,
>  	bio->bi_iter.bi_sector = dmz_blk2sect(block);
>  	bio_set_dev(bio, zmd->dev->bdev);
>  	bio_set_op_attrs(bio, op, REQ_SYNC | REQ_META | REQ_PRIO);
> -	bio_add_page(bio, page, DMZ_BLOCK_SIZE, 0);
> +	bio_add_page(bio, page, DMZ_BLOCK_SIZE, 0, false);
>  	ret = submit_bio_wait(bio);
>  	bio_put(bio);
>  
> diff --git a/drivers/md/md.c b/drivers/md/md.c
> index 05ffffb8b769..585016563ec1 100644
> --- a/drivers/md/md.c
> +++ b/drivers/md/md.c
> @@ -817,7 +817,7 @@ void md_super_write(struct mddev *mddev, struct md_rdev *rdev,
>  
>  	bio_set_dev(bio, rdev->meta_bdev ? rdev->meta_bdev : rdev->bdev);
>  	bio->bi_iter.bi_sector = sector;
> -	bio_add_page(bio, page, size, 0);
> +	bio_add_page(bio, page, size, 0, false);
>  	bio->bi_private = rdev;
>  	bio->bi_end_io = super_written;
>  
> @@ -859,7 +859,7 @@ int sync_page_io(struct md_rdev *rdev, sector_t sector, int size,
>  		bio->bi_iter.bi_sector = sector + rdev->new_data_offset;
>  	else
>  		bio->bi_iter.bi_sector = sector + rdev->data_offset;
> -	bio_add_page(bio, page, size, 0);
> +	bio_add_page(bio, page, size, 0, false);
>  
>  	submit_bio_wait(bio);
>  
> diff --git a/drivers/md/raid1-10.c b/drivers/md/raid1-10.c
> index 400001b815db..f79c87b3d2bb 100644
> --- a/drivers/md/raid1-10.c
> +++ b/drivers/md/raid1-10.c
> @@ -76,7 +76,7 @@ static void md_bio_reset_resync_pages(struct bio *bio, struct resync_pages *rp,
>  		 * won't fail because the vec table is big
>  		 * enough to hold all these pages
>  		 */
> -		bio_add_page(bio, page, len, 0);
> +		bio_add_page(bio, page, len, 0, false);
>  		size -= len;
>  	} while (idx++ < RESYNC_PAGES && size > 0);
>  }
> diff --git a/drivers/md/raid1.c b/drivers/md/raid1.c
> index fdf451aac369..a9e736ef1b33 100644
> --- a/drivers/md/raid1.c
> +++ b/drivers/md/raid1.c
> @@ -1112,7 +1112,7 @@ static void alloc_behind_master_bio(struct r1bio *r1_bio,
>  		if (unlikely(!page))
>  			goto free_pages;
>  
> -		bio_add_page(behind_bio, page, len, 0);
> +		bio_add_page(behind_bio, page, len, 0, false);
>  
>  		size -= len;
>  		i++;
> @@ -2854,7 +2854,7 @@ static sector_t raid1_sync_request(struct mddev *mddev, sector_t sector_nr,
>  				 * won't fail because the vec table is big
>  				 * enough to hold all these pages
>  				 */
> -				bio_add_page(bio, page, len, 0);
> +				bio_add_page(bio, page, len, 0, false);
>  			}
>  		}
>  		nr_sectors += len>>9;
> diff --git a/drivers/md/raid10.c b/drivers/md/raid10.c
> index 3b6880dd648d..e172fd3666d7 100644
> --- a/drivers/md/raid10.c
> +++ b/drivers/md/raid10.c
> @@ -3449,7 +3449,7 @@ static sector_t raid10_sync_request(struct mddev *mddev, sector_t sector_nr,
>  			 * won't fail because the vec table is big enough
>  			 * to hold all these pages
>  			 */
> -			bio_add_page(bio, page, len, 0);
> +			bio_add_page(bio, page, len, 0, false);
>  		}
>  		nr_sectors += len>>9;
>  		sector_nr += len>>9;
> @@ -4659,7 +4659,7 @@ static sector_t reshape_request(struct mddev *mddev, sector_t sector_nr,
>  			 * won't fail because the vec table is big enough
>  			 * to hold all these pages
>  			 */
> -			bio_add_page(bio, page, len, 0);
> +			bio_add_page(bio, page, len, 0, false);
>  		}
>  		sector_nr += len >> 9;
>  		nr_sectors += len >> 9;
> diff --git a/drivers/md/raid5-cache.c b/drivers/md/raid5-cache.c
> index cbbe6b6535be..b62806564760 100644
> --- a/drivers/md/raid5-cache.c
> +++ b/drivers/md/raid5-cache.c
> @@ -804,7 +804,7 @@ static struct r5l_io_unit *r5l_new_meta(struct r5l_log *log)
>  	io->current_bio = r5l_bio_alloc(log);
>  	io->current_bio->bi_end_io = r5l_log_endio;
>  	io->current_bio->bi_private = io;
> -	bio_add_page(io->current_bio, io->meta_page, PAGE_SIZE, 0);
> +	bio_add_page(io->current_bio, io->meta_page, PAGE_SIZE, 0, false);
>  
>  	r5_reserve_log_entry(log, io);
>  
> @@ -864,7 +864,7 @@ static void r5l_append_payload_page(struct r5l_log *log, struct page *page)
>  		io->need_split_bio = false;
>  	}
>  
> -	if (!bio_add_page(io->current_bio, page, PAGE_SIZE, 0))
> +	if (!bio_add_page(io->current_bio, page, PAGE_SIZE, 0, false))
>  		BUG();
>  
>  	r5_reserve_log_entry(log, io);
> @@ -1699,7 +1699,8 @@ static int r5l_recovery_fetch_ra_pool(struct r5l_log *log,
>  
>  	while (ctx->valid_pages < ctx->total_pages) {
>  		bio_add_page(ctx->ra_bio,
> -			     ctx->ra_pool[ctx->valid_pages], PAGE_SIZE, 0);
> +			     ctx->ra_pool[ctx->valid_pages], PAGE_SIZE, 0,
> +			     false);
>  		ctx->valid_pages += 1;
>  
>  		offset = r5l_ring_add(log, offset, BLOCK_SECTORS);
> diff --git a/drivers/md/raid5-ppl.c b/drivers/md/raid5-ppl.c
> index 17e9e7d51097..12003f091465 100644
> --- a/drivers/md/raid5-ppl.c
> +++ b/drivers/md/raid5-ppl.c
> @@ -476,7 +476,7 @@ static void ppl_submit_iounit(struct ppl_io_unit *io)
>  	bio->bi_opf = REQ_OP_WRITE | REQ_FUA;
>  	bio_set_dev(bio, log->rdev->bdev);
>  	bio->bi_iter.bi_sector = log->next_io_sector;
> -	bio_add_page(bio, io->header_page, PAGE_SIZE, 0);
> +	bio_add_page(bio, io->header_page, PAGE_SIZE, 0, false);
>  	bio->bi_write_hint = ppl_conf->write_hint;
>  
>  	pr_debug("%s: log->current_io_sector: %llu\n", __func__,
> @@ -501,7 +501,7 @@ static void ppl_submit_iounit(struct ppl_io_unit *io)
>  		if (test_bit(STRIPE_FULL_WRITE, &sh->state))
>  			continue;
>  
> -		if (!bio_add_page(bio, sh->ppl_page, PAGE_SIZE, 0)) {
> +		if (!bio_add_page(bio, sh->ppl_page, PAGE_SIZE, 0, false)) {
>  			struct bio *prev = bio;
>  
>  			bio = bio_alloc_bioset(GFP_NOIO, BIO_MAX_PAGES,
> @@ -510,7 +510,7 @@ static void ppl_submit_iounit(struct ppl_io_unit *io)
>  			bio->bi_write_hint = prev->bi_write_hint;
>  			bio_copy_dev(bio, prev);
>  			bio->bi_iter.bi_sector = bio_end_sector(prev);
> -			bio_add_page(bio, sh->ppl_page, PAGE_SIZE, 0);
> +			bio_add_page(bio, sh->ppl_page, PAGE_SIZE, 0, false);
>  
>  			bio_chain(bio, prev);
>  			ppl_submit_iounit_bio(io, prev);
> diff --git a/drivers/nvme/target/io-cmd-bdev.c b/drivers/nvme/target/io-cmd-bdev.c
> index a065dbfc43b1..6ba1fd806394 100644
> --- a/drivers/nvme/target/io-cmd-bdev.c
> +++ b/drivers/nvme/target/io-cmd-bdev.c
> @@ -144,7 +144,7 @@ static void nvmet_bdev_execute_rw(struct nvmet_req *req)
>  	bio_set_op_attrs(bio, op, op_flags);
>  
>  	for_each_sg(req->sg, sg, req->sg_cnt, i) {
> -		while (bio_add_page(bio, sg_page(sg), sg->length, sg->offset)
> +		while (bio_add_page(bio, sg_page(sg), sg->length, sg->offset, false)
>  				!= sg->length) {
>  			struct bio *prev = bio;
>  
> diff --git a/drivers/staging/erofs/data.c b/drivers/staging/erofs/data.c
> index ba467ba414ff..4fb84db9d5b4 100644
> --- a/drivers/staging/erofs/data.c
> +++ b/drivers/staging/erofs/data.c
> @@ -70,7 +70,7 @@ struct page *__erofs_get_meta_page(struct super_block *sb,
>  			goto err_out;
>  		}
>  
> -		err = bio_add_page(bio, page, PAGE_SIZE, 0);
> +		err = bio_add_page(bio, page, PAGE_SIZE, 0, false);
>  		if (unlikely(err != PAGE_SIZE)) {
>  			err = -EFAULT;
>  			goto err_out;
> @@ -290,7 +290,7 @@ static inline struct bio *erofs_read_raw_page(struct bio *bio,
>  		}
>  	}
>  
> -	err = bio_add_page(bio, page, PAGE_SIZE, 0);
> +	err = bio_add_page(bio, page, PAGE_SIZE, 0, false);
>  	/* out of the extent or bio is full */
>  	if (err < PAGE_SIZE)
>  		goto submit_bio_retry;
> diff --git a/drivers/staging/erofs/unzip_vle.c b/drivers/staging/erofs/unzip_vle.c
> index 11aa0c6f1994..3cecd109324e 100644
> --- a/drivers/staging/erofs/unzip_vle.c
> +++ b/drivers/staging/erofs/unzip_vle.c
> @@ -1453,7 +1453,7 @@ static bool z_erofs_vle_submit_all(struct super_block *sb,
>  			++nr_bios;
>  		}
>  
> -		err = bio_add_page(bio, page, PAGE_SIZE, 0);
> +		err = bio_add_page(bio, page, PAGE_SIZE, 0, false);
>  		if (err < PAGE_SIZE)
>  			goto submit_bio_retry;
>  
> diff --git a/drivers/target/target_core_iblock.c b/drivers/target/target_core_iblock.c
> index b5ed9c377060..9dc0d3712241 100644
> --- a/drivers/target/target_core_iblock.c
> +++ b/drivers/target/target_core_iblock.c
> @@ -501,7 +501,7 @@ iblock_execute_write_same(struct se_cmd *cmd)
>  	refcount_set(&ibr->pending, 1);
>  
>  	while (sectors) {
> -		while (bio_add_page(bio, sg_page(sg), sg->length, sg->offset)
> +		while (bio_add_page(bio, sg_page(sg), sg->length, sg->offset, false)
>  				!= sg->length) {
>  
>  			bio = iblock_get_bio(cmd, block_lba, 1, REQ_OP_WRITE,
> @@ -753,7 +753,7 @@ iblock_execute_rw(struct se_cmd *cmd, struct scatterlist *sgl, u32 sgl_nents,
>  		 *	length of the S/G list entry this will cause and
>  		 *	endless loop.  Better hope no driver uses huge pages.
>  		 */
> -		while (bio_add_page(bio, sg_page(sg), sg->length, sg->offset)
> +		while (bio_add_page(bio, sg_page(sg), sg->length, sg->offset, false)
>  				!= sg->length) {
>  			if (cmd->prot_type && dev->dev_attrib.pi_prot_type) {
>  				rc = iblock_alloc_bip(cmd, bio, &prot_miter);
> diff --git a/drivers/target/target_core_pscsi.c b/drivers/target/target_core_pscsi.c
> index b5388a106567..570ef259d78d 100644
> --- a/drivers/target/target_core_pscsi.c
> +++ b/drivers/target/target_core_pscsi.c
> @@ -916,7 +916,7 @@ pscsi_map_sg(struct se_cmd *cmd, struct scatterlist *sgl, u32 sgl_nents,
>  				page, len, off);
>  
>  			rc = bio_add_pc_page(pdv->pdv_sd->request_queue,
> -					bio, page, bytes, off);
> +					bio, page, bytes, off, false);
>  			pr_debug("PSCSI: bio->bi_vcnt: %d nr_vecs: %d\n",
>  				bio_segments(bio), nr_vecs);
>  			if (rc != bytes) {
> diff --git a/fs/btrfs/check-integrity.c b/fs/btrfs/check-integrity.c
> index c5ee3ac73930..d1bdddf3299a 100644
> --- a/fs/btrfs/check-integrity.c
> +++ b/fs/btrfs/check-integrity.c
> @@ -1633,7 +1633,7 @@ static int btrfsic_read_block(struct btrfsic_state *state,
>  
>  		for (j = i; j < num_pages; j++) {
>  			ret = bio_add_page(bio, block_ctx->pagev[j],
> -					   PAGE_SIZE, 0);
> +					   PAGE_SIZE, 0, false);
>  			if (PAGE_SIZE != ret)
>  				break;
>  		}
> diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
> index fcedb69c4d7a..3e28a0c01a60 100644
> --- a/fs/btrfs/compression.c
> +++ b/fs/btrfs/compression.c
> @@ -337,7 +337,7 @@ blk_status_t btrfs_submit_compressed_write(struct inode *inode, u64 start,
>  							  0);
>  
>  		page->mapping = NULL;
> -		if (submit || bio_add_page(bio, page, PAGE_SIZE, 0) <
> +		if (submit || bio_add_page(bio, page, PAGE_SIZE, 0, false) <
>  		    PAGE_SIZE) {
>  			/*
>  			 * inc the count before we submit the bio so
> @@ -365,7 +365,7 @@ blk_status_t btrfs_submit_compressed_write(struct inode *inode, u64 start,
>  			bio->bi_opf = REQ_OP_WRITE | write_flags;
>  			bio->bi_private = cb;
>  			bio->bi_end_io = end_compressed_bio_write;
> -			bio_add_page(bio, page, PAGE_SIZE, 0);
> +			bio_add_page(bio, page, PAGE_SIZE, 0, false);
>  		}
>  		if (bytes_left < PAGE_SIZE) {
>  			btrfs_info(fs_info,
> @@ -491,7 +491,7 @@ static noinline int add_ra_bio_pages(struct inode *inode,
>  		}
>  
>  		ret = bio_add_page(cb->orig_bio, page,
> -				   PAGE_SIZE, 0);
> +				   PAGE_SIZE, 0, false);
>  
>  		if (ret == PAGE_SIZE) {
>  			nr_pages++;
> @@ -616,7 +616,7 @@ blk_status_t btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
>  							  comp_bio, 0);
>  
>  		page->mapping = NULL;
> -		if (submit || bio_add_page(comp_bio, page, PAGE_SIZE, 0) <
> +		if (submit || bio_add_page(comp_bio, page, PAGE_SIZE, 0, false) <
>  		    PAGE_SIZE) {
>  			ret = btrfs_bio_wq_end_io(fs_info, comp_bio,
>  						  BTRFS_WQ_ENDIO_DATA);
> @@ -649,7 +649,7 @@ blk_status_t btrfs_submit_compressed_read(struct inode *inode, struct bio *bio,
>  			comp_bio->bi_private = cb;
>  			comp_bio->bi_end_io = end_compressed_bio_read;
>  
> -			bio_add_page(comp_bio, page, PAGE_SIZE, 0);
> +			bio_add_page(comp_bio, page, PAGE_SIZE, 0, false);
>  		}
>  		cur_disk_byte += PAGE_SIZE;
>  	}
> diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
> index 7485910fdff0..e3ddfff82c12 100644
> --- a/fs/btrfs/extent_io.c
> +++ b/fs/btrfs/extent_io.c
> @@ -2042,7 +2042,7 @@ int repair_io_failure(struct btrfs_fs_info *fs_info, u64 ino, u64 start,
>  	}
>  	bio_set_dev(bio, dev->bdev);
>  	bio->bi_opf = REQ_OP_WRITE | REQ_SYNC;
> -	bio_add_page(bio, page, length, pg_offset);
> +	bio_add_page(bio, page, length, pg_offset, false);
>  
>  	if (btrfsic_submit_bio_wait(bio)) {
>  		/* try to remap that extent elsewhere? */
> @@ -2357,7 +2357,7 @@ struct bio *btrfs_create_repair_bio(struct inode *inode, struct bio *failed_bio,
>  		       csum_size);
>  	}
>  
> -	bio_add_page(bio, page, failrec->len, pg_offset);
> +	bio_add_page(bio, page, failrec->len, pg_offset, false);
>  
>  	return bio;
>  }
> @@ -2775,7 +2775,7 @@ static int submit_extent_page(unsigned int opf, struct extent_io_tree *tree,
>  
>  		if (prev_bio_flags != bio_flags || !contig || !can_merge ||
>  		    force_bio_submit ||
> -		    bio_add_page(bio, page, page_size, pg_offset) < page_size) {
> +		    bio_add_page(bio, page, page_size, pg_offset, false) < page_size) {
>  			ret = submit_one_bio(bio, mirror_num, prev_bio_flags);
>  			if (ret < 0) {
>  				*bio_ret = NULL;
> @@ -2790,7 +2790,7 @@ static int submit_extent_page(unsigned int opf, struct extent_io_tree *tree,
>  	}
>  
>  	bio = btrfs_bio_alloc(bdev, offset);
> -	bio_add_page(bio, page, page_size, pg_offset);
> +	bio_add_page(bio, page, page_size, pg_offset, false);
>  	bio->bi_end_io = end_io_func;
>  	bio->bi_private = tree;
>  	bio->bi_write_hint = page->mapping->host->i_write_hint;
> diff --git a/fs/btrfs/raid56.c b/fs/btrfs/raid56.c
> index f02532ef34f0..5d2a3b8cf45c 100644
> --- a/fs/btrfs/raid56.c
> +++ b/fs/btrfs/raid56.c
> @@ -1097,7 +1097,7 @@ static int rbio_add_io_page(struct btrfs_raid_bio *rbio,
>  		    !last->bi_status &&
>  		    last->bi_disk == stripe->dev->bdev->bd_disk &&
>  		    last->bi_partno == stripe->dev->bdev->bd_partno) {
> -			ret = bio_add_page(last, page, PAGE_SIZE, 0);
> +			ret = bio_add_page(last, page, PAGE_SIZE, 0, false);
>  			if (ret == PAGE_SIZE)
>  				return 0;
>  		}
> @@ -1109,7 +1109,7 @@ static int rbio_add_io_page(struct btrfs_raid_bio *rbio,
>  	bio_set_dev(bio, stripe->dev->bdev);
>  	bio->bi_iter.bi_sector = disk_start >> 9;
>  
> -	bio_add_page(bio, page, PAGE_SIZE, 0);
> +	bio_add_page(bio, page, PAGE_SIZE, 0, false);
>  	bio_list_add(bio_list, bio);
>  	return 0;
>  }
> diff --git a/fs/btrfs/scrub.c b/fs/btrfs/scrub.c
> index a99588536c79..2b63d595e9f6 100644
> --- a/fs/btrfs/scrub.c
> +++ b/fs/btrfs/scrub.c
> @@ -1433,7 +1433,7 @@ static void scrub_recheck_block_on_raid56(struct btrfs_fs_info *fs_info,
>  		struct scrub_page *page = sblock->pagev[page_num];
>  
>  		WARN_ON(!page->page);
> -		bio_add_page(bio, page->page, PAGE_SIZE, 0);
> +		bio_add_page(bio, page->page, PAGE_SIZE, 0, false);
>  	}
>  
>  	if (scrub_submit_raid56_bio_wait(fs_info, bio, first_page)) {
> @@ -1486,7 +1486,7 @@ static void scrub_recheck_block(struct btrfs_fs_info *fs_info,
>  		bio = btrfs_io_bio_alloc(1);
>  		bio_set_dev(bio, page->dev->bdev);
>  
> -		bio_add_page(bio, page->page, PAGE_SIZE, 0);
> +		bio_add_page(bio, page->page, PAGE_SIZE, 0, false);
>  		bio->bi_iter.bi_sector = page->physical >> 9;
>  		bio->bi_opf = REQ_OP_READ;
>  
> @@ -1569,7 +1569,7 @@ static int scrub_repair_page_from_good_copy(struct scrub_block *sblock_bad,
>  		bio->bi_iter.bi_sector = page_bad->physical >> 9;
>  		bio->bi_opf = REQ_OP_WRITE;
>  
> -		ret = bio_add_page(bio, page_good->page, PAGE_SIZE, 0);
> +		ret = bio_add_page(bio, page_good->page, PAGE_SIZE, 0, false);
>  		if (PAGE_SIZE != ret) {
>  			bio_put(bio);
>  			return -EIO;
> @@ -1670,7 +1670,7 @@ static int scrub_add_page_to_wr_bio(struct scrub_ctx *sctx,
>  		goto again;
>  	}
>  
> -	ret = bio_add_page(sbio->bio, spage->page, PAGE_SIZE, 0);
> +	ret = bio_add_page(sbio->bio, spage->page, PAGE_SIZE, 0, false);
>  	if (ret != PAGE_SIZE) {
>  		if (sbio->page_count < 1) {
>  			bio_put(sbio->bio);
> @@ -2071,7 +2071,7 @@ static int scrub_add_page_to_rd_bio(struct scrub_ctx *sctx,
>  	}
>  
>  	sbio->pagev[sbio->page_count] = spage;
> -	ret = bio_add_page(sbio->bio, spage->page, PAGE_SIZE, 0);
> +	ret = bio_add_page(sbio->bio, spage->page, PAGE_SIZE, 0, false);
>  	if (ret != PAGE_SIZE) {
>  		if (sbio->page_count < 1) {
>  			bio_put(sbio->bio);
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 91c4bfde03e5..74aae2aa69c4 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -3075,7 +3075,7 @@ static int submit_bh_wbc(int op, int op_flags, struct buffer_head *bh,
>  	bio_set_dev(bio, bh->b_bdev);
>  	bio->bi_write_hint = write_hint;
>  
> -	bio_add_page(bio, bh->b_page, bh->b_size, bh_offset(bh));
> +	bio_add_page(bio, bh->b_page, bh->b_size, bh_offset(bh), false);
>  	BUG_ON(bio->bi_iter.bi_size != bh->b_size);
>  
>  	bio->bi_end_io = end_bio_bh_io_sync;
> diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
> index 51763b09a11b..604766e24a46 100644
> --- a/fs/crypto/bio.c
> +++ b/fs/crypto/bio.c
> @@ -131,7 +131,7 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
>  			pblk << (inode->i_sb->s_blocksize_bits - 9);
>  		bio_set_op_attrs(bio, REQ_OP_WRITE, 0);
>  		ret = bio_add_page(bio, ciphertext_page,
> -					inode->i_sb->s_blocksize, 0);
> +					inode->i_sb->s_blocksize, 0, false);
>  		if (ret != inode->i_sb->s_blocksize) {
>  			/* should never happen! */
>  			WARN_ON(1);
> diff --git a/fs/direct-io.c b/fs/direct-io.c
> index e9f3b79048ae..b8b5d8e31aeb 100644
> --- a/fs/direct-io.c
> +++ b/fs/direct-io.c
> @@ -761,7 +761,7 @@ static inline int dio_bio_add_page(struct dio_submit *sdio)
>  	int ret;
>  
>  	ret = bio_add_page(sdio->bio, sdio->cur_page,
> -			sdio->cur_page_len, sdio->cur_page_offset);
> +			sdio->cur_page_len, sdio->cur_page_offset, false);
>  	if (ret == sdio->cur_page_len) {
>  		/*
>  		 * Decrement count only, if we are done with this page
> diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
> index 4cd321328c18..a76ce3346705 100644
> --- a/fs/ext4/page-io.c
> +++ b/fs/ext4/page-io.c
> @@ -402,7 +402,7 @@ static int io_submit_add_bh(struct ext4_io_submit *io,
>  			return ret;
>  		io->io_bio->bi_write_hint = inode->i_write_hint;
>  	}
> -	ret = bio_add_page(io->io_bio, page, bh->b_size, bh_offset(bh));
> +	ret = bio_add_page(io->io_bio, page, bh->b_size, bh_offset(bh), false);
>  	if (ret != bh->b_size)
>  		goto submit_and_retry;
>  	wbc_account_io(io->io_wbc, page, bh->b_size);
> diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
> index 84222b89da52..90ee8263d266 100644
> --- a/fs/ext4/readpage.c
> +++ b/fs/ext4/readpage.c
> @@ -264,7 +264,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
>  		}
>  
>  		length = first_hole << blkbits;
> -		if (bio_add_page(bio, page, length, 0) < length)
> +		if (bio_add_page(bio, page, length, 0, false) < length)
>  			goto submit_and_realloc;
>  
>  		if (((map.m_flags & EXT4_MAP_BOUNDARY) &&
> diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
> index 51bf04ba2599..24353c9c8a41 100644
> --- a/fs/f2fs/data.c
> +++ b/fs/f2fs/data.c
> @@ -308,7 +308,7 @@ static inline void __submit_bio(struct f2fs_sb_info *sbi,
>  			SetPagePrivate(page);
>  			set_page_private(page, (unsigned long)DUMMY_WRITTEN_PAGE);
>  			lock_page(page);
> -			if (bio_add_page(bio, page, PAGE_SIZE, 0) < PAGE_SIZE)
> +			if (bio_add_page(bio, page, PAGE_SIZE, 0, false) < PAGE_SIZE)
>  				f2fs_bug_on(sbi, 1);
>  		}
>  		/*
> @@ -461,7 +461,7 @@ int f2fs_submit_page_bio(struct f2fs_io_info *fio)
>  	bio = __bio_alloc(fio->sbi, fio->new_blkaddr, fio->io_wbc,
>  				1, is_read_io(fio->op), fio->type, fio->temp);
>  
> -	if (bio_add_page(bio, page, PAGE_SIZE, 0) < PAGE_SIZE) {
> +	if (bio_add_page(bio, page, PAGE_SIZE, 0, false) < PAGE_SIZE) {
>  		bio_put(bio);
>  		return -EFAULT;
>  	}
> @@ -530,7 +530,7 @@ void f2fs_submit_page_write(struct f2fs_io_info *fio)
>  		io->fio = *fio;
>  	}
>  
> -	if (bio_add_page(io->bio, bio_page, PAGE_SIZE, 0) < PAGE_SIZE) {
> +	if (bio_add_page(io->bio, bio_page, PAGE_SIZE, 0, false) < PAGE_SIZE) {
>  		__submit_merged_bio(io);
>  		goto alloc_new;
>  	}
> @@ -598,7 +598,7 @@ static int f2fs_submit_page_read(struct inode *inode, struct page *page,
>  	/* wait for GCed page writeback via META_MAPPING */
>  	f2fs_wait_on_block_writeback(inode, blkaddr);
>  
> -	if (bio_add_page(bio, page, PAGE_SIZE, 0) < PAGE_SIZE) {
> +	if (bio_add_page(bio, page, PAGE_SIZE, 0, false) < PAGE_SIZE) {
>  		bio_put(bio);
>  		return -EFAULT;
>  	}
> @@ -1621,7 +1621,7 @@ static int f2fs_mpage_readpages(struct address_space *mapping,
>  		 */
>  		f2fs_wait_on_block_writeback(inode, block_nr);
>  
> -		if (bio_add_page(bio, page, blocksize, 0) < blocksize)
> +		if (bio_add_page(bio, page, blocksize, 0, false) < blocksize)
>  			goto submit_and_realloc;
>  
>  		inc_page_count(F2FS_I_SB(inode), F2FS_RD_DATA);
> diff --git a/fs/gfs2/lops.c b/fs/gfs2/lops.c
> index e0523ef8421e..3dca16f510b7 100644
> --- a/fs/gfs2/lops.c
> +++ b/fs/gfs2/lops.c
> @@ -334,11 +334,11 @@ void gfs2_log_write(struct gfs2_sbd *sdp, struct page *page,
>  
>  	bio = gfs2_log_get_bio(sdp, blkno, &sdp->sd_log_bio, REQ_OP_WRITE,
>  			       gfs2_end_log_write, false);
> -	ret = bio_add_page(bio, page, size, offset);
> +	ret = bio_add_page(bio, page, size, offset, false);
>  	if (ret == 0) {
>  		bio = gfs2_log_get_bio(sdp, blkno, &sdp->sd_log_bio,
>  				       REQ_OP_WRITE, gfs2_end_log_write, true);
> -		ret = bio_add_page(bio, page, size, offset);
> +		ret = bio_add_page(bio, page, size, offset, false);
>  		WARN_ON(ret == 0);
>  	}
>  }
> diff --git a/fs/gfs2/meta_io.c b/fs/gfs2/meta_io.c
> index a7e645d08942..c7db0f249002 100644
> --- a/fs/gfs2/meta_io.c
> +++ b/fs/gfs2/meta_io.c
> @@ -225,7 +225,7 @@ static void gfs2_submit_bhs(int op, int op_flags, struct buffer_head *bhs[],
>  		bio_set_dev(bio, bh->b_bdev);
>  		while (num > 0) {
>  			bh = *bhs;
> -			if (!bio_add_page(bio, bh->b_page, bh->b_size, bh_offset(bh))) {
> +			if (!bio_add_page(bio, bh->b_page, bh->b_size, bh_offset(bh), false)) {
>  				BUG_ON(bio->bi_iter.bi_size == 0);
>  				break;
>  			}
> diff --git a/fs/gfs2/ops_fstype.c b/fs/gfs2/ops_fstype.c
> index b041cb8ae383..cdd52e6c02f7 100644
> --- a/fs/gfs2/ops_fstype.c
> +++ b/fs/gfs2/ops_fstype.c
> @@ -243,7 +243,7 @@ static int gfs2_read_super(struct gfs2_sbd *sdp, sector_t sector, int silent)
>  	bio = bio_alloc(GFP_NOFS, 1);
>  	bio->bi_iter.bi_sector = sector * (sb->s_blocksize >> 9);
>  	bio_set_dev(bio, sb->s_bdev);
> -	bio_add_page(bio, page, PAGE_SIZE, 0);
> +	bio_add_page(bio, page, PAGE_SIZE, 0, false);
>  
>  	bio->bi_end_io = end_bio_io_page;
>  	bio->bi_private = page;
> diff --git a/fs/hfsplus/wrapper.c b/fs/hfsplus/wrapper.c
> index 08c1580bdf7a..3eff6b4dcb69 100644
> --- a/fs/hfsplus/wrapper.c
> +++ b/fs/hfsplus/wrapper.c
> @@ -77,7 +77,8 @@ int hfsplus_submit_bio(struct super_block *sb, sector_t sector,
>  		unsigned int len = min_t(unsigned int, PAGE_SIZE - page_offset,
>  					 io_size);
>  
> -		ret = bio_add_page(bio, virt_to_page(buf), len, page_offset);
> +		ret = bio_add_page(bio, virt_to_page(buf), len, page_offset,
> +				   false);
>  		if (ret != len) {
>  			ret = -EIO;
>  			goto out;
> diff --git a/fs/iomap.c b/fs/iomap.c
> index ab578054ebe9..c706fd2b0f6e 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -356,7 +356,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  		ctx->bio->bi_end_io = iomap_read_end_io;
>  	}
>  
> -	bio_add_page(ctx->bio, page, plen, poff);
> +	bio_add_page(ctx->bio, page, plen, poff, false);
>  done:
>  	/*
>  	 * Move the caller beyond our range so that it keeps making progress.
> @@ -624,7 +624,7 @@ iomap_read_page_sync(struct inode *inode, loff_t block_start, struct page *page,
>  	bio.bi_opf = REQ_OP_READ;
>  	bio.bi_iter.bi_sector = iomap_sector(iomap, block_start);
>  	bio_set_dev(&bio, iomap->bdev);
> -	__bio_add_page(&bio, page, plen, poff);
> +	__bio_add_page(&bio, page, plen, poff, false);
>  	return submit_bio_wait(&bio);
>  }
>  
> @@ -1616,7 +1616,7 @@ iomap_dio_zero(struct iomap_dio *dio, struct iomap *iomap, loff_t pos,
>  	bio->bi_end_io = iomap_dio_bio_end_io;
>  
>  	get_page(page);
> -	__bio_add_page(bio, page, len, 0);
> +	__bio_add_page(bio, page, len, 0, false);
>  	bio_set_op_attrs(bio, REQ_OP_WRITE, flags);
>  	iomap_dio_submit_bio(dio, iomap, bio);
>  }
> diff --git a/fs/jfs/jfs_logmgr.c b/fs/jfs/jfs_logmgr.c
> index 6b68df395892..42a8c1a8fb77 100644
> --- a/fs/jfs/jfs_logmgr.c
> +++ b/fs/jfs/jfs_logmgr.c
> @@ -1997,7 +1997,7 @@ static int lbmRead(struct jfs_log * log, int pn, struct lbuf ** bpp)
>  	bio->bi_iter.bi_sector = bp->l_blkno << (log->l2bsize - 9);
>  	bio_set_dev(bio, log->bdev);
>  
> -	bio_add_page(bio, bp->l_page, LOGPSIZE, bp->l_offset);
> +	bio_add_page(bio, bp->l_page, LOGPSIZE, bp->l_offset, false);
>  	BUG_ON(bio->bi_iter.bi_size != LOGPSIZE);
>  
>  	bio->bi_end_io = lbmIODone;
> @@ -2141,7 +2141,7 @@ static void lbmStartIO(struct lbuf * bp)
>  	bio->bi_iter.bi_sector = bp->l_blkno << (log->l2bsize - 9);
>  	bio_set_dev(bio, log->bdev);
>  
> -	bio_add_page(bio, bp->l_page, LOGPSIZE, bp->l_offset);
> +	bio_add_page(bio, bp->l_page, LOGPSIZE, bp->l_offset, false);
>  	BUG_ON(bio->bi_iter.bi_size != LOGPSIZE);
>  
>  	bio->bi_end_io = lbmIODone;
> diff --git a/fs/jfs/jfs_metapage.c b/fs/jfs/jfs_metapage.c
> index fa2c6824c7f2..6f66f0a15768 100644
> --- a/fs/jfs/jfs_metapage.c
> +++ b/fs/jfs/jfs_metapage.c
> @@ -401,7 +401,7 @@ static int metapage_writepage(struct page *page, struct writeback_control *wbc)
>  				continue;
>  			}
>  			/* Not contiguous */
> -			if (bio_add_page(bio, page, bio_bytes, bio_offset) <
> +			if (bio_add_page(bio, page, bio_bytes, bio_offset, false) <
>  			    bio_bytes)
>  				goto add_failed;
>  			/*
> @@ -444,7 +444,7 @@ static int metapage_writepage(struct page *page, struct writeback_control *wbc)
>  		next_block = lblock + len;
>  	}
>  	if (bio) {
> -		if (bio_add_page(bio, page, bio_bytes, bio_offset) < bio_bytes)
> +		if (bio_add_page(bio, page, bio_bytes, bio_offset, false) < bio_bytes)
>  				goto add_failed;
>  		if (!bio->bi_iter.bi_size)
>  			goto dump_bio;
> @@ -518,7 +518,7 @@ static int metapage_readpage(struct file *fp, struct page *page)
>  			bio_set_op_attrs(bio, REQ_OP_READ, 0);
>  			len = xlen << inode->i_blkbits;
>  			offset = block_offset << inode->i_blkbits;
> -			if (bio_add_page(bio, page, len, offset) < len)
> +			if (bio_add_page(bio, page, len, offset, false) < len)
>  				goto add_failed;
>  			block_offset += xlen;
>  		} else
> diff --git a/fs/mpage.c b/fs/mpage.c
> index e234c9a8802d..67e6d1dda984 100644
> --- a/fs/mpage.c
> +++ b/fs/mpage.c
> @@ -313,7 +313,7 @@ static struct bio *do_mpage_readpage(struct mpage_readpage_args *args)
>  	}
>  
>  	length = first_hole << blkbits;
> -	if (bio_add_page(args->bio, page, length, 0) < length) {
> +	if (bio_add_page(args->bio, page, length, 0, false) < length) {
>  		args->bio = mpage_bio_submit(REQ_OP_READ, op_flags, args->bio);
>  		goto alloc_new;
>  	}
> @@ -650,7 +650,7 @@ static int __mpage_writepage(struct page *page, struct writeback_control *wbc,
>  	 */
>  	wbc_account_io(wbc, page, PAGE_SIZE);
>  	length = first_unmapped << blkbits;
> -	if (bio_add_page(bio, page, length, 0) < length) {
> +	if (bio_add_page(bio, page, length, 0, false) < length) {
>  		bio = mpage_bio_submit(REQ_OP_WRITE, op_flags, bio);
>  		goto alloc_new;
>  	}
> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
> index 690221747b47..fb58bf7bc06f 100644
> --- a/fs/nfs/blocklayout/blocklayout.c
> +++ b/fs/nfs/blocklayout/blocklayout.c
> @@ -182,7 +182,7 @@ do_add_page_to_bio(struct bio *bio, int npg, int rw, sector_t isect,
>  			return ERR_PTR(-ENOMEM);
>  		bio_set_op_attrs(bio, rw, 0);
>  	}
> -	if (bio_add_page(bio, page, *len, offset) < *len) {
> +	if (bio_add_page(bio, page, *len, offset, false) < *len) {
>  		bio = bl_submit_bio(bio);
>  		goto retry;
>  	}
> diff --git a/fs/nilfs2/segbuf.c b/fs/nilfs2/segbuf.c
> index 20c479b5e41b..64ecdab529c7 100644
> --- a/fs/nilfs2/segbuf.c
> +++ b/fs/nilfs2/segbuf.c
> @@ -424,7 +424,8 @@ static int nilfs_segbuf_submit_bh(struct nilfs_segment_buffer *segbuf,
>  			return -ENOMEM;
>  	}
>  
> -	len = bio_add_page(wi->bio, bh->b_page, bh->b_size, bh_offset(bh));
> +	len = bio_add_page(wi->bio, bh->b_page, bh->b_size, bh_offset(bh),
> +			   false);
>  	if (len == bh->b_size) {
>  		wi->end++;
>  		return 0;
> diff --git a/fs/ocfs2/cluster/heartbeat.c b/fs/ocfs2/cluster/heartbeat.c
> index f3c20b279eb2..e8c209c2e348 100644
> --- a/fs/ocfs2/cluster/heartbeat.c
> +++ b/fs/ocfs2/cluster/heartbeat.c
> @@ -569,7 +569,7 @@ static struct bio *o2hb_setup_one_bio(struct o2hb_region *reg,
>  		mlog(ML_HB_BIO, "page %d, vec_len = %u, vec_start = %u\n",
>  		     current_page, vec_len, vec_start);
>  
> -		len = bio_add_page(bio, page, vec_len, vec_start);
> +		len = bio_add_page(bio, page, vec_len, vec_start, false);
>  		if (len != vec_len) break;
>  
>  		cs += vec_len / (PAGE_SIZE/spp);
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index d152d1ab2ad1..085ccd01e059 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -667,7 +667,7 @@ xfs_add_to_ioend(
>  			atomic_inc(&iop->write_count);
>  		if (bio_full(wpc->ioend->io_bio))
>  			xfs_chain_bio(wpc->ioend, wbc, bdev, sector);
> -		bio_add_page(wpc->ioend->io_bio, page, len, poff);
> +		bio_add_page(wpc->ioend->io_bio, page, len, poff, false);
>  	}
>  
>  	wpc->ioend->io_size += len;
> diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
> index 548344e25128..2b981cf8d2af 100644
> --- a/fs/xfs/xfs_buf.c
> +++ b/fs/xfs/xfs_buf.c
> @@ -1389,7 +1389,7 @@ xfs_buf_ioapply_map(
>  			nbytes = size;
>  
>  		rbytes = bio_add_page(bio, bp->b_pages[page_index], nbytes,
> -				      offset);
> +				      offset, false);
>  		if (rbytes < nbytes)
>  			break;
>  
> diff --git a/include/linux/bio.h b/include/linux/bio.h
> index 6ac4f6b192e6..05fcc5227d0e 100644
> --- a/include/linux/bio.h
> +++ b/include/linux/bio.h
> @@ -429,13 +429,14 @@ extern void bio_uninit(struct bio *);
>  extern void bio_reset(struct bio *);
>  void bio_chain(struct bio *, struct bio *);
>  
> -extern int bio_add_page(struct bio *, struct page *, unsigned int,unsigned int);
> +extern int bio_add_page(struct bio *, struct page *, unsigned int,
> +			unsigned int, bool is_gup);
>  extern int bio_add_pc_page(struct request_queue *, struct bio *, struct page *,
> -			   unsigned int, unsigned int);
> +			   unsigned int, unsigned int, bool is_gup);
>  bool __bio_try_merge_page(struct bio *bio, struct page *page,
>  		unsigned int len, unsigned int off, bool same_page);
>  void __bio_add_page(struct bio *bio, struct page *page,
> -		unsigned int len, unsigned int off);
> +		unsigned int len, unsigned int off, bool is_gup);
>  int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter);
>  struct rq_map_data;
>  extern struct bio *bio_map_user_iov(struct request_queue *,
> diff --git a/kernel/power/swap.c b/kernel/power/swap.c
> index d7f6c1a288d3..ca5e0e1576e3 100644
> --- a/kernel/power/swap.c
> +++ b/kernel/power/swap.c
> @@ -274,7 +274,7 @@ static int hib_submit_io(int op, int op_flags, pgoff_t page_off, void *addr,
>  	bio_set_dev(bio, hib_resume_bdev);
>  	bio_set_op_attrs(bio, op, op_flags);
>  
> -	if (bio_add_page(bio, page, PAGE_SIZE, 0) < PAGE_SIZE) {
> +	if (bio_add_page(bio, page, PAGE_SIZE, 0, false) < PAGE_SIZE) {
>  		pr_err("Adding page to bio failed at %llu\n",
>  		       (unsigned long long)bio->bi_iter.bi_sector);
>  		bio_put(bio);
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 6b3be0445c61..c36bfe4ba317 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -42,7 +42,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
>  		bio->bi_end_io = end_io;
>  
>  		for (i = 0; i < nr; i++)
> -			bio_add_page(bio, page + i, PAGE_SIZE, 0);
> +			bio_add_page(bio, page + i, PAGE_SIZE, 0, false);
>  		VM_BUG_ON(bio->bi_iter.bi_size != PAGE_SIZE * nr);
>  	}
>  	return bio;
> -- 
> 2.20.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

