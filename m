Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3ED6B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 01:23:51 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y143so104111090pfb.6
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 22:23:51 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id n65si11693703pfn.198.2017.01.12.22.23.49
        for <linux-mm@kvack.org>;
        Thu, 12 Jan 2017 22:23:50 -0800 (PST)
Date: Fri, 13 Jan 2017 15:23:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170113062343.GA7827@bbox>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <20170109234110.GA10298@bbox>
 <20170113042444.GE9360@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113042444.GE9360@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: zhouxianrong@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

Hi Sergey,

On Fri, Jan 13, 2017 at 01:24:44PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> sorry, was mostly offline for the past few days, now catching up.
> 
> On (01/10/17 08:41), Minchan Kim wrote:
> > > the idea is that without doing more calculations we extend zero pages
> > > to same element pages for zram. zero page is special case of
> > > same element page with zero element.
> > > 
> 
> interesting idea.
> 
> [..]
> > >  	flush_dcache_page(page);
> > > @@ -431,7 +479,7 @@ static ssize_t mm_stat_show(struct device *dev,
> > >  			mem_used << PAGE_SHIFT,
> > >  			zram->limit_pages << PAGE_SHIFT,
> > >  			max_used << PAGE_SHIFT,
> > > -			(u64)atomic64_read(&zram->stats.zero_pages),
> > > +			(u64)atomic64_read(&zram->stats.same_pages),
> > 
> > Unfortunately, we cannot replace zero pages stat with same pages's one right
> > now due to compatibility problem. Please add same_pages to tail of the stat
> > and we should warn deprecated zero_pages stat so we finally will remove it
> > two year later. Please reference Documentation/ABI/obsolete/sysfs-block-zram
> > And add zero-pages to the document.
> > 
> > For example,
> > 
> > ... mm_stat_show()
> > {
> >         pr_warn_once("zero pages was deprecated so it will be removed at 2019 Jan");
> > }
> > 
> > Sergey, what's your opinion?
> 
> oh, I was going to ask you whether you have any work in progress at
> the moment or not. because deprecated attrs are scheduled to be removed
> in 4.11. IOW, we must send the clean up patch, well, right now. so I can
> prepare the patch, but it can conflict with someone's 'more serious/relevant'
> work.

I think deprecating attrs is top priority to me so go ahead. :)

> 
> we also have zram hot/addd sysfs attr, which must be deprecated and
> converted to a char device. per Greg KH.
> 
> > Please add same_pages to tail of the stat
> 
> sounds ok to me. and yes, can deprecate zero_pages.
> 
> seems that with that patch the concept of ZRAM_ZERO disappears. both
> ZERO and SAME_ELEMENT pages are considered to be the same thing now.

Right.

> which is fine and makes sense to me, I think. and if ->.same_pages will
> replace ->.zero_pages in mm_stat() then I'm also OK. yes, we will see
> increased number in the last column of mm_stat file, but I don't tend
> to see any issues here. Minchan, what do you think?

Could you elaborate a bit? Do you mean this?

        ret = scnprintf(buf, PAGE_SIZE,
                        "%8llu %8llu %8llu %8lu %8ld %8llu %8lu\n",
                        orig_size << PAGE_SHIFT,
                        (u64)atomic64_read(&zram->stats.compr_data_size),
                        mem_used << PAGE_SHIFT,
                        zram->limit_pages << PAGE_SHIFT,
                        max_used << PAGE_SHIFT,
                        // (u64)atomic64_read(&zram->stats.zero_pages),
                        (u64)atomic64_read(&zram->stats.same_pages),
                        pool_stats.pages_compacted);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
