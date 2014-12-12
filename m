Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C83376B006C
	for <linux-mm@kvack.org>; Fri, 12 Dec 2014 01:39:58 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so6626770pac.36
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 22:39:58 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id pv9si588289pac.112.2014.12.11.22.39.55
        for <linux-mm@kvack.org>;
        Thu, 11 Dec 2014 22:39:57 -0800 (PST)
Date: Fri, 12 Dec 2014 15:40:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: disclose statistics to debugfs
Message-ID: <20141212064055.GA17166@bbox>
References: <1418218820-4153-1-git-send-email-opensource.ganesh@gmail.com>
 <20141211234005.GA13405@bbox>
 <CADAEsF9cZ-JOrKx1_9FCu7_SW19Je938wK_wdy+jdBTehgZiXw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CADAEsF9cZ-JOrKx1_9FCu7_SW19Je938wK_wdy+jdBTehgZiXw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Dec 12, 2014 at 01:53:16PM +0800, Ganesh Mahendran wrote:
> Hello Minchan
> 
> 2014-12-12 7:40 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> > Hello Ganesh,
> >
> > On Wed, Dec 10, 2014 at 09:40:20PM +0800, Ganesh Mahendran wrote:
> >> As we now talk more and more about the fragmentation of zsmalloc. But
> >> we still need to manually add some debug code to see the fragmentation.
> >> So, I think we may add the statistics of memory fragmention in zsmalloc
> >> and disclose them to debugfs. Then we can easily get and analysis
> >> them when adding or developing new feature for zsmalloc.
> >>
> >> Below entries will be created when a zsmalloc pool is created:
> >>     /sys/kernel/debug/zsmalloc/pool-n/obj_allocated
> >>     /sys/kernel/debug/zsmalloc/pool-n/obj_used
> >>
> >> Then the status of objects usage will be:
> >>     objects_usage = obj_used / obj_allocated
> >>
> >
> > I didn't look at the code in detail but It would be handy for developer
> > but not sure we should deliver it to admin so need configurable?
> What kind of configuration do you want?
> I think it is reasonable to expose such information to admin like
> */sys/kernel/debug/usb/device*
> 
> Or maybe we can enclose these code by DEBUG macro which will be
> defined when CONFIG_ZSMALLOC_DEBUG is selected.

Hmm, I'd like to separte DEBUG and STAT because we can add some
sanity checking(ex, poisoning for invalid overwriting or
handle<->obj mapping verification) with DEBUG while we could
count obj stat with STAT.

So, now it seems you want CONFIG_ZSMALLOC_STAT?

> 
> >
> > How about making it per-sizeclass information, not per-pool?
> Yes, you are right. Per sizeclass information will be better for
> developers than per pool.
> 
> Is it acceptable to show 256 lines like:
> #cat /sys/kernel/debug/zsmalloc/pool-1/obj_in_classes
> class      obj_allocated     obj_used
> 1 ...
> 2 ...
> ....
> ....
> 255
> 
> Anyway for developers, these information is more usefull.

It would be better to show the number of pages so we can know
how many of fragment space in last subpage of zspage is wasted.
But I don't want to keep pages_used in memory but you could
calcurate it dynamically with obj_allocated when user access debugfs.

#cat /sys/kernel/debug/zsmalloc/pool-1/obj_in_classes
class-size      obj_allocated     obj_used    pages_used
32
48
.
.
.

Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
