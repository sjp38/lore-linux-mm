Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4837B6B0253
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 23:24:33 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 204so99030118pfx.1
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 20:24:33 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id x32si11417506pld.31.2017.01.12.20.24.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 20:24:32 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id b22so6377808pfd.3
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 20:24:32 -0800 (PST)
Date: Fri, 13 Jan 2017 13:24:44 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170113042444.GE9360@jagdpanzerIV.localdomain>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <20170109234110.GA10298@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170109234110.GA10298@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: zhouxianrong@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

Hello,

sorry, was mostly offline for the past few days, now catching up.

On (01/10/17 08:41), Minchan Kim wrote:
> > the idea is that without doing more calculations we extend zero pages
> > to same element pages for zram. zero page is special case of
> > same element page with zero element.
> > 

interesting idea.

[..]
> >  	flush_dcache_page(page);
> > @@ -431,7 +479,7 @@ static ssize_t mm_stat_show(struct device *dev,
> >  			mem_used << PAGE_SHIFT,
> >  			zram->limit_pages << PAGE_SHIFT,
> >  			max_used << PAGE_SHIFT,
> > -			(u64)atomic64_read(&zram->stats.zero_pages),
> > +			(u64)atomic64_read(&zram->stats.same_pages),
> 
> Unfortunately, we cannot replace zero pages stat with same pages's one right
> now due to compatibility problem. Please add same_pages to tail of the stat
> and we should warn deprecated zero_pages stat so we finally will remove it
> two year later. Please reference Documentation/ABI/obsolete/sysfs-block-zram
> And add zero-pages to the document.
> 
> For example,
> 
> ... mm_stat_show()
> {
>         pr_warn_once("zero pages was deprecated so it will be removed at 2019 Jan");
> }
> 
> Sergey, what's your opinion?

oh, I was going to ask you whether you have any work in progress at
the moment or not. because deprecated attrs are scheduled to be removed
in 4.11. IOW, we must send the clean up patch, well, right now. so I can
prepare the patch, but it can conflict with someone's 'more serious/relevant'
work.

we also have zram hot/addd sysfs attr, which must be deprecated and
converted to a char device. per Greg KH.

> Please add same_pages to tail of the stat

sounds ok to me. and yes, can deprecate zero_pages.

seems that with that patch the concept of ZRAM_ZERO disappears. both
ZERO and SAME_ELEMENT pages are considered to be the same thing now.
which is fine and makes sense to me, I think. and if ->.same_pages will
replace ->.zero_pages in mm_stat() then I'm also OK. yes, we will see
increased number in the last column of mm_stat file, but I don't tend
to see any issues here. Minchan, what do you think?


> -ZRAM_ATTR_RO(zero_pages);
> +ZRAM_ATTR_RO(same_pages);

this part is a no-no-no-no :)  we can't simply rename the user space
visible attrs.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
