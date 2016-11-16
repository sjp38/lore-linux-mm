Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id AE97A6B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 02:17:50 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id q186so37206603itb.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 23:17:50 -0800 (PST)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id a203si4388882ita.81.2016.11.15.23.17.48
        for <linux-mm@kvack.org>;
        Tue, 15 Nov 2016 23:17:50 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <6e2dec0d-cef5-60ac-2cf6-a89ded82e2f4@kernel.dk>
In-Reply-To: <6e2dec0d-cef5-60ac-2cf6-a89ded82e2f4@kernel.dk>
Subject: Re: [PATCH] mm: don't cap request size based on read-ahead setting
Date: Wed, 16 Nov 2016 15:17:33 +0800
Message-ID: <000701d23fd9$805dcdd0$81196970$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Jens Axboe' <axboe@kernel.dk>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 'Linus Torvalds' <torvalds@linux-foundation.org>

On Wednesday, November 16, 2016 12:31 PM Jens Axboe wrote:
> @@ -369,10 +369,25 @@ ondemand_readahead(struct address_space *mapping,
>   		   bool hit_readahead_marker, pgoff_t offset,
>   		   unsigned long req_size)
>   {
> -	unsigned long max = ra->ra_pages;
> +	unsigned long io_pages, max_pages;
>   	pgoff_t prev_offset;
> 
>   	/*
> +	 * If bdi->io_pages is set, that indicates the (soft) max IO size
> +	 * per command for that device. If we have that available, use
> +	 * that as the max suitable read-ahead size for this IO. Instead of
> +	 * capping read-ahead at ra_pages if req_size is larger, we can go
> +	 * up to io_pages. If io_pages isn't set, fall back to using
> +	 * ra_pages as a safe max.
> +	 */
> +	io_pages = inode_to_bdi(mapping->host)->io_pages;
> +	if (io_pages) {
> +		max_pages = max_t(unsigned long, ra->ra_pages, req_size);
> +		io_pages = min(io_pages, max_pages);

Doubt if you mean
		max_pages = min(io_pages, max_pages);
> +	} else
> +		max_pages = ra->ra_pages;
> +


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
