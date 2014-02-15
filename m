Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id EF9D06B0031
	for <linux-mm@kvack.org>; Sat, 15 Feb 2014 01:40:44 -0500 (EST)
Received: by mail-la0-f48.google.com with SMTP id mc6so9943765lab.35
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 22:40:44 -0800 (PST)
Received: from mail-lb0-x233.google.com (mail-lb0-x233.google.com [2a00:1450:4010:c04::233])
        by mx.google.com with ESMTPS id q5si11983479lbr.71.2014.02.14.22.40.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Feb 2014 22:40:42 -0800 (PST)
Received: by mail-lb0-f179.google.com with SMTP id l4so10061288lbv.10
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 22:40:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAMrOTPgBtANS_ryRjan0-dTL97U7eRvtf3dCsss=Kn+Uk89fuA@mail.gmail.com>
References: <CAMrOTPgBtANS_ryRjan0-dTL97U7eRvtf3dCsss=Kn+Uk89fuA@mail.gmail.com>
From: Pradeep Sawlani <pradeep.sawlani@gmail.com>
Date: Fri, 14 Feb 2014 22:40:21 -0800
Message-ID: <CAMrOTPgbDt16Tg-REvhzVKHZacVrphPBPxjkEMa=64TJjyZBLA@mail.gmail.com>
Subject: Re: KSM on Android
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: surim@lab126.com, Izik Eidus <izik.eidus@ravellosystems.com>

> Re-sending this in plain text format (Apologies)
>
> Hello,
>
> In pursuit of saving memory on Android, I started experimenting with
> Kernel Same Page Merging(KSM).
> Number of pages shared because of KSM is reported by
> /sys/kernel/mm/pages_sharing.
> Documentation/vm/ksm.txt explains this as:
>
> "pages_sharing    - how many more sites are sharing them i.e. how much saved"
>
> After enabling KSM on Android device, this number was reported as 19666 pages.
> Obvious optimization is to find out source of sharing and see if we
> can avoid duplicate pages at first place.
> In order to collect the data needed, It needed few
> modifications(trace_printk) statement in mm/ksm.c.
> Data should be collected from second cycle because that's when ksm
> starts merging
> pages. First KSM cycle is only used to calculate the checksum, pages
> are added to
> unstable tree and eventually moved to stable tree after this.
>
> After analyzing data from second KSM cycle, few things which stood out:
> 1.  In the same cycle, KSM can scan same page multiple times. Scanning
> a page involves
>     comparing page with pages in stable tree, if no match is found
> checksum is calculated.
>     From the look of it, it seems to be cpu intensive operation and
> impacts dcache as well.
>
> 2.  Same page which is already shared by multiple process can be
> replaced by KSM page.
>     In this case, let say a particular page is mapped 24 times and is
> replaced by KSM page then
>     eventually all 24 entries will point to KSM page. pages_sharing
> will account for all 24 pages.
>     so pages _sharing does not actually report amount of memory saved.
> From the above example actual
>     savings is one page.
>
> Both cases happen very often with Android because of its architecture
> - Zygote spawning(fork) multiple
> applications. To calculate actual savings, we should account for same
> page(pfn)replaced by same KSM page only once.
> In the case 2 example, page_sharing should account only one page.
> After recalculating memory saving comes out to be 8602 pages (~34MB).
>
> I am trying to find out right solution to fix pages_sharing and
> eventually optimize KSM to scan page
> once even if it is mapped multiple times.
>
> Comments?
>
Correct Izik's email address.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
