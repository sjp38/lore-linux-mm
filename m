Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8166F6B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 20:35:21 -0400 (EDT)
Received: by pacws9 with SMTP id ws9so122812515pac.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 17:35:21 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id kn8si857755pab.45.2015.07.07.17.35.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 17:35:20 -0700 (PDT)
Received: by pddu5 with SMTP id u5so47214508pdd.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 17:35:20 -0700 (PDT)
Date: Wed, 8 Jul 2015 09:35:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFCv3 0/5] enable migration of driver pages
Message-ID: <20150708003507.GA8764@blaptop.AC68U>
References: <1436243785-24105-1-git-send-email-gioh.kim@lge.com>
 <20150707153701.bfcde75108d1fb8aaedc8134@linux-foundation.org>
 <559C68B3.3010105@lge.com>
 <20150707170746.1b91ba0d07382cbc9ba3db92@linux-foundation.org>
 <559C6CA6.1050809@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <559C6CA6.1050809@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, viro@zeniv.linux.org.uk, mst@redhat.com, koct9i@gmail.com, aquini@redhat.com, linux-fsdevel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, gunho.lee@lge.com, Gioh Kim <gurugio@hanmail.net>

On Wed, Jul 08, 2015 at 09:19:50AM +0900, Gioh Kim wrote:
> 
> 
> 2015-07-08 i??i ? 9:07i?? Andrew Morton i?'(e??) i?' e,?:
> >On Wed, 08 Jul 2015 09:02:59 +0900 Gioh Kim <gioh.kim@lge.com> wrote:
> >
> >>
> >>
> >>2015-07-08 ______ 7:37___ Andrew Morton ___(___) ___ ___:
> >>>On Tue,  7 Jul 2015 13:36:20 +0900 Gioh Kim <gioh.kim@lge.com> wrote:
> >>>
> >>>>From: Gioh Kim <gurugio@hanmail.net>
> >>>>
> >>>>Hello,
> >>>>
> >>>>This series try to enable migration of non-LRU pages, such as driver's page.
> >>>>
> >>>>My ARM-based platform occured severe fragmentation problem after long-term
> >>>>(several days) test. Sometimes even order-3 page allocation failed. It has
> >>>>memory size 512MB ~ 1024MB. 30% ~ 40% memory is consumed for graphic processing
> >>>>and 20~30 memory is reserved for zram.
> >>>>
> >>>>I found that many pages of GPU driver and zram are non-movable pages. So I
> >>>>reported Minchan Kim, the maintainer of zram, and he made the internal
> >>>>compaction logic of zram. And I made the internal compaction of GPU driver.
> >>>>
> >>>>They reduced some fragmentation but they are not enough effective.
> >>>>They are activated by its own interface, /sys, so they are not cooperative
> >>>>with kernel compaction. If there is too much fragmentation and kernel starts
> >>>>to compaction, zram and GPU driver cannot work with the kernel compaction.
> >>>>
> >>>>...
> >>>>
> >>>>This patch set is tested:
> >>>>- turn on Ubuntu 14.04 with 1G memory on qemu.
> >>>>- do kernel building
> >>>>- after several seconds check more than 512MB is used with free command
> >>>>- command "balloon 512" in qemu monitor
> >>>>- check hundreds MB of pages are migrated
> >>>
> >>>OK, but what happens if the balloon driver is not used to force
> >>>compaction?  Does your test machine successfully compact pages on
> >>>demand, so those order-3 allocations now succeed?
> >>
> >>If any driver that has many pages like the balloon driver is forced to compact,
> >>the system can get free high-order pages.
> >>
> >>I have to show how this patch work with a driver existing in the kernel source,
> >>for kernel developers' undestanding. So I selected the balloon driver
> >>because it has already compaction and working with kernel compaction.
> >>I can show how driver pages is compacted with lru-pages together.
> >>
> >>Actually balloon driver is not best example to show how this patch compacts pages.
> >>The balloon driver compaction is decreasing page consumtion, for instance 1024MB -> 512MB.
> >>I think it is not compaction precisely. It frees pages.
> >>Of course there will be many high-order pages after 512MB is freed.
> >
> >Can the various in-kernel GPU drivers benefit from this?  If so, wiring
> >up one or more of those would be helpful?
> 
> I'm sure that other in-kernel GPU drivers can have benefit.
> It must be helpful.
> 
> If I was familiar with other in-kernel GPU drivers code, I tried to patch them.
> It's too bad.
> 
> Minchan Kim said he had a plan to apply this patch into zram compaction.
> Many embedded machines use several hundreds MB for zram.
> The zram can also have benefit with this patch as much as GPU drivers.
> 

Hello Gioh,

It would be helpful for fork-latency and zra+CMA in small memory system.
I will implement zsmalloc.migratepages after I finish current going works.

Thanks for the nice work!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
