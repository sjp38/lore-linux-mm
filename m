Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 523272806D2
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 14:15:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n198so1512276wmg.9
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 11:15:15 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id 128si3330787wmd.74.2017.04.21.11.15.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 11:15:13 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id r190so23495990wme.1
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 11:15:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170413054248.GB16783@bbox>
References: <CAA25o9TyPusF1Frn2a4OAco-DKFcskZVzy6S2JvhTANpm8cL7A@mail.gmail.com>
 <20170413054248.GB16783@bbox>
From: Luigi Semenzato <semenzato@google.com>
Date: Fri, 21 Apr 2017 11:15:11 -0700
Message-ID: <CAA25o9RzWxWueRasHFVTwAPJ9k8uEJ9bd_FB3NwCDv_ZLK4BMA@mail.gmail.com>
Subject: Re: thrashing on file pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Tim Murray <timmurray@google.com>, Johannes Weiner <hannes@cmpxchg.org>, vinmenon@codeaurora.org

Thank you very much Minchan.

I took a look at Johannes proposal.  It all makes sense but I'd like
to point out one additional issue, which is partly a time scale issue.

In Chrome OS (and this potentially applies to Android) one common use
pattern is to do some work in one browser tab, then switch to another
tab and do some work there and so on (think of apps instead of tabs on
Android).  Thus there is a loose notion of a "working set of tabs".

For Chrome OS, it is important that the tab working set fit in memory
(RAM + swap).  If it does not, some tabs in the set get "discarded"
while using the others: i.e. the browser releases most of their
resources, including their javascript and DOM state.

Thus, swapping is *much* better than discarding, and usually faster.
Then it is quite allright for a renderer process (a process backing
one or more tabs) to make very little progress for some time, while it
pages in its code and data (mostly data in the case of Chrome OS).
The length of "some time" depends on the application, but in this case
(interactive application) could be as long as a small number of
seconds.

Thus there should be a way of nullifying any actions that may be taken
as a result of thrashing detection, because in these cases the
thrashing is expected and preferable to the alternatives.




On Wed, Apr 12, 2017 at 10:42 PM, Minchan Kim <minchan@kernel.org> wrote:
> Hi Luigi,
>
> On Tue, Apr 04, 2017 at 06:01:50PM -0700, Luigi Semenzato wrote:
>> Greetings MM community, and apologies for being out of touch.
>>
>> We're running into a MM problem which we encountered in the early
>> versions of Chrome OS, about 7 years ago, which is that under certain
>> interactive loads we thrash on executable pages.
>>
>> At the time, Mandeep Baines solved this problem by introducing a
>> min_filelist_kbytes parameter, which simply stops the scanning of the
>> file list whenever the number of pages in it is below that threshold.
>> This works surprisingly well for Chrome OS because the Chrome browser
>> has a known text size and is the only large user program.
>> Additionally we use Feedback-Directed Optimization to keep the hot
>> code together in the same pages.
>>
>> But given that Chromebooks can run Android apps, the picture is
>> changing.  We can bump min_filelist_kbytes, but we no longer have an
>> upper bound for the working set of a workflow which cycles through
>> multiple Android apps.  Tab/app switching is more natural and
>> therefore more frequent on laptops than it is on phones, and it puts a
>> bigger strain on the MM.
>>
>> I should mention that we manage memory also by OOM-killing Android
>> apps and discarding Chrome tabs before the system runs our of memory.
>> We also reassign kernel-OOM-kill priorities for the cases in which our
>> user-level killing code isn't quick enough.
>>
>> In our attempts to avoid the thrashing, we played around with
>> swappiness.  Dmitry Torokhov (three desks down from mine) suggested
>> shifting the upper bound of 100 to 200, which makes sense because we
>
> It does makes sense but look at below.
>
>> use zram to reclaim anonymous pages, and paging back from zram is a
>> lot faster than reading from SSD.  So I have played around with
>> swappiness up to 190 but I can still reproduce the thrashing.  I have
>> noticed this code in vmscan.c:
>>
>>         if (!sc->priority && swappiness) {
>>                 scan_balance = SCAN_EQUAL;
>>                 goto out;
>>         }
>>
>> which suggests that under heavy pressure, swappiness is ignored.  I
>> removed this code, but that didn't help either.  I am not fully
>> convinced that my experiments are fully repeatable (quite the
>> opposite), and there may be variations in the point at which thrashing
>> starts, but the bottom line is that it still starts.
>
> If sc->priroity is zero, maybe, it means VM would already reclaim
> lots of workingset. That might be one of reason you cannot see the
> difference.
>
> I think more culprit is as follow,
>
> get_scan_count:
>
>         if (!inactive_file_is_low(lruvec) && lruvec_lru_size() >> sc->priroity) {
>                 scan_balance = SCAN_FILE;
>                 goto out;
>         }
>
> And it works with
> shrink_list:
>         if (is_active_lru(lru))
>                 if (inactive_list_is_low(lru)
>                                 shrink_active_list(lru);
>
> It means VM prefer file-backed page to anonymous page reclaim until below condition.
>
> get_scan_count:
>
>         if (global_reclaim(sc)) {
>                 if (zonefile + zonefree <= high_wmark_pages(zone))
>                         scan_balance = SCAN_ANON;
>         }
>
> It means VM will protect some amount of file-backed pages but
> the amount of pages VM protected depends high watermark which relies on
> min_free_kbytes. Recently, you can control the size via watermark_scale_factor
> without min_free_kbytes. So you can mimic min_filelist_kbytes with that
> although it has limitation for high watermark(20%).
> (795ae7a0de6b, mm: scale kswapd watermarks in proportion to memory)
>
>>
>> Are we the only ones with this problem?  It's possible, since Android
>
> No. You're not lonely.
> http://lkml.kernel.org/r/20170317231636.142311-1-timmurray@google.com
>
> Johannes are preparing some patches(aggressive anonymous page reclaim
> + thrashing detection).
>
> https://lwn.net/Articles/690069/
> https://marc.info/?l=linux-mm&m=148351203826308
>
> I hope we makes progress the discussion to find some solution.
> Please, join the discussion if you have interested. :)
>
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
