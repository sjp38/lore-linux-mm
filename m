Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A03726B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 09:14:51 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f5so108017189pgi.1
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 06:14:51 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z40si808266plh.114.2017.02.06.06.14.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 06:14:50 -0800 (PST)
Date: Mon, 6 Feb 2017 06:14:48 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170206141448.GF2267@bombadil.infradead.org>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1486111347-112972-1-git-send-email-zhouxianrong@huawei.com>
 <20170205142100.GA9611@bbox>
 <2f6e188c-5358-eeab-44ab-7634014af651@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f6e188c-5358-eeab-44ab-7634014af651@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@huawei.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, iamjoonsoo.kim@lge.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On Mon, Feb 06, 2017 at 09:28:18AM +0800, zhouxianrong wrote:
> > > +static inline void zram_fill_page_partial(char *ptr, unsigned int size,
> > > +		unsigned long value)
> > > +{
> > > +	int i;
> > > +	unsigned long *page;
> > > +
> > > +	if (likely(value == 0)) {
> > > +		memset(ptr, 0, size);
> > > +		return;
> > > +	}
> > > +
> > > +	i = ((unsigned long)ptr) % sizeof(*page);
> > > +	if (i) {
> > > +		while (i < sizeof(*page)) {
> > > +			*ptr++ = (value >> (i * 8)) & 0xff;
> > > +			--size;
> > > +			++i;
> > > +		}
> > > +	}
> > > +
> > 
> > I don't think we need this part because block layer works with sector
> > size or multiple times of it so it must be aligned unsigned long.
> 
> Minchan and Matthew Wilcox:
> 
> 1. right, but users could open /dev/block/zram0 file and do any read operations.

But any such read operation would go through the page cache, so will
be page aligned.  Unless they do an O_DIRECT operation, in which case
it must be aligned to block size.  Please, try it.  I/Os which are not
aligned should be failed long before they reach your driver.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
