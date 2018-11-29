Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E6EA6B53CA
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 12:46:26 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id x13so1730503wro.9
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 09:46:26 -0800 (PST)
Received: from mail.grenz-bonn.de (mail.grenz-bonn.de. [178.33.37.38])
        by mx.google.com with ESMTPS id k13si2055000wrm.210.2018.11.29.09.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 09:46:24 -0800 (PST)
Received: from [192.168.42.60] (unknown [213.55.176.240])
	by ks357529.kimsufi.com (Postfix) with ESMTPSA id 1CC8FA0F32
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 18:46:23 +0100 (CET)
From: =?UTF-8?Q?Niklas_Hamb=c3=bcchen?= <mail@nh2.me>
Subject: Question about the laziness of MADV_FREE
Message-ID: <47407223-2fa2-2721-c6c3-1c1659dc474e@nh2.me>
Date: Thu, 29 Nov 2018 18:46:17 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello,

I'm trying to investigate the memory behaviour of a program that uses madvise(MADV_FREE) to tell the kernel that it no longer uses some pages.

I'm seeing some things I can't quite explain, concerning when freeing happens and how it is accounted for in /proc/pid/smaps.

`man madvise` shows:

       MADV_FREE (since Linux 4.5)
              The application no longer requires the pages in the range
              specified by addr and len.  The kernel can thus free these
              pages, but the freeing could be delayed until memory pressure
              occurs.
              ...
              On a swapless system, freeing
              pages in a given range happens instantly, regardless of memory
              pressure.

https://www.kernel.org/doc/Documentation/filesystems/proc.txt says:

    "LazyFree" shows the amount of memory which is marked by madvise(MADV_FREE).
    The memory isn't freed immediately with madvise(). It's freed in memory
    pressure if the memory is clean. Please note that the printed value might
    be lower than the real value due to optimizations used in the current
    implementation. If this is not desirable please file a bug report.

First, I am on a swapless system.
Nevertheless do I do not observe freeing happening instantly.
Instead, freeing does happen only under memory pressure.

For example, on a 64 GB RAM machine I have a process taking 30 GB resident memory ("RES" in tools like htop). After I put on memory pressure (for example using `stress-ng --vm-bytes 1G --vm-keep -m 50` to allocate and touch 50 GB), RES for that process decreases to 10 GB.

At the same time, I can see the number in LazyFree decrease during this operation.

According to the man page, I would not expect this "ballooning" to be necessary given that I have no swap.

Question 1:
Is `man madvise` outdated? Or am I measuring wrong?

Question 2:
Is the swap condition really binary? E.g. if the man page is accurate, would me adding 1 MB swap already make a difference in the behaviour, or are there more sophisticated rules at play?

Second, as you can see above, the proc-documentation of LazyFree does not mention any special swap rules.

Third, can anybody elaborate on "the printed value might be lower than the real value due to optimizations used in the current implementation"? How far off might the reported LazyFree be?
For my investigation it would be very useful if I could get accurate accounting.
How much work would the "If this is not desirable please file a bug report" bit entail?

Any answers would be very appreciated!
Niklas
