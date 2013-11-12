Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id D88496B0106
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 04:11:33 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id xb12so2548153pbc.23
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 01:11:33 -0800 (PST)
Received: from psmtp.com ([74.125.245.119])
        by mx.google.com with SMTP id gn4si18752580pbc.351.2013.11.12.01.11.31
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 01:11:32 -0800 (PST)
Message-ID: <5281F0B4.8060902@oracle.com>
Date: Tue, 12 Nov 2013 17:11:16 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: mm/zswap: change to writethrough
References: <CALZtONAxsYxLizARV3Aam_n7534g5gh_FFkTz6jb-0Q9gThuBQ@mail.gmail.com>
In-Reply-To: <CALZtONAxsYxLizARV3Aam_n7534g5gh_FFkTz6jb-0Q9gThuBQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: sjennings@variantweb.net, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, minchan@kernel.org, weijie.yang@samsung.com, k.kozlowski@samsung.com, konrad.wilk@oracle.com


On 11/12/2013 03:12 AM, Dan Streetman wrote:
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
> 
> Besides the additional disc IO that obviously comes with making zswap
> writethrough (additional only before zswap fills up), are there any
> other disadvantages?  Is it a common situation for there to be no
> memory left and get_free_page actively waiting on swap-out, but before
> zswap fills up?
> 
> Making it writethrough also could open up other possible improvements,
> like making the compression and storage of new swap-out pages async,
> so the compression doesn't delay the write out to disc.
> 

I like this idea and those benefits, the only question I'm not sure is
would it be too complicate to implement this feature? It sounds like we
need to reimplement something like swapcache to handle zswap write through.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
