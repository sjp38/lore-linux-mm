Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8BDC86B0390
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 01:42:51 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p81so26029338pfd.12
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 22:42:51 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id f1si22784858plk.101.2017.04.12.22.42.49
        for <linux-mm@kvack.org>;
        Wed, 12 Apr 2017 22:42:50 -0700 (PDT)
Date: Thu, 13 Apr 2017 14:42:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: thrashing on file pages
Message-ID: <20170413054248.GB16783@bbox>
References: <CAA25o9TyPusF1Frn2a4OAco-DKFcskZVzy6S2JvhTANpm8cL7A@mail.gmail.com>
MIME-Version: 1.0
In-Reply-To: <CAA25o9TyPusF1Frn2a4OAco-DKFcskZVzy6S2JvhTANpm8cL7A@mail.gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, timmurray@google.com, Johannes Weiner <hannes@cmpxchg.org>, vinmenon@codeaurora.org

Hi Luigi,

On Tue, Apr 04, 2017 at 06:01:50PM -0700, Luigi Semenzato wrote:
> Greetings MM community, and apologies for being out of touch.
> 
> We're running into a MM problem which we encountered in the early
> versions of Chrome OS, about 7 years ago, which is that under certain
> interactive loads we thrash on executable pages.
> 
> At the time, Mandeep Baines solved this problem by introducing a
> min_filelist_kbytes parameter, which simply stops the scanning of the
> file list whenever the number of pages in it is below that threshold.
> This works surprisingly well for Chrome OS because the Chrome browser
> has a known text size and is the only large user program.
> Additionally we use Feedback-Directed Optimization to keep the hot
> code together in the same pages.
> 
> But given that Chromebooks can run Android apps, the picture is
> changing.  We can bump min_filelist_kbytes, but we no longer have an
> upper bound for the working set of a workflow which cycles through
> multiple Android apps.  Tab/app switching is more natural and
> therefore more frequent on laptops than it is on phones, and it puts a
> bigger strain on the MM.
> 
> I should mention that we manage memory also by OOM-killing Android
> apps and discarding Chrome tabs before the system runs our of memory.
> We also reassign kernel-OOM-kill priorities for the cases in which our
> user-level killing code isn't quick enough.
> 
> In our attempts to avoid the thrashing, we played around with
> swappiness.  Dmitry Torokhov (three desks down from mine) suggested
> shifting the upper bound of 100 to 200, which makes sense because we

It does makes sense but look at below.

> use zram to reclaim anonymous pages, and paging back from zram is a
> lot faster than reading from SSD.  So I have played around with
> swappiness up to 190 but I can still reproduce the thrashing.  I have
> noticed this code in vmscan.c:
> 
>         if (!sc->priority && swappiness) {
>                 scan_balance = SCAN_EQUAL;
>                 goto out;
>         }
> 
> which suggests that under heavy pressure, swappiness is ignored.  I
> removed this code, but that didn't help either.  I am not fully
> convinced that my experiments are fully repeatable (quite the
> opposite), and there may be variations in the point at which thrashing
> starts, but the bottom line is that it still starts.

If sc->priroity is zero, maybe, it means VM would already reclaim
lots of workingset. That might be one of reason you cannot see the
difference.

I think more culprit is as follow,

get_scan_count:

        if (!inactive_file_is_low(lruvec) && lruvec_lru_size() >> sc->priroity) {
                scan_balance = SCAN_FILE;
                goto out;
        }

And it works with
shrink_list:
        if (is_active_lru(lru))
                if (inactive_list_is_low(lru)
                                shrink_active_list(lru);

It means VM prefer file-backed page to anonymous page reclaim until below condition.

get_scan_count:

        if (global_reclaim(sc)) {
                if (zonefile + zonefree <= high_wmark_pages(zone))
                        scan_balance = SCAN_ANON;
        }

It means VM will protect some amount of file-backed pages but
the amount of pages VM protected depends high watermark which relies on
min_free_kbytes. Recently, you can control the size via watermark_scale_factor
without min_free_kbytes. So you can mimic min_filelist_kbytes with that
although it has limitation for high watermark(20%).
(795ae7a0de6b, mm: scale kswapd watermarks in proportion to memory)

> 
> Are we the only ones with this problem?  It's possible, since Android

No. You're not lonely.
http://lkml.kernel.org/r/20170317231636.142311-1-timmurray@google.com

Johannes are preparing some patches(aggressive anonymous page reclaim
+ thrashing detection).

https://lwn.net/Articles/690069/
https://marc.info/?l=linux-mm&m=148351203826308

I hope we makes progress the discussion to find some solution.
Please, join the discussion if you have interested. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
