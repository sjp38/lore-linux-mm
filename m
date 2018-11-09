Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 776DE6B06FE
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 10:12:42 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 134-v6so1361068pga.1
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 07:12:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w15-v6si8879223plk.269.2018.11.09.07.12.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 09 Nov 2018 07:12:41 -0800 (PST)
Date: Fri, 9 Nov 2018 07:12:39 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/16] xfs: drop ->writepage completely
Message-ID: <20181109151239.GD9153@infradead.org>
References: <20181107063127.3902-1-david@fromorbit.com>
 <20181107063127.3902-2-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181107063127.3902-2-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

[adding linux-mm to the CC list]

On Wed, Nov 07, 2018 at 05:31:12PM +1100, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> ->writepage is only used in one place - single page writeback from
> memory reclaim. We only allow such writeback from kswapd, not from
> direct memory reclaim, and so it is rarely used. When it comes from
> kswapd, it is effectively random dirty page shoot-down, which is
> horrible for IO patterns. We will already have background writeback
> trying to clean all the dirty pages in memory as efficiently as
> possible, so having kswapd interrupt our well formed IO stream only
> slows things down. So get rid of xfs_vm_writepage() completely.

Interesting.  IFF we can pull this off it would simplify a lot of
things, so I'm generally in favor of it.

->writepage callers in generic code are:

 (1) mm/vmscan.c:pageout() - this is the kswaped (or direct reclaim) you
     mention above.  It basically does nothing in this case which isn't
     great, but the whole point of this patch..
 (2) mm/migrate.c:writeout() - this is only called if no ->migratepage
     method is presend, but we have one in XFS, so we should be ok.

Plus a few pieces of code that are just library functions like
generic_writepages and mpage_writepages.
