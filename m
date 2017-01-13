Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE166B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:07:56 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f144so108375662pfa.3
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 00:07:56 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u1si8407736plj.178.2017.01.13.00.07.54
        for <linux-mm@kvack.org>;
        Fri, 13 Jan 2017 00:07:55 -0800 (PST)
Date: Fri, 13 Jan 2017 17:03:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170113080330.GB8018@bbox>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <20170109234110.GA10298@bbox>
 <20170113042444.GE9360@jagdpanzerIV.localdomain>
 <20170113062343.GA7827@bbox>
 <20170113063614.GA484@jagdpanzerIV.localdomain>
 <20170113064719.GA8018@bbox>
 <20170113070245.GB484@jagdpanzerIV.localdomain>
MIME-Version: 1.0
In-Reply-To: <20170113070245.GB484@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: zhouxianrong@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

On Fri, Jan 13, 2017 at 04:02:45PM +0900, Sergey Senozhatsky wrote:
> On (01/13/17 15:47), Minchan Kim wrote:
> [..]
> > > > Could you elaborate a bit? Do you mean this?
> > > > 
> > > >         ret = scnprintf(buf, PAGE_SIZE,
> > > >                         "%8llu %8llu %8llu %8lu %8ld %8llu %8lu\n",
> > > >                         orig_size << PAGE_SHIFT,
> > > >                         (u64)atomic64_read(&zram->stats.compr_data_size),
> > > >                         mem_used << PAGE_SHIFT,
> > > >                         zram->limit_pages << PAGE_SHIFT,
> > > >                         max_used << PAGE_SHIFT,
> > > >                         // (u64)atomic64_read(&zram->stats.zero_pages),
> > > >                         (u64)atomic64_read(&zram->stats.same_pages),
> > > >                         pool_stats.pages_compacted);
> > > 
> > > yes, correct.
> > > 
> > > do we need to export it as two different stats (zero_pages and
> > > same_pages), if those are basically same thing internally?
> > 
> > So, let summary up.
> > 
> > 1. replace zero_page stat into same page stat in mm_stat
> > 2. s/zero_pages/same_pages/Documentation/blockdev/zram.txt
> > 3. No need to warn to "cat /sys/block/zram0/mm_stat" user to see zero_pages
> >    about semantic change
> 
> 1) account zero_page and same_pages in one attr.
> 
> 	this already is in the patch.
> 
> 2) do not rename zero_pages attr.
> 
> 	we can't do this so fast, I think.
> 
> 
> > 3. No need to warn to "cat /sys/block/zram0/mm_stat" user to see zero_pages
> >    about semantic change
> 
> yes. we just _may_ have more pages (depending on data pattern) which we treat
> as "zero" pages internally. this results in lower memory consumption. I don't
> think warn users about this change is necessary; they won't be able to do
> anything about it anyway. zero_pages stat is pretty much just a fun number to
> know. isn't it?
> 

I just wanted to confirm your thought.
I hope anyone doesn't is sensitive on that number. ;)
Let's replace zero_page stat field in mm_stat.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
