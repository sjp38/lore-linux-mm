Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E320DC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:18:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91C562171F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 20:18:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AxwBpRf+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91C562171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D5808E0003; Mon, 28 Jan 2019 15:18:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 184D58E0001; Mon, 28 Jan 2019 15:18:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09B818E0003; Mon, 28 Jan 2019 15:18:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC2B78E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 15:18:16 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id o23so12593499pll.0
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 12:18:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wgPt2H/DmAnwlgup2soLzlWLYtVHWSMfqaiqmsG/OYk=;
        b=GunTO9q6FXA9I/5pMHXD6mfclmoZ49X30xAS75QeUhFE+CzwfqPTzZUhHGWOa4vvm0
         2nPYOYi8eY+e1+SrdTAD2Mb2em3MftVLbSKobjuywgXgDvaRLn8PMrUNXafQKTabGQ5v
         tPDkO2JhbyAjzu+TVs3varDOUnhM8KydamPM60mOFjoA3B8w1IqqVQ4yN9oqPKfkP10u
         pPNkPHZYIXlx4lpkf5WedgJXAuH1iYrZQ/KmSu3TJEMzv42GnNVHY7249Uye5TjZwOG+
         rMcAyxPRQ+/irm7pJ4zlFtsNhtYyCR02TPTX3rIlokrdc4KKa2S4ltyXT9zsWpN68Wae
         zjew==
X-Gm-Message-State: AJcUukfm1NwYcMN/gN37+tPId7MKOWbwOIyfc7uo5awZIF0DDQW60r+v
	2JLLonlNJvPMhV/dnmiWolsSOWMxSG9wdHeRlGeBSkoq+sGZvfAHLJs8vTA5AaQvfTdk7gQ3fbl
	2fI+p4CcK7lE7YCgP/8cjFbgH/gcQeOFDg0bZ6Wd5snnUs42XQO+DDULIluDniiq5Sw==
X-Received: by 2002:a62:6b8a:: with SMTP id g132mr23474238pfc.201.1548706696367;
        Mon, 28 Jan 2019 12:18:16 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7Ed/M9oxG25dvkczkizsaHN/gz32qTL/tDdYl2isXeIcEfyF3GIimHlbN5UCix4a6tkBw1
X-Received: by 2002:a62:6b8a:: with SMTP id g132mr23474200pfc.201.1548706695704;
        Mon, 28 Jan 2019 12:18:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548706695; cv=none;
        d=google.com; s=arc-20160816;
        b=gpa7FOyVVEyExqpYuXMiMLDpQwWPKZJ6Rvdkt7STHbKlO83fPN+YV9TAXBvL7q7mYJ
         z2AylG/oLy+cBdFhGlR7UvrGBznPFuEvT+sa7PDnbGTjU9KRd3ZtULI+ddeskUSypsD6
         hdphmK6xptKAx0H19iqtpkJsrQbkbzo8Py/LCJBImpqZSC64OmAFeOyD1CkuBFcPYNR5
         9X/yQ+lsRzF4mWbD/759/eK1zBFPg5V3djHcYrrDWLKvxSY0Al/jxlJTq2sX/LknbvdR
         0nAPpZoMF4vxHX6cPVIB9wnUreU+ky2g6R2r7AU7A/thohJoosN0FAM6moLTYUV8xL/0
         ArUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wgPt2H/DmAnwlgup2soLzlWLYtVHWSMfqaiqmsG/OYk=;
        b=QN6MR1cmvIniHbscBhpdyQWg2LfzkafsYAan6KGnJb3Fd2/+e99YOyeH17VssJUCWo
         lv/DTdmbmSKhBHAel6NJkWnPtF+l2ELdfpSyj+R/ar07shwpTO7kPwt45QEdM9aM9cUa
         qVF11E05NcPOuNfHJZlmlNNFd2l6khhgAdCVr11/zxNiS7GiWvXqHQ+0YT0tZEgLQuub
         Evl5ofQTvcQl9RgizWj/fzuhWC70YPSpBFw6bKsXY/jaeD43XKQ0Vr9Jv/ZCvEw6vY8G
         yybLFUN2GuIJIflOmPl20bFGduq5UBvNcztqe5WSsG4JzRzD1zBPHJUWXhKm+qB0mzXC
         eMvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AxwBpRf+;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id x24si32825788plr.379.2019.01.28.12.18.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 28 Jan 2019 12:18:15 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) client-ip=198.137.202.133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AxwBpRf+;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 198.137.202.133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=wgPt2H/DmAnwlgup2soLzlWLYtVHWSMfqaiqmsG/OYk=; b=AxwBpRf+SNWzzD9VADhvwc1Ag
	kAZVydJhlTokrIZkzQKECuK2h3XcAKO+THB4GofmZQTbz/iXZwa7kWzMGak99Z6YKjzjfbV3vpc9y
	lg34617NFdugAZ8/XPyQ8HGYHjNNd7gL3t6h6vsskfrtYQi4YRuWUWGc/imgh6SUiJMHUKHZqh6/v
	zOZUG/S7J+9f7Tf0Cl6tz3zXQmGrplsQkz6NqRZPlQHVYMfJYbdY3BNsNDgcar+qBvVJsedcoQI/h
	Z2Qf/fPTqsXjiou1U+JvdDGl89BdaTA/JUHJVAxNWT2yLKuSOiNq0mtMBZTJCk4ycK3Ri1qBwEx3O
	sFlIn97Qw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1goDM5-0001VU-H3; Mon, 28 Jan 2019 20:18:05 +0000
Date: Mon, 28 Jan 2019 12:18:05 -0800
From: Matthew Wilcox <willy@infradead.org>
To: zhengbin <zhengbin13@huawei.com>
Cc: Goldwyn Rodrigues <rgoldwyn@suse.com>, Christoph Hellwig <hch@lst.de>,
	Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>,
	akpm@linux-foundation.org, darrick.wong@oracle.com,
	amir73il@gmail.com, david@fromorbit.com, hannes@cmpxchg.org,
	jrdr.linux@gmail.com, hughd@google.com, linux-mm@kvack.org,
	houtao1@huawei.com, yi.zhang@huawei.com
Subject: Re: [PATCH] mm/filemap: pass inclusive 'end_byte' parameter to
 filemap_range_has_page
Message-ID: <20190128201805.GA31437@bombadil.infradead.org>
References: <1548678679-18122-1-git-send-email-zhengbin13@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1548678679-18122-1-git-send-email-zhengbin13@huawei.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 28, 2019 at 08:31:19PM +0800, zhengbin wrote:
> The 'end_byte' parameter of filemap_range_has_page is required to be
> inclusive, so follow the rule.

Reviewed-by: Matthew Wilcox <willy@infradead.org>
Fixes: 6be96d3ad34a ("fs: return if direct I/O will trigger writeback")

Adding the people in the sign-off chain to the Cc.

> Signed-off-by: zhengbin <zhengbin13@huawei.com>
> ---
>  mm/filemap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 9f5e323..a236bf3 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -3081,7 +3081,7 @@ generic_file_direct_write(struct kiocb *iocb, struct iov_iter *from)
>  	if (iocb->ki_flags & IOCB_NOWAIT) {
>  		/* If there are pages to writeback, return */
>  		if (filemap_range_has_page(inode->i_mapping, pos,
> -					   pos + write_len))
> +					   pos + write_len - 1))
>  			return -EAGAIN;
>  	} else {
>  		written = filemap_write_and_wait_range(mapping, pos,
> --
> 2.7.4
> 

