Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 274706B53DA
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 13:01:01 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so1488250edz.15
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 10:01:01 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cf9-v6si116477ejb.120.2018.11.29.10.00.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 10:00:59 -0800 (PST)
Date: Thu, 29 Nov 2018 19:00:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Question about the laziness of MADV_FREE
Message-ID: <20181129180057.GZ6923@dhcp22.suse.cz>
References: <47407223-2fa2-2721-c6c3-1c1659dc474e@nh2.me>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <47407223-2fa2-2721-c6c3-1c1659dc474e@nh2.me>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Niklas =?iso-8859-1?Q?Hamb=FCchen?= <mail@nh2.me>
Cc: linux-mm@kvack.org

On Thu 29-11-18 18:46:17, Niklas Hamb�chen wrote:
> Hello,
> 
> I'm trying to investigate the memory behaviour of a program that uses madvise(MADV_FREE) to tell the kernel that it no longer uses some pages.
> 
> I'm seeing some things I can't quite explain, concerning when freeing happens and how it is accounted for in /proc/pid/smaps.
> 
> `man madvise` shows:
> 
>        MADV_FREE (since Linux 4.5)
>               The application no longer requires the pages in the range
>               specified by addr and len.  The kernel can thus free these
>               pages, but the freeing could be delayed until memory pressure
>               occurs.
>               ...
>               On a swapless system, freeing
>               pages in a given range happens instantly, regardless of memory
>               pressure.

This part is outdated since 93e06c7a6453 ("mm: enable MADV_FREE for
swapless system") since 4.12. Something to fix in the man page. I will
send a patch for that. Thanks for pointing it out.

> https://www.kernel.org/doc/Documentation/filesystems/proc.txt says:
> 
>     "LazyFree" shows the amount of memory which is marked by madvise(MADV_FREE).
>     The memory isn't freed immediately with madvise(). It's freed in memory
>     pressure if the memory is clean. Please note that the printed value might
>     be lower than the real value due to optimizations used in the current
>     implementation. If this is not desirable please file a bug report.
> 
> First, I am on a swapless system.
> Nevertheless do I do not observe freeing happening instantly.
> Instead, freeing does happen only under memory pressure.

Yes this is how MADV_FREE is implemented.

> For example, on a 64 GB RAM machine I have a process taking 30 GB resident memory ("RES" in tools like htop). After I put on memory pressure (for example using `stress-ng --vm-bytes 1G --vm-keep -m 50` to allocate and touch 50 GB), RES for that process decreases to 10 GB.
> 
> At the same time, I can see the number in LazyFree decrease during this operation.

Those pages get reclaimed under memory pressure.

> According to the man page, I would not expect this "ballooning" to be
> necessary given that I have no swap.
> 
> Question 1:
> Is `man madvise` outdated? Or am I measuring wrong?

yep.

> Question 2:
> Is the swap condition really binary? E.g. if the man page is accurate, would me adding 1 MB swap already make a difference in the behaviour, or are there more sophisticated rules at play?

It used to be like that.

> Second, as you can see above, the proc-documentation of LazyFree does not mention any special swap rules.
> 
> Third, can anybody elaborate on "the printed value might be lower
> than the real value due to optimizations used in the current
> implementation"? How far off might the reported LazyFree be?

We batch multiple pages to become really lazyfree. This means that those
pages are sitting on a per-cpu list (see mark_page_lazyfree). So the
the number drift depends on the number of CPUs.

> For my investigation it would be very useful if I could get accurate accounting.
> How much work would the "If this is not desirable please file a bug report" bit entail?

What would be the reason to get the exact number?
-- 
Michal Hocko
SUSE Labs
