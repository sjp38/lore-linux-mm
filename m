Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id BA5966B007D
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 10:40:43 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so592041pab.26
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 07:40:43 -0800 (PST)
Received: from psmtp.com ([74.125.245.121])
        by mx.google.com with SMTP id cx4si23947090pbc.239.2013.11.13.07.40.41
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 07:40:42 -0800 (PST)
Received: by mail-oa0-f42.google.com with SMTP id h16so640433oag.15
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 07:40:40 -0800 (PST)
Date: Wed, 13 Nov 2013 09:40:22 -0600
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: mm/zswap: change to writethrough
Message-ID: <20131113154022.GA6277@cerebellum.variantweb.net>
References: <CALZtONAxsYxLizARV3Aam_n7534g5gh_FFkTz6jb-0Q9gThuBQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONAxsYxLizARV3Aam_n7534g5gh_FFkTz6jb-0Q9gThuBQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, minchan@kernel.org, bob.liu@oracle.com, weijie.yang@samsung.com, k.kozlowski@samsung.com

On Mon, Nov 11, 2013 at 02:12:12PM -0500, Dan Streetman wrote:
> Seth, have you (or anyone else) considered making zswap a writethrough
> cache instead of writeback?  I think that it would significantly help
> the case where zswap fills up and starts writing back its oldest pages
> to disc - all the decompression work would be avoided since zswap
> could just evict old pages and forget about them, and it seems likely
> that when zswap is full that's probably the worst time to add extra
> work/delay, while adding extra disc IO (presumably using dma) before
> zswap is full doesn't seem to me like it would have much impact,
> except in the case where zswap isn't full but there is so little free
> memory that new allocs are waiting on swap-out.

There are two main benefits to zswap:
1) avoid write to swap space while the compressed pool is not full and
2) reduce application delay on anonymous page faults

Doing a writethough approach eliminates benefit 1 as there would
be just as much swap out activity with or without zswap.  However, you
still retain benefit 2.

The reclaim from zswap also becomes much simplier if the the compressed
page can be treated as clean.  It doesn't need to be written back and
can just be freed and the bit in the frontswap_map unset.

I'm not opposed to this.  The obstacle of writeback has influenced the
design a lot more than I would have liked.  You do lose the benefit of
decreased swap out traffic, but the real performance killer, application
latency on an anonymous page fault, is still greatly improved.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
