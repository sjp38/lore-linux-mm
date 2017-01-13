Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D22B36B0253
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 01:47:24 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so105716035pfb.7
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 22:47:24 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id e5si11766588plb.138.2017.01.12.22.47.23
        for <linux-mm@kvack.org>;
        Thu, 12 Jan 2017 22:47:24 -0800 (PST)
Date: Fri, 13 Jan 2017 15:47:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170113064719.GA8018@bbox>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <20170109234110.GA10298@bbox>
 <20170113042444.GE9360@jagdpanzerIV.localdomain>
 <20170113062343.GA7827@bbox>
 <20170113063614.GA484@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113063614.GA484@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: zhouxianrong@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On Fri, Jan 13, 2017 at 03:36:14PM +0900, Sergey Senozhatsky wrote:
> On (01/13/17 15:23), Minchan Kim wrote:
> [..]
> > > > Please add same_pages to tail of the stat
> > > 
> > > sounds ok to me. and yes, can deprecate zero_pages.
> > > 
> > > seems that with that patch the concept of ZRAM_ZERO disappears. both
> > > ZERO and SAME_ELEMENT pages are considered to be the same thing now.
> > 
> > Right.
> > 
> > > which is fine and makes sense to me, I think. and if ->.same_pages will
> > > replace ->.zero_pages in mm_stat() then I'm also OK. yes, we will see
> > > increased number in the last column of mm_stat file, but I don't tend
> > > to see any issues here. Minchan, what do you think?
> > 
> > Could you elaborate a bit? Do you mean this?
> > 
> >         ret = scnprintf(buf, PAGE_SIZE,
> >                         "%8llu %8llu %8llu %8lu %8ld %8llu %8lu\n",
> >                         orig_size << PAGE_SHIFT,
> >                         (u64)atomic64_read(&zram->stats.compr_data_size),
> >                         mem_used << PAGE_SHIFT,
> >                         zram->limit_pages << PAGE_SHIFT,
> >                         max_used << PAGE_SHIFT,
> >                         // (u64)atomic64_read(&zram->stats.zero_pages),
> >                         (u64)atomic64_read(&zram->stats.same_pages),
> >                         pool_stats.pages_compacted);
> 
> yes, correct.
> 
> do we need to export it as two different stats (zero_pages and
> same_pages), if those are basically same thing internally?

So, let summary up.

1. replace zero_page stat into same page stat in mm_stat
2. s/zero_pages/same_pages/Documentation/blockdev/zram.txt
3. No need to warn to "cat /sys/block/zram0/mm_stat" user to see zero_pages
   about semantic change

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
