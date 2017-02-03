Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF0C46B0038
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 10:33:51 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c73so26280449pfb.7
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 07:33:51 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t12si25777963pfj.24.2017.02.03.07.33.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 07:33:50 -0800 (PST)
Date: Fri, 3 Feb 2017 07:33:50 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170203153350.GC2267@bombadil.infradead.org>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1486111347-112972-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1486111347-112972-1-git-send-email-zhouxianrong@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, minchan@kernel.org, iamjoonsoo.kim@lge.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On Fri, Feb 03, 2017 at 04:42:27PM +0800, zhouxianrong@huawei.com wrote:
> +static inline void zram_fill_page_partial(char *ptr, unsigned int size,
> +		unsigned long value)
> +{
> +	int i;
> +	unsigned long *page;
> +
> +	if (likely(value == 0)) {
> +		memset(ptr, 0, size);
> +		return;
> +	}
> +
> +	i = ((unsigned long)ptr) % sizeof(*page);
> +	if (i) {
> +		while (i < sizeof(*page)) {
> +			*ptr++ = (value >> (i * 8)) & 0xff;
> +			--size;
> +			++i;
> +		}
> +	}
> +
> +	for (i = size / sizeof(*page); i > 0; --i) {
> +		page = (unsigned long *)ptr;
> +		*page = value;
> +		ptr += sizeof(*page);
> +		size -= sizeof(*page);
> +	}
> +
> +	for (i = 0; i < size; ++i)
> +		*ptr++ = (value >> (i * 8)) & 0xff;
> +}

You're assuming little-endian here.  I think you need to do a
cpu_to_le() here, but I don't think we have a cpu_to_leul, only
cpu_to_le64/cpu_to_le32.  So you may have some work to do ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
