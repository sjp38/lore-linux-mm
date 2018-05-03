Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 690D76B0009
	for <linux-mm@kvack.org>; Thu,  3 May 2018 09:16:32 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a16so5628781wmg.9
        for <linux-mm@kvack.org>; Thu, 03 May 2018 06:16:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i41-v6si6053654ede.346.2018.05.03.06.16.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 May 2018 06:16:31 -0700 (PDT)
Date: Thu, 3 May 2018 15:16:30 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] iomap: add a swapfile activation function
Message-ID: <20180503131630.tpfv5eu744vxx4gj@quack2.suse.cz>
References: <20180502203228.GA4141@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180502203228.GA4141@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: xfs <linux-xfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, hch@infradead.org, cyberax@amazon.com, jack@suse.cz, osandov@osandov.com, Eryu Guan <guaneryu@gmail.com>

On Wed 02-05-18 13:32:28, Darrick J. Wong wrote:
> +/*
> + * Collect physical extents for this swap file.  Physical extents reported to
> + * the swap code must be trimmed to align to a page boundary.  The logical
> + * offset within the file is irrelevant since the swapfile code maps logical
> + * page numbers of the swap device to the physical page-aligned extents.
> + */
> +static int iomap_swapfile_add_extent(struct iomap_swapfile_info *isi)
> +{
> +	struct iomap *iomap = &isi->iomap;
> +	unsigned long nr_pages;
> +	uint64_t first_ppage;
> +	uint64_t first_ppage_reported;
> +	uint64_t last_ppage;
> +	int error;
> +
> +	/*
> +	 * Round the start up and the length down so that the physical
> +	 * extent aligns to a page boundary.
> +	 */
> +	first_ppage = ALIGN(iomap->addr, PAGE_SIZE) >> PAGE_SHIFT;
> +	last_ppage = (ALIGN_DOWN(iomap->addr + iomap->length, PAGE_SIZE) >>
> +			PAGE_SHIFT) - 1;
> +	nr_pages = last_ppage - first_ppage + 1;

So if I pass in iomap->addr = 1k, iomap->length = 1k, I get first_ppage =
1, last_ppage = -1, and thus nr_pages = (unsigned long)-1 and the test
below does not hit although it should. I think you need there

	if (first_ppage > last_ppage)

Otherwise the patch looks good to me.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
