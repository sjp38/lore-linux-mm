Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD176B02C3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 09:29:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j83so32617790pfe.10
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 06:29:07 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f16si914958plk.484.2017.08.08.06.29.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 06:29:05 -0700 (PDT)
Date: Tue, 8 Aug 2017 06:29:04 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1 2/6] fs: use on-stack-bio if backing device has
 BDI_CAP_SYNC capability
Message-ID: <20170808132904.GC31390@bombadil.infradead.org>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org>
 <1502175024-28338-3-git-send-email-minchan@kernel.org>
 <20170808124959.GB31390@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170808124959.GB31390@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>

On Tue, Aug 08, 2017 at 05:49:59AM -0700, Matthew Wilcox wrote:
> +	struct bio sbio;
> +	struct bio_vec sbvec;

... this needs to be sbvec[nr_pages], of course.

> -		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
> +		if (bdi_cap_synchronous_io(inode_to_bdi(inode))) {
> +			bio = &sbio;
> +			bio_init(bio, &sbvec, nr_pages);

... and this needs to be 'sbvec', not '&sbvec'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
