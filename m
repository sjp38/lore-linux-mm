Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 071CA6B0266
	for <linux-mm@kvack.org>; Sun,  8 Apr 2018 02:54:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b16so3228839pfi.5
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 23:54:39 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p61-v6si11776719plb.633.2018.04.07.23.54.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 07 Apr 2018 23:54:38 -0700 (PDT)
Date: Sat, 7 Apr 2018 23:54:25 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Block layer use of __GFP flags
Message-ID: <20180408065425.GD16007@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <bart.vanassche@wdc.com>, Hannes Reinecke <hare@suse.com>, Martin Steigerwald <martin@lichtvoll.de>, Oleksandr Natalenko <oleksandr@natalenko.name>, Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org, linux-mm@kvack.org


Please explain:

commit 6a15674d1e90917f1723a814e2e8c949000440f7
Author: Bart Van Assche <bart.vanassche@wdc.com>
Date:   Thu Nov 9 10:49:54 2017 -0800

    block: Introduce blk_get_request_flags()
    
    A side effect of this patch is that the GFP mask that is passed to
    several allocation functions in the legacy block layer is changed
    from GFP_KERNEL into __GFP_DIRECT_RECLAIM.

Why was this thought to be a good idea?  I think gfp.h is pretty clear:

 * Useful GFP flag combinations that are commonly used. It is recommended
 * that subsystems start with one of these combinations and then set/clear
 * __GFP_FOO flags as necessary.

Instead, the block layer now throws away all but one bit of the
information being passed in by the callers, and all it tells the allocator
is whether or not it can start doing direct reclaim.  I can see that
you may well be in a situation where you don't want to start more I/O,
but your caller knows that!  Why make the allocator work harder than
it has to?  In particular, why isn't the page allocator allowed to wake
up kswapd to do reclaim in non-atomic context, but is when the caller
is in atomic context?

This changelog is woefully short on detail.  It says what you're doing,
but not why you're doing it.  And now I have no idea and I have to ask you
what you were thinking at the time.  Please be more considerate in future.
