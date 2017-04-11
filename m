Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 68F366B03A5
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 15:25:38 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k14so697324wrc.16
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 12:25:38 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id j11si9263343wre.322.2017.04.11.12.25.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 12:25:36 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id t189so8580265wmt.1
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 12:25:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA25o9TyPusF1Frn2a4OAco-DKFcskZVzy6S2JvhTANpm8cL7A@mail.gmail.com>
References: <CAA25o9TyPusF1Frn2a4OAco-DKFcskZVzy6S2JvhTANpm8cL7A@mail.gmail.com>
From: Luigi Semenzato <semenzato@google.com>
Date: Tue, 11 Apr 2017 12:25:35 -0700
Message-ID: <CAA25o9QvXMOj1RpJZTP7UfZP8uR0e-nexuFbVSAVWBMWjV8EnQ@mail.gmail.com>
Subject: Re: thrashing on file pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>

Maybe this message was too long.  Quick summary:

Are we (chrome os) the only ones who experience thrashing from
excessive eviction of code pages?

Chrome OS added a mechanism (also called "the hacky patch")
https://codereview.chromium.org/4128001 which stops the scanning of
file lists below a fixed threshold (configurable with sysctl).  This
has worked very well.  Would it be worth upstreaming?  Are there
alternatives?

We have other ways of freeing up memory---specifically we close Chrome
tabs (and Android apps, now).  But, depending on allocation speed, we
may get behind with the freeing, and end up thrashing to the point
that even OOM kills are seriously delayed.

And furthermore: are we the only one who would like to see the max
value for swappiness be raised from 100 to 200?  This seems reasonable
when the swap device is much faster than the file backing device.

These may not be issues on servers, where the load is carefully
controlled.  But they seem hard to avoid on consumer devices.

Your reply will help millions of people!  (Us too, but that's just a
side effect.)

Thanks :)






On Tue, Apr 4, 2017 at 6:01 PM, Luigi Semenzato <semenzato@google.com> wrote:
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
>
> Are we the only ones with this problem?  It's possible, since Android
> by design can be aggressive in killing processes, and conversely
> Chrome OS is popular in the low-end of the market, where devices with
> 2GB of RAM are still common, and memory exhaustion can be reached
> pretty easily.  I noticed that vmscan.c has code which tries to
> protect pages with the VM_EXEC flag from premature eviction, so the
> problem might have been seen before in some form.
>
> I'll be grateful for any suggestion, advice, or other information.  Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
