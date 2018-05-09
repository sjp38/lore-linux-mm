Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1B86B0526
	for <linux-mm@kvack.org>; Wed,  9 May 2018 11:12:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s3so26392273pfh.0
        for <linux-mm@kvack.org>; Wed, 09 May 2018 08:12:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 9-v6si26953550plf.283.2018.05.09.08.12.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 08:12:46 -0700 (PDT)
Date: Wed, 9 May 2018 08:12:43 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 01/33] block: add a lower-level bio_add_page interface
Message-ID: <20180509151243.GA1313@bombadil.infradead.org>
References: <20180509074830.16196-1-hch@lst.de>
 <20180509074830.16196-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509074830.16196-2-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Wed, May 09, 2018 at 09:47:58AM +0200, Christoph Hellwig wrote:
> +/**
> + * __bio_try_merge_page - try adding data to an existing bvec
> + * @bio: destination bio
> + * @page: page to add
> + * @len: length of the range to add
> + * @off: offset into @page
> + *
> + * Try adding the data described at @page + @offset to the last bvec of @bio.
> + * Return %true on success or %false on failure.  This can happen frequently
> + * for file systems with a block size smaller than the page size.
> + */

Could we make this:

/**
 * __bio_try_merge_page() - Try appending data to an existing bvec.
 * @bio: Destination bio.
 * @page: Page to add.
 * @len: Length of the data to add.
 * @off: Offset of the data in @page.
 *
 * Try to add the data at @page + @off to the last bvec of @bio.  This is
 * a useful optimisation for file systems with a block size smaller than
 * the page size.
 *
 * Context: Any context.
 * Return: %true on success or %false on failure.
 */

(page, len, off) is a bit weird to me.  Usually we do (page, off, len).

> +/**
> + * __bio_add_page - add page to a bio in a new segment
> + * @bio: destination bio
> + * @page: page to add
> + * @len: length of the range to add
> + * @off: offset into @page
> + *
> + * Add the data at @page + @offset to @bio as a new bvec.  The caller must
> + * ensure that @bio has space for another bvec.
> + */

/**
 * __bio_add_page - Add page to a bio in a new segment.
 * @bio: Destination bio.
 * @page: Page to add.
 * @len: Length of the data to add.
 * @off: Offset of the data in @page.
 *
 * Add the data at @page + @off to @bio as a new bvec.  The caller must
 * ensure that @bio has space for another bvec.
 *
 * Context: Any context.
 */

> +static inline bool bio_full(struct bio *bio)
> +{
> +	return bio->bi_vcnt >= bio->bi_max_vecs;
> +}

I really like this helper.
