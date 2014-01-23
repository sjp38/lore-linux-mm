Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5AFFB6B0035
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 07:46:47 -0500 (EST)
Received: by mail-bk0-f45.google.com with SMTP id v16so328485bkz.4
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 04:46:46 -0800 (PST)
Received: from mail-ig0-x235.google.com (mail-ig0-x235.google.com [2607:f8b0:4001:c05::235])
        by mx.google.com with ESMTPS id tl9si10106939bkb.326.2014.01.23.04.46.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 04:46:46 -0800 (PST)
Received: by mail-ig0-f181.google.com with SMTP id j1so4631331iga.2
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 04:46:44 -0800 (PST)
Message-ID: <52E10F37.7030904@gmail.com>
Date: Thu, 23 Jan 2014 07:46:47 -0500
From: Austin S Hemmelgarn <ahferroin7@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/zswap: add writethrough option
References: <1387459407-29342-1-git-send-email-ddstreet@ieee.org> <20140114001115.GU1992@bbox> <CALZtONCCrckuHxgHB=GQj0tHszLAYTZZLGzFTnRkj9pvxx0dyg@mail.gmail.com> <20140115054208.GL1992@bbox> <CALZtONCehE8Td2C2w-fOC596uD54y1-kyc3SiKABBEODMb+a7Q@mail.gmail.com> <CALZtONAaPCi8eUhSmdXSxWbeFFN=ChsfL9OurSZUsSPo-_gnfg@mail.gmail.com> <20140122123358.a65c42605513fc8466152801@linux-foundation.org> <20140123001806.GF31230@bbox>
In-Reply-To: <20140123001806.GF31230@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Weijie Yang <weijie.yang@samsung.com>, Shirish Pargaonkar <spargaonkar@suse.com>, Mel Gorman <mgorman@suse.de>

On 2014-01-22 19:18, Minchan Kim wrote:
> 
> From the beginning, zswap is for reducing swap I/O but if workingset
> overflows, it should write back rather than OOM with expecting a small
> number of writeback would make the system happy because the high memory
> pressure is temporal so soon most of workload would be hit in zswap
> without further writeback.
> 
But write-through would still reduce I/O to swap, the only difference is
that it just reduces the need to read from swap, not the need for all
I/O.  This can still be significant because it would mean (assuming that
zswap uses a LRU algorithm for deciding what to drop) that static pages
that get accessed frequently and get swapped out often would just get
written to swap once, and only be read from zswap.

Also, I disagree with the implication that memory pressure is
short-lived, I have a desktop with 16G of RAM, and I regularly work with
data-sets that are at-least that size (mostly hi-res images and
hi-quality video/audio).
> If memory pressure continues and writeback steadily, it means zswap's
> benefit would be mitigated, even worse by addding comp/decomp overhead.
> In that case, it would be better to disable zswap, even.
> 
> Dan said writethrough supporting is first step to make zswap smart
> but anybody didn't say further words to step into the smart and
> what's the *real* workload want it and what's the *real* number from
> that because dm-cache/zram might be a good fit.
> (I don't intend to argue zram VS zswap. If the concern is solved by
> existing solution, why should we invent new function and
> have maintenace cost?) so it's very hard for me to judge that we should
> accept and maintain it.
bcache isn't stable enough that I would even trust using it for /tmp,
let alone using it for swap (i consistently get kernel OOPSes when it's
compiled in or loaded as a module, even when I'm not using it), and
dm-cache is a pain to setup (especially if it needs to happen every time
the system boots).  Part of the big advantage of zswap is that it is
(relatively) stable, and all it takes to set it up is turning on a pair
of kconfig options.
> We need blueprint for the future and make an agreement on the
> direction before merging this patch.
> 
> But code size is not much and Seth already gave an his Ack so I don't
> want to hurt Dan any more(Sorry for Dan) and wasting my time so pass
> the decision to others(ex, Seth and Bob).
> If they insist on, I don't object any more.
> 
> Sorry for bothering Dan.
> 
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
