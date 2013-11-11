Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D98456B011A
	for <linux-mm@kvack.org>; Mon, 11 Nov 2013 14:12:36 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id hz1so2313806pad.3
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 11:12:36 -0800 (PST)
Received: from psmtp.com ([74.125.245.194])
        by mx.google.com with SMTP id b9si9816814paw.107.2013.11.11.11.12.34
        for <linux-mm@kvack.org>;
        Mon, 11 Nov 2013 11:12:35 -0800 (PST)
Received: by mail-wg0-f41.google.com with SMTP id n12so1976082wgh.0
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 11:12:32 -0800 (PST)
MIME-Version: 1.0
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 11 Nov 2013 14:12:12 -0500
Message-ID: <CALZtONAxsYxLizARV3Aam_n7534g5gh_FFkTz6jb-0Q9gThuBQ@mail.gmail.com>
Subject: mm/zswap: change to writethrough
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjennings@variantweb.net
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, minchan@kernel.org, bob.liu@oracle.com, weijie.yang@samsung.com, k.kozlowski@samsung.com

Seth, have you (or anyone else) considered making zswap a writethrough
cache instead of writeback?  I think that it would significantly help
the case where zswap fills up and starts writing back its oldest pages
to disc - all the decompression work would be avoided since zswap
could just evict old pages and forget about them, and it seems likely
that when zswap is full that's probably the worst time to add extra
work/delay, while adding extra disc IO (presumably using dma) before
zswap is full doesn't seem to me like it would have much impact,
except in the case where zswap isn't full but there is so little free
memory that new allocs are waiting on swap-out.

Besides the additional disc IO that obviously comes with making zswap
writethrough (additional only before zswap fills up), are there any
other disadvantages?  Is it a common situation for there to be no
memory left and get_free_page actively waiting on swap-out, but before
zswap fills up?

Making it writethrough also could open up other possible improvements,
like making the compression and storage of new swap-out pages async,
so the compression doesn't delay the write out to disc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
